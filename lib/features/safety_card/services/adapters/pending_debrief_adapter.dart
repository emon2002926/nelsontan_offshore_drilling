import 'package:hive/hive.dart';

import '../../models/pending_debrief_model.dart';

class PendingDebriefModelAdapter extends TypeAdapter<PendingDebriefModel> {
  @override
  final int typeId = 13;

  @override
  PendingDebriefModel read(BinaryReader reader) {
    final localId         = reader.read() as String;
    final activityId      = reader.read() as int;
    final typeOfDevriefId = reader.read() as int;

    // New format stores a List of {question, answer}; the legacy format
    // stored three fixed strings here. Migrate old records on read.
    final raw = reader.read();
    final List<Map> questionAnswer;
    if (raw is List) {
      questionAnswer = raw.cast<Map>();
    } else {
      questionAnswer = [
        {'question': 'What Happened?',          'answer': raw as String},
        {'question': 'What Worked Well?',       'answer': reader.read() as String},
        {'question': 'What Could Be Improved?', 'answer': reader.read() as String},
      ];
    }

    return PendingDebriefModel(
      localId:           localId,
      activityId:        activityId,
      typeOfDevriefId:   typeOfDevriefId,
      questionAnswer:    questionAnswer,
      submitAnonymously: reader.read() as bool,
      createdAt:         DateTime.fromMillisecondsSinceEpoch(reader.read() as int),
      syncStatus:        reader.read() as String,
      retryCount:        reader.read() as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingDebriefModel obj) {
    writer.write(obj.localId);
    writer.write(obj.activityId);
    writer.write(obj.typeOfDevriefId);
    writer.write(obj.questionAnswer);
    writer.write(obj.submitAnonymously);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.syncStatus);
    writer.write(obj.retryCount);
  }
}
