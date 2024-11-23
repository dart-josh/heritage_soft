import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/guest_model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';

class GuestSI extends StatefulWidget {
  const GuestSI({super.key});

  @override
  State<GuestSI> createState() => _GuestSIState();
}

class _GuestSIState extends State<GuestSI> {
  // text controller
  TextEditingController name_controller = TextEditingController();
  TextEditingController phone_controller = TextEditingController();
  TextEditingController address_controller = TextEditingController();

  // focus node
  FocusNode name_node = FocusNode();
  FocusNode phone_node = FocusNode();
  FocusNode address_node = FocusNode();

  bool done = false;

  String purpose_select = 'Select one';
  String facility_select = 'Select one';

  List<String> facility_options = [
    'Gym',
    'Physio',
    'Spa',
  ];
  List<String> purpose_options = [
    'Enquiry',
    'Visit',
    'Meeting',
    'Invitation',
  ];

  @override
  void initState() {
    name_controller.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    name_controller.dispose();
    phone_controller.dispose();
    address_controller.dispose();
    name_node.dispose();
    phone_node.dispose();
    address_node.dispose();
    super.dispose();
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'images/office.jpg',
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
                    (done)
                        // welcome area
                        ? welcome_box()

                        // form area
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // main content
                              main_page(),

                              // proceed button
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  height: 45,
                                  padding: EdgeInsets.only(right: 40),
                                  child: (name_controller.text.isNotEmpty)
                                      ? proceed_box()
                                      : Container(),
                                ),
                              )
                            ],
                          ),

                    // close button
                    Positioned(
                      top: 20,
                      right: 20,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: left_side(),
          ),
          Expanded(
            flex: 4,
            child:
                (facility_select != 'Select one') ? right_side() : Container(),
          ),
        ],
      ),
    );
  }

  // left side
  Widget left_side() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          company_info(),
          SizedBox(height: 20),
          form1(),
        ],
      ),
    );
  }

  // right side
  Widget right_side() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: form2(),
    );
  }

  // company info
  Widget company_info() {
    return Column(
      children: [
        // logo
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          backgroundImage: AssetImage('images/logo.jpg'),
          // child: Center(
          //   child: Text('LOGO'),
          // ),
        ),

        SizedBox(height: 20),

        // welcome text
        Padding(
          padding: EdgeInsets.only(left: 120),
          child: Text(
            '... Welcome to',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
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
        ),

        SizedBox(height: 6),

        // office name label
        Text(
          'Delightsome Heritage International',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            letterSpacing: 1,
            height: 1,
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

  // form 1
  Widget form1() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Purpose of visit
          Container(
            width: 250,
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Select_form(
              require: true,
              label: 'Purpose of visit',
              options: purpose_options,
              text_value: purpose_select,
              setval: (val) {
                if (val != null) {
                  purpose_select = val;
                  setState(() {});
                }
              },
            ),
          ),

          // Facility
          if (purpose_select != 'Select one')
            Container(
              width: 250,
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Select_form(
                require: true,
                label: 'What Facility are you visiting',
                options: facility_options,
                text_value: facility_select,
                setval: (val) {
                  if (val != null) {
                    facility_select = val;
                    setState(() {});

                    Future.delayed(Duration(milliseconds: 400), () {
                      FocusScope.of(context).requestFocus(name_node);
                    });
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  // form 2
  Widget form2() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Text(
            'Please fill out the form below.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),

          // full name
          Container(
            width: 270,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text_field(
              require: true,
              label: 'Full name',
              controller: name_controller,
              node: name_node,
              hintText: 'John Doe',
            ),
          ),

          // phone
          Container(
            width: 270,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text_field(
              label: 'Phone no.',
              controller: phone_controller,
              node: phone_node,
              hintText: 'xxxx xxx xxxx',
            ),
          ),

          // address
          Container(
            width: 270,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text_field(
              label: 'Address',
              controller: address_controller,
              node: address_node,
              maxLine: 3,
            ),
          ),
        ],
      ),
    );
  }

  // proceed box
  Widget proceed_box() {
    return InkWell(
      onTap: () async {
        if (name_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.red,
            toastText: 'Enter name',
            icon: Icons.error,
          );
          return;
        }

        if (phone_controller.text.isNotEmpty &&
            (phone_controller.text.length > 11 ||
                phone_controller.text.length < 10)) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Phone No Invalid',
            icon: Icons.error,
          );
          return;
        }

        DateTime date_st = DateTime.now();

        String title = DateFormat('MMMM').format(date_st);
        int year = date_st.year;
        String month = '$title, $year';

        String date = Helpers.date_format(date_st, same_year: true);

        GuestModel map = GuestModel(
          key: '',
          name: name_controller.text.trim(),
          phone: phone_controller.text.trim(),
          address: address_controller.text.trim(),
          purpose: purpose_select,
          facility: facility_select,
          date: date_st.toString(),
        );

        AdminDatabaseHelpers.add_visitor_to_record(
            '$month/$date', map.toJson());

        setState(() {
          done = true;
        });
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF69DD90).withOpacity(0.67),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/icon/Icon-walking.png',
              width: 18,
              height: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Proceed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // welcome box
  Widget welcome_box() {
    if (mounted)
      Future.delayed(
        Duration(seconds: 5),
        () {
          if (mounted) Navigator.pop(context);
        },
      );

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                company_info(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  //
}
