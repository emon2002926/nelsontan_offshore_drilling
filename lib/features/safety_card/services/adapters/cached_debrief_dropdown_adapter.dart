import 'package:hive/hive.dart';

import '../../models/cached_debrief_dropdown_model.dart';

class CachedDebriefDropdownModelAdapter
    extends TypeAdapter<CachedDebriefDropdownModel> {
  @override
  final int typeId = 12; // 10 and 11 are taken by safety card

  @override
  CachedDebriefDropdownModel read(BinaryReader reader) {
    final activities   = (reader.read() as List).cast<Map>();
    final debriefTypes = (reader.read() as List).cast<Map>();
    final cachedAt =
        DateTime.fromMillisecondsSinceEpoch(reader.read() as int);

    // Older cache entries were written without questions
    final questions = reader.availableBytes > 0
        ? (reader.read() as List).cast<Map>()
        : <Map>[];

    return CachedDebriefDropdownModel(
      activities:   activities,
      debriefTypes: debriefTypes,
      cachedAt:     cachedAt,
      questions:    questions,
    );
  }

  @override
  void write(BinaryWriter writer, CachedDebriefDropdownModel obj) {
    writer.write(obj.activities);
    writer.write(obj.debriefTypes);
    writer.write(obj.cachedAt.millisecondsSinceEpoch);
    writer.write(obj.questions);
  }
}
