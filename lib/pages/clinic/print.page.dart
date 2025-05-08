import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/clinic_models/equipement.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:int_to_words/int_to_words.dart';

class PhysioPrintPage extends StatefulWidget {
  final PhysioPaymentPrintModel? payment_print;
  final PhysioSessionPrintModel? session_print;
  final AssessmentPrintModel? assessment_print;
  const PhysioPrintPage({
    super.key,
    this.payment_print,
    this.session_print,
    this.assessment_print,
  });

  @override
  State<PhysioPrintPage> createState() => _PhysioPrintPageState();
}

class _PhysioPrintPageState extends State<PhysioPrintPage> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        color: Colors.red,
        width: 172,
        height: 500,
        child: PdfPreview(
          padding: EdgeInsets.all(0),
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          initialPageFormat: PdfPageFormat.roll80,
          build: (format) => _generatePdf(format),
        ),
      ),
    );
  }

  var main = pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
  var label = pw.TextStyle(fontSize: 8);

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    final image = await imageFromAssetBundle('images/logo.jpg');

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => widget.payment_print != null
            ? payment_build(widget.payment_print!, image)
            : widget.session_print != null
                ? session_build(widget.session_print!, image)
                : widget.assessment_print != null
                    ? assessment_build(widget.assessment_print!, image)
                    : pw.Container(),
      ),
    );

    return pdf.save();
  }

  // payment print
  pw.Widget payment_build(PhysioPaymentPrintModel print, image) {
    var value = NumberFormat("#,###", "en_US");
    final IntToWords _number = IntToWords();

    bool is_assessment = print.receipt_type.contains('Assessment');

    return pw.Padding(
      padding: pw.EdgeInsets.only(left: -10, top: -10, right: 16),
      child: pw.Column(
        children: [
          // header
          pw.Column(children: [
            // head
            pw.Row(
              children: [
                // logo
                pw.Container(
                  width: 27,
                  height: 27,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Image(image),
                ),

                pw.SizedBox(width: 6),

                // name
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Heritage Physiotheraphy Clinic',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        '...feel the touch of care and relief',
                        style: pw.TextStyle(
                          fontSize: 6,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 4),

            // address
            pw.Text(
              '46, TOS Benson Road, Opp. Ikorodu General Hospital, Ikorodu, Lagos State',
              style: label,
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 2),

            // phone
            pw.Text(
              '07055583233  |  08059551532  |  09038463737',
              textAlign: pw.TextAlign.center,
              style: label,
            ),
          ]),

          pw.Divider(),

          pw.SizedBox(height: 6),

          // receipt id
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Receipt ID: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.receipt_id, style: main),
            ],
          ),

          pw.SizedBox(height: 6),

          // receipt type
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Receipt Type: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.receipt_type, style: main),
            ],
          ),

          pw.SizedBox(height: 4),

          // date
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Date: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.date, style: main),
            ],
          ),

          pw.SizedBox(height: 8),
          // cleint id
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Patient ID: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.client_id, style: main),
            ],
          ),

          pw.SizedBox(height: 4),

          // client name
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Patient Name: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                  child: pw.Text(print.client_name,
                      textAlign: pw.TextAlign.right, style: main)),
            ],
          ),

          pw.SizedBox(height: 8),

          //? Others

          // cost per session
          if (!is_assessment)
            detail_tile('Cost per Session: ', print.cost_p_session.toString()),

          if (print.amount != 0 &&
              print.amount_b4_discount != print.amount &&
              print.amount_b4_discount != 0)
            pw.SizedBox(height: 2),
          // discount amount
          if (print.amount != 0 &&
              print.amount_b4_discount != print.amount &&
              print.amount_b4_discount != 0)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // label
                pw.Text('Initial Amount: ', style: label),
                // pw.SizedBox(width: 5),
                pw.Expanded(
                  child: pw.Text(
                    '${value.format(print.amount_b4_discount)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      decoration: pw.TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ),
          if (print.amount != 0 &&
              print.amount_b4_discount != print.amount &&
              print.amount_b4_discount != 0)
            pw.SizedBox(height: 2),

          // amount
          detail_tile('Amount Paid: ', print.amount.toString()),

          // amount_in_words
          detail_tile(
            'Amount in Words: ',
            print.amount == 0 ? '0' : '${_number.convert(print.amount)} naira',
          ),

          pw.SizedBox(height: 4),

          // sessions added
          if (!is_assessment)
            if (print.session_paid != 0)
              detail_tile('Sessions Added: ', print.session_paid.toString()),

          if (print.old_float != 0 || print.new_float != 0)
            pw.SizedBox(height: 4),

          // old floating
          if (!is_assessment)
            if (print.old_float != 0)
              detail_tile('Old Floating: ', print.old_float.toString()),

          // new floating
          if (!is_assessment)
            if (print.new_float != 0)
              detail_tile('New Floating: ', print.new_float.toString()),

          pw.SizedBox(height: 15),

          // NON REFUNDABLE POLICY
          pw.Center(
            child: pw.Text('THIS IS A NOT REFUNDABLE TICKET', style: label),
          ),

          pw.SizedBox(height: 4),
          pw.Center(child: pw.Text('Thanks for your Patronage', style: label)),
        ],
      ),
    );
  }

  pw.Widget session_build(PhysioSessionPrintModel print, image) {
    // var value = NumberFormat("#,###", "en_US");
    // final IntToWords _number = IntToWords();

    return pw.Padding(
      padding: pw.EdgeInsets.only(left: -10, top: -10, right: 16),
      child: pw.Column(
        children: [
          // header
          pw.Column(children: [
            // head
            pw.Row(
              children: [
                // logo
                pw.Container(
                  width: 27,
                  height: 27,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Image(image),
                ),

                pw.SizedBox(width: 6),

                // name
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Heritage Physiotheraphy Clinic',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        '...feel the touch of care and relief',
                        style: pw.TextStyle(
                          fontSize: 6,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 4),

            // address
            pw.Text(
              '46, TOS Benson Road, Opp. Ikorodu General Hospital, Ikorodu, Lagos State',
              style: label,
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 2),

            // phone
            pw.Text(
              '07055583233  |  08059551532  |  09038463737',
              textAlign: pw.TextAlign.center,
              style: label,
            ),
          ]),

          pw.Divider(),

          pw.SizedBox(height: 6),

          // receipt id
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Receipt ID: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.receipt_id, style: main),
            ],
          ),

          pw.SizedBox(height: 6),

          // receipt type
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Receipt Type: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.receipt_type, style: main),
            ],
          ),

          pw.SizedBox(height: 4),

          // date
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Date: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.date, style: main),
            ],
          ),

          pw.SizedBox(height: 8),

          // cleint id
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Patient ID: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.client_id, style: main),
            ],
          ),

          pw.SizedBox(height: 4),

          // client name
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Patient Name: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                  child: pw.Text(print.client_name,
                      textAlign: pw.TextAlign.right, style: main)),
            ],
          ),

          pw.SizedBox(height: 8),

          //? Others

          // total_session
          detail_tile('Total Session', print.total_session.toString()),

          // session_frequency
          detail_tile('Session Frequency', print.session_frequency.toString()),

          // utilized_session
          detail_tile('Utilized Session', print.utilized_session.toString()),

          // remaining_session
          detail_tile('Remaining Session', print.remaining_session.toString()),

          // active_session
          detail_tile('Active Session', print.active_session.toString()),

          // paid_session
          detail_tile('Paid Session', print.paid_session.toString()),

          // amount_paid
          detail_tile('Amount Paid', print.amount_paid.toString()),

          // cost_p_session
          detail_tile('Cost per Session', print.cost_p_session.toString()),

          pw.SizedBox(height: 4),

          // sessions_to_be_paid
          detail_tile(
              'Sessions to be paid', print.sessions_to_be_paid.toString()),

          // current_cost
          detail_tile('Current Cost', print.current_cost.toString()),

          // floating_amount
          if (print.floating_amount != 0)
            detail_tile('Floating Amount', print.floating_amount.toString()),

          pw.SizedBox(height: 15),

          // NON REFUNDABLE POLICY
          pw.Center(
            child: pw.Text(
                'THIS IS THE CURRENT CLINIC DETAILS FOR THE ABOVE PATIENT',
                textAlign: pw.TextAlign.center,
                style: label),
          ),

          pw.SizedBox(height: 4),
          pw.Center(child: pw.Text('Thanks for your Patronage', style: label)),
        ],
      ),
    );
  }

  pw.Widget assessment_build(AssessmentPrintModel print, image) {
    // var value = NumberFormat("#,###", "en_US");
    // final IntToWords _number = IntToWords();

    return pw.Padding(
      padding: pw.EdgeInsets.only(left: -10, top: -10, right: 16),
      child: pw.Column(
        children: [
          // header
          pw.Column(children: [
            // head
            pw.Row(
              children: [
                // logo
                pw.Container(
                  width: 27,
                  height: 27,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Image(image),
                ),

                pw.SizedBox(width: 6),

                // name
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Heritage Physiotheraphy Clinic',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        '...feel the touch of care and relief',
                        style: pw.TextStyle(
                          fontSize: 6,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 4),

            // address
            pw.Text(
              '46, TOS Benson Road, Opp. Ikorodu General Hospital, Ikorodu, Lagos State',
              style: label,
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 2),

            // phone
            pw.Text(
              '07055583233  |  08059551532  |  09038463737',
              textAlign: pw.TextAlign.center,
              style: label,
            ),
          ]),

          pw.Divider(),

          pw.SizedBox(height: 6),

          // receipt id
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Assessment Details', style: main),
            ],
          ),

          pw.SizedBox(height: 4),

          // date
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Assessment Date: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.assessment_date ?? '', style: main),
            ],
          ),

          pw.SizedBox(height: 8),

          // cleint id
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Patient ID: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Text(print.patient_id, style: main),
            ],
          ),

          pw.SizedBox(height: 4),

          // client name
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Patient Name: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                  child: pw.Text(print.patient_name,
                      textAlign: pw.TextAlign.right, style: main)),
            ],
          ),

          pw.SizedBox(height: 8),

          //? Others

          // cases
          detail_tile('Case(s) ', print.case_select),

          // case select
          if (print.case_select_others != null &&
              print.case_select_others != '')
            detail_tile('Other cases', print.case_select_others ?? ''),

          // floating_amount
          if (print.case_description != '')
            detail_tile('Case description', print.case_description),

          detail_tile('PT Diagnosis: ', print.diagnosis),

          detail_tile('Case type', print.case_type),

          detail_tile('Treatment type', print.treatment_type),

          detail_tile('Equipements to be Used: ',
              print.equipments.map((e) => e.equipmentName).join(', ')),

          pw.SizedBox(height: 15),

          // NON REFUNDABLE POLICY
          pw.Center(
            child: pw.Text(
                'THIS IS THE ASSESSMENT DETAILS FOR THE ABOVE PATIENT',
                textAlign: pw.TextAlign.center,
                style: label),
          ),

          pw.SizedBox(height: 4),
          pw.Center(child: pw.Text('Thanks for your Patronage', style: label)),
        ],
      ),
    );
  }

  // detail tile
  pw.Widget detail_tile(String title, String value, {bool naira = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // label
          pw.Text(title, style: label),
          // pw.SizedBox(width: 5),
          pw.Expanded(
            child: pw.Text(
                (int.tryParse(value) != null)
                    ? Helpers.format_amount(int.parse(value), naira: naira)
                    : value,
                textAlign: pw.TextAlign.right,
                style: main),
          ),
        ],
      ),
    );
  }

  //
}

class PhysioPaymentPrintModel {
  String date;
  String receipt_id;
  String client_id;
  String client_name;
  int session_paid;
  int amount;
  int amount_b4_discount;
  String receipt_type;
  int cost_p_session;
  int old_float;
  int new_float;

  PhysioPaymentPrintModel({
    required this.date,
    required this.receipt_id,
    required this.client_id,
    required this.client_name,
    required this.session_paid,
    required this.amount,
    required this.amount_b4_discount,
    required this.receipt_type,
    required this.cost_p_session,
    required this.old_float,
    required this.new_float,
  });
}

class PhysioSessionPrintModel {
  String date;
  String receipt_id;
  String client_id;
  String client_name;
  String receipt_type;
  int total_session;
  String session_frequency;
  int utilized_session;
  int remaining_session;
  int active_session;
  int paid_session;
  int amount_paid;
  int cost_p_session;
  int sessions_to_be_paid;
  int current_cost;
  int floating_amount;

  PhysioSessionPrintModel({
    required this.date,
    required this.receipt_id,
    required this.client_id,
    required this.client_name,
    required this.receipt_type,
    required this.total_session,
    required this.session_frequency,
    required this.utilized_session,
    required this.remaining_session,
    required this.active_session,
    required this.paid_session,
    required this.amount_paid,
    required this.cost_p_session,
    required this.sessions_to_be_paid,
    required this.current_cost,
    required this.floating_amount,
  });
}

class AssessmentPrintModel {
  String patient_id;
  String patient_name;
  String case_select;
  String? case_select_others;
  String case_description;
  String diagnosis;
  String case_type;
  String treatment_type;
  List<EquipmentModel> equipments;
  String? assessment_date;

  AssessmentPrintModel({
    required this.patient_id,
    required this.patient_name,
    required this.case_select,
    required this.case_select_others,
    required this.case_description,
    required this.diagnosis,
    required this.case_type,
    required this.treatment_type,
    required this.equipments,
    required this.assessment_date,
  });
}
