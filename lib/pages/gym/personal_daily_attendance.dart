import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/helpers/gym_database_helpers.dart';

class PDA extends StatefulWidget {
  final UserPDA client;
  final String date;
  const PDA({super.key, required this.date, required this.client});

  @override
  State<PDA> createState() => _PDAState();
}

class _PDAState extends State<PDA> {
  List<Map> _morning_session = [];
  List<Map> _afternoon_session = [];
  List<Map> _evening_session = [];
  List<Map> _other_session = [];

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

  @override
  void initState() {
    get_attendance();
    super.initState();
  }

  // get attendance by session
  get_attendance() async {
    String month = widget.date.substring(2).trim();
    String date = widget.date;

    String att_key = '${widget.client.key}/$month/$date/sessions';
    await GymDatabaseHelpers.get_client_personal_attendance_by_key(att_key)
        .then((snapshot) {
      // if (snapshot.value != null) {
        // Map val = snapshot.value as Map;

        // if (val.isNotEmpty) {
        //   val.forEach((key, value) {
        //     Map sess_map = {
        //       'timeIn': value['time_in'],
        //       'timeOut': value['time_out'],
        //     };

        //     if (value['session'] == 'morning') _morning_session.add(sess_map);
        //     if (value['session'] == 'afternoon')
        //       _afternoon_session.add(sess_map);
        //     if (value['session'] == 'evening') _evening_session.add(sess_map);
        //     if (value['session'] == 'midnight') _other_session.add(sess_map);
        //   });
        // }
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
              // id & subscription
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

                      // client id
                      Text(
                        widget.client.id,
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

                  // subscription plan
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xFF3C58E6).withOpacity(0.67),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Image.asset(
                          'images/icon/map-gym.png',
                          width: 11,
                          height: 11,
                        ),
                        SizedBox(width: 2),
                        Text(
                          widget.client.sub_plan,
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
                '${widget.client.f_name}\'s Attendance History',
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
        session_tile(_morning_session, 'Morning Session'),

        // afternoon
        session_tile(_afternoon_session, 'Afternoon Session'),

        // evening
        session_tile(_evening_session, 'Evening Session'),

        // other
        _other_session.isEmpty
            ? Container()
            : session_tile(_other_session, 'Other Session'),
      ],
    );
  }

  // session tile
  Widget session_tile(List<Map> session, String title) {
    return Container(
      child: Column(
        children: [
          // session title
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
                    // time title
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

              // empty session
              : Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      'No attendance for this session',
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

class UserPDA {
  String key;
  String id;
  String f_name;
  String sub_plan;

  UserPDA({
    required this.key,
    required this.id,
    required this.f_name,
    required this.sub_plan,
  });
}
