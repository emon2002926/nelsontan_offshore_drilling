import 'package:hive/hive.dart';
import 'package:nelsontan_offshore_drilling/features/profile/data/models/profile_model.dart';


class ProfileHiveModel {
  int      id;
  String   name;
  String   email;
  String?  profile;
  String   entryCompany;
  String   position;
  String   phone;
  bool     isVerified;
  String   approveStatus;
  String   status;
  DateTime createdAt;
  DateTime updatedAt;
  int?     companyId;
  int?     rigId;
  String?  companyName;  // new — flattened from company.name
  String?  rigName;      // new — flattened from rig.name

  ProfileHiveModel({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
    required this.entryCompany,
    required this.position,
    required this.phone,
    required this.isVerified,
    required this.approveStatus,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.companyId,
    this.rigId,
    this.companyName,
    this.rigName,
  });

  factory ProfileHiveModel.fromDomain(ProfileModel m) => ProfileHiveModel(
    id:            m.id,
    name:          m.name,
    email:         m.email,
    profile:       m.profile,
    entryCompany:  m.entryCompany,
    position:      m.position,
    phone:         m.phone,
    isVerified:    m.isVerified,
    approveStatus: m.approveStatus,
    status:        m.status,
    createdAt:     m.createdAt,
    updatedAt:     m.updatedAt,
    companyId:     m.companyId,
    rigId:         m.rigId,
    companyName:   m.company?.name,
    rigName:       m.rig?.name,
  );

  ProfileModel toDomain() => ProfileModel(
    id:            id,
    name:          name,
    email:         email,
    profile:       profile,
    entryCompany:  entryCompany,
    position:      position,
    phone:         phone,
    isVerified:    isVerified,
    approveStatus: approveStatus,
    status:        status,
    createdAt:     createdAt,
    updatedAt:     updatedAt,
    companyId:     companyId,
    rigId:         rigId,
    company:       companyName != null && companyId != null
        ? ProfileCompanyModel(id: companyId!, name: companyName!)
        : null,
    rig:           rigName != null && rigId != null
        ? ProfileRigModel(id: rigId!, name: rigName!)
        : null,
  );
}
// ── Adapter ───────────────────────────────────────────────────────────────────
// typeId 20 — matches what you had before, change if already taken.
// write() and read() field order MUST stay in sync — never reorder.
// DateTime stored as int (milliseconds) — Hive has no native DateTime support.

class ProfileHiveModelAdapter extends TypeAdapter<ProfileHiveModel> {
  @override
  final int typeId = 18;

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
      // new fields — appended at the end
      companyName:   reader.read() as String?,
      rigName:       reader.read() as String?,
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
    // new fields — appended at the end
    writer.write(obj.companyName);
    writer.write(obj.rigName);
  }
}