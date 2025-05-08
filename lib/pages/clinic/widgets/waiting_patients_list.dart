import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/pages/clinic/clinic_tab.dart';

class WaitingPatientsList extends StatefulWidget {
  const WaitingPatientsList({super.key});

  @override
  State<WaitingPatientsList> createState() => _WaitingPatientsListState();
}

class _WaitingPatientsListState extends State<WaitingPatientsList> {
  final TextEditingController search_controller = TextEditingController();

  @override
  void dispose() {
    search_controller.dispose();
    super.dispose();
  }

  DoctorModel? active_doctor;
  List<PatientModel> pending_patient = [];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height - 50;
    active_doctor = AppData.get(context).active_doctor;
    pending_patient = active_doctor?.pen_patients ?? [];

    return Container(
      width: 400,
      height: height,
      decoration: BoxDecoration(),
      padding: EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          // search bar
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(81, 0, 0, 0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextField(
              controller: search_controller,
              onChanged: search_value,
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

          // empty search list
          search_on && search_list.isEmpty
              ? Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(81, 0, 0, 0),
                  ),
                  child: Center(
                    child: Text(
                      'Patient not Found !!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )

              // main list
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: (search_on)
                          ? search_list.map((e) {
                              return client_tile(e);
                            }).toList()
                          : pending_patient.map((e) {
                              return client_tile(e);
                            }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // client tile
  Widget client_tile(PatientModel patient) {
    String name = '${patient.f_name} ${patient.l_name}';

    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(81, 0, 0, 0),
      ),
      child: InkWell(
        onTap: () {
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
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              SizedBox(width: 5),

              // details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // patient id
                    Text(
                      patient.patient_id,
                      style: TextStyle(color: Colors.black87, fontSize: 11),
                    ),

                    // name
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),

              // treatment type
              Text(
                patient.clinic_variables?.case_type ?? '',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool search_on = false;
  List<PatientModel> search_list = [];

  // search value
  search_value(String value) {
    search_on = true;
    search_list.clear();

    if (value.isNotEmpty) {
      search_list = pending_patient
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

    setState(() {});
  }
}
