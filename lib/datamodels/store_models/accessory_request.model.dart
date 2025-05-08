import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';

class AccessoryRequestModel {
  String? key;
  List<AccessoryItemModel> accessories;
  PatientModel? patient;
  DoctorModel? doctor;

  AccessoryRequestModel({
    this.key,
    required this.accessories,
    this.patient,
    this.doctor,
  });

  factory AccessoryRequestModel.fromMap(Map map) {
    return AccessoryRequestModel(
      key: map['_id'] ?? '',
      accessories: List<AccessoryItemModel>.from(
          map['accessories'].map((x) => AccessoryItemModel.fromMap(x))),
      patient: map['patient'] != null
          ? PatientModel.fromMap(
              map['patient'],
            )
          : null,
      doctor: map['doctor'] != null ? DoctorModel.fromMap(map['doctor']) : null,
    );
  }

  Map toJson() => {
        'id': key,
        'accessories': accessories.map((e) => e.toJson()).toList(),
        'patient': patient?.key,
        'doctor': doctor?.key,
      };
}
