import 'package:hive/hive.dart';

import '../../models/pending_submission_model.dart';

class PendingSubmissionModelAdapter extends TypeAdapter<PendingSubmissionModel> {
  @override
  final int typeId = 10;

  @override
  PendingSubmissionModel read(BinaryReader reader) {
    return PendingSubmissionModel(
      localId:           reader.read() as String,
      cardTypeId:        reader.read() as int,
      areaId:            reader.read() as int,
      hazardIds:         (reader.read() as List).cast<int>(),
      description:       reader.read() as String,
      riskSeverity:      reader.read() as String,
      actionTaken:       reader.read() as bool,
      immediateAction:   reader.read() as bool,
      submitAnonymously: reader.read() as bool,
      localImagePath:    reader.read() as String?,
      createdAt:         DateTime.fromMillisecondsSinceEpoch(reader.read() as int),
      syncStatus:        reader.read() as String,
      retryCount:        reader.read() as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingSubmissionModel obj) {
    writer.write(obj.localId);
    writer.write(obj.cardTypeId);
    writer.write(obj.areaId);
    writer.write(obj.hazardIds);
    writer.write(obj.description);
    writer.write(obj.riskSeverity);
    writer.write(obj.actionTaken);
    writer.write(obj.immediateAction);
    writer.write(obj.submitAnonymously);
    writer.write(obj.localImagePath);
    writer.write(obj.createdAt.millisecondsSinceEpoch); // DateTime → int
    writer.write(obj.syncStatus);
    writer.write(obj.retryCount);
  }
}