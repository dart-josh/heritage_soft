import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/attendance_model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/staff_database_helpers.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';
import 'package:month_year_picker2/month_year_picker2.dart';

class SAH extends StatefulWidget {
  final At_Date month;
  final SAH_Model staff;
  const SAH({super.key, required this.month, required this.staff});

  @override
  State<SAH> createState() => _SAHState();
}

class _SAHState extends State<SAH> {
  At_Date? active_month;
  SAH_Model? staff;
  List<PersonalAttendanceModel> att_hist = [];

  bool maxMonth = true;
  bool minMonth = false;

  DateTime firstDay = DateTime(2010);
  DateTime lastDay = DateTime.now();

  bool isLoading = false;

  @override
  void initState() {
    active_month = widget.month;
    staff = widget.staff;
    load_data();

    super.initState();
  }

  // change month
  change_month(bool prev) {
    if (isLoading) return;

    int active_mont = active_month!.month;
    int active_year = active_month!.year;

    int new_month = active_mont;
    int new_year = active_year;

    // previous
    if (prev) {
      if (minMonth) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Max History reached',
          icon: Icons.warning_rounded,
        );

        return;
      } else {
        new_month = active_mont - 1;

        if (new_month == 0) {
          new_year = active_year - 1;
          new_month = 12;
        }
      }
    }

    // next
    else {
      if (maxMonth) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'No further history yet',
          icon: Icons.warning_rounded,
        );
        return;
      } else {
        new_month = active_mont + 1;

        if (new_month == 13) {
          new_year = active_year + 1;
          new_month = 1;
        }
      }
    }

    String title = DateFormat('MMMM').format(DateTime(new_year, new_month));

    At_Date newDate =
        At_Date(title: '$title, $new_year', year: new_year, month: new_month);

    // first day
    int first_month = firstDay.month;
    int first_year = firstDay.year;

    // last day
    int last_month = lastDay.month;
    int last_year = lastDay.year;

    if (newDate.year > last_year ||
        (newDate.year == last_year && newDate.month > last_month)) return;

    if (newDate.year < first_year ||
        (newDate.year == last_year && newDate.month < first_month)) return;

    setState(() {
      active_month = newDate;
    });

    load_data();
  }

  // select month
  select_month() async {
    var selected = await showMonthYearPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDay,
      lastDate: lastDay,
    );

    if (selected != null) {
      int month = selected.month;
      int year = selected.year;

      String title = DateFormat('MMMM').format(selected);

      At_Date newDate =
          At_Date(title: '$title, $year', year: year, month: month);

      active_month = newDate;
      setState(() {});

      load_data();
    }
  }

  // get attendance
  load_data() async {
    isLoading = true;
    att_hist.clear();

    String att_key = '${staff!.key}/${active_month!.title}';

    await StaffDatabaseHelpers.get_staff_attendance_by_key(att_key)
        .then((snapshot) {
      if (snapshot.value != null) {
        Map map = snapshot.value as Map;

        if (map.isNotEmpty) {
          map.forEach((key, value) {
            att_hist.add(PersonalAttendanceModel.fromMap(value));
          });
        }
      }
    });

    isLoading = false;

    setState(() {});
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
                'images/office.jpg',
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
                          'images/att_2.jpeg',
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

        // month selector
        month_selector(),

        // attendance list
        Expanded(child: attendance_list()),

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
              // id & role
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ID
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // id label
                      Text(
                        'ID',
                        style: TextStyle(
                          color: Color(0xFFAFAFAF),
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),

                      // staff id
                      Text(
                        staff!.user_id,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 1,
                          height: 0.8,
                          shadows: [
                            Shadow(
                              color: Color(0xFF000000),
                              offset: Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 6),

                  // role
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xFF3C58E6).withOpacity(0.67),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      staff!.role,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

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
                '${staff!.name}\'s Attendance History',
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

  check_month() {
    // first day
    int first_month = firstDay.month;
    int first_year = firstDay.year;

    // last day
    int last_month = lastDay.month;
    int last_year = lastDay.year;

    int month = active_month!.month;
    int year = active_month!.year;

    if (last_month == month && last_year == year) {
      maxMonth = true;
    } else {
      maxMonth = false;
    }

    if (first_month == month && first_year == year) {
      minMonth = true;
    } else {
      minMonth = false;
    }

    setState(() {});
  }

  // month selector
  Widget month_selector() {
    check_month();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // previous button
            InkWell(
              onTap: () {
                change_month(true);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: minMonth ? Color(0xFF928F8F) : Colors.white,
                size: 25,
              ),
            ),

            SizedBox(width: 50),

            // month
            Container(
              width: 200,
              child: Center(
                child: InkWell(
                  onTap: () {
                    select_month();
                  },
                  child: Text(
                    active_month!.title,
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
                change_month(false);
              },
              child: Icon(
                Icons.arrow_forward_ios,
                color: maxMonth ? Color(0xFF928F8F) : Colors.white,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // attendance list
  Widget attendance_list() {
    att_hist.sort((a, b) => DateFormat("E, d MMM")
        .parse(b.date)
        .compareTo(DateFormat("E, d MMM").parse(a.date)));

    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )

        // list
        : att_hist.isNotEmpty
            ? ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: att_hist.length,
                itemBuilder: (context, index) => history_tile(att_hist[index]),
              )

            // empty list
            : Center(
                child: Text(
                  'No attendance to view!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              );
  }

  // history tile
  Widget history_tile(PersonalAttendanceModel history) {
    TextStyle dateStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 18,
      letterSpacing: 1,
    );

    TextStyle headingStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      letterSpacing: 1,
    );

    TextStyle sessionStyle = TextStyle(
      color: Colors.white70,
      fontSize: 14,
      letterSpacing: 1,
    );

    TextStyle time_in_style = TextStyle(
      color: Colors.greenAccent,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      letterSpacing: 1,
    );

    TextStyle time_out_style = TextStyle(
      color: Color(0xFFff6f6f),
      fontWeight: FontWeight.bold,
      fontSize: 14,
      letterSpacing: 1,
    );

    history.sessions.sort((a, b) => a.session_key!.compareTo(b.session_key!));

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF899cd0).withOpacity(0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      margin: EdgeInsets.symmetric(horizontal: 35, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                // date
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFababab)),
                      ),
                    ),
                    child: Text(
                      history.date,
                      textAlign: TextAlign.left,
                      style: dateStyle,
                    ),
                  ),
                ),

                // time in
                Expanded(
                  flex: 4,
                  child: Center(child: Text('Time In', style: headingStyle)),
                ),

                // time out
                Expanded(
                  flex: 4,
                  child: Center(child: Text('Time Out', style: headingStyle)),
                ),
              ],
            ),
          ),

          // sessions
          Column(
            children: history.sessions
                .map(
                  (e) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFb4b4b4)),
                      ),
                    ),
                    child: Row(
                      children: [
                        // session head
                        Expanded(
                          flex: 2,
                          child: Center(child: Text('', style: sessionStyle)),
                        ),

                        // time in
                        Expanded(
                          flex: 4,
                          child: Center(
                              child: Text(e.time_in, style: time_in_style)),
                        ),

                        // time out
                        Expanded(
                          flex: 4,
                          child: Center(
                              child: Text(e.time_out, style: time_out_style)),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // capitalize
  String capitalize(String val) {
    var val_up = val[0].toUpperCase();

    var new_val = val.replaceRange(0, 1, val_up);

    return new_val;
  }

  //
}

class SAH_Model {
  String key;
  String user_id;
  String name;
  String role;

  SAH_Model({
    required this.key,
    required this.user_id,
    required this.name,
    required this.role,
  });
}
