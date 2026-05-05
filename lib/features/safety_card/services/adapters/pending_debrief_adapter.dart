import 'package:hive/hive.dart';

import '../../models/pending_debrief_model.dart';

class PendingDebriefModelAdapter extends TypeAdapter<PendingDebriefModel> {
  @override
  final int typeId = 13;

  @override
  PendingDebriefModel read(BinaryReader reader) {
    return PendingDebriefModel(
      localId:          reader.read() as String,
      activityId:       reader.read() as int,
      typeOfDevriefId:  reader.read() as int,
      whatHappend:      reader.read() as String,
      whatWorkedWell:   reader.read() as String,
      whatImproved:     reader.read() as String,
      submitAnonymously: reader.read() as bool,
      createdAt:        DateTime.fromMillisecondsSinceEpoch(reader.read() as int),
      syncStatus:       reader.read() as String,
      retryCount:       reader.read() as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingDebriefModel obj) {
    writer.write(obj.localId);
    writer.write(obj.activityId);
    writer.write(obj.typeOfDevriefId);
    writer.write(obj.whatHappend);
    writer.write(obj.whatWorkedWell);
    writer.write(obj.whatImproved);
    writer.write(obj.submitAnonymously);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.syncStatus);
    writer.write(obj.retryCount);
  }
}