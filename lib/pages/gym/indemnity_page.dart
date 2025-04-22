import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:qr_flutter/qr_flutter.dart';

class indemnityPage extends StatefulWidget {
  final String client_key;
  final String client_name;
  const indemnityPage({
    super.key,
    required this.client_key,
    required this.client_name,
  });

  @override
  State<indemnityPage> createState() => _indemnityPageState();
}

class _indemnityPageState extends State<indemnityPage> {
  bool is_verified = false;
  late StreamSubscription verification_stream;

  StreamSubscription listen_to_verification() {
    return GymDatabaseHelpers.client_details_stream(widget.client_key)
        .listen((event) {
      // if (event.exists) {
      //   is_verified = event.data()!['indemnity_verified'] ?? false;
      //   setState(() {});
      // }
    });
  }

  @override
  void initState() {
    verification_stream = listen_to_verification();
    super.initState();
  }

  @override
  void dispose() {
    verification_stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.75;
    double height = MediaQuery.of(context).size.height * 0.90;
    return Scaffold(
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'images/legal.png',
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
                          'images/legal.png',
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: Column(
        children: [
          // top bar
          top_bar(),

          Expanded(
            child: indemnity(),
          ),

          // action button
          finish_button(),
        ],
      ),
    );
  }

  // top bar
  Widget top_bar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFd1cfcf)),
        ),
      ),
      child: Stack(
        children: [
          // heading
          Center(
            child: Text(
              'CLIENT INDEMNITY AGREEMENT',
              style: TextStyle(
                color: Colors.white,
                // height: 1,
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

          // action button
          Positioned(
            right: 0,
            top: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // close button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // indemnity form
  Widget indemnity() {
    String verification_url =
        '$indemnity_base_url?indemnity=true&key=${widget.client_key}';

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFffffff).withOpacity(0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          // indemnity
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        indemnity_write_up,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 50),

          // verification box
          Container(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Scan this barcode to access this indemnity form agreement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 30),

                // barcode box
                Container(
                  width: 255,
                  height: 255,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: QrImageView(
                      data: verification_url,
                      version: QrVersions.auto,
                      size: 240,
                      gapless: true,
                      embeddedImage: AssetImage('images/logo.jpg'),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(40, 40),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // link
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200.withOpacity(.8),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      Icon(Icons.link, color: Colors.white54),
                      SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectableText(
                            verification_url,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // text

                // verification box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black45),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        child: (is_verified)
                            ? Icon(
                                Icons.verified,
                                color: Colors.green.shade400,
                              )
                            : CircularProgressIndicator(),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          is_verified ? 'User verified' : 'Await Verification',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // finish button
  Widget finish_button() {
    if (!is_verified) return Container(height: 33);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF6BEF89).withOpacity(0.8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        margin: EdgeInsets.only(bottom: 5),
        child: Center(
          child: Text(
            'Finish',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              // height: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  //
}
