import 'package:hive/hive.dart';
import '../models/profile_hive_model.dart';


class ProfileHiveModelAdapter extends TypeAdapter<ProfileHiveModel> {
  @override
  final int typeId = 13;

  @override
  ProfileHiveModel read(BinaryReader reader) {
    return ProfileHiveModel(
      id:            reader.read() as int,
      name:          reader.read() as String,
      email:         reader.read() as String,
      profile:       reader.read() as String?,
      entryCompany:  reader.read() as String,
      position:      reader.read() as String,
      phone:         reader.read() as String,
      isVerified:    reader.read() as bool,
      approveStatus: reader.read() as String,
      status:        reader.read() as String,
      createdAt:     DateTime.fromMillisecondsSinceEpoch(reader.read() as int),
      updatedAt:     DateTime.fromMillisecondsSinceEpoch(reader.read() as int),
      companyId:     reader.read() as int?,
      rigId:         reader.read() as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileHiveModel obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.email);
    writer.write(obj.profile);
    writer.write(obj.entryCompany);
    writer.write(obj.position);
    writer.write(obj.phone);
    writer.write(obj.isVerified);
    writer.write(obj.approveStatus);
    writer.write(obj.status);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.updatedAt.millisecondsSinceEpoch);
    writer.write(obj.companyId);
    writer.write(obj.rigId);
  }
}