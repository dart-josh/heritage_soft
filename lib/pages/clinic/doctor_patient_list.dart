import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/pages/clinic/clinic_tab.dart';
import 'package:heritage_soft/pages/clinic/widgets/physio_hmo_tag.dart';

class PatientList extends StatefulWidget {
  final List<MyPatientModel> my_patients;
  final List<PatientModel> ongoing_patient;
  final List<PatientModel> pending_patient;
  final int? inital_index;

  const PatientList({
    super.key,
    required this.my_patients,
    required this.ongoing_patient,
    required this.pending_patient,
    this.inital_index,
  });

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList>
    with TickerProviderStateMixin {
  final TextEditingController search_controller = TextEditingController();
  final TextEditingController search_controller_2 = TextEditingController();

  int _index = 0;

  @override
  void initState() {
    search_controller.addListener(() {
      setState(() {});
    });
    search_controller_2.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    search_controller.dispose();
    search_controller_2.dispose();
    super.dispose();
  }

  List<MyPatientModel> my_patients = [];
  List<PatientModel> ongoing_patients = [];
  List<PatientModel> pending_patients = [];

  UserModel? active_user;

  get_patients() {
    active_user = AppData.get(context).active_user;
    DoctorModel? active_doctor = AppData.get(context).active_doctor;

    pending_patients = widget.pending_patient;
    ongoing_patients = widget.ongoing_patient;
    my_patients = widget.my_patients;

    if (active_doctor != null) {
      pending_patients = active_doctor.pen_patients;
      ongoing_patients = active_doctor.ong_patients;
      my_patients = active_doctor.my_patients;
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel? active_user = AppData.get(context).active_user;
    bool is_doc = active_user?.app_role == 'Doctor';

    get_patients();
    _index = pending_patients.isNotEmpty
        ? 1
        : ongoing_patients.isNotEmpty
            ? 0
            : 2;

    if (widget.inital_index != null) _index = widget.inital_index ?? _index;

    return DefaultTabController(
      length: 3,
      initialIndex: _index,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 2, 20, 35),
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 2, 20, 35),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Ongoing Treatment'),
              Tab(text: 'Pending Patients'),
              Tab(text: is_doc ? 'My Patients' : 'Doctor\'s Patients'),
            ],
          ),
          title: Text('Patient List'),
        ),
        body: TabBarView(
          children: [
            patients_list(ongoing_patients, horiz_list: true),
            patients_list(pending_patients, horiz_list: is_doc),
            patients_list_2(my_patients),
          ],
        ),
      ),
    );
  }

  List<PatientModel> search_list = [];
  List<MyPatientModel> search_list_2 = [];
  bool search_on = false;

  // list of patients
  Widget patients_list(List<PatientModel> patients, {bool horiz_list = false}) {
    return Column(
      children: [
        SizedBox(height: 20),
        // search bar
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Color.fromARGB(81, 0, 0, 0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            controller: search_controller,
            onChanged: search_value(search_controller.text, patients),
            style: TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              hintText: 'Search',
              hintStyle: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white54,
                size: 20,
              ),
              suffixIcon: search_controller.text.isNotEmpty
                  ? InkWell(
                      onTap: () {
                        search_controller.clear();
                        search_list.clear();
                        search_on = false;
                        setState(() {});
                      },
                      child: Icon(
                        Icons.clear,
                        color: Colors.white54,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // patient list
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horiz_list ? 300 : 10, vertical: 20),
            child:
                // empty serach
                search_on && search_list.isEmpty
                    ? Center(
                        child: Text(
                          'Search does not match any record',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      )

                    // search list
                    : search_list.isNotEmpty
                        ? Container(
                            child: horiz_list
                                ? ListView(
                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                                    physics: BouncingScrollPhysics(),
                                    children: search_list
                                        .map((e) => Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: list_tile(e),
                                            ))
                                        .toList())
                                : GridView(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisExtent: 120,
                                      mainAxisSpacing: 15,
                                      crossAxisSpacing: 20,
                                    ),
                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                                    physics: BouncingScrollPhysics(),
                                    children: search_list
                                        .map((e) => list_tile(e))
                                        .toList(),
                                  ),
                          )

                        // empty patient list
                        : patients.isEmpty
                            ? Center(
                                child: Text(
                                  'No Patients!!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              )

                            // patients list
                            : Container(
                                child: horiz_list
                                    ? ListView(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 20, 15),
                                        physics: BouncingScrollPhysics(),
                                        children: patients
                                            .map((e) => Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: list_tile(e),
                                                ))
                                            .toList())
                                    : GridView(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisExtent: 120,
                                          mainAxisSpacing: 15,
                                          crossAxisSpacing: 20,
                                        ),
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 20, 15),
                                        physics: BouncingScrollPhysics(),
                                        children: patients
                                            .map((e) => list_tile(e))
                                            .toList(),
                                      ),
                              ),
          ),
        ),
      ],
    );
  }

  Widget patients_list_2(List<MyPatientModel> patients,
      {bool horiz_list = false}) {
    return Column(
      children: [
        SizedBox(height: 20),
        // search bar
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Color.fromARGB(81, 0, 0, 0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            controller: search_controller_2,
            onChanged: search_value_2(search_controller_2.text, patients),
            style: TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              hintText: 'Search',
              hintStyle: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white54,
                size: 20,
              ),
              suffixIcon: search_controller_2.text.isNotEmpty
                  ? InkWell(
                      onTap: () {
                        search_controller_2.clear();
                        search_list_2.clear();
                        search_on = false;
                        setState(() {});
                      },
                      child: Icon(
                        Icons.clear,
                        color: Colors.white54,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // patient list
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horiz_list ? 300 : 10, vertical: 20),
            child:
                // empty serach
                search_on && search_list_2.isEmpty
                    ? Center(
                        child: Text(
                          'Search does not match any record',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      )

                    // search list
                    : search_list_2.isNotEmpty
                        ? Container(
                            child: horiz_list
                                ? ListView(
                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                                    physics: BouncingScrollPhysics(),
                                    children: search_list_2
                                        .map((e) => Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: list_tile_2(e),
                                            ))
                                        .toList())
                                : GridView(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisExtent: 120,
                                      mainAxisSpacing: 15,
                                      crossAxisSpacing: 20,
                                    ),
                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                                    physics: BouncingScrollPhysics(),
                                    children: search_list_2
                                        .map((e) => list_tile_2(e))
                                        .toList(),
                                  ),
                          )

                        // empty patient list
                        : patients.isEmpty
                            ? Center(
                                child: Text(
                                  'No Patients!!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              )

                            // patients list
                            : Container(
                                child: horiz_list
                                    ? ListView(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 20, 15),
                                        physics: BouncingScrollPhysics(),
                                        children: patients
                                            .map((e) => Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: list_tile_2(e),
                                                ))
                                            .toList())
                                    : GridView(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisExtent: 120,
                                          mainAxisSpacing: 15,
                                          crossAxisSpacing: 20,
                                        ),
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 20, 15),
                                        physics: BouncingScrollPhysics(),
                                        children: patients
                                            .map((e) => list_tile_2(e))
                                            .toList(),
                                      ),
                              ),
          ),
        ),
      ],
    );
  }

  // patients tile
  Widget list_tile(PatientModel patient) {
    String cl_name = '${patient.f_name} ${patient.l_name}';

    return InkWell(
      enableFeedback: (active_user?.app_role == 'Doctor'),
      onTap: () {
        if (active_user?.app_role == 'Doctor')
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClinicTab(
                patient: patient,
              ),
            ),
          );
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

            // treatment type
            Text(
              patient.clinic_variables?.case_type ?? '',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                letterSpacing: .8,
              ),
            ),
            //
          ],
        ),
      ),
    );
  }

  Widget list_tile_2(MyPatientModel patient) {
    String cl_name = '${patient.patient?.f_name} ${patient.patient?.l_name}';

    return InkWell(
      enableFeedback: (active_user?.app_role == 'Doctor'),
      onTap: () {
        if (active_user?.app_role == 'Doctor')
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClinicTab(
                patient: patient.patient!,
              ),
            ),
          );
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
                child: patient.patient?.user_image.isEmpty ?? false
                    ? Image.asset(
                        'images/icon/user-alt.png',
                        width: 50,
                        height: 50,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          patient.patient?.user_image ?? '',
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
                        patient.patient?.patient_id ?? '',
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
                  PhysioHMOTag(hmo: patient.patient?.hmo ?? ''),
                ],
              ),
            ),

            // treatment count
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(143, 26, 48, 93),
                  ),
                  // padding: EdgeInsets.all(8),
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Text(
                      patient.session_count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            //
          ],
        ),
      ),
    );
  }

  search_value(String value, List<PatientModel> patients) {
    search_on = true;
    search_list.clear();

    if (value.isNotEmpty) {
      search_list = patients
          .where((element) =>
              element.f_name.toLowerCase().contains(value.toLowerCase()) ||
              element.m_name.toLowerCase().contains(value.toLowerCase()) ||
              element.l_name.toLowerCase().contains(value.toLowerCase()) ||
              element.patient_id
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    } else {
      search_on = false;
    }

    // setState(() {});
  }

  search_value_2(String value, List<MyPatientModel> patients) {
    search_on = true;
    search_list_2.clear();

    if (value.isNotEmpty) {
      search_list_2 = patients
          .where((element) =>
              element.patient?.f_name
                  .toLowerCase()
                  .contains(value.toLowerCase()) ??
              false ||
                  (element.patient?.m_name
                          .toLowerCase()
                          .contains(value.toLowerCase()) ??
                      false) ||
                  (element.patient?.l_name
                          .toLowerCase()
                          .contains(value.toLowerCase()) ??
                      false) ||
                  (element.patient?.patient_id
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()) ??
                      false))
          .toList();
    } else {
      search_on = false;
    }

    // setState(() {});
  }

  //
}
