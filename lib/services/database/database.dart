import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class Note extends HiveObject {
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
      ..notes = reader.readString()
      ..colorValue = reader.readInt32();
  }

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeString(obj.notes)
      ..writeInt32(obj.colorValue);
  }

}

class Database extends GetxService {
  Completer<Box<Note>> _notesBox = Completer();

  @override
  void onInit() {
    super.onInit();
    loadNotesBox();
  }

  Future<void> loadNotesBox() async {
    Hive.init('./');
    Hive.registerAdapter(NoteAdapter());
    _notesBox.complete(Hive.openBox<Note>('notes'));
  }

  Future<Note> getLastOpenedNote() async {
    final notesBox = await _notesBox.future;
    final allNote = notesBox.values;
    if (allNote != null && allNote.isNotEmpty) {
      return allNote.last;
    }
    final note = Note();
    notesBox.add(note);
    return note;
  }

}
