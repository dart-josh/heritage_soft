import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/pages/clinic/print.page.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/pages/clinic/widgets/physio_hmo_tag.dart';
import 'package:intl/intl.dart';

class ClinicInvoiceHistory extends StatefulWidget {
  final PatientModel patient;
  const ClinicInvoiceHistory({super.key, required this.patient});

  @override
  State<ClinicInvoiceHistory> createState() => _ClinicInvoiceHistoryState();
}

class _ClinicInvoiceHistoryState extends State<ClinicInvoiceHistory> {
  late PatientModel patient;

  @override
  void initState() {
    patient = widget.patient;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.85;
    double height = MediaQuery.of(context).size.height * 0.93;
    return Scaffold(
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'images/background1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // background cover box
          Positioned.fill(
            child: Container(
              decoration:
                  BoxDecoration(color: Color(0xFFe0d9d2).withOpacity(0.20)),
            ),
          ),

          // blur cover box
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 2.0,
                sigmaY: 2.0,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // main content (dialog box)
          Container(
            child: Center(
              child: Container(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    // background
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'images/sub.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF202020).withOpacity(0.69),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // main content
                    Column(
                      children: [
                        // main content
                        Expanded(child: main_page()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGETs

  // main page
  Widget main_page() {
    return Column(
      children: [
        // top bar
        topBar(),

        SizedBox(height: 8),

        // record list
        Expanded(child: record_list()),

        SizedBox(height: 10),
      ],
    );
  }

  // top bar
  Widget topBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFd1cfcf)),
        ),
      ),
      child: Stack(
        children: [
          // id area and action buttons
          Row(
            children: [
              // id & hmo
              id_sub_group(),

              Expanded(child: Container()),

              SizedBox(width: 10),

              // close button
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),

          // heading
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${patient.f_name}\'s Clinic Invoice',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  height: 1,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.7,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // id & hmo
  Widget id_sub_group() {
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label
          Text(
            'ID',
            style: TextStyle(
              color: Color(0xFFAFAFAF),
              fontSize: 14,
              letterSpacing: 1,
              height: 1,
            ),
          ),

          // id group
          Row(
            children: [
              // client id
              Text(
                widget.patient.patient_id,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1,
                  height: 0.8,
                  shadows: [
                    Shadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),

              // hmo tag
              PhysioHMOTag(hmo: widget.patient.hmo),
            ],
          ),
        ],
      ),
    );
  }

  // assessment list
  Widget record_list() {
    patient.clinic_invoice.sort((a, b) => b.date.compareTo(a.date));
    return patient.clinic_invoice.isNotEmpty
        ? ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: patient.clinic_invoice.length,
            itemBuilder: (context, index) =>
                history_tile(patient.clinic_invoice[index]),
          )

        // no record
        : Center(
            child: Text(
              'No Assessment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          );
  }

  // history tile
  Widget history_tile(InvoiceModel history) {
    UserModel? active_user = AppData.get(context).active_user;
    String date =
        '${DateFormat.jm().format(history.date)} ${DateFormat('dd-MM-yyyy').format(history.date)}';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 146, 108, 54).withOpacity(0.75),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.fromLTRB(24, 15, 24, 15),
        margin: EdgeInsets.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // heading
            Row(
              children: [
                // diagnosis label
                Text(
                  'Invoice ID: ',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    history.invoice_id,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(width: 5),

                // ass date
                Text(
                  date,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                SizedBox(width: 5),

                // print icon
                if (active_user != null && active_user.app_role != 'Doctor')
                  InkWell(
                    onTap: () async {
                      int remaining_session =
                          history.total_session - history.completed_session;
                      int active_session =
                          history.paid_session - history.completed_session;
                      int sessions_to_be_paid =
                          history.total_session - history.paid_session;
                      int current_cost =
                          history.cost_per_session * sessions_to_be_paid;

                      PhysioSessionPrintModel print = PhysioSessionPrintModel(
                        date:
                            '${DateFormat.jm().format(DateTime.now())} ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                        receipt_id: history.invoice_id,
                        client_id: widget.patient.patient_id,
                        client_name:
                            '${widget.patient.f_name} ${widget.patient.l_name}',
                        receipt_type: 'Treatment Invoice',
                        total_session: history.total_session,
                        session_frequency: history.frequency,
                        utilized_session: history.completed_session,
                        remaining_session: remaining_session,
                        active_session: active_session,
                        paid_session: history.paid_session,
                        amount_paid: history.amount_paid,
                        cost_p_session: history.cost_per_session,
                        sessions_to_be_paid: sessions_to_be_paid,
                        current_cost: current_cost,
                        floating_amount: history.floating_amount,
                      );

                      await showDialog(
                          context: context,
                          builder: (context) =>
                              PhysioPrintPage(session_print: print));
                    },
                    child: Icon(Icons.receipt, color: Colors.white70, size: 20),
                  ),

                SizedBox(width: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
