import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/store_models/sales_record.model.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class SalesPrintPage extends StatefulWidget {
  final SalesPrintModel? print;
  final RequestPrintModel? print2;
  const SalesPrintPage({super.key, this.print, this.print2});

  @override
  State<SalesPrintPage> createState() => _SalesPrintPageState();
}

class _SalesPrintPageState extends State<SalesPrintPage> {
  pw.Font? font;
  pw.Font? bold_font;

  void get_font() async {
    font = await PdfGoogleFonts.notoSansMonoRegular();
    bold_font = await PdfGoogleFonts.notoSansMonoExtraBold();
  }

  @override
  void initState() {
    get_font();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: 190,
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

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => widget.print2 != null
            ? request_print_build(widget.print2!)
            : widget.print != null
                ? sales_print_build(widget.print!)
                : pw.Container(),
      ),
    );

    return pdf.save();
  }

  // windows build
  pw.Widget sales_print_build(SalesPrintModel print) {
    var value = NumberFormat("#,###.##", "en_US");

    pw.TextStyle header_style = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      font: bold_font,
    );

    pw.TextStyle slogan_style = pw.TextStyle(
      fontSize: 7,
      fontStyle: pw.FontStyle.italic,
      font: font,
    );

    pw.TextStyle text_style = pw.TextStyle(fontSize: 8, font: font);

    pw.TextStyle item_style = pw.TextStyle(fontSize: 7, font: font);

    return pw.Container(
      width: 195,
      padding: pw.EdgeInsets.all(2),
      child: pw.Column(
        children: [
          // header
          pw.Center(
            child: pw.Column(
              children: [
                // title
                pw.Text(
                  'Heritage Fitness & Wellness Centre',
                  style: header_style,
                  textAlign: pw.TextAlign.center,
                ),
                // pw.SizedBox(height: 1),
                // slogan
                pw.Text(
                  '...supporting lifestyle of fitness and sound health',
                  style: slogan_style,
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 4),

                // address
                pw.Text(
                  '46, TOS Benson Road, Opp. Ikorodu General Hospital, Ikorodu, Lagos State',
                  style: text_style,
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 1),

                // phone
                pw.Text(
                  '08059551532  |  07055583233',
                  textAlign: pw.TextAlign.center,
                  style: text_style,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 4),

          // receipt info
          pw.Container(
            padding: pw.EdgeInsets.only(right: 30),
            child: pw.Column(
              children: [
                // date & time
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // date
                        pw.Text(print.date,
                            textAlign: pw.TextAlign.left, style: text_style),

                        //time
                        pw.Text(print.time,
                            textAlign: pw.TextAlign.left, style: text_style),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(height: 3),

                // reciept ID
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    info_label('Receipt ID :'),
                    info_value(print.receipt_id),
                  ],
                ),

                // seller
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      info_label('Sold by :'),
                      info_value(print.seller),
                    ]),

                // pw.SizedBox(height: 1),

                // customer
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      info_label('Customer :'),
                      info_value(print.customer),
                    ]),
              ],
            ),
          ),

          pw.SizedBox(height: 2),

          pw.Divider(borderStyle: pw.BorderStyle.dashed),

          pw.SizedBox(height: 3),

          // items
          pw.Column(
            children: print.items
                .map(
                  (item) => pw.Container(
                    padding: pw.EdgeInsets.only(bottom: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        // name
                        pw.Container(
                          width: 85,
                          child: pw.Text(item.name.toUpperCase(),
                              overflow: pw.TextOverflow.clip,
                              style: item_style),
                        ),

                        pw.SizedBox(width: 4),

                        // qty
                        pw.Container(
                          width: 16,
                          child:
                              pw.Text(item.qty.toString(), style: item_style),
                        ),

                        pw.SizedBox(width: 4),

                        // price
                        pw.Container(
                          width: 26,
                          child: pw.Text(value.format(item.price),
                              style: item_style),
                        ),

                        pw.SizedBox(width: 4),

                        // total_price
                        pw.Container(
                          width: 38,
                          child: pw.Text(value.format(item.total_price),
                              style: item_style),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),

          pw.Divider(borderStyle: pw.BorderStyle.dashed),

          // totals
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 15),
            child: pw.Column(
              children: [
                // sub total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    total_label('Subtotal'),
                    total_value(value.format(print.sub_total)),
                  ],
                ),

                // discount
                if (print.discount != 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      total_label('Discount'),
                      total_value(value.format(print.discount)),
                    ],
                  ),

                // total
                if (print.discount != 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      total_label('Total'),
                      total_value(value.format(print.total)),
                    ],
                  ),
              ],
            ),
          ),

          pw.Divider(borderStyle: pw.BorderStyle.dashed),

          // payment
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 15),
            child: pw.Column(
              children: [
                // payment methods
                pw.Column(
                  children: print.pmts
                      .map(
                        (pmt) => pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            total_label(pmt.paymentMethod ?? 'Unknown'),
                            total_value(value.format(pmt.amount)),
                          ],
                        ),
                      )
                      .toList(),
                ),

                pw.SizedBox(height: 2),

                // total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    total_label('Total Payment'),
                    total_value(value.format(print.total)),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 10),

          // message
          pw.Text(
            'Thanks for your patronage. We look forward to seeing you again',
            style: text_style,
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 2),

          pw.Text(
            'This ticket is not refundable',
            style: text_style,
            textAlign: pw.TextAlign.center,
          ),

          //
        ],
      ),
    );
  }

  pw.Widget request_print_build(RequestPrintModel print) {
    var value = NumberFormat("#,###.##", "en_US");

    pw.TextStyle header_style = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      font: bold_font,
    );

    pw.TextStyle slogan_style = pw.TextStyle(
      fontSize: 7,
      fontStyle: pw.FontStyle.italic,
      font: font,
    );

    pw.TextStyle text_style = pw.TextStyle(fontSize: 8, font: font);

    pw.TextStyle item_style = pw.TextStyle(fontSize: 7, font: font);

    return pw.Container(
      width: 195,
      padding: pw.EdgeInsets.all(2),
      child: pw.Column(
        children: [
          // header
          pw.Center(
            child: pw.Column(
              children: [
                // title
                pw.Text(
                  'Heritage Fitness & Wellness Centre',
                  style: header_style,
                  textAlign: pw.TextAlign.center,
                ),
                // pw.SizedBox(height: 1),
                // slogan
                pw.Text(
                  '...supporting lifestyle of fitness and sound health',
                  style: slogan_style,
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 4),

                // address
                pw.Text(
                  '46, TOS Benson Road, Opp. Ikorodu General Hospital, Ikorodu, Lagos State',
                  style: text_style,
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 1),

                // phone
                pw.Text(
                  '08059551532  |  07055583233',
                  textAlign: pw.TextAlign.center,
                  style: text_style,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 4),

          // receipt info
          pw.Container(
            padding: pw.EdgeInsets.only(right: 30),
            child: pw.Column(
              children: [
                // date & time
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // date
                        pw.Text(print.date,
                            textAlign: pw.TextAlign.left, style: text_style),

                        //time
                        pw.Text(print.time,
                            textAlign: pw.TextAlign.left, style: text_style),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(height: 3),

                if (print.patient.isNotEmpty) pw.SizedBox(height: 3),

                // patient
                if (print.patient.isNotEmpty)
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        info_label('Patient :'),
                        info_value(print.patient),
                      ]),
              ],
            ),
          ),

          pw.SizedBox(height: 2),

          pw.Divider(borderStyle: pw.BorderStyle.dashed),

          pw.SizedBox(height: 3),

          // items
          pw.Column(
            children: print.items
                .map(
                  (item) => pw.Container(
                    padding: pw.EdgeInsets.only(bottom: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        // name
                        pw.Container(
                          width: 85,
                          child: pw.Text(item.name.toUpperCase(),
                              overflow: pw.TextOverflow.clip,
                              style: item_style),
                        ),

                        pw.SizedBox(width: 4),

                        // qty
                        pw.Container(
                          width: 16,
                          child:
                              pw.Text(item.qty.toString(), style: item_style),
                        ),

                        pw.SizedBox(width: 4),

                        // price
                        pw.Container(
                          width: 26,
                          child: pw.Text(value.format(item.price),
                              style: item_style),
                        ),

                        pw.SizedBox(width: 4),

                        // total_price
                        pw.Container(
                          width: 38,
                          child: pw.Text(value.format(item.total_price),
                              style: item_style),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),

          pw.Divider(borderStyle: pw.BorderStyle.dashed),

          pw.SizedBox(height: 10),

          // message
          pw.Text(
            'You are required to purchase all the items on this ticket',
            style: text_style,
            textAlign: pw.TextAlign.center,
          ),

          //
        ],
      ),
    );
  }

  // WIDGETS
  // info label
  pw.Widget info_label(String text) {
    pw.TextStyle text_style = pw.TextStyle(fontSize: 8, font: font);
    return pw.Container(
      width: 60,
      child: pw.Text(text, textAlign: pw.TextAlign.left, style: text_style),
    );
  }

  // info value
  pw.Widget info_value(String text) {
    pw.TextStyle text_style = pw.TextStyle(fontSize: 8, font: font);
    return pw.Container(
      width: 70,
      child: pw.Text(text, textAlign: pw.TextAlign.left, style: text_style),
    );
  }

  // total label
  pw.Widget total_label(String text) {
    pw.TextStyle text_style = pw.TextStyle(fontSize: 8, font: font);
    return pw.Container(
      width: 120,
      child: pw.Text(text, textAlign: pw.TextAlign.left, style: text_style),
    );
  }

  // total value
  pw.Widget total_value(String text) {
    pw.TextStyle text_style = pw.TextStyle(fontSize: 8, font: font);
    return pw.Container(
      width: 60,
      child: pw.Text(text, textAlign: pw.TextAlign.left, style: text_style),
    );
  }

  //
}

class SalesPrintModel {
  String date;
  String time;
  String receipt_id;
  String seller;
  String customer;
  List<PrintItemModel> items;
  int sub_total;
  int discount;
  int total;
  List<PaymentMethodModel> pmts;

  SalesPrintModel({
    required this.date,
    required this.time,
    required this.receipt_id,
    required this.seller,
    required this.customer,
    required this.items,
    required this.sub_total,
    required this.discount,
    required this.total,
    required this.pmts,
  });
}

class PrintItemModel {
  String name;
  int qty;
  int price;
  int total_price;

  PrintItemModel({
    required this.name,
    required this.qty,
    required this.price,
    required this.total_price,
  });
}

class RequestPrintModel {
  String date;
  String time;
  String patient;
  List<PrintItemModel> items;

  RequestPrintModel({
    required this.date,
    required this.time,
    required this.patient,
    required this.items,
  });
}
