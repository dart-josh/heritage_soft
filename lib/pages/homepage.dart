import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/pages/store/accessories_list_page.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/other/attendance_page.dart';
import 'package:heritage_soft/pages/other/birthday_list.dart';
import 'package:heritage_soft/pages/other/data_report_page.dart';
import 'package:heritage_soft/pages/other/guest_record.dart';
import 'package:heritage_soft/pages/store/restock_accessories_page.dart';
import 'package:heritage_soft/pages/store/restock_accessory_record_page.dart';
import 'package:heritage_soft/pages/store/sales_record_page.dart';
import 'package:heritage_soft/pages/staff/general_staff_attendance.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/pages/gym/clients_list.dart';
import 'package:heritage_soft/pages/gym/general_attendance_history_table.dart';
import 'package:heritage_soft/pages/other/all_data.dart';
import 'package:heritage_soft/pages/clinic/doctors_list.dart';
import 'package:heritage_soft/pages/clinic/all_patient_list.dart';
import 'package:heritage_soft/pages/clinic/patient_registration_page.dart';
import 'package:heritage_soft/pages/gym/registration_page.dart';
import 'package:heritage_soft/pages/staff/user_list.dart';
import 'package:heritage_soft/widgets/app_bar.dart';
import 'package:heritage_soft/widgets/manage_hmo_dialog.dart';
import 'package:heritage_soft/widgets/manage_passwords.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  cs.CarouselController buttonCarouselController = cs.CarouselController();

  int current_page = 0;

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
                'images/background1.png',
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
            margin: EdgeInsets.only(top: 45),
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
                          color: Color(
                              0xFF4485db), // Color(0xFF01040A).withOpacity(0.83),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // main content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),

                        Expanded(child: sliders()),

                        // bottom text
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            current_page == 0
                                ? 'HERITAGE FITNESS & WELLNESS CENTRE'
                                : current_page == 1
                                    ? 'HERITAGE PHYSIOTHERAPY CLINIC'
                                    : 'DELIGHTSOME HERITAGE INTERNATIONAL',
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

          // app bar
          Positioned.fill(
            child: Container(
              child: MyAppBar(),
            ),
          ),

          //
        ],
      ),
    );
  }

  // WIDGETs

  // sliders
  Widget sliders() {
    UserModel? user = AppData.get(context).active_user;
    return Row(
      children: [
        // previous
        IconButton(
          onPressed: () {
            buttonCarouselController.previousPage(
                duration: Duration(milliseconds: 300), curve: Curves.linear);
          },
          icon: Icon(
            Icons.arrow_left_sharp,
            size: 80,
            color: Colors.white,
          ),
        ),

        // slider
        Expanded(
          child: cs.CarouselSlider(
            items: user!.full_access
                ? [
                    full_access_tab_1(),
                    full_access_tab_2(),
                    full_access_tab_3(),
                  ]
                : (user.app_role == 'Admin' || user.app_role == 'Management')
                    ? [
                        admin_tab_1(),
                        admin_tab_2(),
                      ]
                    : (user.app_role == 'CSU')
                        ? [
                            main_page_0(),
                            main_page_1(),
                          ]
                        : [],
            carouselController: buttonCarouselController,
            options: cs.CarouselOptions(
              viewportFraction: 1,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              onPageChanged: (int, ca) {
                current_page = int;
                setState(() {});
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),

        // next
        IconButton(
          onPressed: () {
            buttonCarouselController.nextPage(
                duration: Duration(milliseconds: 300), curve: Curves.linear);
          },
          icon: Icon(
            Icons.arrow_right_sharp,
            size: 80,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // main page
  Widget main_page_0() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            ft_client_list(),
            pt_client_list(),
            doctors(),
            birthday_list(),
            attendance_history(),
            guest_record(),
          ],
        ),
      ),
    );
  }

  Widget main_page_1() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            data_report(),
            accessories(),
            restock_accessories(),
            restock_accessories_record(),
            sales_record(),
            manage_hmo(),
          ],
        ),
      ),
    );
  }

  Widget admin_tab_1() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            all_data(),
            data_report(),
            birthday_list(),
            ft_client_list(),
            pt_client_list(),
            staff_list(),
            doctors(),
          ],
        ),
      ),
    );
  }

  Widget admin_tab_2() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            attendance_history(),
            staff_attendance_history(),
            guest_record(),
            accessories(),
            restock_accessories(),
            restock_accessories_record(),
            sales_record(),
            manage_hmo(),
            manage_password(),
          ],
        ),
      ),
    );
  }

  Widget full_access_tab_1() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            all_data(),
            ft_client_list(),
            pt_client_list(),
            data_report(),
            staff_list(),
            doctors(),
            birthday_list(),
          ],
        ),
      ),
    );
  }

  Widget full_access_tab_2() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            attendance_history(),
            staff_attendance_history(),
            guest_record(),
            accessories(),
            restock_accessories(),
            restock_accessories_record(),
            sales_record(),
            manage_hmo(),
            manage_password(),
          ],
        ),
      ),
    );
  }

  Widget full_access_tab_3() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            mark_attendance(),
          ],
        ),
      ),
    );
  }

  // TILES

  // Gym Client list
  Widget ft_client_list() {
    return InkWell(
      onTap: () {
        return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientsList()),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/gym_list.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Gym Client List',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // Client list
  Widget pt_client_list() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AllPatientList()),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/pt_clients.jpeg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Physio Client List',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // attendance history
  Widget attendance_history() {
    return InkWell(
      onTap: () async {
        return;
        var conf = await Helpers.enter_password(context,
            title: 'General Attendance password');

        if (conf)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GAH_T()),
          );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/att_2.jpeg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'General Attendance History',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // attendance history
  Widget staff_attendance_history() {
    return InkWell(
      onTap: () async {
        return;
        var conf = await Helpers.enter_password(context,
            title: 'Staff Attendance password');

        if (conf)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GSAH()),
          );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/staff_att_rec.png',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Staff Attendance History',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // mark attendance
  Widget mark_attendance() {
    return InkWell(
      onTap: () async {
        send_notification = false;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendancePage(
              home: true,
            ),
          ),
        );

        send_notification = true;
        setState(() {});
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/attendance.jpeg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Mark Attendance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // doctors
  Widget doctors() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorsList()),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/doctor.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Physiotherapist\'s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  //
  Widget accessories() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccessoriesList()),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/accessories.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Accessories',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget restock_accessories() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RestockAccessoriesPage()),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/accessories.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Restock Accessories',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget restock_accessories_record() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RestockAccessoryRecordPage()),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/accessories.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Restock Accessories Record',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  //
  Widget sales_record() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SalesRecord()),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/shop.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Sales Record',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // staffs
  Widget staff_list() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserList()),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/office.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Staff List',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // gym data
  Widget all_data() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllData(),
          ),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/office_data.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Office\nData',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // mark attendance
  Widget guest_record() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuestRecord(),
          ),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/visir.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Visitors Record',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // mark attendance
  Widget manage_hmo() {
    return InkWell(
      onTap: () {
        return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ManageHMO(),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/hmo.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Manage HMO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget manage_password() {
    return InkWell(
      onTap: () async {
        return;
        // Delete User password
        // Staff Attendance password
        // Heritage024
        var conf =
            await Helpers.enter_password(context, title: 'universal password');

        if (conf)
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ManagePasswords(),
          );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/background4.png',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Manage Passwords',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // send notice
  Widget birthday_list() {
    return InkWell(
      onTap: () {
        return;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BirthdayList()));
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/birthday_list.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Today\'s Birthday',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // data report
  Widget data_report() {
    return InkWell(
      onTap: () {
        return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataReportPage(),
          ),
        );
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/office_data.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Data\nReport',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  //
}
