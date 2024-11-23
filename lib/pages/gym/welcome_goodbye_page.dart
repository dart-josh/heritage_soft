import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:intl/intl.dart';

class WpGp extends StatefulWidget {
  final ClientSignInModel client;
  final String time_in;
  const WpGp({
    super.key,
    required this.wp,
    required this.client,
    required this.time_in,
  });

  final bool wp;

  @override
  State<WpGp> createState() => _WpGpState();
}

class _WpGpState extends State<WpGp> {
  String in_time = '';
  String out_time = '';
  String duration = '';

  @override
  void initState() {
    // get time details if goodbye
    if (!widget.wp && widget.time_in.isNotEmpty)
      get_time_details(DateTime.parse(widget.time_in));

    // pop page after 5sec
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) Navigator.pop(context);
    });
    super.initState();
  }

  get_time_details(DateTime time_in) {
    in_time = DateFormat.jm().format(time_in);
    out_time = DateFormat.jm().format(DateTime.now());

    Duration diff = DateTime.now().difference(time_in);

    int min = diff.inMinutes;
    int hr = diff.inHours;

    if (min > 59) {
      int mn = min - (hr * 60);
      duration = '${hr}hr ${mn}min';
    } else {
      duration = '${min}min';
    }
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
                'images/attendance_background.png',
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          (widget.wp)
                              ? 'images/background3.png'
                              : 'images/background4.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: (widget.wp)
                              ? Color(0xFF01040A).withOpacity(0.53)
                              : Color(0xFF000000).withOpacity(0.69),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // main content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Container()),

                        main_page(),

                        Expanded(child: Container()),
                        // bottom text
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'HERITAGE FITNESS & WELLNESS CENTRE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'MsLineDraw',
                              color: Color(0xFFC6C6C6),
                              fontSize: 27,
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

                        SizedBox(height: 10),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          // quote box
          Expanded(
            flex: (widget.wp) ? 4 : 6,
            child: (widget.wp) ? quote_box() : goodbye_area(),
          ),

          Expanded(
            flex: (widget.wp) ? 6 : 4,
            child: (widget.wp) ? welcome_area() : activity_area(),
          ),
        ],
      ),
    );
  }

  // quote box
  Widget quote_box() {
    return Container(
      margin: EdgeInsets.only(top: 120),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Color(0xFF414141).withOpacity(0.71),
        ),
        child: Stack(
          children: [
            // text
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '...',
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
                    children: [
                      // main text
                      TextSpan(
                        text: Helpers.generate_quote_text(),
                      ),
                      TextSpan(text: '...'),
                    ],
                  ),
                ),
              ),
            ),

            // quote left
            Positioned(
              top: 0,
              left: 0,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Image.asset(
                  'images/icon/quote-left.png',
                  width: 20.8,
                  height: 18.6,
                ),
              ),
            ),

            // quote right
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Image.asset(
                  'images/icon/quote-right.png',
                  width: 20.8,
                  height: 18.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // welcome area
  Widget welcome_area() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          // welcome text
          Text(
            'Welcome'.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Century',
              color: Colors.white,
              fontSize: 40,
              letterSpacing: 5,
              shadows: [
                Shadow(
                  color: Color(0xFF000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),

          // sub text
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                '...to the Gym',
                style: TextStyle(
                  fontFamily: 'DancingScript',
                  color: Colors.white,
                  fontSize: 30,
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

          SizedBox(height: 55),

          // profile area
          Align(
            alignment: Alignment.centerLeft,
            child: profile_area(),
          ),
        ],
      ),
    );
  }

  // goodbye area
  Widget goodbye_area() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // welcome text
          Text(
            'Goodbye'.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Century',
              color: Colors.white,
              fontSize: 40,
              letterSpacing: 5,
              shadows: [
                Shadow(
                  color: Color(0xFF000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),

          SizedBox(height: 55),

          // profile area
          profile_area(),

          SizedBox(height: 10),

          // goodbye text
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '...We look forward to seeing you again',
              style: TextStyle(
                color: Color(0xFFC0C0C0),
                fontFamily: 'Segoepr',
                fontSize: 16,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // profile area
  Widget profile_area() {
    return Column(
      children: [
        // profile image
        CircleAvatar(
          radius: 65,
          backgroundColor: Color(0xFFF3DADA).withOpacity(0.8),
          foregroundColor: Colors.white,
          backgroundImage: widget.client.user_image.isEmpty
              ? null
              : NetworkImage(
                  widget.client.user_image,
                ),
          child: (widget.client.user_image.isEmpty)
              ? Center(
                  child: Image.asset(
                    'images/icon/user-alt.png',
                    width: 73,
                    height: 73,
                  ),
                )
              : Container(),
        ),

        SizedBox(height: 8),

        // profile name
        Text(
          widget.client.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
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
      ],
    );
  }

  // activity area
  Widget activity_area() {
    TextStyle title_style = TextStyle(
        color: Color(0xFF999999),
        fontStyle: FontStyle.italic,
        fontSize: 14,
        letterSpacing: 0.7,
        fontFamily: 'Sitka');
    TextStyle main_style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 18,
      letterSpacing: 1,
      height: 1,
    );

    return Container(
      margin: EdgeInsets.only(top: 120),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(50),
              ),
              color: Color(0xFF173744).withOpacity(0.77),
            ),
            padding: EdgeInsets.fromLTRB(20, 10, 30, 10),
            child: Text(
              'Today\'s Activity',
              style: TextStyle(
                color: Color(0xFFC1C1C1),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                height: 0,
              ),
            ),
          ),

          // main box
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(12),
              ),
              color: Color(0xFF414141).withOpacity(0.71),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // time in
                    Column(
                      children: [
                        // title
                        Text(
                          'Time in',
                          style: title_style,
                        ),
                        SizedBox(height: 2),
                        // main text
                        Text(
                          in_time,
                          style: main_style,
                        ),
                      ],
                    ),

                    // time out
                    Column(
                      children: [
                        // title
                        Text(
                          'Time out',
                          style: title_style,
                        ),
                        SizedBox(height: 2),
                        // main text
                        Text(
                          out_time,
                          style: main_style,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // time spent
                Column(
                  children: [
                    // title
                    Text(
                      'Time spent',
                      style: title_style,
                    ),
                    SizedBox(height: 2),
                    // main text
                    Text(
                      duration,
                      style: main_style,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //
}
