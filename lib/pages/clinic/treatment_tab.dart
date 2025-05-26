import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/casefile.model.dart';
// import 'package:heritage_soft/datamodels/clinic_models/equipement.model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:heritage_soft/helpers/physio_helpers.dart';
import 'package:heritage_soft/pages/clinic/case_file_page.dart';
import 'package:heritage_soft/pages/clinic/request_accessories_page.dart';
import 'package:heritage_soft/pages/clinic/widgets/clinic_info.dart';
import 'package:heritage_soft/pages/clinic/widgets/physio_hmo_tag.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/pages/clinic/widgets/session_plan_dialog.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class TreatmentTab extends StatefulWidget {
  final PatientModel patient;
  final CaseFileModel case_file;

  const TreatmentTab({
    super.key,
    required this.patient,
    required this.case_file,
  });

  @override
  State<TreatmentTab> createState() => _TreatmentTabState();
}

class _TreatmentTabState extends State<TreatmentTab> {
  final TextEditingController bp_controller = TextEditingController();
  final TextEditingController remarks_controller = TextEditingController();
  final TextEditingController note_controller = TextEditingController();

  String decision_select = '';
  String decision_refered_select = '';
  final TextEditingController other_decision_controller =
      TextEditingController();

  String bp_reading = '';

  TextStyle headingStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  late PatientModel patient;
  late CaseFileModel case_file;

  bool assessment = false;

  late String treatment_duration;

  List<String> selected_case_select_options = [];
  String case_type_select = '';
  String treatment_type_select = 'Out Patient';
  // List<String> selected_equipment_options = [];

  TextEditingController case_select_controller = TextEditingController();
  TextEditingController other_case_controller = TextEditingController();
  // TextEditingController equipment_select_controller = TextEditingController();
  TextEditingController diagnosis_controller = TextEditingController();

  DoctorModel? active_doctor;

  update_controllers() {
    assessment = widget.case_file.case_type == 'Assessment';

    bp_controller.text = case_file.bp_reading;
    remarks_controller.text = case_file.remarks;
    note_controller.text = case_file.note;
    bp_reading = bp_controller.text;

    decision_select = case_file.treatment_decision;
    decision_refered_select = case_file.refered_decision;
    other_decision_controller.text = case_file.other_decision;

    treatment_duration =
        widget.patient.clinic_variables?.treatment_duration ?? '';

    // assessment model
    if (widget.patient.assessment_info.isNotEmpty) {
      AssessmentInfoModel assessmentInfoModel =
          widget.patient.assessment_info.last;

      case_select_controller.text = assessmentInfoModel.case_select;
      selected_case_select_options = case_select_controller.text.split(',');
      diagnosis_controller.text = assessmentInfoModel.diagnosis;
      case_type_select = assessmentInfoModel.case_type;
      treatment_type_select = assessmentInfoModel.treatment_type;
      other_case_controller.text = assessmentInfoModel.case_select_others ?? '';
    }
  }

  // validation
  bool validate_fields() {
    // assessment validation
    if (assessment) {
      if (case_select_controller.text.isEmpty &&
          other_case_controller.text.isEmpty) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Please Select a case',
          icon: Icons.error,
        );
        return false;
      }

      if (diagnosis_controller.text.isEmpty) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Enter Doctor Diagnosis',
          icon: Icons.error,
        );
        return false;
      }

      if (case_type_select.isEmpty) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Select specialization',
          icon: Icons.error,
        );
        return false;
      }

      if (treatment_type_select.isEmpty) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Select treatment type',
          icon: Icons.error,
        );
        return false;
      }

      if (patient.clinic_info?.total_session == 0) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Setup Treatment sessions',
          icon: Icons.error,
        );
        return false;
      }
    }

    if (note_controller.text.isEmpty) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'Notepad cannot be empty',
        icon: Icons.error,
      );
      return false;
    }

    if (decision_select.isEmpty) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'Select a decision',
        icon: Icons.error,
      );
      return false;
    }

    if (decision_select.toLowerCase().contains('refer') &&
        decision_refered_select.isEmpty) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'Decision Incomplete',
        icon: Icons.error,
      );
      return false;
    }

    if (decision_select.toLowerCase().contains('other') &&
        other_decision_controller.text.isEmpty) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'Decision Incomplete',
        icon: Icons.error,
      );
      return false;
    }

    return true;
  }

  // save case file
  Future<bool> save_to_file(bool end_t) async {
    // save assessment data
    if (assessment) {
      AssessmentInfoModel ass = AssessmentInfoModel(
        case_select: case_select_controller.text.trim(),
        diagnosis: diagnosis_controller.text.trim(),
        case_type: case_type_select,
        treatment_type: treatment_type_select,
        equipments: [],
        case_select_others: other_case_controller.text.trim(),
        case_description: '',
        assessment_date: DateTime.now(),
      );

      // save assessment details
      var ass_upd = await ClinicDatabaseHelpers.update_assessment_info(context,
          data: ass.toJson(patientKey: widget.patient.key ?? ''),
          showLoading: true,
          showToast: true);

      if (end_t) {
        if (ass_upd == null || ass_upd['patient_data'] == null) {
          return false;
        }
      }
    }

    // case file data
    CaseFileModel file = CaseFileModel(
      patient: widget.patient,
      treatment_date: case_file.treatment_date,
      bp_reading: bp_reading,
      note: note_controller.text,
      remarks: remarks_controller.text,
      doctor: case_file.doctor,
      case_type: case_file.case_type,
      key: case_file.key,
      start_time: case_file.start_time,
      end_time: end_t ? DateTime.now() : case_file.end_time,
      treatment_decision: decision_select,
      refered_decision: decision_refered_select,
      other_decision: other_decision_controller.text.trim(),
    );

    Map data = file.toJson_update();

    // update case file
    var cas_upd = await ClinicDatabaseHelpers.add_update_case_file(context,
        data: data, showLoading: true, showToast: true);

    if (end_t) {
      if (cas_upd == null || cas_upd['caseFile'] == null) {
        return false;
      }
    }

    return true;
  }

  // end treatement
  end_treatment() async {
    // validate fields
    bool valid = validate_fields();

    if (!valid) return;

    var conf = await Helpers.showConfirmation(
      context: context,
      title: assessment ? 'End Assessment' : 'End Treatment',
      message:
          'You are about to end this ${assessment ? 'assessment' : 'treatment'}, Would you like to proceed?',
    );

    if (conf == false) return;

    // save case file
    bool sav = await save_to_file(true);

    if (!sav) return;

    // treatment details
    TreatmentInfoModel treat =
        widget.patient.treatment_info ?? TreatmentInfoModel.gen();

    treat.last_bp = bp_reading;
    treat.last_treatment_date = DateTime.now();

    // assessment info data
    if (assessment) {
      treat.assessment_completed = true;
      treat.assessment_date = DateTime.now();
      treat.skip_assessment = true;
    }

    // update treatment info
    var tre_upd = await ClinicDatabaseHelpers.update_treatment_info(
      context,
      data: treat.toJson(patientKey: widget.patient.key ?? '', update: true),
      showLoading: true,
      showToast: true,
    );

    if (tre_upd == null || tre_upd['patient_data'] == null) return;

    // update clinic info increase completed sessions
    if (!assessment) {
      ClinicInfoModel cli = patient.clinic_info ?? ClinicInfoModel.gen();
      cli.completed_session++;

      var cli_upd = await ClinicDatabaseHelpers.update_clinic_info(context,
          data: cli.toJson(patientKey: widget.patient.key ?? ''),
          showLoading: true,
          showToast: true);

      if (cli_upd == null || cli_upd['patient_data'] == null) return;
    }

    // update doctor tab with patient && remove from clinic
    var my_pat_upd = await ClinicDatabaseHelpers.end_treatment(
      context,
      patient_key: widget.patient.key ?? '',
      doctor_key: active_doctor?.key ?? '',
      showLoading: true,
      showToast: true,
    );

    if (my_pat_upd)
      // remove page with end of treatment
      Navigator.pop(context, 'done');
  }

  @override
  void initState() {
    patient = widget.patient;
    case_file = widget.case_file;
    update_controllers();

    bp_controller.addListener(() {
      bp_reading = bp_controller.text.trim();
      setState(() {});
    });

    refresh();

    super.initState();
  }

  // refresh page because of countdown
  refresh() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) setState(() {});
      refresh();
    });
  }

  @override
  void dispose() {
    bp_controller.dispose();
    remarks_controller.dispose();
    note_controller.dispose();

    case_select_controller.dispose();
    other_case_controller.dispose();
    // equipment_select_controller.dispose();
    diagnosis_controller.dispose();
    other_decision_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;
    double height = MediaQuery.of(context).size.height * 0.97;
    active_doctor = AppData.get(context).active_doctor;

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
                          'images/treatment.jpg',
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
                    Stack(
                      children: [
                        Column(
                          children: [
                            // main content
                            Expanded(child: main_page()),
                          ],
                        ),

                        // time
                        Positioned(top: 50, left: 0, right: 0, child: time()),
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

  // WIDGETS
  Widget main_page() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          // top bar
          topBar(),

          // profile area
          Padding(
            padding: EdgeInsets.only(left: 20, top: 5, bottom: 0, right: 20),
            child: Row(
              children: [
                profile_area(),
                Expanded(child: Container()),
                treatment_action(),
              ],
            ),
          ),

          // main tab
          Expanded(
            child: !assessment ? treatment_area() : assessment_area(),
          ),

          // doctors name
          Container(
            padding: EdgeInsets.only(right: 12, bottom: 6, top: 8),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'PT ${active_doctor!.user.f_name}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // time
  Widget time() {
    List<String> _timer = PhysioHelpers.update_timer(PhysioHelpers.get_duration(
        treatment_duration: treatment_duration,
        start_time: case_file.start_time!));

    TextStyle time_style = TextStyle(
      color: (int.parse(_timer[1]) < 6 && int.parse(_timer[0]) < 1)
          ? Colors.red
          : Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 25,
    );

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // time left
          Column(
            children: [
              Text(
                'Duration: $treatment_duration',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // hr
                  Container(
                    width: _timer[0].contains('-') ? 50 : 35,
                    child: Center(
                      child: Text(_timer[0], style: time_style),
                    ),
                  ),

                  // seperator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Text(':', style: time_style),
                  ),

                  // min
                  Container(
                    width: _timer[1].contains('-') ? 50 : 35,
                    child: Center(
                      child: Text(_timer[1], style: time_style),
                    ),
                  ),

                  // seperator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Text(':', style: time_style),
                  ),

                  // sec
                  Container(
                    width: _timer[2].contains('-') ? 50 : 35,
                    child: Center(
                      child: Text(_timer[2], style: time_style),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // top bar
  Widget topBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFd1cfcf)),
        ),
      ),
      child: Stack(
        children: [
          // header
          Padding(
            padding: EdgeInsets.only(top: 14, bottom: 8),
            child: Center(
              child: Text(
                !assessment ? 'Treatment Tab' : 'Assessment Tab',
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

          // id area
          Positioned(
            top: 0,
            left: 0,
            child: id_sub_group(),
          ),

          // action buttons
          Positioned(
            top: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // session setup
                  if (assessment && patient.assessment_info.isEmpty)
                    InkWell(
                      onTap: () async {
                        var res = await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => SessionPlanDialog(
                            session_set: false,
                            total_session: null,
                            session_details: {
                              'total_sess':
                                  patient.clinic_info?.total_session ?? 0,
                              'frequency': patient.clinic_info?.frequency ?? '',
                            },
                          ),
                        );

                        if (res != null) {
                          Map r_map = res;

                          int total = r_map['total'];
                          String frequency = r_map['frequency'];

                          ClinicInfoModel cli =
                              patient.clinic_info ?? ClinicInfoModel.gen();
                          cli.total_session = total;
                          cli.frequency = frequency;
                          Map data = cli.toJson(patientKey: patient.key ?? '');

                          // update price per session
                          var resp =
                              await ClinicDatabaseHelpers.update_clinic_info(
                                  context,
                                  data: data,
                                  showLoading: true,
                                  showToast: true);

                          if (resp != null && resp['patient_data'] != null) {
                            ClinicHistoryModel hist = ClinicHistoryModel(
                              hist_type: 'Session setup',
                              amount: 0,
                              amount_b4_discount: 0,
                              date: DateTime.now(),
                              session_paid: total,
                              history_id: Helpers.generate_order_id(),
                              cost_p_session: 0,
                              old_float: 0,
                              new_float: 0,
                              session_frequency: frequency,
                            );

                            ClinicDatabaseHelpers.update_clinic_history(
                              context,
                              data: hist.toJson(patientKey: patient.key ?? ''),
                            );
                          }

                          setState(() {});
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 13, vertical: 4),
                        child: Text('Session Setup'),
                      ),
                    ),

                  // case history
                  if (!assessment)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => CaseFileD(
                              patient: widget.patient,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.folder,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),

                  // options
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: options_menu(
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // close button
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () async {
                        await save_to_file(false);

                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.cancel,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // more options
  Widget options_menu({required child}) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(0),
      offset: Offset(0, 30),
      child: child,
      elevation: 8,
      onSelected: (value) async {
        // health details
        // if (value == 1) {
        //   }

        // request accessories
        if (value == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestAccessoriesPage(
                patient: widget.patient,
              ),
            ),
          );
        }

        // clinic info page
        if (value == 3) {
          if (widget.patient.assessment_info.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => ClinicInfo(
                info: widget.patient.assessment_info.last,
                patient: widget.patient,
              ),
            );
          }
        }
      },
      itemBuilder: (context) => [
        // health details
        PopupMenuItem(
          value: 1,
          child: Container(
            child: Row(
              children: [
                Icon(Icons.health_and_safety),
                SizedBox(width: 8),
                Text(
                  'Health details',
                  style: TextStyle(),
                ),
              ],
            ),
          ),
        ),

        // accessories
        PopupMenuItem(
          value: 2,
          child: Container(
            child: Row(
              children: [
                Icon(Icons.shopping_bag),
                SizedBox(width: 8),
                Text(
                  'Request Accessories',
                  style: TextStyle(),
                ),
              ],
            ),
          ),
        ),

        // clinic info
        if (!assessment)
          PopupMenuItem(
            value: 3,
            child: Container(
              child: Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 8),
                  Text(
                    'Treatment protocol',
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
          ),

        // PopupMenuDivider(),
      ],
    );
  }

  // id & hmo
  Widget id_sub_group() {
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label
          Text(
            'ID',
            style: TextStyle(
              color: Color(0xFFAFAFAF),
              fontSize: 14,
              letterSpacing: 1,
              height: 1,
            ),
          ),

          // id group
          Row(
            children: [
              // client id
              Text(
                widget.patient.patient_id,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1,
                  height: 0.8,
                  shadows: [
                    Shadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),

              // hmo tag
              PhysioHMOTag(hmo: widget.patient.hmo),
            ],
          ),
        ],
      ),
    );
  }

  // profile
  Widget profile_area() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Stack(
        children: [
          // name container
          Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF888570).withOpacity(0.66),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.fromLTRB(33, 6, 10, 6),
              child: Text(
                '${widget.patient.f_name.trim()} ${widget.patient.l_name.trim()}',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // profile image
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFf3f0da),
              foregroundColor: Colors.white,
              backgroundImage: widget.patient.user_image.isNotEmpty
                  ? NetworkImage(
                      widget.patient.user_image,
                    )
                  : null,
              child: Center(
                child: widget.patient.user_image.isEmpty
                    ? Image.asset(
                        'images/icon/health-person.png',
                        width: 25,
                        height: 25,
                      )
                    : Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // treatment actions
  Widget treatment_action() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(width: 10),

          // end treatment
          InkWell(
            onTap: () {
              end_treatment();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              height: 30,
              width: 155,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.stop,
                      size: 25,
                      color: Colors.white,
                    ),
                    SizedBox(width: 2),
                    Text(
                      assessment ? 'End Assessment' : 'End Treatment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // assessment area
  Widget assessment_area() {
    if (selected_case_select_options.isNotEmpty)
      case_select_controller.text = selected_case_select_options.join(',');
    else
      case_select_controller.text = '';

    if (case_select_controller.text.startsWith(',')) {
      case_select_controller.text =
          case_select_controller.text.replaceFirst(',', '');
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        children: [
          // left
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // case multi-select
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text_field(
                      label: 'Select Medical condition',
                      controller: case_select_controller,
                      edit: true,
                      icon: case_multi_select(
                        child: Icon(
                          Icons.select_all,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // other case
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text_field(
                      label: 'Enter other condition(s)',
                      controller: other_case_controller,
                      font_size: 15,
                    ),
                  ),

                  // diagnosis
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text_field(
                      label: 'PT Diagnosis',
                      controller: diagnosis_controller,
                      maxLine: 2,
                      font_size: 14,
                    ),
                  ),

                  // case type
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    // width: 100,
                    child: Select_form(
                      label: 'Specialization',
                      options: case_type_options,
                      text_value: case_type_select,
                      setval: (val) {
                        case_type_select = val;
                        setState(() {});
                      },
                    ),
                  ),

                  // treatment type
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    // width: 100,
                    child: Select_form(
                      label: 'Treatment type',
                      options: treatment_type_options,
                      text_value: treatment_type_select,
                      setval: (val) {
                        treatment_type_select = val;
                        setState(() {});
                      },
                    ),
                  ),

                  // // equipment
                  // Container(
                  //   padding: EdgeInsets.symmetric(vertical: 6),
                  //   child: Text_field(
                  //     label: 'Equipment',
                  //     controller: equipment_select_controller,
                  //     edit: true,
                  //     icon: equipment_multi_select(
                  //       child: Icon(
                  //         Icons.select_all,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          SizedBox(width: 60),

          // right
          Expanded(
            flex: 6,
            child: Column(
              children: [
                bp_display(),

                // note box
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // current bp textfield
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // bp textfield
                                Container(
                                  width: 160,
                                  child: Text_field(
                                    label: !assessment
                                        ? 'Current B.P Reading'
                                        : 'B.P Reading',
                                    controller: bp_controller,
                                  ),
                                ),

                                SizedBox(width: 6),

                                InkWell(
                                  onTap: () {
                                    bp_reading = bp_controller.text.trim();
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    height: 40,
                                    width: 43,
                                    child: Center(
                                      child: Icon(
                                        Icons.done_all,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // notepad
                        notePad(),

                        SizedBox(height: 20),

                        decision_area(),
                      ],
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

  // treatment area
  Widget treatment_area() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // pt diagnosis
          if (widget.patient.assessment_info.isNotEmpty &&
              widget.patient.assessment_info.last.diagnosis.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
              child: Text(
                widget.patient.assessment_info.last.diagnosis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // main box
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 6),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // actions
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(child: left_area()),
                        ),

                        SizedBox(width: 60),

                        // BP && note
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                bp_display(),

                                SizedBox(height: 10),

                                // current bp textfield
                                Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // bp textfield
                                      Container(
                                        width: 160,
                                        child: Text_field(
                                          label: !assessment
                                              ? 'Current B.P Reading'
                                              : 'B.P Reading',
                                          controller: bp_controller,
                                        ),
                                      ),

                                      SizedBox(width: 6),

                                      InkWell(
                                        onTap: () {
                                          bp_reading =
                                              bp_controller.text.trim();
                                          setState(() {});
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          height: 40,
                                          width: 43,
                                          child: Center(
                                            child: Icon(
                                              Icons.done_all,
                                              size: 25,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 20),

                                notePad(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SizedBox(height: 10),
        ],
      ),
    );
  }

  // action area
  Widget left_area() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),

          // previous B.P with date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // previous bp (2 bp reading back)
              if (widget.patient.treatment_info?.last_bp_p.isNotEmpty ?? false)
                Row(
                  children: [
                    Text(
                      'Previous B.P Reading:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      widget.patient.treatment_info!.last_bp_p != '0'
                          ? widget.patient.treatment_info!.last_bp_p
                          : 'Not recorded',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

              //  previous bp (2 bp reading back) date
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  widget.patient.treatment_info?.last_treatment_date_p != null
                      ? Helpers.date_format(
                          widget.patient.treatment_info!.last_treatment_date_p!)
                      : '',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              SizedBox(height: 6),

              // last bp reading
              Row(
                children: [
                  Text(
                    'Last B.P Reading:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    widget.patient.treatment_info?.last_bp != '0'
                        ? widget.patient.treatment_info?.last_bp ?? ''
                        : 'Not recorded',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // last bp reading date
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  widget.patient.treatment_info?.last_treatment_date != null
                      ? Helpers.date_format(
                          widget.patient.treatment_info!.last_treatment_date!)
                      : '',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          // decision area & remarks
          decision_area(),
        ],
      ),
    );
  }

  // bp text
  Widget bp_display() {
    return Row(
      children: [
        // label
        Text(
          'Current B.P Reading:',
          style: TextStyle(
            // fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white70,
          ),
        ),

        SizedBox(width: 6),

        // value
        Text(
          bp_reading,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),

        Expanded(child: Container()),

        // date
        Text(
          Helpers.date_format(DateTime.now()),
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  // notepad
  Widget notePad() {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 5),
          // label
          Text(
            'NOTEPAD',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),

          SizedBox(height: 2),

          // note
          Text_field(
            label: '',
            controller: note_controller,
            is_filled: true,
            fill_color: Colors.black38,
            maxLine: 16,
            font_size: 12,
            top_border_only: true,
          ),

          // action bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
              color: Color.fromARGB(255, 240, 193, 123),
            ),
            width: double.infinity,
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                8,
                (index) => Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // decison & remarks
  Widget decision_area() {
    return Container(
      child: Column(
        children: [
          // decision select
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            // width: 100,
            child: Row(
              children: [
                // main decision
                Expanded(
                  flex: 6,
                  child: Select_form(
                    label: 'Treatment Decision',
                    options: assessment
                        ? assessment_decision_select_options
                        : treatment_decision_select_options,
                    text_value: decision_select,
                    setval: (val) {
                      decision_select = val;
                      setState(() {});
                    },
                  ),
                ),

                SizedBox(width: 20),

                // refer decision
                Expanded(
                  flex: 6,
                  child: // refered decision
                      (decision_select.toLowerCase().contains('refer'))
                          ? Container(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              // width: 100,
                              child: Select_form(
                                label: 'Refer to',
                                options: decision_refered_options,
                                text_value: decision_refered_select.isEmpty
                                    ? 'Select'
                                    : decision_refered_select,
                                setval: (val) {
                                  decision_refered_select = val;
                                  setState(() {});
                                },
                              ),
                            )
                          : Container(),
                )
              ],
            ),
          ),

          // other decision
          if (decision_select.toLowerCase().contains('other'))
            Container(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text_field(
                controller: other_decision_controller,
                hintText: 'Specify others',
              ),
            ),

          SizedBox(height: 10),

          // remarks
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text_field(
              label: 'Remarks',
              controller: remarks_controller,
              is_filled: true,
              fill_color: Colors.black38,
              maxLine: 5,
              font_size: 14,
            ),
          ),
        ],
      ),
    );
  }

  // case select
  Widget case_multi_select({required child}) {
    case_select_options.sort((a, b) => a.compareTo(b));

    return PopupMenuButton<String>(
        padding: EdgeInsets.all(0),
        offset: Offset(0, 30),
        child: child,
        elevation: 8,
        onSelected: (value) async {
          final old_val = selected_case_select_options.join(', ');
          bool is_in = selected_case_select_options.contains(value);

          if (is_in) {
            selected_case_select_options.remove(value);
          } else {
            selected_case_select_options.add(value);
          }

          if (diagnosis_controller.text.isEmpty ||
              diagnosis_controller.text == old_val) {
            diagnosis_controller.text = selected_case_select_options.join(', ');
          }

          setState(() {});
        },
        itemBuilder: (context) => case_select_options.map((e) {
              bool is_in = selected_case_select_options.contains(e);

              return PopupMenuItem(
                padding: EdgeInsets.all(0),
                value: e,
                child: Container(
                  width: double.infinity,
                  height: kMinInteractiveDimension,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: is_in ? Colors.red.shade100 : Colors.blue.shade50,
                  ),
                  child: Text(
                    e,
                    style: TextStyle(),
                  ),
                ),
              );
            }).toList());
  }

  //
}
