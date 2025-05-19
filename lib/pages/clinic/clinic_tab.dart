import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/casefile.model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:heritage_soft/helpers/physio_helpers.dart';
import 'package:heritage_soft/helpers/server_helpers.dart';
import 'package:heritage_soft/pages/clinic/case_file_page.dart';
import 'package:heritage_soft/pages/clinic/doctors_list.dart';
import 'package:heritage_soft/pages/clinic/clinic_history_page.dart';
import 'package:heritage_soft/pages/clinic/patient_pofile_page.dart';
import 'package:heritage_soft/pages/clinic/print.page.dart';
import 'package:heritage_soft/pages/clinic/request_accessories_page.dart';
import 'package:heritage_soft/pages/clinic/treatment_tab.dart';
import 'package:heritage_soft/pages/clinic/widgets/full_session_details.dart';
import 'package:heritage_soft/pages/clinic/widgets/session_payment_dialog.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/options_dialog.dart';
import 'package:heritage_soft/pages/clinic/widgets/physio_hmo_tag.dart';
import 'package:heritage_soft/pages/clinic/widgets/session_plan_dialog.dart';
import 'package:heritage_soft/pages/clinic/widgets/clinic_info.dart';
import 'package:heritage_soft/widgets/text_field.dart';

import 'package:intl/intl.dart';

class ClinicTab extends StatefulWidget {
  final PatientModel patient;
  const ClinicTab({super.key, required this.patient});

  @override
  State<ClinicTab> createState() => _ClinicTabState();
}

class _ClinicTabState extends State<ClinicTab> {
  TextStyle headingStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  bool can_treat = true;

  bool assessment_completed = false;
  bool ongoing_treatment = false;
  bool assessment_paid = false;

  TreatmentInfoModel? treatmentModel;
  AssessmentInfoModel? assessmentModel;
  PhysioPaymentPrintModel? assessment_print;
  //?
  bool skip_assessment = false;

  late PatientModel patient;
  UserModel? active_user;
  DoctorModel? active_doctor;

  String? case_type;

  bool run_timer = false;

  bool isLoading = false;

  void get_patient(PatientModel pat) {
    var patt = AppData.get(context).patients.where((p) => p.key == pat.key);

    if (active_user != null && active_user!.app_role != 'Doctor') if (patt
        .isNotEmpty) {
      patient = patt.first;
    }

    get_treatment_info();
    get_assessment();
    get_variables();

    if (mounted) setState(() {});
  }

  // stream clinin variables
  get_variables() {
    can_treat = patient.current_doctor?.key == active_doctor?.key;
    case_type = patient.clinic_variables?.case_type;
    run_timer = patient.current_case_id != null &&
        patient.clinic_variables?.start_time != null;
  }

  // stream treatment info
  get_treatment_info() {
    if (patient.treatment_info != null) {
      // ongoing treatment
      ongoing_treatment = patient.current_case_id != null;

      // assessment paid
      assessment_paid = patient.treatment_info?.assessment_paid ?? false;

      //? skip_assessment
      skip_assessment = patient.treatment_info?.skip_assessment ?? false;

      // treatment model
      treatmentModel = patient.treatment_info;
    } else {
      treatmentModel = null;
      ongoing_treatment = false;
    }
  }

  // assessment stream
  get_assessment() {
    if (patient.assessment_info.isNotEmpty) {
      assessment_completed = true;
      assessmentModel = patient.assessment_info.last;
    } else {
      assessment_completed = false;
    }
  }

  dynamic doc_patient_stream(dynamic data) async {
    PatientModel pat = PatientModel.fromMap(data);

    if (widget.patient.key == pat.key) if (mounted)
      setState(() {
        patient = pat;
      });
  }

  fetch_patient() async {
    isLoading = true;
    var get_pat = await ClinicDatabaseHelpers.get_patient_by_id(context,
        patient_key: widget.patient.key ?? '');
    isLoading = false;
    if (get_pat != null) {
      patient = get_pat;
    }
  }

  @override
  void initState() {
    patient = widget.patient;

    active_user = AppData.get(context, listen: false).active_user;
    if (active_user != null && active_user?.app_role == 'Doctor') {
      fetch_patient();
      ServerHelpers.socket!.on('Patient', (data) {
        doc_patient_stream(data);
      });
    }

    refresh();
    super.initState();
  }

  @override
  void dispose() {
    if (active_user != null && active_user?.app_role == 'Doctor')
      ServerHelpers.socket!.off('Patient');
    super.dispose();
  }

  // constantly update UI because of Timer
  refresh() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) setState(() {});
      if (run_timer) refresh();
    });
  }

  // time countdown
  Widget time() {
    if (patient.clinic_variables?.start_time == null) return Container();

    // get current Time count
    List<String> _timer = PhysioHelpers.update_timer(PhysioHelpers.get_duration(
        treatment_duration: patient.clinic_variables?.treatment_duration ?? '',
        start_time: patient.clinic_variables?.start_time ?? DateTime.now()));

    TextStyle time_style = TextStyle(
      color: (int.parse(_timer[1]) < 6 && int.parse(_timer[0]) < 1)
          ? Colors.red
          : Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // time
          Column(
            children: [
              // Duration (only for CSU user)
              if (active_user!.app_role == 'CSU' ||
                  active_user!.app_role == 'ICT')
                Text(
                  'Duration: ${patient.clinic_variables?.treatment_duration}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

              // countdown
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

  @override
  Widget build(BuildContext context) {
    active_user = AppData.get(context).active_user;
    active_doctor = AppData.get(context).active_doctor;
    get_patient(patient);

    double width = MediaQuery.of(context).size.width * 0.8;
    double height = MediaQuery.of(context).size.height * 0.7;
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
              decoration: BoxDecoration(color: Color(0x55e0d9d2)),
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

  // WIDGETS
  Widget main_page() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          // top bar
          topBar(),

          // profile area & session & billing setup
          if (!isLoading) patient_data(),

          // session info area
          Expanded(
              child: Center(
                  child: (isLoading)
                      ? CircularProgressIndicator()
                      : session_tab())),

          if (!isLoading) SizedBox(height: 30),

          // action tab
          if (!isLoading)
            Padding(
              padding: EdgeInsets.all(12),
              child: action_tab(),
            ),
        ],
      ),
    );
  }

  //

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
          // heading
          Padding(
            padding: EdgeInsets.only(top: 14, bottom: 8),
            child: Center(
              child: Text(
                'Clinic Tab',
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
                  // sub history
                  if (active_user!.app_role != 'Doctor')
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: InkWell(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClinicHistoryPage(patient: patient),
                            ),
                          );
                        },
                        child: Image.asset(
                          'images/icon/sentiayoga.png',
                          width: 21,
                          height: 21,
                        ),
                      ),
                    ),

                  // session details
                  if (active_user!.app_role != 'Doctor')
                    if (patient.clinic_info != null &&
                        assessmentModel != null &&
                        assessment_completed)
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: InkWell(
                          onTap: () {
                            Map map = {
                              'total_session':
                                  patient.clinic_info!.total_session,
                              'frequency': patient.clinic_info!.frequency,
                              'utilized_session':
                                  patient.clinic_info!.completed_session,
                              'paid_session': patient.clinic_info!.paid_session,
                              'amount_paid': patient.clinic_info!.amount_paid,
                              'cost_p_session':
                                  patient.clinic_info!.cost_per_session,
                              'floating_amount':
                                  patient.clinic_info!.floating_amount,
                            };

                            showDialog(
                              context: context,
                              builder: (context) => SessionDetailsDialog(
                                session_details: map,
                                patient: patient,
                              ),
                            );
                          },
                          child: Icon(
                            Icons.line_style,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),

                  // clinic info
                  if (assessmentModel != null && assessment_completed)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ClinicInfo(
                              info: assessmentModel!,
                              patient: patient,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.info,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),

                  // case history
                  if (assessment_completed)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          if (treatmentModel == null) return;

                          if (!assessment_completed) return;

                          if (assessmentModel == null) return;

                          showDialog(
                            context: context,
                            builder: (context) => CaseFileD(
                              patient: patient,
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

                  // request accessories (doctor only)
                  if (((active_user!.app_role == 'Doctor') && can_treat) ||
                      active_user!.full_access)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestAccessoriesPage(
                                patient: patient,
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),

                  SizedBox(height: 10),

                  // close button
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
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
                patient.patient_id,
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
              PhysioHMOTag(hmo: patient.hmo),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientProfilePage(
                patient: patient,
                from_clinic: true,
              ),
            ),
          );
        },
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
                  '${patient.f_name} ${patient.l_name}',
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
                backgroundImage: patient.user_image.isNotEmpty
                    ? NetworkImage(
                        patient.user_image,
                      )
                    : null,
                child: Center(
                  child: patient.user_image.isEmpty
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
      ),
    );
  }

  TextStyle title_style = TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );

  TextStyle value_style = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  TextStyle action_style = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  // profile area || clinic & billing setup
  Widget patient_data() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          profile_area(),

          //?
          if (active_user!.app_role == 'Doctor' ||
              active_user!.app_role == 'CSU' ||
              active_user!.full_access)
            if (!skip_assessment &&
                (patient.clinic_variables?.case_type != 'Assessment'))
              InkWell(
                onTap: () async {
                  var res = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ClinicInfo(
                      info: assessmentModel ?? null,
                      new_det: true,
                      patient: patient,
                    ),
                  );

                  if (res != null) {
                    AssessmentInfoModel ass = res;
                    ass.assessment_date = DateTime.now();
                    Map data = ass.toJson(patientKey: patient.key ?? '');

                    // save assessment details
                    await ClinicDatabaseHelpers.update_assessment_info(
                      context,
                      data: data,
                      showToast: true,
                      showLoading: true,
                      loadingText: 'Updating Assessment info...',
                    );

                    // update treatment info
                    TreatmentInfoModel tre =
                        patient.treatment_info ?? TreatmentInfoModel.gen();
                    tre.skip_assessment = true;

                    await ClinicDatabaseHelpers.update_treatment_info(
                      context,
                      data: tre.toJson(
                          patientKey: patient.key ?? '', update: false),
                      loadingText: 'Updating Treatment info...',
                      showToast: true,
                      showLoading: true,
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  child: Text('Skip Assessment'),
                ),
              ),

          // session setup
          clinic_options(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Text(active_user!.app_role == 'Doctor'
                  ? 'Session setup'
                  : 'Clinic options'),
            ),
          ),
        ],
      ),
    );
  }

  // session tab
  Widget session_tab() {
    int total_session = patient.clinic_info?.total_session ?? 0;
    String frequency = patient.clinic_info?.frequency ?? '';
    int paid_session = patient.clinic_info?.paid_session ?? 0;
    int completed_session = patient.clinic_info?.completed_session ?? 0;
    int cost_per_session = patient.clinic_info?.cost_per_session ?? 0;
    int active_sess = paid_session - completed_session;
    int amount_paid = patient.clinic_info?.amount_paid ?? 0;
    int balance = total_session - completed_session;
    int current_cost = cost_per_session * (total_session - paid_session);

    // assessment not yet completed
    if (!assessment_completed)
      return Container(
        child: Text(
          'Pending Assessment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );

    // assessment completed
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // title
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'Treatment Sessions',
              style: headingStyle,
            ),
          ),

          SizedBox(height: 20),

          // values (1st row)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // no of session
              session_info_tile(
                  label: 'Total Sessions', value: total_session.toString()),

              // frequency
              session_info_tile(label: 'Frequency', value: frequency),

              // Utilized
              session_info_tile(
                  label: 'Utilized', value: completed_session.toString()),

              // balance
              if (active_user?.app_role != 'Doctor')
                session_info_tile(
                    label: 'Sessions Left', value: balance.toString()),
            ],
          ),

          SizedBox(height: 20),

          // values (2nd row)
          Row(
            mainAxisAlignment: (active_user!.app_role != 'Doctor')
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.center,
            children: [
              // total cost
              if (active_user!.app_role != 'Doctor')
                session_info_tile(
                    label: 'Current cost',
                    value: Helpers.format_amount(current_cost, naira: true)),

              if (active_user!.app_role != 'Doctor')
                // total paid
                session_info_tile(
                    label: 'Amount paid',
                    value: Helpers.format_amount(amount_paid, naira: true)),

              // paid
              if (active_user?.app_role != 'Doctor')
                session_info_tile(
                    label: 'Session Paid', value: paid_session.toString())
              else
                session_info_tile(
                    label: 'Sessions Left', value: balance.toString()),

              if (active_user!.app_role == 'Doctor') SizedBox(width: 150),

              // active
              session_info_tile(
                  label: 'Active Session', value: active_sess.toString()),
            ],
          )
        ],
      ),
    );
  }

  // session info tile
  Widget session_info_tile({required String label, required String value}) {
    return Column(
      children: [
        // title
        Text(label, style: title_style),
        SizedBox(height: 2),
        Text(value, style: value_style),
      ],
    );
  }

  // action tab
  Widget action_tab() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ///? TAB 1
          // (CSU user only)
          if (active_user!.app_role == 'CSU' || active_user!.app_role == 'ICT')
            // session payment
            InkWell(
              onTap: () async {
                // if session info not set
                if (patient.clinic_info == null
                    // && patient.clinic_info!.total_session == 0
                    ) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Setup Clinic',
                    icon: Icons.error,
                  );
                  return;
                }

                // if billing not set
                if (patient.clinic_info?.cost_per_session == 0) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Setup a billing Plan',
                    icon: Icons.error,
                  );
                  return;
                }

                var old_float = patient.clinic_info?.floating_amount;

                // session plan dialog for payment
                var res = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => SessionPaymentDialog(
                    session_details: {
                      'cost_p_session': patient.clinic_info?.cost_per_session,
                      'total_session': patient.clinic_info?.total_session,
                      'session_paid': patient.clinic_info?.paid_session,
                      'amount_paid': patient.clinic_info?.amount_paid,
                      'floating_amount': patient.clinic_info?.floating_amount,
                    },
                  ),
                );

                if (res != null) {
                  int amount_paid = res['discounted_amount'];
                  int amount_b4_discount = res['amount_to_pay'];
                  int new_session = res['new_session'];

                  var new_float = res['floating_amount'];

                  // update paid session
                  ClinicInfoModel cli =
                      patient.clinic_info ?? ClinicInfoModel.gen();
                  cli.amount_paid = res['total_amount'];
                  cli.paid_session = res['total_active_session'];
                  cli.floating_amount = res['floating_amount'];

                  Map data = cli.toJson(patientKey: patient.key ?? '');

                  // update price per session
                  var resp = await ClinicDatabaseHelpers.update_clinic_info(
                      context,
                      data: data,
                      showLoading: true,
                      showToast: true);

                  if (resp != null && resp['patient_data'] != null) {
                    ClinicHistoryModel hist = ClinicHistoryModel(
                      hist_type: 'Session payment',
                      amount: amount_paid,
                      amount_b4_discount: amount_b4_discount,
                      date: DateTime.now(),
                      session_paid: new_session,
                      history_id: Helpers.generate_order_id(),
                      cost_p_session:
                          patient.clinic_info?.cost_per_session ?? 0,
                      old_float: old_float ?? 0,
                      new_float: new_float,
                      session_frequency: '',
                    );

                    ClinicDatabaseHelpers.update_clinic_history(
                      context,
                      data: hist.toJson(patientKey: patient.key ?? ''),
                    );

                    var printt = await Helpers.showConfirmation(
                      context: context,
                      title: 'Print Receipt',
                      message:
                          'Would you like to print receipt for this payment',
                    );

                    if (printt) {
                      //? print
                      PhysioPaymentPrintModel printModel =
                          PhysioPaymentPrintModel(
                        date:
                            '${DateFormat.jm().format(hist.date)} ${DateFormat('dd-MM-yyyy').format(hist.date)}',
                        receipt_id: hist.history_id,
                        client_id: patient.patient_id,
                        client_name: '${patient.f_name} ${patient.l_name}',
                        amount: hist.amount,
                        receipt_type: hist.hist_type,
                        session_paid: hist.session_paid,
                        amount_b4_discount: hist.amount_b4_discount ?? 0,
                        cost_p_session: hist.cost_p_session.toInt(),
                        old_float: hist.old_float.toInt(),
                        new_float: hist.new_float.toInt(),
                      );

                      await showDialog(
                          context: context,
                          builder: (context) =>
                              PhysioPrintPage(payment_print: printModel));
                    }
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade400.withOpacity(.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Center(
                  child: Text(
                    'Session Payment',
                    style: action_style,
                  ),
                ),
              ),
            )

          // (doctor only) (if doctor can treat)
          else if ((active_user!.app_role == 'Doctor') && can_treat)
            // treatment duration
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    patient.clinic_variables?.case_type ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' - ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    patient.clinic_variables?.treatment_duration ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          ///?

          ///? TAB 2
          // (CSU user only)
          if (active_user!.app_role == 'CSU' || active_user!.app_role == 'ICT')
            // send to clinic
            if (patient.current_case_id == null &&
                patient.current_doctor == null)
              InkWell(
                onTap: () async {
                  send_to_clinic(treatment_type: 'Treatment');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.shade400.withOpacity(.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Center(
                    child: Text('Send to Clinic', style: action_style),
                  ),
                ),
              )
            else
              // Awaiting doctor/ Duration
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (patient.current_case_id == null)
                          ? 'Awaiting Doctor - ${patient.clinic_variables?.case_type ?? ''}'
                          : patient.clinic_variables?.treatment_duration ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (patient.current_case_id == null) SizedBox(height: 2),
                    if (patient.current_case_id == null)
                      Text(
                        'PT - ${patient.current_doctor?.user.f_name ?? ''}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              )

          // (Doctor only && can treat)
          // treatment countdoun
          else if ((active_user!.app_role == 'Doctor') && can_treat)
            if (patient.current_case_id != null) time() else Container()
          else
            Container(),

          ///

          /// Tab 3
          // doctor's action (if doctor can treat)
          if ((active_user!.app_role == 'Doctor') && can_treat)
            InkWell(
              onTap: () async {
                // session plan not set
                if ((patient.clinic_info == null ||
                        patient.clinic_info?.total_session == 0) &&
                    patient.clinic_variables?.case_type != 'Assessment') {
                  Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Setup a treatment plan',
                    icon: Icons.error,
                  );
                  return;
                }

                if (patient.current_case_id == null) {
                  // treatment ended
                  var res = await ClinicDatabaseHelpers.get_case_file_by_date(
                      context,
                      patient_id: patient.key ?? '',
                      treatment_date: DateTime.now(),
                      showLoading: true);

                  if (res != null && res.isNotEmpty) if (ClinicDatabaseHelpers
                      .check_cases_by_type(
                          cases: res,
                          case_type: patient.clinic_variables?.case_type ??
                              'Treatment')) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Treatment done today',
                      icon: Icons.error,
                    );
                    return;
                  }
                }

                if (patient.current_case_id == null) {
                  var conf = await Helpers.showConfirmation(
                      context: context,
                      title:
                          'Go To ${patient.clinic_variables?.case_type ?? ''} Tab',
                      message:
                          'You are about to open the ${patient.clinic_variables?.case_type.toLowerCase() ?? ''} tab for this client, Would you like to proceed?',
                      barrierDismissible: true);

                  if (conf) {
                    start_treatment(
                        case_type:
                            patient.clinic_variables?.case_type ?? 'Treatment');
                  }
                } else
                  start_treatment(
                      case_type:
                          patient.clinic_variables?.case_type ?? 'Treatment');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade400.withOpacity(.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Center(
                  child: Text(treatment_action_title(), style: action_style),
                ),
              ),
            )

          // CSU user action
          else if (active_user!.app_role == 'CSU' ||
              active_user!.app_role == 'ICT')
            // treatmnet countdown
            if (patient.current_case_id != null)
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ongoing ${patient.clinic_variables?.case_type ?? ''}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        time(),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      'PT - ${patient.current_doctor?.user.f_name ?? ''}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              )

            // pending treatment
            else if (patient.current_doctor != null)
              Row(
                children: [
                  // treatment duration
                  InkWell(
                    onTap: () async {
                      var conf = await showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                          title: 'Change Treatment Duration',
                          subtitle:
                              'You are about to change the duration of the current session for this client. Would you like to proceed?',
                        ),
                      );

                      if (conf == null || !conf) return;

                      var dur = await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => OptionsDialog(
                          title: 'Select Duration',
                          options: treatment_time,
                        ),
                      );

                      if (dur == null) return;
                      String treatment_duration = dur;

                      // change treatment duration
                      await ClinicDatabaseHelpers.change_treatment_duration(
                        context,
                        doctor_key: patient.current_doctor?.key ?? '',
                        patient_key: patient.key ?? '',
                        treatment_type:
                            patient.clinic_variables?.case_type ?? '',
                        treatment_duration: treatment_duration,
                        showLoading: true,
                        showToast: true,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Center(
                        child: Text(
                            patient.clinic_variables?.treatment_duration ??
                                'No Duration',
                            style: action_style),
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // remove from clinic
                  InkWell(
                    onTap: () async {
                      var conf = await Helpers.showConfirmation(
                        context: context,
                        title: 'Remove From Clinic',
                        message:
                            'You are about to remove this patient from the waiting list of the doctors. Would you like to proceed?',
                        barrierDismissible: true,
                      );

                      if (!conf) return;

                      await ClinicDatabaseHelpers.remove_from_clinic(
                        context,
                        doctor_key: patient.current_doctor?.key ?? '',
                        patient_key: patient.key ?? '',
                        treatment_type:
                            patient.clinic_variables?.case_type ?? '',
                        treatment_duration:
                            patient.clinic_variables?.treatment_duration ?? '',
                        showLoading: true,
                        showToast: true,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400.withOpacity(.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Center(
                        child: Text('Remove from Clinic', style: action_style),
                      ),
                    ),
                  ),
                ],
              )
            else
              InkWell(
                onTap: () async {
                  bool conf = await Helpers.showConfirmation(
                    context: context,
                    title: 'Send for Assessment',
                    message:
                        'Would you like to send this oatient for assessment',
                  );

                  if (conf) {
                    // send to clinic
                    send_to_clinic(treatment_type: 'Assessment');
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Center(
                    child: Text('Send for Assessment', style: action_style),
                  ),
                ),
              )
          else
            Container(),

          ///
        ],
      ),
    );
  }

  // doctor treatment action title
  String treatment_action_title() {
    if (patient.current_case_id != null)
      return 'Continue ${case_type}';
    else
      return 'Start ${case_type}';
  }

  // session setup pop up menu
  Widget clinic_options({required child}) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(0),
      offset: Offset(0, 30),
      child: child,
      elevation: 8,
      onSelected: (value) async {
        // session plan
        if (value == 1) {
          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SessionPlanDialog(
              session_set: (patient.clinic_info != null &&
                  patient.clinic_info?.total_session != 0),
              total_session: (patient.clinic_info?.total_session != 0)
                  ? patient.clinic_info?.total_session.toString()
                  : null,
            ),
          );

          if (res != null) {
            Map r_map = res;

            int total = r_map['total'];
            String frequency = r_map['frequency'];

            ClinicInfoModel cli = patient.clinic_info ?? ClinicInfoModel.gen();
            cli.total_session = total;
            cli.frequency = frequency;
            Map data = cli.toJson(patientKey: patient.key ?? '');

            // update price per session
            var resp = await ClinicDatabaseHelpers.update_clinic_info(context,
                data: data, showLoading: true, showToast: true);

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
          }
        }

        // add sessions
        if (value == 2) {
          if (patient.clinic_info?.total_session == 0) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Setup a Session Plan',
              icon: Icons.error,
            );
            return;
          }

          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SessionPlanDialog(
              session_set: (patient.clinic_info?.total_session != 0),
              add_session: true,
              session_details: {
                'total_sess': patient.clinic_info?.total_session.toString(),
                'frequency': patient.clinic_info?.frequency,
              },
            ),
          );

          if (res != null) {
            int new_sess = res;
            int added = new_sess - (patient.clinic_info?.total_session ?? 0);

            ClinicInfoModel cli = patient.clinic_info ?? ClinicInfoModel.gen();
            cli.total_session = new_sess;
            Map data = cli.toJson(patientKey: patient.key ?? '');

            // update price per session
            var resp = await ClinicDatabaseHelpers.update_clinic_info(context,
                data: data, showLoading: true, showToast: true);

            if (resp != null && resp['patient_data'] != null) {
              ClinicHistoryModel hist = ClinicHistoryModel(
                hist_type: 'Session added',
                amount: added,
                amount_b4_discount: 0,
                date: DateTime.now(),
                session_paid: new_sess,
                history_id: Helpers.generate_order_id(),
                cost_p_session: 0,
                old_float: 0,
                new_float: 0,
                session_frequency: '',
              );

              ClinicDatabaseHelpers.update_clinic_history(
                context,
                data: hist.toJson(patientKey: patient.key ?? ''),
              );
            }
          }
        }

        // billing setup
        if (value == 3) {
          int total_session = patient.clinic_info?.total_session ?? 0;
          int cost_per_session = patient.clinic_info?.cost_per_session ?? 0;
          int paid_session = patient.clinic_info?.paid_session ?? 0;
          int current_cost = cost_per_session * (total_session - paid_session);

          var con = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => BillingDialog(
              cost_per_session: cost_per_session,
              current_cost: current_cost,
            ),
          );

          if (con != null) {
            int val = con;
            ClinicInfoModel cli = patient.clinic_info ?? ClinicInfoModel.gen();
            cli.cost_per_session = val;
            Map data = cli.toJson(patientKey: patient.key ?? '');

            // update price per session
            await ClinicDatabaseHelpers.update_clinic_info(context,
                data: data, showLoading: true, showToast: true);
          }
        }

        // pay for assesment
        if (value == 4) {
          Map conf = await ClinicDatabaseHelpers.pay_for_assessment(context,
              patient: patient,
              showLoading: true,
              showToast: true,
              loadingText: 'Paying for Assessment...');

          if (conf['status'] == true) {
            ClinicHistoryModel hist = conf['data'];

            var ass_print = PhysioPaymentPrintModel(
              date:
                  '${DateFormat.jm().format(hist.date)} ${DateFormat('dd-MM-yyyy').format(hist.date)}',
              receipt_id: hist.history_id,
              client_id: patient.patient_id,
              client_name: '${patient.f_name} ${patient.l_name}',
              amount: hist.amount,
              receipt_type: hist.hist_type,
              session_paid: hist.session_paid,
              amount_b4_discount: hist.amount_b4_discount ?? 0,
              cost_p_session: hist.cost_p_session.toInt(),
              old_float: hist.old_float.toInt(),
              new_float: hist.new_float.toInt(),
            );

            // print receipt
            bool conf_2 = await Helpers.showConfirmation(
              context: context,
              title: 'Print Receipt',
              message: 'Print receipt for assessment',
            );

            if (conf_2)
              await showDialog(
                  context: context,
                  builder: (context) =>
                      PhysioPrintPage(payment_print: ass_print));
          }
        }
      },
      itemBuilder: (context) => [
        // session plan
        if (active_user!.app_role == 'Doctor')
          PopupMenuItem(
            value: 1,
            child: Container(
              child: Text(
                patient.clinic_info == null ||
                        patient.clinic_info?.total_session == 0
                    ? 'Setup Session Plan'
                    : 'Change Session Frequency',
                style: TextStyle(),
              ),
            ),
          ),

        // add session
        if (active_user!.app_role == 'Doctor')
          if (patient.clinic_info?.total_session != 0)
            PopupMenuItem(
              value: 2,
              child: Container(
                child: Text(
                  'Add Sessions',
                  style: TextStyle(),
                ),
              ),
            ),

        // billing setup
        if (active_user!.app_role == 'CSU' || active_user!.app_role == 'ICT')
          PopupMenuItem(
            value: 3,
            child: Container(
              child: Text(
                'Billing Setup',
                style: TextStyle(),
              ),
            ),
          ),

        // take assessment
        if (active_user!.app_role == 'CSU' || active_user!.app_role == 'ICT')
          PopupMenuItem(
            value: 4,
            child: Container(
              child: Text(
                'Pay for Assessment',
                style: TextStyle(),
              ),
            ),
          ),

        // PopupMenuDivider(),
      ],
    );
  }

  //

  //

  // send to clinic
  send_to_clinic({required String treatment_type}) async {
    // treatment ended
    var res = await ClinicDatabaseHelpers.get_case_file_by_date(context,
        patient_id: patient.key ?? '',
        treatment_date: DateTime.now(),
        showLoading: true,
        loadingText: 'Checking Previous Cases...');

    if (res != null && res.isNotEmpty) if (ClinicDatabaseHelpers
        .check_cases_by_type(cases: res, case_type: 'Treatment')) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'Treatment done today',
        icon: Icons.error,
      );
      return;
    }

    // patient.key
    DoctorModel? selected_doctor = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorsList(
          from_clinic: true,
        ),
      ),
    );

    if (selected_doctor != null) {
      // select duration
      var dur = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => OptionsDialog(
          title: 'Select Duration',
          options: treatment_time,
        ),
      );

      if (dur == null) return;

      String treatment_duration = dur;
      // send to selected doctor & save current doctor
      if (patient.current_doctor != null &&
          (patient.current_doctor?.key != selected_doctor.key)) {
        await await ClinicDatabaseHelpers.remove_from_clinic(
          context,
          doctor_key: patient.current_doctor?.key ?? '',
          patient_key: patient.key ?? '',
          treatment_type: patient.clinic_variables?.case_type ?? '',
          treatment_duration:
              patient.clinic_variables?.treatment_duration ?? '',
          showLoading: true,
          showToast: true,
        );
      }

      await ClinicDatabaseHelpers.send_to_clinic(
        context,
        doctor_key: selected_doctor.key ?? '',
        patient_key: patient.key ?? '',
        treatment_type: treatment_type,
        treatment_duration: treatment_duration,
        showLoading: true,
        showToast: true,
      );
    }
  }

  // start treatment
  start_treatment({required String case_type}) async {
    // try to get case file
    CaseFileModel? caseFile = await ClinicDatabaseHelpers.start_treatment(
        context,
        patient: patient,
        doctor: active_doctor!,
        case_type: case_type);

    if (caseFile == null) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'Treatment error, Try again',
        icon: Icons.error,
      );
      return;
    }

    // go to treatment page
    var bac = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentTab(
          patient: patient,
          case_file: caseFile,
        ),
      ),
    );

    // if treatment ended
    if (bac != null) {
      if (bac == 'done') {
        Helpers.showToast(
          context: context,
          color: Colors.blue,
          toastText: 'Session Ended',
          icon: Icons.error,
        );
      }
    }
  }

//
}

class SessionModel {
  int total_session;
  int completed_session;
  int paid_session;
  int? balance;
  int? active;
  int cost_per_session;
  int amount_paid;
  int floating_amount;
  String frequency;

  SessionModel({
    required this.total_session,
    required this.completed_session,
    required this.paid_session,
    required this.frequency,
    required this.cost_per_session,
    required this.amount_paid,
    required this.floating_amount,
  });

  factory SessionModel.fromMap(Map map) {
    return SessionModel(
      total_session: map['total_session'] ?? 0,
      completed_session: map['completed_session'] ?? 0,
      paid_session: map['paid_session'] ?? 0,
      frequency: map['frequency'] ?? '',
      cost_per_session: map['cost_per_session'] ?? 0,
      amount_paid: map['amount_paid'] ?? 0,
      floating_amount: map['floating_amount'] ?? 0,
    );
  }
}

class BillingDialog extends StatefulWidget {
  final int? cost_per_session;
  final int current_cost;
  const BillingDialog(
      {super.key, required this.cost_per_session, required this.current_cost});

  @override
  State<BillingDialog> createState() => _BillingDialogState();
}

class _BillingDialogState extends State<BillingDialog> {
  int? price_select;
  List<int> price_options = [
    5000,
    7500,
    10000,
    12000,
    15000,
    20000,
    25000,
    30000
  ];

  final TextEditingController price_con = TextEditingController();

  @override
  void dispose() {
    price_con.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var val = NumberFormat('#,###');

    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        height: 450,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade400.withOpacity(.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // top bar
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF000000),
                    offset: Offset(0.7, 0.7),
                    blurRadius: 6,
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 2),

                  // title
                  Stack(
                    children: [
                      // heading
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Billing Setup',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      // close button
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // horizontal line
                  Container(
                    height: 1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                  ),

                  SizedBox(height: 4),

                  // subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Text(
                      'Use the form below to setup a payment plan',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // total cost label
            if (widget.cost_per_session != null)
              Text(
                'Current Cost',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

            // total cost
            if (widget.cost_per_session != null)
              Text(
                '₦${val.format(widget.current_cost)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

            SizedBox(height: 20),

            // current price per session label
            if (widget.cost_per_session != null)
              Text(
                'Current Cost per Session',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

            // current price per session
            if (widget.cost_per_session != null)
              Text(
                '₦${val.format(widget.cost_per_session)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

            SizedBox(height: 40),

            // new price per session label
            Text(
              'Price per session',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(width: 10),

            // new price per session
            Container(
              width: 145,
              child: DropdownButtonFormField<int>(
                // itemHeight: 40,
                dropdownColor: Colors.black87,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: price_select,
                items: price_options
                    .map((e) => DropdownMenuItem<int>(
                        value: e, child: Text('₦${val.format(e)}')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    price_select = val;
                    price_con.text = val.toString();
                    if (mounted) setState(() {});
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: 145,
              child: Text_field(
                controller: price_con,
                format: [FilteringTextInputFormatter.digitsOnly],
                prefix: const Text(
                  '₦',
                  style: TextStyle(
                    color: Color(0xFFc3c3c3),
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const Expanded(child: SizedBox()),

            // submit
            InkWell(
              onTap: () {
                if (price_con.text.isEmpty) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.red,
                    toastText: 'Select a price',
                    icon: Icons.error,
                  );
                  return;
                }

                Navigator.pop(context, int.parse(price_con.text));
              },
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xFF3c5bff).withOpacity(0.6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class AssessmentPayment extends StatefulWidget {
  const AssessmentPayment({super.key});

  @override
  State<AssessmentPayment> createState() => _AssessmentPaymentState();
}

class _AssessmentPaymentState extends State<AssessmentPayment> {
  int assessment_amount = 5000;
  List<int> price_options = [
    2000,
    2500,
    3000,
    3500,
    4000,
    4500,
    5000,
    6000,
    7000,
    7500,
    8000,
    10000,
    12000,
    15000,
    20000
  ];

  final TextEditingController price_con = TextEditingController(text: '5000');

  @override
  void dispose() {
    price_con.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var val = NumberFormat('#,###');

    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        height: 350,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade400.withOpacity(.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // top bar
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF000000),
                    offset: Offset(0.7, 0.7),
                    blurRadius: 6,
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 2),

                  // title
                  Stack(
                    children: [
                      // heading
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Assessment Payment',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      // close button
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // horizontal line
                  Container(
                    height: 1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                  ),

                  SizedBox(height: 4),

                  // subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Text(
                      'This confrims that the client has paid for assessment. Use the form below to select amount paid',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            //  label
            Text(
              'Assessment amount',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(width: 10),

            // select amount
            Container(
              width: 145,
              child: DropdownButtonFormField<int>(
                // itemHeight: 40,
                dropdownColor: Colors.black87,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: assessment_amount,
                items: price_options
                    .map((e) => DropdownMenuItem<int>(
                        value: e, child: Text('₦${val.format(e)}')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    assessment_amount = val;
                    price_con.text = val.toString();
                    if (mounted) setState(() {});
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: 145,
              child: Text_field(
                controller: price_con,
                format: [FilteringTextInputFormatter.digitsOnly],
                prefix: const Text(
                  '₦',
                  style: TextStyle(
                    color: Color(0xFFc3c3c3),
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const Expanded(child: SizedBox()),

            // submit
            InkWell(
              onTap: () async {
                if (price_con.text.isEmpty) {
                  return Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Select amount',
                    icon: Icons.error,
                  );
                }

                var conf = await showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Assessment Payment',
                    subtitle:
                        'This confrims that the client has paid for assessment. Would you like to proceed?',
                  ),
                );

                if (conf != null && conf)
                  Navigator.pop(context, int.parse(price_con.text));
              },
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xFF3c5bff).withOpacity(0.6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
