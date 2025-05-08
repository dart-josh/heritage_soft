import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:heritage_soft/pages/clinic/clinic_invoice_history.dart';
import 'package:heritage_soft/pages/clinic/print.page.dart';
import 'package:intl/intl.dart';

class SessionDetailsDialog extends StatefulWidget {
  final Map session_details;
  final PatientModel patient;
  const SessionDetailsDialog({
    super.key,
    required this.session_details,
    required this.patient,
  });

  @override
  State<SessionDetailsDialog> createState() => _SessionDetailsDialogState();
}

class _SessionDetailsDialogState extends State<SessionDetailsDialog> {
  int total_session = 0;
  String session_frequency = '';
  int utilized_session = 0;
  int remaining_session = 0; // total_session - utilized_session
  int active_session = 0; // paid_session - utilized_session
  int paid_session = 0;
  int amount_paid = 0;
  int cost_p_session = 0;
  int sessions_to_be_paid = 0; // total_session - paid_session
  int current_cost = 0; // cost_p_session * sessions_to_be_paid
  int floating_amount = 0;

  get_details(Map map) {
    total_session = map['total_session'];
    session_frequency = map['frequency'];
    utilized_session = map['utilized_session'];
    paid_session = map['paid_session'];
    amount_paid = map['amount_paid'];
    cost_p_session = map['cost_p_session'];
    floating_amount = map['floating_amount'];

    remaining_session = total_session - utilized_session;
    active_session = paid_session - utilized_session;
    sessions_to_be_paid = total_session - paid_session;
    current_cost = cost_p_session * sessions_to_be_paid;
  }

  @override
  void initState() {
    get_details(widget.session_details);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var val = NumberFormat('#,###');

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 500,
        ),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade400.withOpacity(.9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2),

                    // title
                    Stack(
                      children: [
                        // heading
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Clinic Details',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        // hsitory button
                        Positioned(
                          top: 0,
                          left: 0,
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ClinicInvoiceHistory(
                                              patient: widget.patient)));
                            },
                            icon: Icon(
                              Icons.history,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                        ),

                        // close button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // horizontal line
                    Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // session details
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // total session & session frequency
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // total session
                            detail_tile(
                                'Total Session', total_session.toString()),

                            // session frequency
                            detail_tile('Session Frequency', session_frequency),
                          ],
                        ),
                      ),

                      // utilized session & remaining session
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // utilized session
                            detail_tile('Utilized Session',
                                utilized_session.toString()),

                            // remaining session
                            detail_tile('Remaining Session',
                                remaining_session.toString()),
                          ],
                        ),
                      ),

                      // active session
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // active session
                            detail_tile(
                                'Active Session', active_session.toString()),
                          ],
                        ),
                      ),

                      // paid session & amount paid
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // paid session
                            detail_tile(
                                'Paid Session', paid_session.toString()),

                            // amount paid
                            detail_tile(
                              'Amount Paid',
                              amount_paid.toString(),
                              naira: true,
                            ),
                          ],
                        ),
                      ),

                      // sessions to be paid & cost per session
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // sessions to be paid
                            detail_tile('Sessions to be paid',
                                sessions_to_be_paid.toString()),

                            // cost per session
                            detail_tile(
                                'Cost per session', cost_p_session.toString(),
                                naira: true),
                          ],
                        ),
                      ),

                      // current cost
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // current cost
                            detail_tile('Current Cost', current_cost.toString(),
                                naira: true),
                          ],
                        ),
                      ),

                      // floating amount
                      if (floating_amount != 0)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // floating amount
                              detail_tile(
                                  'Floating Amount', floating_amount.toString(),
                                  naira: true),
                            ],
                          ),
                        ),

                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              // print button
              InkWell(
                onTap: () async {
                  var conf = await Helpers.showConfirmation(
                    context: context,
                    title: 'Save & Print Invoice',
                    message:
                        'You are about to save print an invoice for the current clinic details? Click confirm to proceed.',
                  );

                  if (!conf) return;

                  PhysioSessionPrintModel print = PhysioSessionPrintModel(
                    date:
                        '${DateFormat.jm().format(DateTime.now())} ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                    receipt_id: Helpers.generate_order_id(),
                    client_id: widget.patient.patient_id,
                    client_name:
                        '${widget.patient.f_name} ${widget.patient.l_name}',
                    receipt_type: 'Treatment Invoice',
                    total_session: total_session,
                    session_frequency: session_frequency,
                    utilized_session: utilized_session,
                    remaining_session: remaining_session,
                    active_session: active_session,
                    paid_session: paid_session,
                    amount_paid: amount_paid,
                    cost_p_session: cost_p_session,
                    sessions_to_be_paid: sessions_to_be_paid,
                    current_cost: current_cost,
                    floating_amount: floating_amount,
                  );

                  InvoiceModel inv = InvoiceModel(
                    invoice_id: print.receipt_id,
                    invoice_type: print.receipt_type,
                    date: DateTime.now(),
                    total_session: total_session,
                    frequency: session_frequency,
                    completed_session: utilized_session,
                    paid_session: paid_session,
                    cost_per_session: cost_p_session,
                    amount_paid: amount_paid,
                    floating_amount: floating_amount,
                  );

                  var res = await ClinicDatabaseHelpers.update_clinic_invoice(
                    context,
                    data: {
                      'patient': widget.patient.key ?? '',
                      'clinic_invoice': inv.toJson(),
                    },
                    showLoading: true,
                    showToast: true,
                  );

                  if (res != null && res['patient_data'] != null)
                    await showDialog(
                        context: context,
                        builder: (context) =>
                            PhysioPrintPage(session_print: print));
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    color: Color(0xFF3c5bff).withOpacity(0.6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Center(
                    child: Text(
                      'Save & Print invoice',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget

  // detail tile
  Widget detail_tile(String title, String value, {bool naira = false}) {
    return Column(
      children: [
        // label
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),

        // value
        Text(
          (int.tryParse(value) != null)
              ? Helpers.format_amount(int.parse(value), naira: naira)
              : value,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
