import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/datamodels/users_model.dart';
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
  final PhysioHealthClientModel client;
  final bool can_treat;
  const ClinicTab({super.key, required this.client, required this.can_treat});

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

  TreatmentModel? treatmentModel;
  AssessmentModel? assessmentModel;

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

  // stream session info
  get_sessions() {
    session_stream_sub =
        PhysioDatabaseHelpers.session_info_stream(widget.client.key)
            .listen((event) {
      Map<String, dynamic>? map = event.data();

      if (map != null) {
        session_set = true;
        cost_per_session = map['cost_per_session'] ?? null;

        _session_details = SessionModel.fromMap(map);
      }
    });
  }

  // stream clinin variables
  get_variables() {
    var_stream_sub =
        PhysioDatabaseHelpers.clinic_variables_stream(widget.client.key)
            .listen((event) {
      Map? map = event.data();

      if (map != null) {
        // if client is removed from doctor
        // pop the page off
        if (app_role == 'doctor' && can_treat) {
          if (map['can_treat'] != null && map['can_treat'] == false) {
            if (mounted) Navigator.pop(context);
          }
        }

        treatment_duration = map['treatment_duration'] ?? treatment_duration;
        start_time = (map['start_time'] != null)
            ? DateTime.parse(map['start_time'])
            : null;
        can_treat = map['can_treat'] ?? true;
        current_doctor = map['current_doctor'] ?? '';

        if (current_doctor != '') {
          pending_treatment = true;
        } else {
          pending_treatment = false;
        }
      }
    });
  }

  // stream treatment info
  get_treatment() {
    trt_stream_sub =
        PhysioDatabaseHelpers.treatment_info_stream(widget.client.key)
            .listen((event) {
      Map<String, dynamic>? map = event.data();

      if (map != null) {
        // assessment completed
        assessment_completed = map['assessment_completed'] ?? false;

        // ongoing treatment
        ongoing_treatment = map['ongoing_treatment'] ?? false;

        // assessment date
        if (map['assessment_date'] != null) {
          assessment_date = DateTime.parse(map['assessment_date']);
        }

        // assessment paid
        assessment_paid = map['assessment_paid'] ?? false;

        //? skip_assessment
        skip_assessment = map['skip_assessment'] ?? false;

        // treatment model
        treatmentModel = TreatmentModel.fromMap(map);
      } else {
        treatmentModel = null;
        assessment_completed = false;
        ongoing_treatment = false;
      }

      if (mounted) setState(() {});
    });
  }

  // assessment stream
  get_assessment() {
    ass_stream_sub =
        PhysioDatabaseHelpers.assessment_info_stream(widget.client.key)
            .listen((event) {
      Map<String, dynamic>? map = event.data();

      if (map != null) {
        assessmentModel = AssessmentModel.fromMap(map);
      }
    });
  }

  @override
  void initState() {
    get_treatment();
    get_assessment();
    get_variables();
    get_sessions();
    can_treat = widget.can_treat;
    // check for pending treatment
    // if (app_role == 'desk') check_clinic();
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    trt_stream_sub!.cancel();
    ass_stream_sub!.cancel();
    var_stream_sub!.cancel();
    session_stream_sub!.cancel();
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
              // Duration (only for desk user)
              if (app_role == 'desk' || app_role == 'ict')
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                profile_area(),

                //?
                if (skip_assessment)
                  InkWell(
                    onTap: () async {
                      if (assessmentModel != null) {
                        var con = await showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: 'Complete Details',
                            subtitle:
                                'Do you want to submit this details and move to the session setup?',
                            boolean: true,
                          ),
                        );

                        if (con != null) {
                          if (con) {
                            Helpers.showLoadingScreen(context: context);

                            // update treatment info
                            bool ti = await PhysioDatabaseHelpers
                                .update_treatment_info(
                              widget.client.key,
                              {'skip_assessment': false},
                            );

                            Navigator.pop(context);

                            if (!ti) {
                              Helpers.showToast(
                                context: context,
                                color: Colors.redAccent,
                                toastText: 'Error, Try again',
                                icon: Icons.error,
                              );
                              return;
                            }

                            return;
                          }
                        } else {
                          return;
                        }
                      }

                      var res = await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => ClinicInfo(
                            info: assessmentModel ?? null, new_det: true),
                      );

                      if (res != null) {
                        AssessmentModel ass = res;

                        Helpers.showLoadingScreen(context: context);

                        // save assessment details
                        bool dt =
                            await PhysioDatabaseHelpers.save_assessment_details(
                                widget.client.key, ass.toJson());

                        Navigator.pop(context);

                        if (!dt) {
                          Helpers.showToast(
                            context: context,
                            color: Colors.redAccent,
                            toastText: 'Error, Try again',
                            icon: Icons.error,
                          );
                          return;
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                      child: Text('Assessment details'),
                    ),
                  )
                else if (assessment_completed != null && assessment_completed!)

                  // session setup
                  if (app_role == 'doctor')
                    session_setup(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Text('Session Setup'),
                      ),
                    )

                  // billing setup
                  else if (app_role == 'desk' || app_role == 'ict')
                    InkWell(
                      onTap: () async {
                        var con = await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => BillingDialog(
                            cost_per_session: cost_per_session,
                            current_cost: _session_details != null &&
                                    cost_per_session != null
                                ? ((_session_details!.total_session -
                                        _session_details!.paid_session) *
                                    cost_per_session!)
                                : 0,
                          ),
                        );

                        if (con != null) {
                          int val = con;

                          Helpers.showLoadingScreen(context: context);

                          // update price per session
                          bool res =
                              await PhysioDatabaseHelpers.update_clinic_info(
                                  widget.client.key, {'cost_per_session': val});

                          // if error
                          if (!res) {
                            Navigator.pop(context);
                            Helpers.showToast(
                              context: context,
                              color: Colors.red,
                              toastText: 'Error, Try again',
                              icon: Icons.error,
                            );
                            return;
                          }

                          Navigator.pop(context);

                          // success
                          Helpers.showToast(
                            context: context,
                            color: Colors.blue,
                            toastText: 'Price per session Updated',
                            icon: Icons.error,
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Text('Billing Setup'),
                      ),
                    )
                  else
                    Container()

                //? skip assessment
                else if (assessment_completed != null &&
                    !assessment_completed! &&
                    !assessment_paid)
                  if (app_role == 'desk' || app_role == 'ict')
                    InkWell(
                      onTap: () async {
                        var conf = await showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: 'Skip Assessment',
                            subtitle:
                                'You are about to skip this assessment, Would you like to proceed?',
                          ),
                        );

                        if (conf == null || !conf) return;

                        Helpers.showLoadingScreen(context: context);

                        // assessment info data
                        Map<String, dynamic> t_data = {
                          'assessment_completed': true,
                          'assessment_date': DateTime.now().toString(),
                          'skip_assessment': true,
                          'assessment_paid': true,
                        };

                        // update treatment info
                        bool ti =
                            await PhysioDatabaseHelpers.update_treatment_info(
                          widget.client.key,
                          t_data,
                          sett: true,
                        );

                        if (!ti) {
                          Navigator.pop(context);
                          Helpers.showToast(
                            context: context,
                            color: Colors.redAccent,
                            toastText: 'Error, Try again',
                            icon: Icons.error,
                          );
                          return;
                        }

                        Navigator.pop(context);
                        Helpers.showToast(
                          context: context,
                          color: Colors.blue,
                          toastText: 'Assessment Skipped',
                          icon: Icons.error,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Text('Skip Assessment'),
                      ),
                    ),
              ],
            ),
          ),

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
                  if (app_role != 'doctor')
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: InkWell(
                        onTap: () async {
                          Physio_His_CL_Model client_att = Physio_His_CL_Model(
                            key: widget.client.key,
                            id: widget.client.id,
                            name: widget.client.name.split(' ')[0],
                            fullname: widget.client.name,
                            total_amount_paid:
                                _session_details?.amount_paid ?? 0,
                            hmo: widget.client.hmo,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PhysioHistoryPage(client: client_att),
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
                  if (app_role != 'doctor')
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
                                client_id: widget.client.id,
                                client_name: widget.client.name,
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
                              client: widget.client,
                              case_title: assessmentModel!.diagnosis,
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
                  if ((app_role == 'doctor') && widget.can_treat)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestAccessoriesPage(
                                client: widget.client,
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
                widget.client.id,
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
              PhysioHMOTag(hmo: widget.client.hmo),
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
              builder: (context) => PhysioClientProfilePage(
                cl_id: widget.client.key,
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
                  widget.client.name.trim(),
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
                backgroundImage: widget.client.user_image.isNotEmpty
                    ? NetworkImage(
                        widget.client.user_image,
                      )
                    : null,
                child: Center(
                  child: widget.client.user_image.isEmpty
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

    // loading
    if (assessment_completed == null)
      return Container(
        child: CircularProgressIndicator(),
      );

    // assessment not yet completed
    if (!assessment_completed!)
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
            mainAxisAlignment: (app_role != 'doctor')
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.center,
            children: [
              // total cost
              if (app_role != 'doctor')
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
              if (app_role != 'doctor')
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

              if (app_role == 'doctor') SizedBox(width: 150),

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

    if (assessment_completed == null) return Container();

    bool my_patient_to_treat =
        (app_role == 'doctor') ? current_doctor == active_doctor!.key : false;

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          /// TAB 1
          // pay for session (desk user only)
          if (app_role == 'desk' || app_role == 'ict')
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
                      Helpers.showLoadingScreen(context: context);
                      // update assessment paid
                      bool res =
                          await PhysioDatabaseHelpers.update_treatment_info(
                        widget.client.key,
                        {'assessment_paid': true},
                        sett: true,
                      );

                      // error
                      if (!res) {
                        Navigator.pop(context);
                        Helpers.showToast(
                          context: context,
                          color: Colors.red,
                          toastText: 'Error occurred',
                          icon: Icons.check,
                        );
                        return;
                      }

                      PhysioHistoryModel hist = PhysioHistoryModel(
                        hist_type: 'Assessment Payment',
                        amount: conf,
                        amount_b4_discount: 0,
                        date: DateTime.now(),
                        session_paid: 1,
                        history_id: Helpers.generate_order_id(),
                        cost_p_session: 0,
                        old_float: 0,
                        new_float: 0,
                      );

                      bool res2 = await PhysioDatabaseHelpers.add_history(
                          widget.client.key, hist.toJson());

                      // error
                      if (!res2) {
                        Navigator.pop(context);
                        Helpers.showToast(
                          context: context,
                          color: Colors.red,
                          toastText: 'Error occurred',
                          icon: Icons.check,
                        );
                        return;
                      }

                      Navigator.pop(context);

                      assessment_print = PhysioPaymentPrintModel(
                        date:
                            '${DateFormat.jm().format(hist.date)} ${DateFormat('dd-MM-yyyy').format(hist.date)}',
                        receipt_id: hist.history_id,
                        client_id: widget.client.id,
                        client_name: widget.client.name,
                        amount: hist.amount,
                        receipt_type: hist.hist_type,
                        session_paid: hist.session_paid,
                        amount_b4_discount: hist.amount_b4_discount,
                        cost_p_session: hist.cost_p_session,
                        old_float: hist.old_float,
                        new_float: hist.new_float,
                      );

                      Helpers.showToast(
                        context: context,
                        color: Colors.blue,
                        toastText: 'Assessment payment complete',
                        icon: Icons.check,
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
                if (!session_set || _session_details == null) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Setup a Session Plan',
                    icon: Icons.error,
                  );
                  return;
                }

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
                  Map<String, dynamic> map = {
                    'amount_paid': res['total_amount'],
                    'paid_session': res['total_active_session'],
                    'floating_amount': res['floating_amount'],
                  };

                  int amount_paid = res['discounted_amount'];
                  int amount_b4_discount = res['amount_to_pay'];
                  int new_session = res['new_session'];

                  var new_float = res['floating_amount'];

                  Helpers.showLoadingScreen(context: context);

                  // update paid session
                  bool dt = await PhysioDatabaseHelpers.update_clinic_info(
                      widget.client.key, map);

                  // error
                  if (!dt) {
                    Navigator.pop(context);
                    Helpers.showToast(
                      context: context,
                      color: Colors.red,
                      toastText: 'An Error occurred',
                      icon: Icons.error,
                    );
                    return;
                  }

                  PhysioHistoryModel historyModel = PhysioHistoryModel(
                    hist_type: 'Session Payment',
                    amount: amount_paid,
                    amount_b4_discount: amount_b4_discount,
                    date: DateTime.now(),
                    session_paid: new_session,
                    history_id: Helpers.generate_order_id(),
                    cost_p_session: cost_per_session ?? 0,
                    old_float: old_float,
                    new_float: new_float,
                  );

                  bool res2 = await PhysioDatabaseHelpers.add_history(
                      widget.client.key, historyModel.toJson());

                  // error
                  if (!res2) {
                    Navigator.pop(context);
                    Helpers.showToast(
                      context: context,
                      color: Colors.red,
                      toastText: 'Error occurred',
                      icon: Icons.check,
                    );
                    return;
                  }

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
                      client_id: widget.client.id,
                      client_name: widget.client.name,
                      amount: historyModel.amount,
                      receipt_type: historyModel.hist_type,
                      session_paid: historyModel.session_paid,
                      amount_b4_discount: historyModel.amount_b4_discount,
                      cost_p_session: historyModel.cost_p_session,
                      old_float: historyModel.old_float,
                      new_float: historyModel.new_float,
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
          else if ((app_role == 'doctor') &&
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
          // send to clinic (desk user only)
          if (app_role == 'desk' || app_role == 'ict')
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

                // error if assessment not paid
                if (!assessment_paid) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.redAccent,
                    toastText: 'Complete assessment payment',
                    icon: Icons.error,
                  );
                  return;
                }

                // widget.client.key
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

                  Helpers.showLoadingScreen(context: context);

                  // remove from clinic
                  if (pending_treatment)
                    await PhysioDatabaseHelpers.remove_from_clinic(
                      current_doctor,
                      widget.client.key,
                      remove: false,
                    );

                  // assign to doctor
                  bool dt = await PhysioDatabaseHelpers.update_doctors_temp_tab(
                    selected_doctor.key,
                    widget.client.key,
                    {'ongoing_treatment': false, 'pending_treatment': true},
                  );

                  if (!dt) {
                    Navigator.pop(context);
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'An Error Occurred',
                      icon: Icons.error,
                    );
                    return;
                  }

                  // set treatment duration
                  bool dt_2 =
                      await PhysioDatabaseHelpers.update_clinic_variables(
                    widget.client.key,
                    {
                      'treatment_duration': treatment_duration,
                      'can_treat': true,
                      'current_doctor': selected_doctor.key,
                    },
                    sett: true,
                  );

                  if (!dt_2) {
                    Navigator.pop(context);
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'An Error Occurred',
                      icon: Icons.error,
                    );
                    return;
                  }

                  Navigator.pop(context);
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
                  child: Text(
                      !assessment_completed!
                          ? 'Send For Assessment'
                          : 'Send to Clinic',
                      style: action_style),
                ),
              ),
            )

          // treatment countdoun (doctor only) (if ongoing treatment)
          else if ((app_role == 'doctor') &&
              widget.can_treat &&
              can_treat &&
              my_patient_to_treat)
            if (ongoing_treatment!) time() else Container()
          else
            Container(),

          ///

          /// Tab 3
          // doctor's action (if doctor can treat)
          if ((app_role == 'doctor') && widget.can_treat && my_patient_to_treat)
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

          // desk user action
          else if (app_role == 'desk' || app_role == 'ict')
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
                      bool dt =
                          await PhysioDatabaseHelpers.update_clinic_variables(
                        widget.client.key,
                        {'treatment_duration': treatment_duration},
                      );

                      Navigator.pop(context);

                      // error
                      if (!dt) {
                        Helpers.showToast(
                          context: context,
                          color: Colors.red,
                          toastText: 'An Error occurred, Try again',
                          icon: Icons.error,
                        );
                        return;
                      }
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

                      Helpers.showLoadingScreen(context: context);

                      bool dt = await PhysioDatabaseHelpers.remove_from_clinic(
                        current_doctor,
                        widget.client.key,
                        remove: true,
                      );

                      Navigator.pop(context);

                      // error
                      if (!dt) {
                        Helpers.showToast(
                          context: context,
                          color: Colors.red,
                          toastText: 'An Error occurred',
                          icon: Icons.error,
                        );
                        return;
                      }

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
    Helpers.showLoadingScreen(context: context);

    // assign case file key
    String sv_date = (!assessment_completed!)
        ? '${Helpers.date_format(continue_treatment ? current_treatment_date : DateTime.now())} (Assessment)'
        : Helpers.date_format(
            continue_treatment ? current_treatment_date : DateTime.now());

    // check for case file
    await PhysioDatabaseHelpers.get_case_file(widget.client.key, sv_date)
        .then((snap) async {
      CaseFileModel file;

      // existing case file
      if (snap.exists) {
        file = CaseFileModel.fromMap(snap.id, snap.data()!);
      }
      // new case file data
      else {
        file = CaseFileModel(
          treatment_date: DateTime.now(),
          bp_reading: '',
          note: '',
          remarks: '',
          doctor: active_doctor != null ? active_doctor!.fullname : '',
          type: (assessment_completed!) ? 'Treatment' : 'Assessment',
          key: sv_date,
          start_time: DateTime.now(),
          end_time: null,
          decision: '',
          refered_decision: '',
          other_decision: '',
        );

        Map<String, dynamic> data = file.toJson_open();

        // open case file
        bool dt = await PhysioDatabaseHelpers.save_case_file(
          widget.client.key,
          sv_date,
          data,
          sett: true,
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
        PhysioDatabaseHelpers.update_clinic_variables(
            widget.client.key, {'start_time': DateTime.now().toString()});

        // set current treatment date
        PhysioDatabaseHelpers.update_treatment_info(
          widget.client.key,
          {'current_treatment_date': DateTime.now().toString()},
        );
      }

      // set ongoing treatment = true
      PhysioDatabaseHelpers.update_treatment_info(
        widget.client.key,
        {'ongoing_treatment': true},
      );

      // add patient to doctors tab
      PhysioDatabaseHelpers.update_doctors_temp_tab(
        active_doctor!.key,
        widget.client.key,
        {'ongoing_treatment': true, 'pending_treatment': false},
      );

      // remove loading screen
      Navigator.pop(context);

      // go to treatment page
      var bac = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreatmentTab(
            client: widget.client,
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
    });
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
              PhysioDatabaseHelpers.update_clinic_info(
                widget.client.key,
                {'total_session': total, 'frequency': frequency},
              );
            }

            // set session info
            else {
              PhysioDatabaseHelpers.update_clinic_info(
                widget.client.key,
                {
                  'total_session': total,
                  'frequency': frequency,
                  'completed_session': 0,
                  'paid_session': 0,
                },
                sett: true,
              );
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

            PhysioDatabaseHelpers.add_history(widget.client.key, hist.toJson());
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

            PhysioDatabaseHelpers.update_clinic_info(
              widget.client.key,
              {'total_session': new_sess},
            );

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

            PhysioDatabaseHelpers.add_history(widget.client.key, hist.toJson());

            setState(() {});
          }
        }
      },
      itemBuilder: (context) => [
        // session plan
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
