import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/helpers/staff_database_helpers.dart';

class SPDA extends StatefulWidget {
  final UserSPDA staff;
  final String date;
  const SPDA({super.key, required this.date, required this.staff});

  @override
  State<SPDA> createState() => _SPDAState();
}

class _SPDAState extends State<SPDA> {
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

  List<Map> _sessions = [];

  @override
  void initState() {
    get_attendance();
    super.initState();
  }

  get_attendance() async {
    String month = widget.date.substring(2).trim();
    String date = widget.date;

    String att_key = '${widget.staff.key}/$month/$date/sessions';

    await StaffDatabaseHelpers.get_staff_attendance_by_key(att_key)
        .then((snapshot) {
      // if (snapshot.value != null) {
      //   Map map = snapshot.value as Map;

      //   if (map.isNotEmpty) {
      //     map.forEach((key, value) {
      //       Map sess_map = {
      //         'timeIn': value['time_in'],
      //         'timeOut': value['time_out'],
      //       };

      //       _sessions.add(sess_map);
      //     });
      //   }
      // }

      if (mounted) setState(() {});
    });
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

        // date
        date_title(),

        SizedBox(height: 30),

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

                  SizedBox(width: 6),

                  // role
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xFF3C58E6).withOpacity(0.67),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          widget.staff.role,
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
                '${widget.staff.f_name}\'s Attendance History',
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

  // date
  Widget date_title() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: Text(
          widget.date,
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.7,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // attendace list
  Widget attendance_list() {
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        // morning
        session_tile(_sessions, 'Activities'),
      ],
    );
  }

  // session tile
  Widget session_tile(List<Map> session, String title) {
    return Container(
      child: Column(
        children: [
          // title
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: dateStyle,
            ),
          ),

          SizedBox(height: 10),

          // time tab
          session.isNotEmpty
              ? Column(
                  children: [
                    // time heading
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFababab)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex: 1, child: Container()),
                          Expanded(
                            child: Center(
                                child: Text('Time In', style: headingStyle)),
                          ),
                          Expanded(flex: 4, child: Container()),
                          Expanded(
                            child: Center(
                                child: Text('Time Out', style: headingStyle)),
                          ),
                          Expanded(flex: 1, child: Container()),
                        ],
                      ),
                    ),

                    // time
                    Column(
                      children: session.map((e) {
                        int index = session.indexOf(e);
                        return attendance_tile(e, index);
                      }).toList(),
                    ),
                  ],
                )

              // no activity
              : Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      'No activity for this day',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // attendance tile
  Widget attendance_tile(Map session, int index) {
    String timeIn = session['timeIn'];
    String timeOut = session['timeOut'];

    bool isEven = index.isEven;

    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
                color:
                    Color(isEven ? 0xFF696d93 : 0xFF3F4049).withOpacity(0.59)),
            child: Row(
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                  child: Center(child: Text(timeIn, style: time_in_style)),
                ),
                Expanded(flex: 4, child: Container()),
                Expanded(
                  child: Center(child: Text(timeOut, style: time_out_style)),
                ),
                Expanded(flex: 1, child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //
}

class UserSPDA {
  String key;
  String user_id;
  String f_name;
  String role;

  UserSPDA({
    required this.key,
    required this.user_id,
    required this.f_name,
    required this.role,
  });
}
