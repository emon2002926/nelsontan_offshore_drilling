import 'package:hive/hive.dart';

import '../../models/cached_debrief_dropdown_model.dart';

class CachedDebriefDropdownModelAdapter
    extends TypeAdapter<CachedDebriefDropdownModel> {
  @override
  final int typeId = 12; // 10 and 11 are taken by safety card

  @override
  CachedDebriefDropdownModel read(BinaryReader reader) {
    return CachedDebriefDropdownModel(
      activities:  (reader.read() as List).cast<Map>(),
      debriefTypes: (reader.read() as List).cast<Map>(),
      cachedAt:    DateTime.fromMillisecondsSinceEpoch(reader.read() as int),
    );
  }

  @override
  void write(BinaryWriter writer, CachedDebriefDropdownModel obj) {
    writer.write(obj.activities);
    writer.write(obj.debriefTypes);
    writer.write(obj.cachedAt.millisecondsSinceEpoch);
  }
}