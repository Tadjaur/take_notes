import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:hive/hive.dart';

class Note extends HiveObject {
  String? id;
  DateTime? _savedUpdatedAt;

  /// The notes value.
  /// Empty by default.
  Rx<String> title = 'Untitled'.obs;

  /// The notes value.
  /// Empty by default.
  Rx<String> notes = ''.obs;

  /// The color value.
  /// Default to grey color value
  Rx<int> colorValue = Colors.grey.shade200.value.obs;

  /// Returns the color representation of the [colorValue]
  /// field.
  Color get color {
    return Color(colorValue.value);
  }

  DateTime get dbUpdatedAt => _savedUpdatedAt ?? DateTime.now().toUtc();

  /// Convert the current user notes content to it's json representation.
  /// The [id] is removed because it is not a part of user content.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title.value,
        'notes': notes.value,
        'colorValue': colorValue.value,
        'dbUpdatedAt': dbUpdatedAt.millisecondsSinceEpoch,
      };

  Note();
  Note.fromJson(String this.id, Map<String, dynamic> json)
      : title = (json['title'] as String).obs,
        notes = (json['notes'] as String).obs,
        _savedUpdatedAt =
            DateTime.fromMillisecondsSinceEpoch(json['dbUpdatedAt']),
        colorValue = (json['colorValue'] as int).obs;

  void updateFromJson(Map<String, dynamic> json) {
    title.value = (json['title'] as String);
    notes.value = (json['notes'] as String);
    colorValue.value = (json['colorValue'] as int);
    _savedUpdatedAt = DateTime.fromMillisecondsSinceEpoch(json['dbUpdatedAt']);
  }
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  Note read(BinaryReader reader) {
    return Note()
      ..id = (() {
        final c = reader.readString();
        return c.isEmpty ? null : c;
      })()
      ..title = reader.readString().obs
      ..notes = reader.readString().obs
      ..colorValue = reader.readInt().obs
      .._savedUpdatedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeString(obj.id ?? '')
      ..writeString(obj.title.value)
      ..writeString(obj.notes.value)
      ..writeInt(obj.colorValue.value)
      ..writeInt(obj.dbUpdatedAt.millisecondsSinceEpoch);
  }
}
