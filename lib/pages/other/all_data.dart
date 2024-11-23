import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/datamodels/hmo_model.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/datamodels/users_model.dart';
import 'package:heritage_soft/pages/gym/clients_list.dart';
import 'package:heritage_soft/pages/physio/doctors_list.dart';
import 'package:heritage_soft/pages/physio/physio_clients_list.dart';
import 'package:heritage_soft/pages/staff/staff_list.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AllData extends StatefulWidget {
  const AllData({super.key});

  @override
  State<AllData> createState() => _AllDataState();
}

class _AllDataState extends State<AllData> {
  CarouselController buttonCarouselController = CarouselController();

  List<ClientListModel> all_gym_cl = [];
  List<ClientListModel> active_gym_cl = [];
  List<ClientListModel> expired_gym_cl = [];
  List<ClientListModel> hmo_cl = [];
  List<HMO_Model> gym_hmos = [];

  List<PhysioClientListModel> all_physio_cl = [];
  List<PhysioClientListModel> phy_prv_cl = [];
  List<PhysioClientListModel> phy_hmo_cl = [];
  List<HMO_Model> physio_hmos = [];
  int total_phy_session = 0;

  List<StaffModel> staffs = [];
  List<DoctorModel> doctors = [];

  int current_page = 0;

  // get gym data
  get_gym_data() {
    all_gym_cl = Provider.of<AppData>(context).clients;

    active_gym_cl = all_gym_cl.where((element) => element.sub_status!).toList();

    expired_gym_cl =
        all_gym_cl.where((element) => !element.sub_status!).toList();

    hmo_cl = all_gym_cl.where((element) => element.hmo != 'No HMO').toList();

    gym_hmos = Provider.of<AppData>(context).gym_hmo.toList();
  }

  // get physio data
  get_physio_data() {
    all_physio_cl = Provider.of<AppData>(context).physio_clients;

    phy_prv_cl =
        all_physio_cl.where((element) => element.hmo == 'No HMO').toList();

    phy_hmo_cl =
        all_physio_cl.where((element) => element.hmo != 'No HMO').toList();

    physio_hmos = Provider.of<AppData>(context).physio_hmo.toList();

    total_phy_session = 0;
    Provider.of<AppData>(context).all_doctors.forEach((element) {
      total_phy_session += element.total_sessions;
    });
  }

  // get staff data
  get_staff_data() {
    staffs = Provider.of<AppData>(context).staffs;
    doctors = Provider.of<AppData>(context).all_doctors;
  }

  //
  // get_finaice_data() {}

  @override
  Widget build(BuildContext context) {
    get_gym_data();
    get_physio_data();
    get_staff_data();
    double width = MediaQuery.of(context).size.width * 0.45;
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
                          'images/office_data.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF4485db),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // main content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
    return Stack(
      children: [
        Column(
          children: [
            // top data slider
            CarouselSlider(
              items: [
                top_box_gym(),
                top_box_physio(),
                top_box_staff(),
                // top_box_finance(),
              ],
              carouselController: buttonCarouselController,
              options: CarouselOptions(
                height: 230,
                // aspectRatio: 16 / 9,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: false,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 10),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                enlargeFactor: 0.3,
                onPageChanged: (int, ca) {
                  current_page = int;
                  setState(() {});
                },
                scrollDirection: Axis.horizontal,
              ),
            ),

            // selector
            Container(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // previous
                  selector_box(
                      (current_page == 0)
                          ? ''
                          : (current_page == 1)
                              ? 'Gym Data'
                              : (current_page == 2)
                                  ? 'Physio Data'
                                  // : (current_page == 3)
                                  //     ? 'Staff Data'
                                  : '',
                      false),

                  // active
                  active_box(
                    (current_page == 0)
                        ? 'Gym Data'
                        : (current_page == 1)
                            ? 'Physio Data'
                            : (current_page == 2)
                                ? 'Staff Data'
                                // : (current_page == 3)
                                //     ? 'Finance'
                                : '',
                  ),

                  // next
                  selector_box(
                      (current_page == 0)
                          ? 'Physio Data'
                          : (current_page == 1)
                              ? 'Staff Data'
                              // : (current_page == 2)
                              //     ? 'Finance'
                              : '',
                      true),
                ],
              ),
            ),

            // list box
            Expanded(child: list_box()),
          ],
        ),

        // close icon
        Positioned(
          top: 12,
          right: 12,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.cancel,
              color: Colors.white70,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }

  // gym data
  Widget top_box_gym() {
    return Container(
      height: 230,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        children: [
          SizedBox(height: 20),
          // active
          figure_tile(
            label: 'Total',
            figure: all_gym_cl.length,
          ),

          SizedBox(height: 25),

          // others
          Row(
            children: [
              // 1st column
              Column(
                children: [
                  // total
                  Container(
                    padding: EdgeInsets.only(left: 80),
                    child: figure_tile(
                        label: 'Active', figure: active_gym_cl.length),
                  ),

                  SizedBox(height: 20),

                  // hmo
                  figure_tile(label: 'HMO\'s', figure: gym_hmos.length),
                ],
              ),

              Expanded(child: Container()),

              // 2nd column
              Column(
                children: [
                  // expired
                  Container(
                    padding: EdgeInsets.only(right: 80),
                    child: figure_tile(
                      label: 'Inactive',
                      figure: expired_gym_cl.length,
                    ),
                  ),

                  SizedBox(height: 20),

                  // staff
                  figure_tile(label: 'HMO Clients', figure: hmo_cl.length),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // physio data
  Widget top_box_physio() {
    return Container(
      height: 230,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        children: [
          SizedBox(height: 20),
          // active
          figure_tile(label: 'Total Patients', figure: all_physio_cl.length),

          SizedBox(height: 25),

          // others
          Row(
            children: [
              // 1st column
              Column(
                children: [
                  // total
                  Container(
                    padding: EdgeInsets.only(left: 80),
                    child: figure_tile(
                      label: 'Private Patients',
                      figure: phy_prv_cl.length,
                    ),
                  ),

                  SizedBox(height: 20),

                  // hmo
                  figure_tile(
                    label: 'Total Sessions',
                    figure: total_phy_session,
                  ),
                ],
              ),

              Expanded(child: Container()),

              // 2nd column
              Column(
                children: [
                  // expired
                  Container(
                    padding: EdgeInsets.only(right: 80),
                    child: figure_tile(
                        label: 'HMO Patients', figure: phy_hmo_cl.length),
                  ),

                  SizedBox(height: 20),

                  // staff
                  figure_tile(label: 'HMO\'s', figure: physio_hmos.length),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // staf data
  Widget top_box_staff() {
    return Container(
      height: 230,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        children: [
          SizedBox(height: 20),
          // active
          // figure_tile(label: 'Active', figure: active_gym_cl.length),

          SizedBox(height: 25),

          // others
          Row(
            children: [
              // 1st column
              Column(
                children: [
                  // total
                  figure_tile(label: 'Staffs', figure: staffs.length),

                  SizedBox(height: 20),

                  // hmo
                  // figure_tile(label: 'HMO\'s', figure: gym_hmos.length),
                ],
              ),

              Expanded(child: Container()),

              // 2nd column
              Column(
                children: [
                  // expired
                  figure_tile(label: 'Physiotherapist', figure: doctors.length),

                  SizedBox(height: 20),

                  // staff
                  // figure_tile(label: 'HMO Clients', figure: hmo_cl.length),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // finance
  Widget top_box_finance() {
    return Container();
  }

  // figure tile
  Widget figure_tile({required String label, required int figure}) {
    var value = NumberFormat('#,###');
    return Container(
      width: 120,
      child: Column(
        children: [
          // figure
          Text(
            value.format(figure),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              height: 1,
              letterSpacing: 0.5,
            ),
          ),
          
          SizedBox(height: 0),

          // label
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // list box
  Widget list_box() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // main container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFf7f8e1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          padding: EdgeInsets.fromLTRB(0, 50, 0, 10),
          margin: EdgeInsets.symmetric(horizontal: 0.1),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // spacing
                  SizedBox(height: 10),

                  // client list
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClientsList()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(2, 2),
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.16),
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // icon
                          Icon(
                            Icons.people,
                            size: 22,
                            color: Color(0xFF5a5a5a),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'GYM Clients',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(child: Container()),

                          // arrow
                          Icon(
                            Icons.chevron_right,
                            size: 30,
                            color: Color(0xFF8e8e8e),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // physio clients
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhysioClientsList()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(2, 2),
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.16),
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // icon
                          Icon(
                            Icons.health_and_safety,
                            size: 22,
                            color: Color(0xFF5a5a5a),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Physio Clients',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(child: Container()),

                          // arrow
                          Icon(
                            Icons.chevron_right,
                            size: 30,
                            color: Color(0xFF8e8e8e),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // staffs
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StaffList()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(2, 2),
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.16),
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // icon
                          Icon(
                            Icons.group_work,
                            size: 22,
                            color: Color(0xFF5a5a5a),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'All Staff',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(child: Container()),

                          // arrow
                          Icon(
                            Icons.chevron_right,
                            size: 30,
                            color: Color(0xFF8e8e8e),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // doctors
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorsList()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(2, 2),
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.16),
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // icon
                          Icon(
                            Icons.medical_information,
                            size: 22,
                            color: Color(0xFF5a5a5a),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Physiotherapist',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(child: Container()),

                          // arrow
                          Icon(
                            Icons.chevron_right,
                            size: 30,
                            color: Color(0xFF8e8e8e),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //
                ],
              ),
            ),
          ),
        ),

        // decoration
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Icon(
              Icons.workspaces_rounded,
              size: 30,
              color: Color(0xFF5a5a5a),
            ),
          ),
        ),
      ],
    );
  }

  // selector box
  Widget selector_box(String title, bool next) {
    return Container(
      width: 80,
      child: InkWell(
        onTap: () {
          if (next) {
            buttonCarouselController.nextPage(
                duration: Duration(milliseconds: 300), curve: Curves.linear);
          } else {
            buttonCarouselController.previousPage(
                duration: Duration(milliseconds: 300), curve: Curves.linear);
          }
        },
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.blue.withOpacity(.7),
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // display box
  Widget active_box(String title) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
//
}
