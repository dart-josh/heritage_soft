import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/casefile.model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/physio_database_helpers.dart';
import 'package:heritage_soft/helpers/physio_helpers.dart';
import 'package:heritage_soft/pages/physio/case_file_page.dart';
import 'package:heritage_soft/pages/physio/doctors_list.dart';
import 'package:heritage_soft/pages/physio/physio_history_page.dart';
import 'package:heritage_soft/pages/physio/physio_pofile_page.dart';
import 'package:heritage_soft/pages/physio/print.page.dart';
import 'package:heritage_soft/pages/physio/request_accessories_page.dart';
import 'package:heritage_soft/pages/physio/treatment_tab.dart';
import 'package:heritage_soft/pages/physio/widgets/full_session_details.dart';
import 'package:heritage_soft/pages/physio/widgets/session_payment_dialog.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/options_dialog.dart';
import 'package:heritage_soft/pages/physio/widgets/physio_hmo_tag.dart';
import 'package:heritage_soft/pages/physio/widgets/session_plan_dialog.dart';
import 'package:heritage_soft/pages/physio/widgets/clinic_info.dart';

import 'package:intl/intl.dart';

class ClinicTab extends StatefulWidget {
  final PatientModel patient;
  final bool can_treat;
  const ClinicTab({super.key, required this.patient, required this.can_treat});

  @override
  State<ClinicTab> createState() => _ClinicTabState();
}

class _ClinicTabState extends State<ClinicTab> {
  TextStyle headingStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  bool session_set = false;
  int total_session = 0;
  String frequency = '';
  int paid_sess = 0;
  int active_sess = 0;
  int completed_session = 0;

  int? cost_per_session;

  SessionModel? _session_details;

  String treatment_duration = '30 Mins';
  DateTime? start_time;

  bool can_treat = true;

  bool? assessment_completed = null;
  bool? ongoing_treatment = null;
  DateTime? assessment_date;
  bool assessment_paid = false;

  TreatmentInfoModel? treatmentModel;
  AssessmentInfoModel? assessmentModel;

  StreamSubscription? trt_stream_sub;
  StreamSubscription? ass_stream_sub;

  StreamSubscription? var_stream_sub;
  StreamSubscription? session_stream_sub;

  bool treatment_done_today = false;
  bool treatment_elapse = false;

  bool pending_treatment = false;
  List<DoctorModel> doctors = [];

  bool treatment_completed = false;

  String current_doctor = '';

  PhysioPaymentPrintModel? assessment_print;

  //?
  bool skip_assessment = false;

  late PatientModel patient;
  UserModel? active_user;
  DoctorModel? active_doctor;

  void get_patient(PatientModel patient) {
    var res = AppData.get(context)
        .patients
        .where((p) => p.key == patient.key)
        .toList();

    if (res.isNotEmpty) {
      patient = res.first;
    }

    get_treatment_info();
    get_assessment();
    get_variables();
    get_sessions();
  }

  // stream session info
  get_sessions() {
    cost_per_session = patient.clinic_info?.cost_per_session ?? 0;

    _session_details =
        SessionModel.fromMap(patient.clinic_info?.toJson() ?? {});

    if (_session_details != null) {
      session_set = true;
    }
  }

  // stream clinin variables
  get_variables() {
    // if patient is removed from doctor
    // pop the page off
    if (active_user!.app_role == 'Doctor' && can_treat) {
      if (patient.clinic_variables != null &&
          patient.clinic_variables?.can_treat == false) {
        if (mounted) Navigator.pop(context);
      }
    }

    treatment_duration =
        patient.clinic_variables?.treatment_duration ?? treatment_duration;
    start_time = patient.clinic_variables?.start_time;
    can_treat = patient.clinic_variables?.can_treat ?? true;
    current_doctor = patient.current_doctor?.key ?? '';

    if (current_doctor != '') {
      pending_treatment = true;
    } else {
      pending_treatment = false;
    }
  }

  // stream treatment info
  get_treatment_info() {
    if (patient.treatment_info != null) {
      // assessment completed
      assessment_completed =
          patient.treatment_info?.assessment_completed ?? false;

      // ongoing treatment
      ongoing_treatment = patient.treatment_info?.ongoing_treatment ?? false;

      // assessment date
      if (patient.treatment_info?.assessment_date != null) {
        assessment_date = patient.treatment_info?.assessment_date;
      }

      // assessment paid
      assessment_paid = patient.treatment_info?.assessment_paid ?? false;

      //? skip_assessment
      skip_assessment = patient.treatment_info?.skip_assessment ?? false;

      // treatment model
      treatmentModel = patient.treatment_info;
    } else {
      treatmentModel = null;
      assessment_completed = false;
      ongoing_treatment = false;
    }
  }

  // assessment stream
  get_assessment() {
    if (patient.assessment_info.isNotEmpty) {
      assessmentModel = patient.assessment_info[0];
    }
  }

  @override
  void initState() {
    patient = widget.patient;

    can_treat = widget.can_treat;
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // constantly update UI because of Timer
  refresh() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) setState(() {});
      refresh();
    });
  }

  // time countdown
  Widget time() {
    if (start_time == null) return Container();

    // get current Time count
    List<String> _timer = PhysioHelpers.update_timer(PhysioHelpers.get_duration(
        treatment_duration: treatment_duration, start_time: start_time!));

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
                  'Duration: $treatment_duration',
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
          patient_data(),

          // session info area
          Expanded(child: Center(child: session_tab(_session_details))),

          SizedBox(height: 30),

          // action tab
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
                                  PhysioHistoryPage(patient: patient),
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
                    if (_session_details != null &&
                        assessmentModel != null &&
                        assessment_completed!)
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: InkWell(
                          onTap: () {
                            Map map = {
                              'total_session': _session_details!.total_session,
                              'frequency': _session_details!.frequency,
                              'utilized_session':
                                  _session_details!.completed_session,
                              'paid_session': _session_details!.paid_session,
                              'amount_paid': _session_details!.amount_paid,
                              'cost_p_session':
                                  _session_details!.cost_per_session,
                              'floating_amount':
                                  _session_details!.floating_amount,
                            };

                            showDialog(
                              context: context,
                              builder: (context) => SessionDetailsDialog(
                                session_details: map,
                                client_id: patient.patient_id,
                                client_name: patient.f_name,
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
                  if (assessmentModel != null && assessment_completed!)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                ClinicInfo(info: assessmentModel!),
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
                  if (assessment_completed != null && assessment_completed!)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          if (treatmentModel == null) return;

                          if (!assessment_completed!) return;

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
                  if ((active_user!.app_role == 'Doctor') && widget.can_treat)
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
                can_treat: widget.can_treat,
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
          if (!skip_assessment)
            InkWell(
              onTap: () async {
                var res = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      ClinicInfo(info: assessmentModel ?? null, new_det: true),
                );

                if (res != null) {
                  AssessmentInfoModel ass = res;
                  Map data = ass.toJson();
                  data.addAll({'patient': patient.key});
                  // save assessment details
                  await PhysioDatabaseHelpers.update_assessment_info(
                    context,
                    data: data,
                    showToast: true,
                    showLoading: true,
                    loadingText: 'Updating Assessment info...',
                  );

                  // update treatment info
                  treatmentModel?.skip_assessment = true;
                  await PhysioDatabaseHelpers.update_treatment_info(
                    context,
                    data: {
                      'patient': patient.key,
                      'treatment_info': treatmentModel?.toJson(),
                    },
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
          // else if (assessment_completed != null && assessment_completed!)

          // session setup
          session_setup(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Text('Patient Data'),
            ),
          ),
        ],
      ),
    );
  }

  // session tab
  Widget session_tab(SessionModel? session) {
    var val = NumberFormat('#,###');

    if (session != null) {
      total_session = session.total_session;
      frequency = session.frequency;
      paid_sess = session.paid_session;
      completed_session = session.completed_session;
      active_sess = session.paid_session - session.completed_session;
    }

    int balance = (session == null)
        ? 0
        : session.total_session - session.completed_session;

    int current_cost = (session == null || cost_per_session == null)
        ? 0
        : cost_per_session! * (total_session - session.paid_session);

    // assessment not yet completed
    if (assessment_completed == null || !assessment_completed!)
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
              Column(
                children: [
                  // title
                  Text('Total Sessions', style: title_style),
                  SizedBox(height: 2),
                  Text(
                      (session == null) ? '' : session.total_session.toString(),
                      style: value_style),
                ],
              ),

              // frequency
              Column(
                children: [
                  // title
                  Text('Frequency', style: title_style),
                  SizedBox(height: 2),
                  Text((session == null) ? '' : session.frequency,
                      style: value_style),
                ],
              ),

              // completed
              Column(
                children: [
                  // title
                  Text('Utilized', style: title_style),
                  SizedBox(height: 2),
                  Text(
                      (session == null)
                          ? ''
                          : session.completed_session.toString(),
                      style: value_style),
                ],
              ),

              // balance
              Column(
                children: [
                  // title
                  Text('Remainder', style: title_style),
                  SizedBox(height: 2),
                  Text((session == null) ? '' : balance.toString(),
                      style: value_style),
                ],
              ),
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
                Column(
                  children: [
                    // title
                    Text('Current cost', style: title_style),
                    SizedBox(height: 2),
                    Text(
                        (session == null) ? '' : '₦${val.format(current_cost)}',
                        style: value_style),
                  ],
                ),

              // total paid
              if (active_user!.app_role != 'Doctor')
                Column(
                  children: [
                    // title
                    Text('Amount paid', style: title_style),
                    SizedBox(height: 2),
                    Text(
                        (session == null)
                            ? ''
                            : '₦${val.format(session.amount_paid)}',
                        style: value_style),
                  ],
                ),

              // paid
              Column(
                children: [
                  // title
                  Text('Paid Sessions', style: title_style),
                  SizedBox(height: 2),
                  Text((session == null) ? '' : session.paid_session.toString(),
                      style: value_style),
                ],
              ),

              if (active_user!.app_role == 'Doctor') SizedBox(width: 150),

              // active
              Column(
                children: [
                  // title
                  Text('Active Session', style: title_style),
                  SizedBox(height: 2),
                  Text((session == null) ? '' : active_sess.toString(),
                      style: value_style),
                ],
              ),
              // Container(width: 100),
            ],
          )
        ],
      ),
    );
  }

  // validate treatment based on date
  void validate_treatment() {
    if (ongoing_treatment != null &&
        assessment_completed != null &&
        treatmentModel != null) {
      // if not ongoin treatment && assessment completed
      if (!ongoing_treatment! && assessment_completed!) {
        if (assessment_date != null &&
            treatmentModel!.last_treatment_date != null) {
          // if last treatment is today
          if (Helpers.date_format(treatmentModel!.last_treatment_date!) ==
                  Helpers.date_format(DateTime.now()) &&
              (completed_session > 0)) {
            // if treatment elapsed till today
            if (treatmentModel!.treatment_elapse) {
              treatment_done_today = false;
            } else {
              treatment_done_today = true;
            }
          }
        }
      }

      if (treatmentModel!.current_treatment_date != null) if (Helpers
                  .date_format(treatmentModel!.current_treatment_date!) !=
              Helpers.date_format(DateTime.now()) &&
          (ongoing_treatment!)) {
        treatment_elapse = true;
      }
    }
  }

  // action tab
  Widget action_tab() {
    // validate treatment
    validate_treatment();

    bool my_patient_to_treat = (active_user!.app_role == 'Doctor')
        ? current_doctor == active_doctor!.key
        : false;

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          /// TAB 1
          // pay for session (CSU user only)
          if (active_user!.app_role == 'CSU' || active_user!.app_role == 'ICT')
            InkWell(
              onTap: () async {
                // assessment payment
                if (!assessment_completed!) {
                  // assessment not paid
                  if (!assessment_paid) {
                    var conf = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AssessmentPayment(),
                    );

                    if (conf != null) {
                      Map data = patient.treatment_info?.toJson() ?? {};
                      data['assessment_paid'] = true;

                      // update assessment paid

                      await PhysioDatabaseHelpers.update_treatment_info(
                        context,
                        data: data,
                        showLoading: true,
                        showToast: true,
                      );

                      ClinicHistoryModel hist = ClinicHistoryModel(
                        hist_type: 'Assessment Payment',
                        amount: conf,
                        amount_b4_discount: 0,
                        date: DateTime.now(),
                        session_paid: 1,
                        history_id: Helpers.generate_order_id(),
                        cost_p_session: 0,
                        old_float: 0,
                        new_float: 0,
                        session_frequency: '',
                      );

                      Map data_h = hist.toJson();
                      data_h['patient'] = patient.key;

                      PhysioDatabaseHelpers.update_clinic_history(context,
                          data: data_h);

                      assessment_print = PhysioPaymentPrintModel(
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
                    }
                  }

                  // print assessment receipt
                  else if (assessment_print != null) {
                    //? print
                    await showDialog(
                        context: context,
                        builder: (context) =>
                            PhysioPrintPage(payment_print: assessment_print));
                  }

                  return;
                }

                // if session info not set
                // if (!session_set || _session_details == null) {
                //   Helpers.showToast(
                //     context: context,
                //     color: Colors.redAccent,
                //     toastText: 'Setup a Session Plan',
                //     icon: Icons.error,
                //   );
                //   return;
                // }

                // if billing not set
                if (cost_per_session == null) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Setup a billing Plan',
                    icon: Icons.error,
                  );
                  return;
                }

                var old_float = _session_details!.floating_amount;

                // session plan dialog for payment
                var res = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => SessionPaymentDialog(
                    session_details: {
                      'cost_p_session': _session_details!.cost_per_session,
                      'total_session': _session_details!.total_session,
                      'session_paid': _session_details!.paid_session,
                      'amount_paid': _session_details!.amount_paid,
                      'floating_amount': _session_details!.floating_amount,
                    },
                  ),
                );

                if (res != null) {
                  // Map<String, dynamic> map = {
                  //   'amount_paid': res['total_amount'],
                  //   'paid_session': res['total_active_session'],
                  //   'floating_amount': res['floating_amount'],
                  // };

                  int amount_paid = res['discounted_amount'];
                  int amount_b4_discount = res['amount_to_pay'];
                  int new_session = res['new_session'];

                  var new_float = res['floating_amount'];

                  Map map = patient.clinic_info?.toJson() ?? {};
                  map['amount_paid'] = res['total_amount'];
                  map['paid_session'] = res['total_active_session'];
                  map['floating_amount'] = res['floating_amount'];
                  map['patient'] = patient.key;

                  // update paid session
                  await PhysioDatabaseHelpers.update_clinic_info(context,
                      data: map, showLoading: true, showToast: true);

                  ClinicHistoryModel historyModel = ClinicHistoryModel(
                    hist_type: 'Session Payment',
                    amount: amount_paid,
                    amount_b4_discount: amount_b4_discount,
                    date: DateTime.now(),
                    session_paid: new_session,
                    history_id: Helpers.generate_order_id(),
                    cost_p_session: cost_per_session?.toDouble() ?? 0,
                    old_float: old_float.toDouble(),
                    new_float: new_float,
                    session_frequency: '',
                  );

                  Map data_h2 = historyModel.toJson();
                  data_h2['patient'] = patient.key;

                  await PhysioDatabaseHelpers.update_clinic_history(context,
                      data: data_h2);

                  Navigator.pop(context);

                  var printt = await showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      title: 'Print Receipt',
                      subtitle:
                          'Would you like to print receipt for this payment',
                      boolean: true,
                    ),
                  );

                  if (printt != null && printt) {
                    //? print
                    PhysioPaymentPrintModel printModel =
                        PhysioPaymentPrintModel(
                      date:
                          '${DateFormat.jm().format(historyModel.date)} ${DateFormat('dd-MM-yyyy').format(historyModel.date)}',
                      receipt_id: historyModel.history_id,
                      client_id: patient.patient_id,
                      client_name: '${patient.f_name} ${patient.l_name}',
                      amount: historyModel.amount,
                      receipt_type: historyModel.hist_type,
                      session_paid: historyModel.session_paid,
                      amount_b4_discount: historyModel.amount_b4_discount ?? 0,
                      cost_p_session: historyModel.cost_p_session.toInt(),
                      old_float: historyModel.old_float.toInt(),
                      new_float: historyModel.new_float.toInt(),
                    );

                    await showDialog(
                        context: context,
                        builder: (context) =>
                            PhysioPrintPage(payment_print: printModel));
                  }

                  setState(() {});
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
                    !assessment_completed!
                        ? !assessment_paid
                            ? 'Pay for Assessment'
                            : (assessment_print != null)
                                ? 'Print Assessment Receipt'
                                : 'Assessment Paid'
                        : 'Session Payment',
                    style: action_style,
                  ),
                ),
              ),
            )

          // treatment duration (doctor only) (if doctor can treat)
          else if ((active_user!.app_role == 'Doctor') &&
              widget.can_treat &&
              can_treat &&
              my_patient_to_treat)
            // treatment duration
            if (!treatment_completed)
              Center(
                child: Text(
                  treatment_duration,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container()
          else
            Container(),

          ///

          /// TAB 2
          // send to clinic (CSU user only)
          if (active_user!.app_role == 'CSU' || active_user!.app_role == 'ICT')
            InkWell(
              onTap: () async {
                if (ongoing_treatment == null) return;

                // error if ongoing treatment
                if (ongoing_treatment!) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Treatment ongoing',
                    icon: Icons.error,
                  );
                  return;
                }

                // error if treatment done for today
                if (treatment_done_today) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Treatment done for today',
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

                  // remove from clinic
                  PhysioDatabaseHelpers.remove_from_clinic(
                    context,
                    data: {'patient': patient.key, 'Doctor': current_doctor},
                  );

                  // assign to doctor
                  PhysioDatabaseHelpers.send_to_clinic(
                    context,
                    data: {'patient': patient.key, 'Doctor': current_doctor},
                  );

                  // set treatment duration

                  pending_treatment = true;

                  setState(() {});
                }
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

          // treatment countdoun (doctor only) (if ongoing treatment)
          else if ((active_user!.app_role == 'Doctor') &&
              widget.can_treat &&
              can_treat &&
              my_patient_to_treat)
            if (ongoing_treatment!) time() else Container()
          else
            Container(),

          ///

          /// Tab 3
          // doctor's action (if doctor can treat)
          if ((active_user!.app_role == 'Doctor') &&
              widget.can_treat &&
              my_patient_to_treat)
            // treatment done
            if (treatment_completed || !can_treat)
              Container()
            // go to treatment tab
            else
              InkWell(
                onTap: () async {
                  if (assessment_completed == null || ongoing_treatment == null)
                    return;

                  // session plan not set
                  if (assessment_completed! && total_session == 0) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Setup a treatment plan',
                      icon: Icons.error,
                    );
                    return;
                  }

                  // treatment ended
                  if (treatment_done_today) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Treatment for today Ended',
                      icon: Icons.error,
                    );
                    return;
                  }

                  // treatment elapse
                  if (treatment_elapse) {
                    var conf_elap = await showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        title:
                            '${(!assessment_completed!) ? 'Assessment' : 'Treatment'} Elapsed',
                        subtitle:
                            'The previous ${(!assessment_completed!) ? 'assessment' : 'treatment'}'
                            ' for this client has not ended,\nYou need to end this '
                            '${(!assessment_completed!) ? 'assessment' : 'treatment'} before proceeding.',
                      ),
                    );

                    if (conf_elap != null && conf_elap) {
                      start_treatment(
                          continue_treatment: true,
                          current_treatment_date:
                              treatmentModel!.current_treatment_date ??
                                  DateTime.now());
                    }
                  }
                  // same day treatment
                  else {
                    var conf = await showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        title:
                            'Go To ${(!assessment_completed!) ? 'Assessment' : 'Treatment'} Tab',
                        subtitle:
                            'You are about to open the ${(!assessment_completed!) ? 'assessment' : 'treatment'} tab for this client, Would you like to proceed?',
                      ),
                    );

                    if (conf != null && conf == true) {
                      start_treatment(
                          continue_treatment: false,
                          current_treatment_date:
                              treatmentModel!.current_treatment_date ??
                                  DateTime.now());
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
                    child: Text(treatment_action_title(), style: action_style),
                  ),
                ),
              )

          // CSU user action
          else if (active_user!.app_role == 'CSU' ||
              active_user!.app_role == 'ICT')
            // ongoing treatment label & treatmnet countdown
            if (ongoing_treatment != null && ongoing_treatment!)
              Container(
                child: Row(
                  children: [
                    Text(
                      'Ongoing Treatment',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    time(),
                  ],
                ),
              )

            // pending treatment
            else if (pending_treatment)
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

                      Helpers.showLoadingScreen(context: context);
                      String treatment_duration = dur;

                      // change treatment duration

                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Center(
                        child: Text(treatment_duration, style: action_style),
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // remove from clinic
                  InkWell(
                    onTap: () async {
                      var conf = await showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                          title: 'Remove From Clinic',
                          subtitle:
                              'You are about to remove this patient from the waiting list of the doctors. Would you like to proceed?',
                        ),
                      );

                      if (conf == null || !conf) return;

                      await PhysioDatabaseHelpers.remove_from_clinic(
                        context,
                        data: {'id': current_doctor, 'patient': patient.key},
                        showLoading: true,
                        showToast: true,
                      );

                      pending_treatment = false;
                      setState(() {});
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
              Container()
          else
            Container(),

          ///
        ],
      ),
    );
  }

  // FUNCTIONS
  start_treatment(
      {required bool continue_treatment,
      required DateTime current_treatment_date}) async {
    // assign case file key
    String sv_date = (!assessment_completed!)
        ? '${Helpers.date_format(continue_treatment ? current_treatment_date : DateTime.now())} (Assessment)'
        : Helpers.date_format(
            continue_treatment ? current_treatment_date : DateTime.now());

    // check for case file
    // if it exist get case file and open
    // if not open new case file

    Map data1 = {'treatment_date': sv_date, 'patient': patient.key};
    // try to get case file
    List<CaseFileModel>? cases =
        await PhysioDatabaseHelpers.get_case_file_by_date(context, data: data1);

    if (cases == null || cases.isEmpty) {
      return;
    }

    CaseFileModel file = cases[0];

    // new case file data

    file = CaseFileModel(
      treatment_date: DateTime.now(),
      bp_reading: '',
      note: '',
      remarks: '',
      doctor: active_doctor!,
      case_type: (assessment_completed!) ? 'Treatment' : 'Assessment',
      key: sv_date,
      start_time: DateTime.now(),
      end_time: null,
      treatment_decision: '',
      refered_decision: '',
      other_decision: '',
      patient: patient,
    );

    Map<String, dynamic> data = file.toJson_open();

    // open case file
    bool dt = await PhysioDatabaseHelpers.add_update_case_file(
      context,
      data: data,
    );

    if (!dt) {
      Navigator.pop(context);
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'Error, Try again',
        icon: Icons.error,
      );
      return;
    }

    // set start time

    // set current treatment date

    // set ongoing treatment = true

    // add patient to doctors tab
    PhysioDatabaseHelpers.update_doc_ongoing_patient(
      context,
      data: {'id': active_doctor?.key ?? '', 'patient': patient.key ?? ''},
    );

    // remove loading screen
    Navigator.pop(context);

    // go to treatment page
    var bac = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentTab(
          patient: patient,
          treatmentInfo: treatmentModel,
          assessmentModel: assessmentModel,
          case_file: file,
          assessment_completed: assessment_completed!,
          completed_session: completed_session,
          session_details: _session_details,
          treatment_duration: treatment_duration,
          treatment_elapse: treatment_elapse,
        ),
      ),
    );

    // if treatment ended
    if (bac != null) {
      if (bac == 'done') {
        treatment_completed = true;
        setState(() {});

        Helpers.showToast(
          context: context,
          color: Colors.blue,
          toastText: 'Session Ended',
          icon: Icons.error,
        );
      }
    }
  }

  // doctor treatment action title
  String treatment_action_title() {
    if (assessment_completed == null || ongoing_treatment == null)
      return '...';
    else if (!assessment_completed!) if (ongoing_treatment!)
      return 'Continue Assessment';
    else
      return 'Clinical Assessment';
    else if (ongoing_treatment!) if (treatment_elapse)
      return 'Treatment Elapsed';
    else
      return 'Continue Treatment';
    else if (treatment_done_today)
      return 'Treatment done';
    else
      return 'Start Treatment';
  }

  // session setup pop up menu
  Widget session_setup({required child}) {
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
              session_set: session_set,
              total_session:
                  (total_session != 0) ? total_session.toString() : null,
            ),
          );

          if (res != null) {
            Map r_map = res;

            int total = r_map['total'];
            String frequency = r_map['frequency'];

            // update session info
            if (session_set || (total_session != 0)) {
              // PhysioDatabaseHelpers.update_clinic_info(
              //   patient.key,
              //   {'total_session': total, 'frequency': frequency},
              // );
            }

            // set session info
            else {
              // PhysioDatabaseHelpers.update_clinic_info(
              //   patient.key,
              //   {
              //     'total_session': total,
              //     'frequency': frequency,
              //     'completed_session': 0,
              //     'paid_session': 0,
              //   },
              //   sett: true,
              // );
            }

            PhysioHistoryModel hist = PhysioHistoryModel(
                hist_type: (session_set || (total_session != 0))
                    ? 'Session Updated'
                    : 'Session Setup',
                amount: 0,
                amount_b4_discount: 0,
                date: DateTime.now(),
                session_paid: total,
                history_id: Helpers.generate_order_id(),
                cost_p_session: 0,
                old_float: 0,
                new_float: 0,
                session_frequency: frequency);

            // PhysioDatabaseHelpers.add_history(patient.key, hist.toJson());
          }
        }

        // add sessions
        if (value == 2) {
          if (!session_set) {
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
              session_set: session_set,
              add_session: true,
              session_details: {
                'total_sess': total_session.toString(),
                'frequency': frequency,
              },
            ),
          );

          if (res != null) {
            int new_sess = res;

            int added = new_sess - total_session;

            // PhysioDatabaseHelpers.update_clinic_info(
            //   patient.key,
            //   {'total_session': new_sess},
            // );

            PhysioHistoryModel hist = PhysioHistoryModel(
              hist_type: 'Session Added',
              amount: added,
              amount_b4_discount: 0,
              date: DateTime.now(),
              session_paid: new_sess,
              history_id: Helpers.generate_order_id(),
              cost_p_session: 0,
              old_float: 0,
              new_float: 0,
            );

            // session added
            // session frequency
            // total session

            // PhysioDatabaseHelpers.add_history(patient.key, hist.toJson());

            setState(() {});
          }
        }

        // billing setup
        if (value == 3) {
          var con = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => BillingDialog(
              cost_per_session: cost_per_session,
              current_cost: _session_details != null && cost_per_session != null
                  ? ((_session_details!.total_session -
                          _session_details!.paid_session) *
                      cost_per_session!)
                  : 0,
            ),
          );

          if (con != null) {
            int val = con;
            Map data = patient.clinic_info?.toJson() ?? {};
            data['cost_per_session'] = val;
            data['patient'] = patient.key;

            // update price per session

            await PhysioDatabaseHelpers.update_clinic_info(context, data: data);
          }
        }

        // take assessment
        if (value == 4) {
          // pay for assessment

          // enter new assesment info

          // update treatment info
          Map data = patient.treatment_info?.toJson() ?? {};
          data['assessment_completed'] = true;
          data['assessment_date'] = DateTime.now().toString();
          data['skip_assessment'] = true;
          data['assessment_paid'] = true;
          data['patient'] = patient.key;

          await PhysioDatabaseHelpers.update_treatment_info(
            context,
            data: data,
            showLoading: true,
            showToast: true,
          );
        }
      },
      itemBuilder: (context) => [
        // session plan
        if (active_user!.app_role == 'Doctor')
          PopupMenuItem(
            value: 1,
            child: Container(
              child: Text(
                !session_set || total_session == 0
                    ? 'Setup Session Plan'
                    : 'Change Session Frequency',
                style: TextStyle(),
              ),
            ),
          ),

        // add session
        if (active_user!.app_role == 'Doctor')
          if (session_set && total_session != 0)
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
                'Send for Assessment',
                style: TextStyle(),
              ),
            ),
          ),

        // PopupMenuDivider(),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    var val = NumberFormat('#,###');

    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        height: 400,
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

                    setState(() {});
                  }
                },
              ),
            ),

            SizedBox(height: 40),

            // submit
            InkWell(
              onTap: () {
                if (price_select == null) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.red,
                    toastText: 'Select a price',
                    icon: Icons.error,
                  );
                  return;
                }

                Navigator.pop(context, price_select);
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

                    setState(() {});
                  }
                },
              ),
            ),

            SizedBox(height: 40),

            // submit
            InkWell(
              onTap: () async {
                var conf = await showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Assessment Payment',
                    subtitle:
                        'This confrims that the client has paid for assessment. Would you like to proceed?',
                  ),
                );

                if (conf != null && conf)
                  Navigator.pop(context, assessment_amount);
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
          ],
        ),
      ),
    );
  }
}
