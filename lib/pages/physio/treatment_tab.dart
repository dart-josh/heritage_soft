import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/clinic_models/casefile.model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/physio_helpers.dart';
import 'package:heritage_soft/pages/physio/clinic_tab.dart';
import 'package:heritage_soft/pages/physio/request_accessories_page.dart';
import 'package:heritage_soft/pages/physio/widgets/clinic_info.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/pages/physio/widgets/physio_hmo_tag.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/pages/physio/widgets/session_plan_dialog.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class TreatmentTab extends StatefulWidget {
  final PatientModel patient;
  final TreatmentInfoModel? treatmentInfo;
  final AssessmentInfoModel? assessmentModel;
  final CaseFileModel case_file;
  final bool assessment_completed;
  final int completed_session;
  final SessionModel? session_details;
  final String treatment_duration;
  final bool treatment_elapse;

  const TreatmentTab({
    super.key,
    required this.patient,
    this.treatmentInfo,
    required this.assessmentModel,
    required this.case_file,
    required this.assessment_completed,
    required this.completed_session,
    required this.session_details,
    required this.treatment_duration,
    required this.treatment_elapse,
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

  bool file_set = false;
  CaseFileModel? case_file;

  bool assessment_completed = false;

  bool file_saved = false;

  SessionModel? session_set;

  late String treatment_duration;

  List<String> selected_case_select_options = [];

  String case_type_select = '';

  String treatment_type_select = '';

  List<String> selected_equipment_options = [];

  TextEditingController case_select_controller = TextEditingController();
  TextEditingController equipment_select_controller = TextEditingController();
  TextEditingController diagnosis_controller = TextEditingController();

  DoctorModel? active_doctor;

  update_controllers() {
    session_set = widget.session_details;
    bp_controller.text = case_file!.bp_reading;
    remarks_controller.text = case_file!.remarks;
    note_controller.text = case_file!.note;
    bp_reading = bp_controller.text;

    decision_select = case_file!.treatment_decision;
    decision_refered_select = case_file!.refered_decision;
    other_decision_controller.text = case_file!.other_decision;

    // assessment model
    if (widget.assessmentModel != null) {
      case_select_controller.text = widget.assessmentModel!.case_select;
      selected_case_select_options = case_select_controller.text.split(',');
      diagnosis_controller.text = widget.assessmentModel!.diagnosis;
      case_type_select = widget.assessmentModel!.case_type;
      treatment_type_select = widget.assessmentModel!.treatment_type;
      equipment_select_controller.text = widget.assessmentModel!.equipments.map((e) => e.equipmentName).toList().join(',');
      selected_equipment_options = equipment_select_controller.text.split(',');
    }
  }

  // validation
  bool validate_fields() {
    // assessment validation
    if (!assessment_completed) {
      if (case_select_controller.text.isEmpty) {
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
          toastText: 'Enter PT Diagnosis',
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

      if (session_set == null) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Setup Treatment sessions',
          icon: Icons.error,
        );
        return false;
      }
    }

    // general validation
    if (bp_reading.isEmpty) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'BP cannot be empty',
        icon: Icons.error,
      );
      return false;
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
  Future<bool> save_to_file() async {
    Helpers.showLoadingScreen(context: context);

    // save assessment data
    // if (!assessment_completed) {
    //   AssessmentInfoModel ass = AssessmentInfoModel(
    //     case_select: case_select_controller.text.trim(),
    //     diagnosis: diagnosis_controller.text.trim(),
    //     case_type: case_type_select,
    //     treatment_type: treatment_type_select,
    //     equipments: equipment_select_controller.text.split(',').map((e) => EquipmentModel(equipmentName: e.trim(), key: '', equipmentId: '', category: '', costing: 0, status: '', )).toList(), case_select_others: '', case_description: '', assessment_date: null,
    //   );

    //   // save assessment details
    //   // bool dt = await PhysioDatabaseHelpers.save_assessment_details(
    //   //     widget.patient.key, ass.toJson());

    //   if (!dt) {
    //     Navigator.pop(context);
    //     Helpers.showToast(
    //       context: context,
    //       color: Colors.redAccent,
    //       toastText: 'Error, Try again',
    //       icon: Icons.error,
    //     );
    //     return false;
    //   }
    // }

    // case file data
    // String sv_date = case_file!.key;

    // CaseFileModel file = CaseFileModel(
    //   treatment_date: case_file!.treatment_date,
    //   bp_reading: bp_reading,
    //   note: note_controller.text,
    //   remarks: remarks_controller.text,
    //   doctor: active_doctor != null ? active_doctor!.fullname : 'No Doctor',
    //   type: (assessment_completed) ? 'Treatment' : 'Assessment',
    //   key: case_file!.key,
    //   start_time: case_file!.start_time,
    //   end_time: case_file!.end_time,
    //   decision: decision_select,
    //   refered_decision: decision_refered_select,
    //   other_decision: other_decision_controller.text.trim(),
    // );

    // Map<String, dynamic> data = file.toJson_update();

    // update case file
    // bool cf = await PhysioDatabaseHelpers.save_case_file(
    //     widget.patient.key, sv_date, data);

    // if (!cf) {
    //   Navigator.pop(context);
    //   Helpers.showToast(
    //     context: context,
    //     color: Colors.redAccent,
    //     toastText: 'Error, Try again',
    //     icon: Icons.error,
    //   );
    //   return false;
    // }

    // file_saved = true;

    // Navigator.pop(context);
    // Helpers.showToast(
    //   context: context,
    //   color: Colors.blue,
    //   toastText: 'Case File Saved',
    //   icon: Icons.check,
    // );

    return true;
  }

  // end treatement
  end_treatment(DateTime date) async {
    // validate fields
    bool valid = validate_fields();

    if (!valid) return;

    var conf = await showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: !assessment_completed ? 'End Assessment' : 'End Treatment',
        subtitle:
            'You are about to end this ${!assessment_completed ? 'assessment' : 'treatment'}, Would you like to proceed?',
      ),
    );

    if (conf == null || conf == false) return;

    // save case file
    bool sav = await save_to_file();

    if (!sav) return;

    Helpers.showLoadingScreen(context: context);

    // treatment details
    Map<String, dynamic> t_data = {
      'date': date.toString(),
      if (widget.treatmentInfo!.last_treatment_date != null)
        'date_p': widget.treatmentInfo!.last_treatment_date!.toString(),
      if (widget.treatmentInfo != null)
        'last_bp_p': widget.treatmentInfo!.last_bp,
      'last_bp': bp_reading,
      'ongoing_treatment': false,
      'treatment_elapse': widget.treatment_elapse,
    };

    // assessment info data
    if (!assessment_completed) {
      t_data.addAll(
          {'assessment_completed': true, 'assessment_date': date.toString()});
    }

    // update treatment info
    // bool ti = await PhysioDatabaseHelpers.update_treatment_info(
    //     widget.patient.key, t_data,
    //     sett: (widget.treatmentInfo == null));

    // if (!ti) {
    //   Navigator.pop(context);
    //   Helpers.showToast(
    //     context: context,
    //     color: Colors.redAccent,
    //     toastText: 'Error, Try again',
    //     icon: Icons.error,
    //   );
    //   return;
    // }

    // // update case file with end time
    // bool cf = await PhysioDatabaseHelpers.save_case_file(
    //   widget.client.key,
    //   widget.case_file.key,
    //   {'end_time': DateTime.now().toString()},
    // );

    // if (!cf) {
    //   Navigator.pop(context);
    //   Helpers.showToast(
    //     context: context,
    //     color: Colors.redAccent,
    //     toastText: 'Error, Try again',
    //     icon: Icons.error,
    //   );
    //   return;
    // }

    // // update clinic info increase completed sessions
    // if (assessment_completed) {
    //   int compl = widget.completed_session + 1;

    //   bool ci = await PhysioDatabaseHelpers.update_clinic_info(
    //     widget.client.key,
    //     {'completed_session': compl},
    //   );

    //   if (!ci) {
    //     Navigator.pop(context);
    //     Helpers.showToast(
    //       context: context,
    //       color: Colors.redAccent,
    //       toastText: 'Error, Try again',
    //       icon: Icons.error,
    //     );
    //     return;
    //   }
    // }

    // // update doctor tab with patient & remove from clinic
    // await PhysioDatabaseHelpers.add_patient_to_doctor_tab(
    //     active_doctor!.key, widget.client.key);

    // // remove loading screen
    // Navigator.pop(context);

    // // remove page with end of treatment
    // Navigator.pop(context, 'done');
  }

  @override
  void initState() {
    treatment_duration = widget.treatment_duration;
    assessment_completed = widget.assessment_completed;
    case_file = widget.case_file;
    update_controllers();

    bp_controller.addListener(() {
      bp_reading = bp_controller.text.trim();
      file_saved = false;
      setState(() {});
    });

    remarks_controller.addListener(() {
      file_saved = false;
    });

    note_controller.addListener(() {
      file_saved = false;
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
    equipment_select_controller.dispose();
    diagnosis_controller.dispose();
    other_decision_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;
    double height = MediaQuery.of(context).size.height * 0.97;
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
            child: assessment_completed ? treatment_area() : assessment_area(),
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
        start_time: case_file!.start_time!));

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
                assessment_completed ? 'Treatment Tab' : 'Assessment Tab',
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
                  if (!assessment_completed)
                    InkWell(
                      onTap: () async {
                        var res = await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => SessionPlanDialog(
                            session_set: false,
                            total_session: null,
                            session_details: session_set != null
                                ? {
                                    'total_sess':
                                        session_set!.total_session.toString(),
                                    'frequency': ''
                                  }
                                : null,
                          ),
                        );

                        // if (res != null) {
                        //   Map r_map = res;

                        //   int total = r_map['total'];
                        //   String frequency = r_map['frequency'];

                        //   Helpers.showLoadingScreen(context: context);

                          // set clinic info
                        //   bool ci =
                        //       await PhysioDatabaseHelpers.update_clinic_info(
                        //     widget.client.key,
                        //     {
                        //       'total_session': total,
                        //       'frequency': frequency,
                        //       'completed_session': 0,
                        //       'paid_session': 0,
                        //     },
                        //     sett: true,
                        //   );

                        //   Navigator.pop(context);

                        //   if (!ci) {
                        //     Helpers.showToast(
                        //       context: context,
                        //       color: Colors.red,
                        //       toastText: 'An Error occurred',
                        //       icon: Icons.error,
                        //     );
                        //     return;
                        //   }

                        //   PhysioHistoryModel hist = PhysioHistoryModel(
                        //     hist_type: 'Session Setup',
                        //     amount: 0,
                        //     amount_b4_discount: 0,
                        //     date: DateTime.now(),
                        //     session_paid: total,
                        //     history_id: Helpers.generate_order_id(),
                        //     cost_p_session: 0,
                        //     old_float: 0,
                        //     new_float: 0,
                        //     session_frequency: frequency,
                        //   );

                        //   PhysioDatabaseHelpers.add_history(
                        //       widget.client.key, hist.toJson());

                        //   session_set = SessionModel(
                        //     total_session: total,
                        //     completed_session: 0,
                        //     paid_session: 0,
                        //     frequency: frequency,
                        //     cost_per_session: 0,
                        //     amount_paid: 0,
                        //     floating_amount: 0,
                        //   );

                        //   setState(() {});
                        // }
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
                  if (assessment_completed)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: InkWell(
                        onTap: () {
                          if (widget.treatmentInfo == null) return;

                          if (!assessment_completed) return;

                          if (widget.assessmentModel == null) return;

                          // showDialog(
                          //   context: context,
                          //   builder: (context) => CaseFileD(
                          //     client: widget.client,
                          //     case_title: widget.assessmentModel!.diagnosis,
                          //   ),
                          // );
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
                        if (file_saved) {
                          Navigator.pop(context);
                          return;
                        }

                        var res = await showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: 'Ongoing Treatment',
                            subtitle:
                                'This Treatment has not ended, save this treatment before leaving?',
                          ),
                        );

                        if (res != null) {
                          if (res == true) {
                            await save_to_file();
                          }

                          Navigator.pop(context);
                        }
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
        //   Helpers.showLoadingScreen(context: context);

        //   List<G_PhysioHealthModel> _all = [];

        //   await PhysioDatabaseHelpers.get_physio_health_info(widget.client.key)
        //       .then((snap) async {
        //     snap.docs.forEach((element) {
        //       _all.add(G_PhysioHealthModel(
        //           key: element.id,
        //           data: PhysioHealthModel.fromMap(element.id, element.data())));
        //     });

        //     Navigator.pop(context);

        //     if (_all.isNotEmpty) {
        //       if (widget.client.baseline_done) {
        //         var conf = await showDialog(
        //             context: context,
        //             builder: (context) =>
        //                 PhysioHealthSelectorDialog(list: _all));

        //         if (conf != null) {
        //           if (!conf[1]) {
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                 builder: (context) => PhysioClientHDPage(
        //                   client: widget.client,
        //                   health: conf[0],
        //                 ),
        //               ),
        //             );
        //           }
        //         }
        //       } else {
        //         var data = _all
        //             .where((element) => element.key == 'Baseline')
        //             .first
        //             .data;

        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => PhysioClientHDPage(
        //               client: widget.client,
        //               health: data,
        //             ),
        //           ),
        //         );
        //       }
        //     } else {
        //       if (app_role != 'desk') {
        //         Helpers.showToast(
        //           context: context,
        //           color: Colors.red,
        //           toastText: 'No Health details',
        //           icon: Icons.error,
        //         );
        //         return;
        //       }
        //     }
        //   });
        // }

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
          if (widget.assessmentModel != null) {
            showDialog(
              context: context,
              builder: (context) => ClinicInfo(info: widget.assessmentModel!),
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
        if (assessment_completed)
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
                widget.patient.f_name.trim(),
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
          // save file
          InkWell(
            onTap: () {
              save_to_file();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              height: 30,
              width: 120,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.save,
                      size: 25,
                      color: Colors.white,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Save to File',
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

          SizedBox(width: 10),

          // end treatment
          InkWell(
            onTap: () {
              end_treatment(DateTime.now());
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
                      !assessment_completed
                          ? 'End Assessment'
                          : 'End Treatment',
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

    if (selected_equipment_options.isNotEmpty)
      equipment_select_controller.text = selected_equipment_options.join(',');
    else
      equipment_select_controller.text = '';

    if (case_select_controller.text.startsWith(',')) {
      case_select_controller.text =
          case_select_controller.text.replaceFirst(',', '');
    }

    if (equipment_select_controller.text.startsWith(',')) {
      equipment_select_controller.text =
          equipment_select_controller.text.replaceFirst(',', '');
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

                  // equipment
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text_field(
                      label: 'Equipment',
                      controller: equipment_select_controller,
                      edit: true,
                      icon: equipment_multi_select(
                        child: Icon(
                          Icons.select_all,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
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
                                    label: assessment_completed
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
          if (widget.assessmentModel != null &&
              widget.assessmentModel!.diagnosis.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.assessmentModel!.diagnosis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          if (widget.assessmentModel != null) SizedBox(height: 5),

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
                                          label: assessment_completed
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
              if (widget.treatmentInfo!.last_bp_p.isNotEmpty)
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
                      widget.treatmentInfo!.last_bp_p,
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
                  widget.treatmentInfo!.last_treatment_date_p != null
                      ? Helpers.date_format(
                          widget.treatmentInfo!.last_treatment_date_p!)
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
                    widget.treatmentInfo!.last_bp,
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
                  widget.treatmentInfo!.last_treatment_date != null
                      ? Helpers.date_format(
                          widget.treatmentInfo!.last_treatment_date!)
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
                    options: decision_select_options,
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
    return PopupMenuButton<String>(
        padding: EdgeInsets.all(0),
        offset: Offset(0, 30),
        child: child,
        elevation: 8,
        onSelected: (value) async {
          bool is_in = selected_case_select_options.contains(value);

          if (is_in) {
            selected_case_select_options.remove(value);
          } else {
            selected_case_select_options.add(value);
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

  // equipment select
  Widget equipment_multi_select({required child}) {
    return PopupMenuButton<String>(
        padding: EdgeInsets.all(0),
        offset: Offset(0, 30),
        child: child,
        elevation: 8,
        onSelected: (value) async {
          bool is_in = selected_equipment_options.contains(value);

          if (is_in) {
            selected_equipment_options.remove(value);
          } else {
            selected_equipment_options.add(value);
          }

          setState(() {});
        },
        itemBuilder: (context) => equipment_options.map((e) {
              bool is_in = selected_equipment_options.contains(e);

              return PopupMenuItem(
                enabled: !(e.startsWith('*')),
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
                    e.replaceAll('*', ''),
                    style: TextStyle(),
                  ),
                ),
              );
            }).toList());
  }

  //
}
