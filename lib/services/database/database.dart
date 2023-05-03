import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class Note extends HiveObject {
  /// The notes value.
  /// Empty by default.
  String title = 'Untitled';

  /// The notes value.
  /// Empty by default.
  String notes = '';

  /// The color value.
  /// Default to grey color value
  late int colorValue = Colors.grey.shade200.value;

  /// Returns the color representation of the [colorValue]
  /// field.
  Color get color {
    return Color(colorValue);
  }
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  Note read(BinaryReader reader) {
    return Note()
      ..title = reader.readString()
      ..notes = reader.readString()
      ..colorValue = reader.readInt32();
  }

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeString(obj.title)
      ..writeString(obj.notes)
      ..writeInt32(obj.colorValue);
  }
}

class Database extends GetxService {
  final Completer<Box<Note>> _notesBox = Completer();
  final currentNoteRx = Rx<Note>(Note());
  final allNotes = <Note>{}.obs;

  Note get currentNote => currentNoteRx.value;

  Iterable<Note> get otherNotes =>
      allNotes.where((note) => note != currentNote);

  @override
  void onInit() {
    super.onInit();
    loadNotesBox();
  }

  Future<void> loadNotesBox() async {
    Hive.init('./');
    Hive.registerAdapter(NoteAdapter());
    _notesBox.complete(Hive.openBox<Note>('notes'));
    final notesBox = await _notesBox.future;
    final allNote = notesBox.values;
    if (allNote.isNotEmpty) {
      allNotes.addAll(notesBox.values);
      currentNoteRx.value = allNote.last;
    }
  }

  Note _createNote(Box<Note> notesBox) {
    final note = Note();
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
    if(box.values.length > 1){
      currentNoteRx.value =
          box.getAt((idx + 1) % box.values.length)!;
    }else{
      currentNoteRx.value = _createNote(box);
    }

    box.deleteAt(idx);
    allNotes.removeWhere((element) => element == noteToDelete);
  }
}
