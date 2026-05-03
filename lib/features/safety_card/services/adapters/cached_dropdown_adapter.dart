import 'package:hive/hive.dart';

import '../../models/cached_dropdown_model.dart';

class CachedDropdownModelAdapter extends TypeAdapter<CachedDropdownModel> {
  @override
  final int typeId = 11;

  @override
  CachedDropdownModel read(BinaryReader reader) {
    return CachedDropdownModel(
      areas:      (reader.read() as List).cast<Map>(),
      cardTypes:  (reader.read() as List).cast<Map>(),
      hazards:    (reader.read() as List).cast<Map>(),
      cachedAt:   DateTime.fromMillisecondsSinceEpoch(reader.read() as int),
    );
  }

  @override
  void write(BinaryWriter writer, CachedDropdownModel obj) {
    writer.write(obj.areas);
    writer.write(obj.cardTypes);
    writer.write(obj.hazards);
    writer.write(obj.cachedAt.millisecondsSinceEpoch);
  }
}