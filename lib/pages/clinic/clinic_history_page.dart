import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/clinic/print.page.dart';
import 'package:heritage_soft/pages/clinic/widgets/physio_hmo_tag.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';

class ClinicHistoryPage extends StatefulWidget {
  final PatientModel patient;
  const ClinicHistoryPage({super.key, required this.patient});

  @override
  State<ClinicHistoryPage> createState() => _ClinicHistoryPageState();
}

class _ClinicHistoryPageState extends State<ClinicHistoryPage> {
  late PatientModel patient;
  List<ClinicHistoryModel> active_record = [];
  List<GroupedClinicHistoryModel> _history = [];

  bool isLoading = false;

  int active_year = DateTime.now().year;

  bool maxYear = true;
  bool minYear = false;

  DateTime firstDay = DateTime(2020);
  DateTime lastDay = DateTime.now();

  @override
  void initState() {
    patient = widget.patient;
    load_data();

    super.initState();
  }

  // get all history
  load_data() async {
    if (patient.clinic_history.isNotEmpty) {
      _history = groupRec(patient.clinic_history);
      var chk =
          _history.where((element) => element.year == active_year).toList();

      if (chk.isNotEmpty) {
        active_record = chk.first.record;
      } else {
        active_record.clear();
      }
    } else {}

    setState(() {});
    return;
  }

  // group history
  List<GroupedClinicHistoryModel> groupRec(List<ClinicHistoryModel> ll) {
    List<GroupedClinicHistoryModel> lgl = [];
    var ll_group = groupBy(ll, (e) => get_year(e.date));

    ll_group.forEach((key, value) {
      GroupedClinicHistoryModel gsl =
          GroupedClinicHistoryModel(year: key, record: value);
      lgl.add(gsl);
    });

    lgl.sort((a, b) => b.year.compareTo(a.year));

    return lgl;
  }

  int get_year(DateTime date) {
    return date.year;
  }

  change_year(bool prev) {
    if (isLoading) return;

    // previous
    if (prev) {
      if (minYear) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Max History reached',
          icon: Icons.warning_rounded,
        );

        return;
      } else {
        active_year = active_year - 1;
      }
    }

    // next
    else {
      if (maxYear) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'No further history yet',
          icon: Icons.warning_rounded,
        );
        return;
      } else {
        active_year = active_year + 1;
      }
    }

    var chk = _history.where((element) => element.year == active_year).toList();

    if (chk.isNotEmpty) {
      active_record = chk.first.record;
    } else {
      active_record = [];
    }

    setState(() {});
  }

  // select year
  select_year() async {
    int? selected = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Year"),
          content: Container(
            width: 200,
            height: 400,
            child: YearPicker(
              firstDate: firstDay,
              lastDate: lastDay,
              selectedDate: DateTime(active_year),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );

    if (selected != null) {
      active_year = selected;

      var chk =
          _history.where((element) => element.year == active_year).toList();

      if (chk.isNotEmpty) {
        active_record = chk.first.record;
      } else {
        active_record = [];
      }

      setState(() {});
    }
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

        // total income
        Container(
          padding: EdgeInsets.only(left: 40),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Total Amount Paid:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 4),
              Text(
                Helpers.format_amount(patient.total_amount_paid, naira: true),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),

        // year selector
        year_selector(),

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
                '${patient.f_name}\'s Clinic History',
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

  // check year
  check_year() {
    int first_year = firstDay.year;
    int last_year = lastDay.year;

    int current_year = active_year;

    if (last_year == current_year) {
      maxYear = true;
    } else {
      maxYear = false;
    }

    if (first_year == current_year) {
      minYear = true;
    } else {
      minYear = false;
    }

    setState(() {});
  }

  // year selector
  Widget year_selector() {
    check_year();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // previous button
            InkWell(
              onTap: () {
                change_year(true);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: minYear ? Color(0xFF928F8F) : Colors.white,
                size: 25,
              ),
            ),

            SizedBox(width: 50),

            // year
            Container(
              width: 200,
              child: Center(
                child: InkWell(
                  onTap: () {
                    select_year();
                  },
                  child: Text(
                    active_year.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.7,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 50),

            // next button
            InkWell(
              onTap: () {
                change_year(false);
              },
              child: Icon(
                Icons.arrow_forward_ios,
                color: maxYear ? Color(0xFF928F8F) : Colors.white,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // history list
  Widget record_list() {
    int year_total = 0;

    active_record.sort((a, b) => b.date.compareTo(a.date));

    active_record.forEach((element) {
      year_total += element.amount;
    });

    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : active_record.isNotEmpty
            ? Column(
                children: [
                  // total income for this year
                  Container(
                    padding: EdgeInsets.only(right: 40),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total amount paid:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          Helpers.format_amount(year_total, naira: true),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // record list
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: active_record.length,
                      itemBuilder: (context, index) =>
                          history_tile(active_record[index]),
                    ),
                  ),
                ],
              )

            // no record
            : Center(
                child: Text(
                  'No record for this year',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              );
  }

  // history tile
  Widget history_tile(ClinicHistoryModel history) {
    String date =
        '${DateFormat.jm().format(history.date)} ${DateFormat('dd-MM-yyyy').format(history.date)}';

    bool session_set = (history.hist_type.contains('added') ||
        history.hist_type.contains('setup') ||
        history.hist_type.contains('updated'));

    bool is_assessment = history.hist_type.contains('Assessment');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
      child: Stack(
        children: [
          // main contents
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 146, 108, 54).withOpacity(0.75),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.fromLTRB(24, 25, 24, 15),
            margin: EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // heading
                Row(
                  children: [
                    // session label
                    if (!is_assessment)
                      Text(
                        (session_set) ? 'Total Session' : 'Session(s):',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      )
                    else
                      Text(
                        'Amount Paid:',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),

                    SizedBox(width: 6),

                    // session paid
                    if (!is_assessment)
                      Text(
                        Helpers.format_amount(history.session_paid),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    else
                      Text(
                        Helpers.format_amount(history.amount, naira: true),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),

                    Expanded(child: Container()),

                    // sub date
                    Text(
                      date,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    if (!session_set) SizedBox(width: 5),

                    // print icon
                    if (!session_set)
                      InkWell(
                        onTap: () async {
                          PhysioPaymentPrintModel printModel =
                              PhysioPaymentPrintModel(
                            date:
                                '${DateFormat.jm().format(history.date)} ${DateFormat('dd-MM-yyyy').format(history.date)}',
                            receipt_id: history.history_id,
                            client_id: patient.patient_id,
                            client_name: '${patient.f_name} ${patient.l_name}',
                            amount: history.amount,
                            receipt_type: history.hist_type,
                            session_paid: history.session_paid,
                            amount_b4_discount: history.amount_b4_discount ?? 0,
                            cost_p_session: history.cost_p_session.toInt(),
                            old_float: history.old_float.toInt(),
                            new_float: history.new_float.toInt(),
                          );

                          await showDialog(
                              context: context,
                              builder: (context) =>
                                  PhysioPrintPage(payment_print: printModel));
                        },
                        child: Icon(Icons.receipt,
                            color: Colors.white70, size: 20),
                      ),
                  ],
                ),

                // SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!is_assessment)
                      Column(
                        children: [
                          if ((session_set) &&
                              (history.session_frequency.isNotEmpty))
                            SizedBox(height: 6),

                          // frequency
                          if ((session_set) &&
                              (history.session_frequency.isNotEmpty))
                            Row(
                              children: [
                                // label
                                Text(
                                  'Frequency:',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),

                                SizedBox(width: 6),
                                // cost per session
                                Text(
                                  history.session_frequency,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                          if ((session_set) && history.amount != 0)
                            SizedBox(height: 6),

                          if ((session_set) && history.amount != 0)
                            Row(
                              children: [
                                // cost per session label
                                Text(
                                  'Session added:',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),

                                SizedBox(width: 6),
                                // cost per session
                                Text(
                                  Helpers.format_amount(history.amount),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                          // cost per session
                          if (history.cost_p_session != 0)
                            Row(
                              children: [
                                // cost per session label
                                Text(
                                  'Cost per Session:',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),

                                SizedBox(width: 6),
                                // cost per session
                                Text(
                                  Helpers.format_amount(history.cost_p_session,
                                      naira: true),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                          if (history.old_float != 0) SizedBox(height: 10),

                          // old floating amount
                          if (history.old_float != 0)
                            Row(
                              children: [
                                //  label
                                Text(
                                  'Old Floating amount:',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),

                                SizedBox(width: 6),
                                // value
                                Text(
                                  Helpers.format_amount(history.old_float,
                                      naira: true),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                          if (history.new_float != 0) SizedBox(height: 10),

                          // new floating amount
                          if (history.new_float != 0)
                            Row(
                              children: [
                                //  label
                                Text(
                                  'New Floating amount:',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),

                                SizedBox(width: 6),
                                // value
                                Text(
                                  Helpers.format_amount(history.new_float,
                                      naira: true),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                        ],
                      ),

                    Expanded(child: Container()),

                    // amount
                    if (!session_set)
                      Column(
                        children: [
                          // amount
                          if (history.amount != 0)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Text(
                                  Helpers.format_amount(history.amount,
                                      naira: true),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),

                          // if discount
                          if (history.amount != 0 &&
                              history.amount_b4_discount != null && history.amount_b4_discount != 0 &&
                              (history.amount_b4_discount != history.amount))
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  Helpers.format_amount(
                                      history.amount_b4_discount ?? 0,
                                      naira: true),
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    decorationStyle: TextDecorationStyle.solid,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          // hist type
          Positioned(
            top: 0,
            left: 70,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.blue,
              ),
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Center(
                child: Text(
                  history.hist_type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
}

class GroupedClinicHistoryModel {
  int year;
  List<ClinicHistoryModel> record;

  GroupedClinicHistoryModel({
    required this.year,
    required this.record,
  });
}
