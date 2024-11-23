import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/pages/physio/clinic_tab.dart';
import 'package:heritage_soft/pages/physio/widgets/physio_hmo_tag.dart';
import 'package:provider/provider.dart';

class PatientList extends StatefulWidget {
  final List<PhysioClientListModel>? my_patients;
  final List<PhysioClientListModel>? ongoing_patient;
  final List<PhysioClientListModel>? pending_patient;

  const PatientList({
    super.key,
    this.my_patients,
    this.ongoing_patient,
    this.pending_patient,
  });

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList>
    with TickerProviderStateMixin {
  final TextEditingController search_controller = TextEditingController();

  int _index = 0;

  @override
  void initState() {
    search_controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    search_controller.dispose();
    super.dispose();
  }

  List<PhysioClientListModel> my_patients = [];
  List<PhysioClientListModel> ongoing_patients = [];
  List<PhysioClientListModel> pending_patients = [];

  get_patients() {
    var all_p = Provider.of<AppData>(context).doctors_ong_patients;

    ongoing_patients = all_p
        .where((element) =>
            element.ongoing_treatment && !element.pending_treatment)
        .toList();

    pending_patients = all_p
        .where((element) =>
            element.pending_treatment && !element.ongoing_treatment)
        .toList();

    my_patients = Provider.of<AppData>(context).doctors_patients;
  }

  get_patients_2() {
    pending_patients = widget.pending_patient!;

    ongoing_patients = widget.ongoing_patient!;

    my_patients = widget.my_patients!;
  }

  @override
  Widget build(BuildContext context) {
    bool is_doc = false;
    if (widget.my_patients == null ||
        widget.ongoing_patient == null ||
        widget.pending_patient == null) {
      is_doc = true;
      get_patients();
    } else {
      is_doc = false;
      get_patients_2();
    }

    if (is_doc) {
      _index = ongoing_patients.isEmpty
          ? pending_patients.isEmpty
              ? 2
              : 1
          : 0;
    } else {
      _index = ongoing_patients.isEmpty
          ? pending_patients.isEmpty
              ? 2
              : 1
          : 0;
    }

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
            patients_list(ongoing_patients, horiz_list: true, ong: true),
            patients_list(pending_patients, ong: true, horiz_list: is_doc),
            patients_list(my_patients, my_pat: true),
          ],
        ),
      ),
    );
  }

  List<PhysioClientListModel> search_list = [];
  bool search_on = false;

  // list of patients
  Widget patients_list(List<PhysioClientListModel> patients,
      {bool horiz_list = false, bool ong = false, bool my_pat = false}) {
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
                                              child: list_tile(e, ong, my_pat),
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
                                        .map((e) => list_tile(e, ong, my_pat))
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
                                                  child:
                                                      list_tile(e, ong, my_pat),
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
                                            .map((e) =>
                                                list_tile(e, ong, my_pat))
                                            .toList(),
                                      ),
                              ),
          ),
        ),
      ],
    );
  }

  // patients tile
  Widget list_tile(PhysioClientListModel client, bool can_treat, bool my_pat) {
    String cl_name = '${client.f_name} ${client.l_name}';
    String cl_name2 = '${client.f_name} ${client.m_name} ${client.l_name}';

    return InkWell(
      onTap: () {
        PhysioHealthClientModel client_h = PhysioHealthClientModel(
            key: client.key!,
            id: client.id!,
            name: cl_name2,
            user_image: client.user_image!,
            hmo: client.hmo!,
            baseline_done: client.baseline_done);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClinicTab(
              client: client_h,
              can_treat: can_treat,
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
                child: client.user_image!.isEmpty
                    ? Image.asset(
                        'images/icon/user-alt.png',
                        width: 50,
                        height: 50,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          client.user_image!,
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
                        client.id!,
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
                  PhysioHMOTag(hmo: client.hmo!),
                ],
              ),
            ),

            // treatment count
            (my_pat && client.treatment_sessions != 0)
                ? Container(
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
                            client.treatment_sessions.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),

            //
          ],
        ),
      ),
    );
  }

  search_value(String value, List<PhysioClientListModel> patients) {
    search_on = true;
    search_list.clear();

    if (value.isNotEmpty) {
      search_list = patients
          .where((element) =>
              element.f_name!.toLowerCase().contains(value.toLowerCase()) ||
              element.m_name!.toLowerCase().contains(value.toLowerCase()) ||
              element.l_name!.toLowerCase().contains(value.toLowerCase()) ||
              element.id.toString().toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else {
      search_on = false;
    }

    // setState(() {});
  }

  //
}
