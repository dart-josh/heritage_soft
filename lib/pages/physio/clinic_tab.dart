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

  bool can_treat = true;

  bool? assessment_completed = null;
  bool ongoing_treatment = false;
  DateTime? assessment_date;
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

  void get_patient(PatientModel pat) {
    var res =
        AppData.get(context).patients.where((p) => p.key == pat.key).toList();

    if (res.isNotEmpty) {
      patient = res.first;

      get_treatment_info();
      get_assessment();
      get_variables();
      get_sessions();

      setState(() {});
    }
  }

  // stream session info
  get_sessions() {}

  // stream clinin variables
  get_variables() {
    can_treat = patient.current_doctor == active_doctor?.key;
    case_type = patient.clinic_variables?.case_type;
    run_timer = patient.current_case_id != null &&
        patient.clinic_variables?.start_time != null;
  }

  // stream treatment info
  get_treatment_info() {
    if (patient.treatment_info != null) {
      // assessment completed
      assessment_completed =
          patient.treatment_info?.assessment_completed ?? false;

      // ongoing treatment
      ongoing_treatment = patient.current_case_id != null;

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
      assessmentModel = patient.assessment_info.last;
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
          patient_data(),

          // session info area
          Expanded(child: Center(child: session_tab())),

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
                    if (patient.clinic_info != null &&
                        assessmentModel != null &&
                        assessment_completed!)
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
                  ass.assessment_date = DateTime.now();
                  Map data = ass.toJson(patientKey: patient.key ?? '');

                  // save assessment details
                  await PhysioDatabaseHelpers.update_assessment_info(
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

                  await PhysioDatabaseHelpers.update_treatment_info(
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
          // else if (assessment_completed != null && assessment_completed!)

          // session setup
          clinic_setup(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Text('Clinic setup'),
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
              session_info_tile(
                  label: 'Total Sessions', value: total_session.toString()),

              // frequency
              session_info_tile(label: 'Frequency', value: frequency),

              // Utilized
              session_info_tile(
                  label: 'Utilized', value: completed_session.toString()),

              // balance
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
              session_info_tile(label: 'label', value: paid_session.toString()),

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
          /// TAB 1
          // (CSU user only)
          if (active_user!.app_role == 'CSU' || active_user!.app_role == 'ICT')
            // payment
            InkWell(
              onTap: () async {
                // assessment payment
                if (!assessment_completed!) {
                  // assessment not paid
                  if (!assessment_paid) {
                    Map conf = await PhysioDatabaseHelpers.pay_for_assessment(
                        context,
                        patient: patient,
                        showLoading: true,
                        showToast: true,
                        loadingText: 'Paying for Assessment...');

                    if (conf['status'] == true) {
                      ClinicHistoryModel hist = conf['data'];

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
                if (patient.clinic_info != null
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
                if (patient.clinic_info!.cost_per_session == 0) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Setup a billing Plan',
                    icon: Icons.error,
                  );
                  return;
                }

                var old_float = patient.clinic_info!.floating_amount;

                // session plan dialog for payment
                var res = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => SessionPaymentDialog(
                    session_details: {
                      'cost_p_session': patient.clinic_info!.cost_per_session,
                      'total_session': patient.clinic_info!.total_session,
                      'session_paid': patient.clinic_info!.paid_session,
                      'amount_paid': patient.clinic_info!.amount_paid,
                      'floating_amount': patient.clinic_info!.floating_amount,
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
                  var resp = await PhysioDatabaseHelpers.update_clinic_info(
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
                      old_float: old_float,
                      new_float: new_float,
                      session_frequency: '',
                    );

                    PhysioDatabaseHelpers.update_clinic_history(
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

          // (doctor only) (if doctor can treat)
          else if ((active_user!.app_role == 'Doctor') && can_treat)
            // treatment duration
            Center(
              child: Text(
                patient.clinic_variables?.treatment_duration ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Container(),

          ///

          /// TAB 2
          // (CSU user only)
          if (active_user!.app_role == 'CSU' || active_user!.app_role == 'ICT')
            // send to clinic
            if (patient.current_case_id == null)
              InkWell(
                onTap: () async {
                  // session plan not set
                  if (patient.clinic_info?.total_session == 0) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Setup a treatment plan',
                      icon: Icons.error,
                    );
                    return;
                  }

                  // treatment ended
                  var res = await PhysioDatabaseHelpers.get_case_file_by_date(
                      context,
                      patient_id: patient.patient_id,
                      treatment_date: DateTime.now(),
                      showLoading: true,
                      loadingText: 'Checking Previous Cases...');

                  if (res != null && res.isNotEmpty) if (PhysioDatabaseHelpers
                      .check_cases_by_type(
                          cases: res, case_type: 'Treatment')) {
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

                    await PhysioDatabaseHelpers.send_to_clinic(
                      context,
                      doctor_key: selected_doctor.key ?? '',
                      patient_key: patient.key ?? '',
                      treatment_type: 'Treatment',
                      treatment_duration: treatment_duration,
                      showLoading: true,
                      showToast: true,
                    );
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
            else
              // Awaiting doctor/ Duration
              Center(
                child: Text(
                  (patient.current_case_id == null)
                      ? 'Awaiting Doctor'
                      : patient.clinic_variables?.treatment_duration ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                if (patient.clinic_info?.total_session == 0) {
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
                  var res = await PhysioDatabaseHelpers.get_case_file_by_date(
                      context,
                      patient_id: patient.patient_id,
                      treatment_date: DateTime.now());

                  if (res != null && res.isNotEmpty) if (PhysioDatabaseHelpers
                      .check_cases_by_type(
                          cases: res, case_type: 'Treatment')) {
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
                      title: 'Go To TreatmentTab',
                      message:
                          'You are about to open the treatment tab for this client, Would you like to proceed?',
                      barrierDismissible: true);

                  if (conf) {
                    start_treatment(case_type: 'Treatment');
                  }
                } else
                  start_treatment(case_type: 'Treatment');
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
                      await PhysioDatabaseHelpers.change_treatment_duration(
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

                      await PhysioDatabaseHelpers.remove_from_clinic(
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
              Container()
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
  Widget clinic_setup({required child}) {
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
              session_set: (patient.clinic_info!.total_session != 0),
              total_session: (patient.clinic_info!.total_session != 0)
                  ? patient.clinic_info!.total_session.toString()
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
            var resp = await PhysioDatabaseHelpers.update_clinic_info(context,
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

              PhysioDatabaseHelpers.update_clinic_history(
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
            var resp = await PhysioDatabaseHelpers.update_clinic_info(context,
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

              PhysioDatabaseHelpers.update_clinic_history(
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
            await PhysioDatabaseHelpers.update_clinic_info(context,
                data: data, showLoading: true, showToast: true);
          }
        }

        // take assessment
        if (value == 4) {
          // pay for assessment
          Map conf = await PhysioDatabaseHelpers.pay_for_assessment(context,
              patient: patient,
              showLoading: true,
              showToast: true,
              loadingText: 'Paying for Assessment...');

          if (conf['status'] == true) {
            ClinicHistoryModel hist = conf['data'];

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

            // ? Goto Treatment tab
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

  // FUNCTIONS
  start_treatment({required String case_type}) async {
    // try to get case file
    CaseFileModel? caseFile = await PhysioDatabaseHelpers.start_treatment(
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

    // add patient to doctors tab
    PhysioDatabaseHelpers.update_doc_ongoing_patient(
      context,
      data: {'id': active_doctor?.key ?? '', 'patient': patient.key ?? ''},
    );

    // go to treatment page
    var bac = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentTab(
          patient: patient,
          treatmentInfo: treatmentModel,
          assessmentModel: assessmentModel,
          case_file: caseFile,
          assessment_completed: assessment_completed!,
          completed_session: patient.clinic_info?.completed_session ?? 0,
          session_details: null,
          treatment_duration:
              patient.clinic_variables?.treatment_duration ?? '',
          treatment_elapse: false,
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
