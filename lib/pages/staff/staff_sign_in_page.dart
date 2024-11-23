import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/users_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/staff_database_helpers.dart';
import 'package:heritage_soft/pages/staff/staff_welcome_page.dart';
import 'package:intl/intl.dart';

class StaffSignInPage extends StatefulWidget {
  final StaffModel staff;
  const StaffSignInPage({super.key, required this.staff});

  @override
  State<StaffSignInPage> createState() => _StaffSignInPageState();
}

class _StaffSignInPageState extends State<StaffSignInPage> {
  bool can_sign_in = false;
  bool late_sign_in = false;

  String last_activity = '';
  String time_in = '';

  bool in_out = true;

  @override
  void initState() {
    can_sign_in = widget.staff.user_status;
    in_out = widget.staff.in_out;
    last_activity = get_last_activity(widget.staff.last_activity);

    // if time is past 8:30
    if (DateTime.now().isAfter(DateTime(DateTime.now().year,
        DateTime.now().month, DateTime.now().day, 8, 30))) {
      // if its first time signing in
      if (widget.staff.fresh_day) late_sign_in = true;
    }

    // sign in after 4sec
    if (can_sign_in) {
      Future.delayed(Duration(seconds: 4), () {
        if (mounted) check_in_out();
      });
    }

    // pop page after 30sec
    Future.delayed(Duration(seconds: 30), () {
      if (mounted) Navigator.pop(context);
    });

    refresh();
    super.initState();
  }

  // refresh for time
  refresh() {
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) setState(() {});
      refresh();
    });
  }

  // get last activity
  String get_last_activity(Map? lst_act) {
    if (lst_act == null) return '';
    if (lst_act.isEmpty) return '';

    if (lst_act['time_in'] == 'absent') {
      return 'You failed to sign out the last time';
    }

    if (lst_act['time_in'] == null) {
      return '';
    }

    time_in = lst_act['time_in'];

    DateTime dt_in = DateTime.parse(lst_act['time_in']);
    DateTime? dt_out =
        lst_act['time_out'] != '' ? DateTime.parse(lst_act['time_out']) : null;

    int prv_day = dt_in.day;
    int prv_mont = dt_in.month;
    int prv_year = dt_in.year;

    int tod_day = DateTime.now().day;
    int tod_mont = DateTime.now().month;
    int tod_year = DateTime.now().year;

    String tim = '';

    int day_s = tod_day - prv_day;

    String dt_in_time = DateFormat.jm().format(dt_in);
    String dt_out_time = dt_out != null ? DateFormat.jm().format(dt_out) : '';

    if (tod_mont == prv_mont && tod_year == prv_year) {
      String dt_in_date = Helpers.date_format(dt_in, same_year: true);

      if (day_s < 1) {
        tim =
            'Today -- $dt_in_time  ${dt_out_time != '' ? '-  $dt_out_time' : ''}';
      } else if (day_s < 2) {
        tim =
            'Yesterday -- $dt_in_time  ${dt_out_time != '' ? '-  $dt_out_time' : ''}';
      } else {
        tim =
            '$dt_in_date -- $dt_in_time  ${dt_out_time != '' ? '-  $dt_out_time' : ''}';
      }
    } else {
      String dt_in_date =
          Helpers.date_format(dt_in, same_year: (tod_year == prv_year));
      tim =
          '$dt_in_date -- $dt_in_time  ${dt_out_time != '' ? '-  $dt_out_time' : ''}';
    }

    return tim;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.75;
    double height = MediaQuery.of(context).size.height * 0.85;
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
                  BoxDecoration(color: Color(0xFF202020).withOpacity(0.20)),
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
                      child: Image.asset(
                        'images/attendance.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF202020).withOpacity(0.69),
                        ),
                      ),
                    ),

                    // main content
                    Column(
                      children: [
                        // top
                        top_bar(),

                        main_page(),
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
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              // quote box
              Expanded(
                flex: 5,
                child: news_box(),
              ),

              Expanded(
                flex: 5,
                child: profile_area(),
              ),
            ],
          ),
        ),

        // time
        Positioned(
          top: 15,
          left: 20,
          child: Container(
            width: 130,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromARGB(255, 145, 96, 24).withOpacity(0.6),
            ),
            child: Center(
              child: Text(
                DateFormat.jm().format(DateTime.now()),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // top bar
  Widget top_bar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // id area
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
                widget.staff.user_id,
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

          Expanded(child: Container()),

          SizedBox(width: 10),

          // close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.all(0),
            icon: Icon(
              Icons.cancel,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // news box
  Widget news_box() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // news label
            Text(
              'News/Event:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 2),

            // news
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Color(0xFF414141).withOpacity(0.71),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Center(
                  child: Text(
                    news,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 26,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0xFF000000),
                          offset: Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // profile area
  Widget profile_area() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          SizedBox(height: 10),

          // profile details
          profile_details(),

          SizedBox(height: 30),

          // activity box
          Align(
            alignment: Alignment.centerLeft,
            child: activity_box(),
          ),

          SizedBox(height: 50),

          // sign in box
          check_in_out_box(),
        ],
      ),
    );
  }

  // profile details
  Widget profile_details() {
    String name =
        '${widget.staff.f_name} ${widget.staff.m_name} ${widget.staff.l_name}';

    return Column(
      children: [
        // profile image
        CircleAvatar(
          radius: 65,
          backgroundColor: Color(0xFFF3DADA).withOpacity(0.8),
          foregroundColor: Colors.white,
          backgroundImage: widget.staff.user_image.isEmpty
              ? null
              : NetworkImage(
                  widget.staff.user_image,
                ),
          child: (widget.staff.user_image.isEmpty)
              ? Center(
                  child: Image.asset(
                    'images/icon/user-alt.png',
                    width: 73,
                    height: 73,
                  ),
                )
              : Container(),
        ),

        SizedBox(height: 6),

        // profile name
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),

        SizedBox(height: 5),

        // role box
        Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Color.fromARGB(255, 144, 103, 19).withOpacity(0.4),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Center(
            child: Text(
              widget.staff.role,
              style: TextStyle(fontSize: 14, height: 1, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget activity_box() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(26),
          ),
          color: Color(0xFF403C3C).withOpacity(0.78),
        ),
        padding: EdgeInsets.symmetric(horizontal: 23, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            Text(
              'Previous Work time',
              style: TextStyle(
                color: Color(0xFFAFAFAF),
                fontStyle: FontStyle.italic,
                fontSize: 12,
                height: 1,
              ),
            ),

            SizedBox(height: 7),

            // main text
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                last_activity,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),

            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // check in/out
  Widget check_in_out_box() {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: !in_out
            ? Color.fromARGB(255, 105, 64, 6)
            : can_sign_in
                ? late_sign_in
                    ? Colors.grey
                    : Colors.blue
                : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Center(
        child: Text(
          !in_out
              ? 'GOODBYE'
              : can_sign_in
                  ? late_sign_in
                      ? 'YOU CAME LATE'
                      : 'WELCOME'
                  : 'CANNOT SIGN IN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // FUNCTION
  //check in/out
  void check_in_out() {
    var cl_key = widget.staff.key;

    StaffDatabaseHelpers.mark_staff_attendance(in_out, cl_key, time_in);

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffWelcomePage(
          wp: in_out,
          staff: widget.staff,
          time_in: time_in,
        ),
      ),
    );
  }

  //
}
