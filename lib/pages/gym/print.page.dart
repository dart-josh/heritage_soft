import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:int_to_words/int_to_words.dart';

class GymPrintPage extends StatefulWidget {
  final GymSubPrintModel print;
  const GymPrintPage({super.key, required this.print});

  @override
  State<GymPrintPage> createState() => _GymPrintPageState();
}

class _GymPrintPageState extends State<GymPrintPage> {
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
        build: (context) => win_build(widget.print, image),
      ),
    );

    return pdf.save();
  }

  // windows build
  pw.Widget win_build(GymSubPrintModel print, image) {
    var value = NumberFormat("#,###", "en_US");
    final IntToWords _number = IntToWords();

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
                        'Heritage Fitness & Wellness Centre',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        '...supporting lifestyle of fitness and sound health',
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
              '08059551532  |  09038463737  |  07055583233',
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
              pw.Text('Client ID: ', style: label),
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
              pw.Text('Client Name: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                  child: pw.Text(print.client_name,
                      textAlign: pw.TextAlign.right, style: main)),
            ],
          ),

          pw.SizedBox(height: 4),

          // subscription_plan
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Subscription Plan: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                  child: pw.Text(print.subscription_plan,
                      textAlign: pw.TextAlign.right, style: main)),
            ],
          ),

          pw.SizedBox(height: 4),

          // subscription_type
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Subscription Type: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                  child: pw.Text(print.subscription_type,
                      textAlign: pw.TextAlign.right, style: main)),
            ],
          ),

          pw.SizedBox(height: 4),

          // expiry date
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Expiry Date: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Text(
                  print.expiry_date,
                  textAlign: pw.TextAlign.right,
                  style: main,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 4),

          // extras
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Extra Activities: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                child: print.extras.isNotEmpty
                    ? pw.Wrap(
                        alignment: pw.WrapAlignment.end,
                        spacing: 4,
                        runSpacing: 4,
                        children: print.extras.map((e) {
                          bool last_index = (print.extras.indexOf(e) ==
                              print.extras.length - 1);
                          return pw.Text(last_index ? e : '$e,', style: main);
                        }).toList(),
                      )
                    : pw.Text('None',
                        textAlign: pw.TextAlign.right, style: label),
              ),
            ],
          ),

          if (print.sub_amount_b4_discount != 0 &&
              print.sub_amount_b4_discount != print.amount)
            pw.SizedBox(height: 4),

          // sub_amount_b4_discount
          if (print.sub_amount_b4_discount != 0 &&
              print.sub_amount_b4_discount != print.amount)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // label
                pw.Text('Initial Amount: ', style: label),
                // pw.SizedBox(width: 5),
                pw.Expanded(
                  child: pw.Text(
                    '${value.format(print.sub_amount_b4_discount)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 8,
                      decoration: pw.TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ),

          pw.SizedBox(height: 4),

          // amount
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('Total Amount: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                  child: pw.Text('${value.format(print.amount)}',
                      textAlign: pw.TextAlign.right, style: main)),
            ],
          ),

          pw.SizedBox(height: 4),

          // amount_in_words
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // label
              pw.Text('The sum of: ', style: label),
              // pw.SizedBox(width: 5),
              pw.Expanded(
                  child: pw.Text(
                      print.amount == 0
                          ? '0'
                          : '${_number.convert(print.amount)} naira',
                      textAlign: pw.TextAlign.right,
                      style: main)),
            ],
          ),

          pw.SizedBox(height: 15),

          // NON REFUNDABLE POLICY
          pw.Center(
            child: pw.Text('THIS IS PAYMENT IS NOT REFUNDABLE', style: label),
          ),

          pw.SizedBox(height: 4),
          pw.Center(child: pw.Text('Thanks for your Patronage', style: label)),
        ],
      ),
    );
  }

  //
}

class GymSubPrintModel {
  String date;
  String receipt_id;
  String client_id;
  String client_name;
  String subscription_plan;
  String subscription_type;
  List<String> extras;
  int amount;
  String expiry_date;
  String receipt_type;
  int sub_amount_b4_discount;

  GymSubPrintModel({
    required this.date,
    required this.receipt_id,
    required this.client_id,
    required this.client_name,
    required this.subscription_plan,
    required this.subscription_type,
    required this.extras,
    required this.amount,
    required this.expiry_date,
    required this.receipt_type,
    required this.sub_amount_b4_discount,
  });
}
