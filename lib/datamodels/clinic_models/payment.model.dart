import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';

class PaymentHistoryModel {
  PatientModel patient;
  String history_id;
  String hist_type;
  int amount;
  int? amount_b4_discount;
  DateTime date;
  int session_paid;
  int cost_p_session;
  int old_float;
  int new_float;
  String session_frequency;

  PaymentHistoryModel({
    required this.patient,
    required this.history_id,
    required this.hist_type,
    required this.date,
    required this.amount,
    required this.amount_b4_discount,
    required this.session_paid,
    required this.cost_p_session,
    required this.old_float,
    required this.new_float,
    required this.session_frequency,
  });

  factory PaymentHistoryModel.fromMap(Map map) {
    return PaymentHistoryModel(
      patient: PatientModel.fromMap(map['patient']),
      history_id: map['history_id'] ?? '',
      hist_type: map['hist_type'] ?? '',
      amount: map['amount'] ?? 0,
      amount_b4_discount: map['amount_b4_discount'] ?? 0,
      date: DateTime.parse(map['date']),
      session_paid: map['session_paid'] ?? 0,
      cost_p_session: map['cost_p_session'] ?? 0,
      old_float: map['old_float'] ?? 0,
      new_float: map['new_float'] ?? 0,
      session_frequency: map['session_frequency'] ?? '',
    );
  }
}
