import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../google_drive.dart';
import 'models/note.dart';
import 'models/drive_credential.dart';

enum SyncResponse {
  succeeded,
  failed,
}

class Database extends GetxService {
  static const String noteBoxName = 'notes';
  static const String driveGeneralBoxName = 'drive-credentials';
  static const String driveCredentialsGeneralBoxKey = 'drive-credentials';

  final Completer<Box<Note>> _notesBox = Completer();
  final Completer<Box<DriveCredentials>> _settingsBox = Completer();
  final currentNoteRx = Rx<Note>(Note());
  final allNotes = <Note>{}.obs;
  final GoogleDriveService _driveService;

  Database(this._driveService);
  Note get currentNote => currentNoteRx.value;

  Iterable<Note> get otherNotes =>
      allNotes.where((note) => note != currentNote);

  @override
  void onInit() {
    super.onInit();
    loadBoxes();
  }

  Future<void> loadBoxes() async {
    final docDir = p.join((await getApplicationSupportDirectory()).path,
        kReleaseMode ? 'release' : 'debug');
    Hive.init(docDir);
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(DriveCredentialsAdapter());
    loadNotesBox();
    loadDriveCredentialsBox();
  }

  Future<void> loadDriveCredentialsBox() async {
    _settingsBox.complete(Hive.openBox<DriveCredentials>(driveGeneralBoxName));
  }

  Future<void> loadNotesBox() async {
    _notesBox.complete(Hive.openBox<Note>(noteBoxName));
    final notesBox = await _notesBox.future;
    final allNote = notesBox.values;
    if (allNote.isNotEmpty) {
      allNotes.addAll(notesBox.values);
      currentNoteRx.value = allNote.last;
    } else {
      notesBox.add(currentNote);
    }
  }

  Note _createNote(Box<Note> notesBox, {String? noteId}) {
    final note = Note()..id = noteId;
    notesBox.add(note);
    allNotes.add(note);
    return note;
  }

  Future<void> createNote() async {
    final note = _createNote(await _notesBox.future);
    currentNoteRx.value = note;
  }

  void deleteCurrentNote() async {
    final box = await _notesBox.future;
    final idx =
        box.values.toList().indexWhere((element) => element == currentNote);
    if (idx == -1) {
      return;
    }
    final noteToDelete = currentNote;
    if (box.values.length > 1) {
      currentNoteRx.value = box.getAt((idx + 1) % box.values.length)!;
    } else {
      currentNoteRx.value = _createNote(box);
    }

    box.deleteAt(idx);
    final noteToDeleteId = noteToDelete.id;
    if (noteToDeleteId != null) {
      final settingsBox = await _settingsBox.future;
      DriveCredentials? credentials =
          settingsBox.get(driveCredentialsGeneralBoxKey);
      if (credentials == null) {
        credentials = await _driveService.authenticate();
        settingsBox.put(driveCredentialsGeneralBoxKey, credentials);
      }
      try {
        _driveService.deleteFile(credentials: credentials, id: noteToDeleteId);
      } on Exception {
        print('DELETING NOTE Failed');
      }
    }
    allNotes.removeWhere((element) => element == noteToDelete);
  }

  void saveClientDriveCredentials(DriveCredentials credentials) async {
    final box = await Hive.openBox<DriveCredentials>(driveGeneralBoxName);
    box.put(driveCredentialsGeneralBoxKey, credentials);
  }

  /// Synchronize app data with user's drives.
  Future<SyncResponse> syncData() async {
    final settingsBox = await _settingsBox.future;
    DriveCredentials? credentials =
        settingsBox.get(driveCredentialsGeneralBoxKey);
    if (credentials == null) {
      credentials = await _driveService.authenticate();
      settingsBox.put(driveCredentialsGeneralBoxKey, credentials);
    }

    for (final note in allNotes) {
      final rawNote = utf8.encode(json.encode(note.toJson()));
      final noteId = note.id;
      if (noteId == null) {
        final createdId = await _driveService.createFile(
            credentials: credentials,
            updatedAt: note.dbUpdatedAt,
            raw: rawNote);
        note.id = createdId;
        note.save();
        continue;
      }
      final fileState = await _driveService.searchFile(
        credentials: credentials,
        id: noteId,
        localUpdatedTime: note.dbUpdatedAt,
      );
      switch (fileState) {
        case DriveFileState.unknown:

          /// Do something when we are not able to create
          return SyncResponse.failed;
        case DriveFileState.missingFile:

          /// PASS file should missing a this time.
          print('UNCAUGHT MISSING FILE');
          break;
        case DriveFileState.existWithOutdatedData:
          // Update file when ever file is missing or md5 is invalid.
          await _driveService.updateFile(
            credentials: credentials,
            id: noteId,
            updatedAt: note.dbUpdatedAt,
            raw: rawNote,
          );
          break;
        case DriveFileState.existWithFutureData:
          final String noteString = await _driveService.getMedia(
              credentials: credentials, id: noteId);
          note.updateFromJson(json.decode(noteString));
          note.save();
          break;
        case DriveFileState.existWithUpdatedData:
          // TODO: Handle this case.
          break;
      }
    }

    await _retrieveAllNewNote(credentials);

    return SyncResponse.succeeded;
  }

  Future<void> _retrieveAllNewNote(DriveCredentials credentials) async {
    await _driveService.retrieveNewFile(
        credentials: credentials,
        localFileIds: allNotes.map((element) => element.id).whereType(),
        transform: (String noteId, Stream<List<int>> noteStream) async {
          final note = _createNote(await _notesBox.future, noteId: noteId);
          final noteString = await noteStream.join();
          note.updateFromJson(json.decode(noteString));
          note.save();
        });
  }
}
