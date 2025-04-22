import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/physio_database_helpers.dart';
import 'package:heritage_soft/helpers/server_helpers.dart';
import 'package:heritage_soft/pages/physio/physio_pofile_page.dart';
import 'package:heritage_soft/pages/physio/physio_registration_page.dart';
import 'package:heritage_soft/pages/physio/widgets/physio_hmo_tag.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';

class PhysioClientsList extends StatefulWidget {
  const PhysioClientsList({super.key});

  @override
  State<PhysioClientsList> createState() => _PhysioClientsListState();
}

class _PhysioClientsListState extends State<PhysioClientsList> {
  List<PatientModel> main_patients = [];
  List<PatientModel> patients = [];
  List<PatientModel> search_list = [];
  bool emptySearch = false;

  dynamic get_patients(dynamic data) async {
    PatientModel patient = PatientModel.fromMap(data);

    AppData.set(context).update_patient(patient);
  }

  dynamic remove_patient(dynamic id) async {
    AppData.set(context).delete_patient(id);
  }

  initators() async {
    await PhysioDatabaseHelpers.get_all_patients(context);
  }

  @override
  void initState() {
    initators();
    ServerHelpers.socket!.on('Patient', (data) {
      get_patients(data);
    });
    ServerHelpers.socket!.on('PatientD', (data) {
      remove_patient(data);
    });

    super.initState();
  }

  @override
  void dispose() {
    ServerHelpers.socket!.off('Patient');
    ServerHelpers.socket!.off('PatientD');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.85;
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
                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F8E1).withOpacity(0.69),
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

  // filter function
  List<PatientModel> filter_module() {
    if (!filter_on) return main_patients;

    return main_patients
        .where((element) => ((type_filter_on)
            ? ((type_filter_val == 'Walk-In')
                ? (element.hmo == 'No HMO')
                : (element.hmo == type_filter_val))
            : true))
        .toList();
  }

  // WIDGETS

  int patient_count = 0;
  int filter_patient_count = 0;

  // main page
  Widget main_page() {
    main_patients = Provider.of<AppData>(context).patients;
    patients = filter_module();

    patient_count = main_patients.length;
    filter_patient_count = patients.length;

    if (patients.isNotEmpty && search_list.isNotEmpty)
      search_patients(search_bar_controller.text, build: true);

    return Column(
      children: [
        // top bar
        topBar(),

        // filter area
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  filter_area(),

                  // list
                  Expanded(
                    child: (patients.isEmpty)
                        ? Center(
                            child: Text(
                              'NO CLIENTS',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : list(),
                  ),
                ],
              ),
              Positioned(
                top: 45,
                left: 20,
                child: filter_menu_open ? filter_menu() : Container(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void search_patients(String value, {bool build = false}) {
    search_list.clear();
    emptySearch = false;

    if (value.isNotEmpty) {
      var data = patients
          .where(
            (element) =>
                element.f_name
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.m_name
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.l_name
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.patient_id
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()),
          )
          .toList();

      if (data.isNotEmpty) {
        search_list = data;
      } else {
        // empty search
        emptySearch = true;
      }
    }

    if (!build) setState(() {});
  }

  // CONTROLLER && NODE
  TextEditingController search_bar_controller = TextEditingController();
  FocusNode search_bar_node = FocusNode();

  TextStyle option_style = TextStyle(color: Colors.white, fontSize: 13);
  TextStyle title_style = TextStyle(color: Colors.black, fontSize: 16);

  double search_box_width = 0;
  bool search_on = false;

  bool filter_menu_open = false;
  bool filter_on = false;

  bool type_expanded = false;
  bool type_filter_on = false;
  String type_filter_val = '';
  List<String> type_values = [
    'Walk-In',
    for (var a in physio_hmo) a.hmo_name,
    'Clear',
  ];

  // filter area
  Widget filter_area() {
    var nt = NumberFormat('#,###');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // filter button
          TextButton(
            onPressed: () {
              setState(() {
                filter_menu_open = !filter_menu_open;
              });
            },
            child: Text(
              filter_menu_open ? 'Close menu' : 'Filter',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),

          SizedBox(width: 10),

          // filter list
          Expanded(
            child: (filter_on)
                ? Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      // type status
                      if (type_filter_on)
                        Container(
                          decoration: BoxDecoration(
                            color: (type_filter_val == 'Walk-In')
                                ? Color.fromARGB(255, 144, 103, 19)
                                : Color.fromARGB(255, 165, 19, 151),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            type_filter_val,
                            style: option_style,
                          ),
                        ),
                    ],
                  )
                : Container(),
          ),

          SizedBox(width: 10),

          // total filter
          if (filter_on)
            Container(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                nt.format(filter_patient_count),
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  // fontSize: 14,
                ),
              ),
            ),

          // clear
          if (filter_on)
            TextButton(
              onPressed: () {
                setState(() {
                  filter_on = false;
                  filter_menu_open = false;

                  type_filter_on = false;
                });
              },
              child: Text('Clear'),
            ),
        ],
      ),
    );
  }

  Widget filter_menu() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            offset: Offset(0.7, 0.7),
            color: Colors.black26,
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // type
          InkWell(
            onTap: () {
              setState(() {
                type_expanded = !type_expanded;
              });
            },
            hoverColor: Colors.grey.shade400,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Treatment Type',
                    style: title_style,
                  ),
                  Icon(
                    type_expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // type options
          if (type_expanded)
            Container(
              margin: EdgeInsets.only(left: 25, right: 8),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: type_values
                    .map(
                      (element) => InkWell(
                        onTap: () {
                          if (element == 'Clear') {
                            setState(() {
                              type_expanded = false;
                              type_filter_on = false;
                              type_filter_val = '';
                            });
                          } else {
                            setState(() {
                              type_filter_val = element;
                              type_filter_on = true;
                              filter_on = true;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (element == 'Clear')
                                ? Colors.red.shade400
                                : (element == 'Walk-In')
                                    ? Color.fromARGB(255, 144, 103, 19)
                                    : Color.fromARGB(255, 165, 19, 151),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          child: (element == 'Clear')
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      element,
                                      style: option_style,
                                    ),
                                  ],
                                )
                              : Text(
                                  element,
                                  style: option_style,
                                ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // top bar
  Widget topBar() {
    var nt = NumberFormat('#,###');
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF707070)),
        ),
      ),
      child: Stack(
        children: [
          // header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                'Physio Client List - (${nt.format(patient_count)})',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1),
              ),
            ),
          ),

          // action button
          Positioned(
            top: 10,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhysioRegistrationPage()));
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 24,
                  ),
                ),

                // serach field
                AnimatedContainer(
                  width: search_box_width,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linear,
                  onEnd: () {
                    setState(() {
                      if (search_box_width == 230) {
                        search_on = true;
                        FocusScope.of(context).requestFocus(search_bar_node);
                      } else {
                        search_on = false;
                      }
                    });
                  },
                  child: Container(
                    width: search_box_width,
                    height: 33,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: !search_on
                        ? Container()
                        : TextField(
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            onChanged: search_patients,
                            controller: search_bar_controller,
                            focusNode: search_bar_node,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFF3c3c3c),
                              hintText: 'Search patient...',
                              hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFBCBCBC),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFBCBCBC),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              contentPadding: EdgeInsets.fromLTRB(0, 6, 8, 6),
                              suffixIcon: InkWell(
                                onTap: () {
                                  emptySearch = false;
                                  search_list.clear();
                                  if (search_bar_controller.text.isEmpty) {
                                    search_box_width = 0;
                                  } else {
                                    search_bar_controller.clear();
                                  }
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),

                if (!search_on)
                  InkWell(
                    onTap: () {
                      setState(() {
                        search_on = !search_on;
                        search_box_width = 230;
                      });
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),

                SizedBox(width: 10),

                // close button
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.cancel,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // grid list
  Widget list() {
    // patients.sort((a, b) {
    //   return int.parse(b.patient_id.split('-')[1])
    //       .compareTo(int.parse(a.patient_id.split('-')[1]));
    // });

    return
        // empty serach
        emptySearch
            ? Center(
                child: Text(
                  'Search does not match any record',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              )

            // search list
            : search_list.isNotEmpty
                // searchlist
                ? Container(
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                      ),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: BouncingScrollPhysics(),
                      children: search_list.map((e) => list_tile(e)).toList(),
                    ),
                  )

                // patients list
                : Container(
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                      ),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: BouncingScrollPhysics(),
                      children: patients.map((e) => list_tile(e)).toList(),
                    ),
                  );
  }

  // patient list tile
  Widget list_tile(PatientModel patient) {
    String cl_name = '${patient.f_name} ${patient.l_name}';

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientProfilePage(patient: patient),
          ),
        );

        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            // profile image
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Color(0xFFf97ecf),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: patient.user_image.isEmpty
                    ? Image.asset(
                        'images/icon/user-alt.png',
                        width: 50,
                        height: 50,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          patient.user_image,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            SizedBox(width: 15),

            // user details
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // id
                  Row(
                    children: [
                      // id
                      Text(
                        patient.patient_id,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),

                      Expanded(child: Container()),
                    ],
                  ),

                  SizedBox(height: 6),

                  // name
                  Text(
                    cl_name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      height: 1,
                    ),
                  ),

                  SizedBox(height: 8),

                  // hmo tag
                  PhysioHMOTag(hmo: patient.hmo),
                ],
              ),
            ),

            //
          ],
        ),
      ),
    );
  }

  //
}

class FilterModel {
  bool active;
  String title;

  FilterModel({
    required this.active,
    required this.title,
  });
}
