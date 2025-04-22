import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/helpers/physio_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/physio/clinic_tab.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';

class PhysioHealthRegistrationPage extends StatefulWidget {
  final bool register;
  final PhysioHealthModel health;
  final PhysioHealthClientModel client;
  const PhysioHealthRegistrationPage({
    super.key,
    this.register = false,
    required this.health,
    required this.client,
  });

  @override
  State<PhysioHealthRegistrationPage> createState() =>
      _PhysioHealthRegistrationPageState();
}

class _PhysioHealthRegistrationPageState
    extends State<PhysioHealthRegistrationPage> {
  TextStyle headingStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
    fontSize: 18,
  );

  PhysioHealthModel? health;
  PhysioHealthClientModel? client;

  String fmt_date(String date) {
    return DateFormat('d MMM, y').format(DateFormat('dd_MM_yyyy').parse(date));
  }

  @override
  void initState() {
    client = widget.client;
    health = widget.health;

    update_health_controllers();

    height_controller.addListener(() {
      double height = height_controller.text.isNotEmpty
          ? double.parse(height_controller.text)
          : 0;
      double weight = weight_controller.text.isNotEmpty
          ? double.parse(weight_controller.text)
          : 0;

      Map<String, String> result = Helpers.calc_bmi(height, weight);

      if (result.isEmpty) {
        bmi_select = '';
        bmi_controller.text = '';
      } else {
        bmi_select = result['bmi_class']!;
        bmi_controller.text = result['bmi_fig']!;
      }

      setState(() {});
    });

    weight_controller.addListener(() {
      double height = height_controller.text.isNotEmpty
          ? double.parse(height_controller.text)
          : 0;
      double weight = weight_controller.text.isNotEmpty
          ? double.parse(weight_controller.text)
          : 0;

      Map<String, String> result = Helpers.calc_bmi(height, weight);

      if (result.isEmpty) {
        bmi_select = '';
        bmi_controller.text = '';
      } else {
        bmi_select = result['bmi_class']!;
        bmi_controller.text = result['bmi_fig']!;
      }

      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    // text controller
    height_controller.dispose();
    weight_controller.dispose();
    bmi_controller.dispose();
    ideal_weight_controller.dispose();
    fat_rate_controller.dispose();
    weight_gap_controller.dispose();
    weight_target_controller.dispose();

    waist_controller.dispose();
    arm_controller.dispose();
    chest_controller.dispose();
    thigh_controller.dispose();
    hip_controller.dispose();
    pr_controller.dispose();
    bp_controller.dispose();

    // total cholestrol
    tC_observed_controller.dispose();
    tC_normal_controller.dispose();
    tC_remarks_controller.dispose();

    // high density lipoproteins
    hdl_observed_controller.dispose();
    hdl_normal_controller.dispose();
    hdl_remarks_controller.dispose();

    // low density lipoproteins
    ldl_observed_controller.dispose();
    ldl_normal_controller.dispose();
    ldl_remarks_controller.dispose();

    // Triglycerides
    tg_observed_controller.dispose();
    tg_normal_controller.dispose();
    tg_remarks_controller.dispose();

    // eating habits
    eb_findings_controller.dispose();
    eb_recommendations_controller.dispose();

    // smoking habits
    sb_findings_controller.dispose();
    sb_recommendations_controller.dispose();

    // alcohol habits
    ab_findings_controller.dispose();
    ab_recommendations_controller.dispose();

    // others
    others_findings_controller.dispose();
    others_recommendations_controller.dispose();

    objective_controller.dispose();

    //

    // focus node
    height_node.dispose();
    weight_node.dispose();
    bmi_node.dispose();
    ideal_weight_node.dispose();
    fat_rate_node.dispose();
    weight_gap_node.dispose();
    weight_target_node.dispose();

    waist_node.dispose();
    arm_node.dispose();
    chest_node.dispose();
    thigh_node.dispose();
    hip_node.dispose();
    pr_node.dispose();
    bp_node.dispose();

    objective_node.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.85;
    double height = MediaQuery.of(context).size.height * 0.93;
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
                          'images/health_assessment.jpg',
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

  // WIDGETs

  // main page
  Widget main_page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // top bar
        topBar(),

        // main body
        Expanded(
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: left_side(),
                ),
                Expanded(
                  flex: 5,
                  child: right_side(),
                ),
              ],
            ),
          ),
        ),

        // actions
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Center(
            child: Container(width: 300, child: submit_button()),
          ),
        ),
      ],
    );
  }

  // top bar
  Widget topBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        children: [
          // id area, reset & return button
          Row(
            children: [
              // id
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // id label
                  Text(
                    'ID',
                    style: TextStyle(
                      color: Color(0xFFAFAFAF),
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),

                  // client id
                  Text(
                    client!.id,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1,
                      height: 0.8,
                      shadows: [
                        Shadow(
                          color: Color(0xFF000000),
                          offset: Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Expanded(child: Container()),

              // reset icon
              (widget.register) ? reset_button() : Container(),

              SizedBox(width: 10),

              // return button
              InkWell(
                onTap: () async {
                  var conf = await showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      title: 'Close form',
                      subtitle:
                          'You are about to close this form, you would loose all details entered. Would you like to proceed?',
                      boolean: true,
                    ),
                  );

                  if (conf != null && conf) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Color(0xFFe93f3f),
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // icon
                      Image.asset(
                        'images/icon/icon-return.png',
                        width: 20,
                        height: 12,
                      ),

                      SizedBox(width: 6),

                      Text(
                        'Return',
                        style: TextStyle(
                          color: Color(0xFFe93f3f),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // heading
          Positioned(
            top: 10,
            right: 0,
            left: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFababab)),
                  ),
                ),
                child: Text(
                  '${health!.key == 'Baseline' ? 'Baseline ' : ''}Health Information Form [${fmt_date(health!.date)}]',
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
                client!.name,
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
              backgroundImage: client!.user_image.isNotEmpty
                  ? NetworkImage(
                      client!.user_image,
                    )
                  : null,
              child: Center(
                child: client!.user_image.isEmpty
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

  // text controller
  TextEditingController height_controller = TextEditingController();
  TextEditingController weight_controller = TextEditingController();
  TextEditingController bmi_controller = TextEditingController();
  TextEditingController ideal_weight_controller = TextEditingController();
  TextEditingController fat_rate_controller = TextEditingController();
  TextEditingController weight_gap_controller = TextEditingController();
  TextEditingController weight_target_controller = TextEditingController();

  TextEditingController waist_controller = TextEditingController();
  TextEditingController arm_controller = TextEditingController();
  TextEditingController chest_controller = TextEditingController();
  TextEditingController thigh_controller = TextEditingController();
  TextEditingController hip_controller = TextEditingController();
  TextEditingController pr_controller = TextEditingController();
  TextEditingController bp_controller = TextEditingController();

  // total cholestrol
  TextEditingController tC_observed_controller = TextEditingController();
  TextEditingController tC_normal_controller = TextEditingController();
  TextEditingController tC_remarks_controller = TextEditingController();

  // high density lipoproteins
  TextEditingController hdl_observed_controller = TextEditingController();
  TextEditingController hdl_normal_controller = TextEditingController();
  TextEditingController hdl_remarks_controller = TextEditingController();

  // low density lipoproteins
  TextEditingController ldl_observed_controller = TextEditingController();
  TextEditingController ldl_normal_controller = TextEditingController();
  TextEditingController ldl_remarks_controller = TextEditingController();

  // Triglycerides
  TextEditingController tg_observed_controller = TextEditingController();
  TextEditingController tg_normal_controller = TextEditingController();
  TextEditingController tg_remarks_controller = TextEditingController();

  // eating habits
  TextEditingController eb_findings_controller = TextEditingController();
  TextEditingController eb_recommendations_controller = TextEditingController();

  // smoking habits
  TextEditingController sb_findings_controller = TextEditingController();
  TextEditingController sb_recommendations_controller = TextEditingController();

  // alcohol habits
  TextEditingController ab_findings_controller = TextEditingController();
  TextEditingController ab_recommendations_controller = TextEditingController();

  // others
  TextEditingController others_findings_controller = TextEditingController();
  TextEditingController others_recommendations_controller =
      TextEditingController();

  TextEditingController objective_controller = TextEditingController();

  // focus node
  FocusNode height_node = FocusNode();
  FocusNode weight_node = FocusNode();
  FocusNode bmi_node = FocusNode();
  FocusNode ideal_weight_node = FocusNode();
  FocusNode fat_rate_node = FocusNode();
  FocusNode weight_gap_node = FocusNode();
  FocusNode weight_target_node = FocusNode();

  FocusNode waist_node = FocusNode();
  FocusNode arm_node = FocusNode();
  FocusNode chest_node = FocusNode();
  FocusNode thigh_node = FocusNode();
  FocusNode hip_node = FocusNode();
  FocusNode pr_node = FocusNode();
  FocusNode bp_node = FocusNode();

  FocusNode objective_node = FocusNode();

  List<String?> objectives_list = [];

  bool add_obj = false;
  bool obj_edit = false;
  int edit_obj_val = 0;

  // fasting blood
  String fasting_blood_select = 'Select';

  String bmi_select = '';

  // left side
  Widget left_side() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // profile area
          profile_area(),

          SizedBox(height: 10),

          // heading
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'BMI Details',
              style: headingStyle,
            ),
          ),

          SizedBox(height: 7),

          // form
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // height, weight & BMI
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // height
                        Expanded(
                          flex: 3,
                          child: Text_field(
                            label: 'Height(cm)',
                            controller: height_controller,
                            node: height_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // weight
                        Expanded(
                          flex: 3,
                          child: Text_field(
                            label: 'Weight(kg)',
                            controller: weight_controller,
                            node: weight_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // bmi
                        Expanded(
                          flex: 4,
                          child: Text_field(
                            label: 'BMI',
                            controller: bmi_controller,
                            node: bmi_node,
                            edit: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // bmi class & ideal weight
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // BMI class
                        Expanded(
                          flex: 7,
                          child: Select_form(
                            label: 'BMI Class',
                            options: [],
                            text_value: bmi_select,
                            edit: false,
                            setval: (val) {},
                          ),
                        ),

                        SizedBox(width: 20),

                        // ideal weight
                        Expanded(
                          flex: 3,
                          child: Text_field(
                            label: 'Ideal Weight',
                            controller: ideal_weight_controller,
                            node: ideal_weight_node,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // fat raet, weight gap, weight target
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // fat rate
                        Expanded(
                          flex: 3,
                          child: Text_field(
                            label: 'Fat Rate',
                            controller: fat_rate_controller,
                            node: fat_rate_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // weight gap
                        Expanded(
                          flex: 3,
                          child: Text_field(
                            label: 'Weight Gap',
                            controller: weight_gap_controller,
                            node: weight_gap_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // weight target
                        Expanded(
                          flex: 4,
                          child: Text_field(
                            label: 'Weight Target',
                            controller: weight_target_controller,
                            node: weight_target_node,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // waist, arm & chest
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // waist
                        Expanded(
                          flex: 3,
                          child: Text_field(
                            label: 'Waist',
                            controller: waist_controller,
                            node: waist_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // arm
                        Expanded(
                          flex: 3,
                          child: Text_field(
                            label: 'Arm',
                            controller: arm_controller,
                            node: arm_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // chest
                        Expanded(
                          flex: 4,
                          child: Text_field(
                            label: 'Chest',
                            controller: chest_controller,
                            node: chest_node,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // thighs & hips
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // thighs
                        Expanded(
                          flex: 3,
                          child: Text_field(
                            label: 'Thighs',
                            controller: thigh_controller,
                            node: thigh_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // hips
                        Expanded(
                          flex: 3,
                          child: Text_field(
                            label: 'Hips',
                            controller: hip_controller,
                            node: hip_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // space
                        Expanded(
                          flex: 4,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),

                  // pulse rate & blood pressure
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // pulse rate
                        Expanded(
                          flex: 5,
                          child: Text_field(
                            label: 'Pulse Rate',
                            controller: pr_controller,
                            node: pr_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // Blood pressure
                        Expanded(
                          flex: 5,
                          child: Text_field(
                            label: 'Blood Pressure',
                            controller: bp_controller,
                            node: bp_node,
                          ),
                        ),

                        SizedBox(width: 20),

                        // space
                        Expanded(
                          flex: 4,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // objectives
                  objectives(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // right side
  Widget right_side() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
      child: Column(
        children: [
          SizedBox(height: 10),

          // form
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // lipid profile
                  lipid_profile(),

                  SizedBox(height: 30),

                  // lifestyle assessment
                  lifestyle_assessment(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // objectives
  Widget objectives() {
    TextStyle textfieldStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    );
    TextStyle hintStyle = TextStyle(
      color: Color(0xFFc3c3c3),
      fontSize: 12,
      letterSpacing: 0.6,
      fontStyle: FontStyle.italic,
    );

    return Container(
      child: Column(
        children: [
          // heading
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'Clinical Objectives',
              style: headingStyle,
            ),
          ),

          SizedBox(height: 7),

          // objectives list
          objectives_list.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      objectives_list.map((e) => objective_tile(e!)).toList(),
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No Clinical Objective',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),

          // objective textfield
          add_obj
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: TextField(
                    style: textfieldStyle,
                    controller: objective_controller,
                    focusNode: objective_node,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (value) {
                      _obj_add();
                    },
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Objectives...',
                      hintStyle: hintStyle,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFBCBCBC),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFBCBCBC),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                    ),
                  ),
                )
              : Container(),

          // action buttons
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // add button
                InkWell(
                  onTap: () {
                    if (!obj_edit && objectives_list.length == 5) {
                      Helpers.showToast(
                        context: context,
                        color: Colors.redAccent,
                        toastText: 'You can only add 5 objectives',
                        icon: Icons.error,
                      );
                    } else {
                      _obj_add();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: obj_edit
                          ? Colors.deepPurple
                          : add_obj
                              ? Color(0xFF3c5bff).withOpacity(0.5)
                              : Color(0xFFadedad).withOpacity(0.5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            obj_edit
                                ? Icons.edit
                                : add_obj
                                    ? Icons.check
                                    : Icons.add,
                            color: Colors.white,
                            size: 20),
                        SizedBox(width: 6),
                        Text(
                          obj_edit
                              ? 'Edit Objective'
                              : add_obj
                                  ? 'Add Objective'
                                  : 'New Objective',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            height: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // close button
                add_obj
                    ? InkWell(
                        onTap: () {
                          objective_controller.clear();
                          add_obj = false;
                          obj_edit = false;

                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 3),
                                blurRadius: 6,
                                spreadRadius: 5,
                                color: Colors.black.withOpacity(0.24),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(6),
                          child:
                              Icon(Icons.close, color: Colors.white, size: 25),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FUNCTION
  // add objective
  void _obj_add() {
    // edit objective
    if (obj_edit) {
      if (objective_controller.text.isNotEmpty) {
        // check objectives
        var check = objectives_list.indexWhere(
            (element) => element == objective_controller.text.trim());
        if (check == -1 || check == edit_obj_val) {
          objectives_list[edit_obj_val] = objective_controller.text.trim();

          add_obj = false;
          obj_edit = false;
          objective_controller.clear();

          // show toast
          Helpers.showToast(
            context: context,
            color: Colors.greenAccent,
            toastText: 'Objective Edited successfully',
            icon: Icons.check,
          );
        } else {
          // show error
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Objective already exist',
            icon: Icons.error,
          );
          Future.delayed(Duration(milliseconds: 300), () {
            FocusScope.of(context).requestFocus(objective_node);
          });
        }
      } else {
        // show erro
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Objective cannot be empty',
          icon: Icons.error,
        );
        Future.delayed(Duration(milliseconds: 300), () {
          FocusScope.of(context).requestFocus(objective_node);
        });
      }
    } else if (add_obj) {
      if (objective_controller.text.isNotEmpty) {
        // check objectives
        var check = objectives_list
            .where((element) => element == objective_controller.text.trim());
        if (check.isEmpty) {
          objectives_list.add(objective_controller.text.trim());

          add_obj = false;
          obj_edit = false;
          objective_controller.clear();

          // show toast
          Helpers.showToast(
            context: context,
            color: Colors.greenAccent,
            toastText: 'Objective Added successfully',
            icon: Icons.check,
          );
        } else {
          // show error
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Objective already exist',
            icon: Icons.error,
          );
          Future.delayed(Duration(milliseconds: 300), () {
            FocusScope.of(context).requestFocus(objective_node);
          });
        }
      } else {
        // show error toast
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Objective cannot be empty',
          icon: Icons.error,
        );
        Future.delayed(Duration(milliseconds: 300), () {
          FocusScope.of(context).requestFocus(objective_node);
        });
      }
    } else {
      add_obj = true;
      obj_edit = false;
      Future.delayed(Duration(milliseconds: 300), () {
        FocusScope.of(context).requestFocus(objective_node);
      });
    }

    setState(() {});
  }

  // objective tile
  Widget objective_tile(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Stack(
        children: [
          // main container
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Stack(
              children: [
                // text container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF4cadbc).withOpacity(0.3),
                    border:
                        Border.all(color: Color(0xFF72b9d3).withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  padding: EdgeInsets.fromLTRB(10, 15, 30, 15),
                  child: SelectableText(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                // copy button
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: text));

                      // show toast
                      Helpers.showToast(
                        context: context,
                        color: Colors.grey,
                        toastText: 'Copied to clipboard',
                        icon: Icons.check,
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      color: Color(0xFFdfd0d0),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // edit button
          Positioned(
            top: 0,
            left: 0,
            child: InkWell(
              onTap: () {
                int val =
                    objectives_list.indexWhere((element) => element == text);
                objective_controller.text = objectives_list[val]!;

                obj_edit = true;
                edit_obj_val = val;

                add_obj = true;

                Future.delayed(Duration(milliseconds: 300), () {
                  FocusScope.of(context).requestFocus(objective_node);
                });

                setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black38,
                ),
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.edit,
                  color: Color(0xFFdfd0d0),
                  size: 12,
                ),
              ),
            ),
          ),

          // delete button
          Positioned(
            top: 0,
            left: 24,
            child: InkWell(
              onTap: () {
                int val =
                    objectives_list.indexWhere((element) => element == text);
                objectives_list.removeAt(val);
                obj_edit = false;
                objective_controller.clear();
                add_obj = false;
                setState(() {});
                Helpers.showToast(
                  context: context,
                  color: Colors.greenAccent,
                  toastText: 'Objective Deleted successfully',
                  icon: Icons.check,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity(0.5),
                ),
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.delete,
                  color: Color(0xFFdfd0d0),
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // lipid profile
  Widget lipid_profile() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // heading
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'Lipid Profile & Fasting Blood Sugar',
              style: headingStyle,
            ),
          ),

          SizedBox(height: 7),

          // list
          // total cholestrol
          lipid_profile_tile(
            title: 'Total Cholestrol',
            observed_controller: tC_observed_controller,
            normal_controller: tC_normal_controller,
            remarks_controller: tC_remarks_controller,
          ),

          // high density lipoproteins
          lipid_profile_tile(
            title: 'High Density Lipoproteins',
            observed_controller: hdl_observed_controller,
            normal_controller: hdl_normal_controller,
            remarks_controller: hdl_remarks_controller,
          ),

          // low density lipoproteins
          lipid_profile_tile(
            title: 'Low Density Lipoproteins',
            observed_controller: ldl_observed_controller,
            normal_controller: ldl_normal_controller,
            remarks_controller: ldl_remarks_controller,
          ),

          // Triglycerides
          lipid_profile_tile(
            title: 'Triglycerides',
            observed_controller: tg_observed_controller,
            normal_controller: tg_normal_controller,
            remarks_controller: tg_remarks_controller,
          ),

          fasting_blood(),
        ],
      ),
    );
  }

  // fasting blood
  Widget fasting_blood() {
    return Container(
      width: 200,
      child: Select_form(
        label: 'Fasting Blood',
        options: ['True', 'False'],
        text_value: fasting_blood_select,
        setval: (val) {
          setState(() {
            fasting_blood_select = val;
          });
        },
      ),
    );
  }

  // lifestyle assessment
  Widget lifestyle_assessment() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // heading
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'Lifestyle Assessment',
              style: headingStyle,
            ),
          ),

          SizedBox(height: 7),

          // list
          // eating habits
          lifestyle_assessment_tile(
            title: 'Eating Habits',
            findings_controller: eb_findings_controller,
            recommendations_controller: eb_recommendations_controller,
          ),

          // smoking habits
          lifestyle_assessment_tile(
            title: 'Smoking Habits',
            findings_controller: sb_findings_controller,
            recommendations_controller: sb_recommendations_controller,
          ),

          // Alcohol habits
          lifestyle_assessment_tile(
            title: 'Alcohol Habits',
            findings_controller: ab_findings_controller,
            recommendations_controller: ab_recommendations_controller,
          ),

          // Others
          lifestyle_assessment_tile(
            title: 'Others',
            findings_controller: others_findings_controller,
            recommendations_controller: others_recommendations_controller,
          ),
        ],
      ),
    );
  }

  // lipid profile tile
  Widget lipid_profile_tile({
    required String title,
    required TextEditingController observed_controller,
    required TextEditingController normal_controller,
    required TextEditingController remarks_controller,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        children: [
          // container
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFa6ca8e).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.fromLTRB(15, 25, 15, 12),
              child: Column(
                // contents
                children: [
                  // observed & normal
                  Row(
                    children: [
                      // observed value
                      Expanded(
                        flex: 6,
                        child: Text_field(
                          label: 'Observed value',
                          controller: observed_controller,
                        ),
                      ),

                      SizedBox(width: 20),

                      // normal value
                      Expanded(
                        flex: 6,
                        child: Text_field(
                          label: 'Normal value',
                          controller: normal_controller,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Text_field(
                    label: 'Remarks',
                    controller: remarks_controller,
                  ),
                ],
              ),
            ),
          ),

          // title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFF6bd5b9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
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

  // lipid profile tile
  Widget lifestyle_assessment_tile({
    required String title,
    required TextEditingController findings_controller,
    required TextEditingController recommendations_controller,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        children: [
          // container
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF8eb6ca).withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.fromLTRB(15, 25, 15, 12),
              child: Column(
                // contents
                children: [
                  Text_field(
                    label: 'Findings',
                    controller: findings_controller,
                  ),
                  SizedBox(height: 12),
                  Text_field(
                    label: 'Recommendations',
                    controller: recommendations_controller,
                    center: true,
                  ),
                ],
              ),
            ),
          ),

          // title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFF6b99d5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
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

  // submit button
  Widget submit_button() {
    return InkWell(
      onTap: () async {
        if (height_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Height cannot be Empty',
            icon: Icons.error,
          );
          return;
        }

        if (weight_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Weight cannot be Empty',
            icon: Icons.error,
          );
          return;
        }

        var _conf = await showDialog(
          context: context,
          builder: (context) => ConfirmDialog(
            title: 'Update Health Data',
            subtitle:
                'You are about to update this health data. Would you like to proceed?',
          ),
        );

        if (_conf == null || !_conf) return;

        if (!client!.baseline_done) {
          var conf = await showDialog(
            context: context,
            builder: (context) => ConfirmDialog(
              title: 'Baseline Complete',
              subtitle:
                  'Is this baseline information complete?\nNote: The details cannot be edited once complete',
              boolean: true,
            ),
          );

          if (conf != null) {
            if (conf) {
              // PhysioDatabaseHelpers.edit_physio_client(client!.key, {
              //   'baseline_done': true,
              // });
            }

            update_health_details(conf);
          } else {
            return;
          }
        } else {
          var conf = await showDialog(
            context: context,
            builder: (context) => ConfirmDialog(
              title: 'Assessment Complete',
              subtitle:
                  'Is this health information complete?\nNote: The details cannot be edited once complete',
              boolean: true,
            ),
          );

          if (conf != null) {
            update_health_details(conf);
          } else {
            return;
          }
        }
      },
      child: Container(
        // width: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF3c5bff).withOpacity(0.5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Center(
          child: Text(
            'Submit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // reset button
  Widget reset_button() {
    return InkWell(
      onTap: () async {
        var res = await showDialog(
          context: context,
          builder: (context) => ConfirmDialog(
            title: 'Reset Form',
            subtitle: 'This would clear this form.\nWould you like to proceed?',
          ),
        );

        if (res != null && !res) return;

        height_controller.text = '';
        weight_controller.text = '';

        bmi_select = '';

        bmi_controller.text = '';

        ideal_weight_controller.text = '';
        fat_rate_controller.text = '';
        weight_gap_controller.text = '';
        weight_target_controller.text = '';
        waist_controller.text = '';
        arm_controller.text = '';
        chest_controller.text = '';
        thigh_controller.text = '';
        hip_controller.text = '';
        pr_controller.text = '';
        bp_controller.text = '';

        tC_observed_controller.text = '';
        tC_normal_controller.text = '';
        tC_remarks_controller.text = '';
        hdl_observed_controller.text = '';
        hdl_normal_controller.text = '';
        hdl_remarks_controller.text = '';
        ldl_observed_controller.text = '';
        ldl_normal_controller.text = '';
        ldl_remarks_controller.text = '';
        tg_observed_controller.text = '';
        tg_normal_controller.text = '';
        tg_remarks_controller.text = '';

        fasting_blood_select = 'False';

        eb_findings_controller.text = '';
        eb_recommendations_controller.text = '';
        sb_findings_controller.text = '';
        sb_recommendations_controller.text = '';
        ab_findings_controller.text = '';
        ab_recommendations_controller.text = '';
        others_findings_controller.text = '';
        others_recommendations_controller.text = '';

        objectives_list.clear();

        setState(() {});
      },
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFFeb7070).withOpacity(0.8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        margin: EdgeInsets.only(right: 10),
        child: Center(
          child: Text(
            'Reset',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              // height: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Functions

  //update text controllers
  void update_health_controllers() {
    height_controller.text = health!.height;
    weight_controller.text = health!.weight;

    double height = height_controller.text.isNotEmpty
        ? double.parse(height_controller.text)
        : 0;
    double weight = weight_controller.text.isNotEmpty
        ? double.parse(weight_controller.text)
        : 0;

    Map<String, String> result = Helpers.calc_bmi(height, weight);

    if (result.isEmpty) {
      bmi_select = '';
      bmi_controller.text = '';
    } else {
      bmi_select = result['bmi_class']!;
      bmi_controller.text = result['bmi_fig']!;
    }

    ideal_weight_controller.text = health!.ideal_weight;
    fat_rate_controller.text = health!.fat_rate;
    weight_gap_controller.text = health!.weight_gap;
    weight_target_controller.text = health!.weight_target;
    waist_controller.text = health!.waist;
    arm_controller.text = health!.arm;
    chest_controller.text = health!.chest;
    thigh_controller.text = health!.thighs;
    hip_controller.text = health!.hips;
    pr_controller.text = health!.pulse_rate;
    bp_controller.text = health!.blood_pressure;

    tC_observed_controller.text = health!.chl_ov;
    tC_normal_controller.text = health!.chl_nv;
    tC_remarks_controller.text = health!.chl_rm;
    hdl_observed_controller.text = health!.hdl_ov;
    hdl_normal_controller.text = health!.hdl_nv;
    hdl_remarks_controller.text = health!.hdl_rm;
    ldl_observed_controller.text = health!.ldl_ov;
    ldl_normal_controller.text = health!.ldl_nv;
    ldl_remarks_controller.text = health!.ldl_rm;
    tg_observed_controller.text = health!.trg_ov;
    tg_normal_controller.text = health!.trg_nv;
    tg_remarks_controller.text = health!.trg_rm;

    fasting_blood_select = health!.blood_sugar ? 'True' : 'False';

    eb_findings_controller.text = health!.eh_finding;
    eb_recommendations_controller.text = health!.eh_recommend;
    sb_findings_controller.text = health!.sh_finding;
    sb_recommendations_controller.text = health!.sh_recommend;
    ab_findings_controller.text = health!.ah_finding;
    ab_recommendations_controller.text = health!.ah_recommend;
    others_findings_controller.text = health!.other_finding;
    others_recommendations_controller.text = health!.other_recommend;

    objectives_list.clear();
    if (health!.ft_obj_1.isNotEmpty) objectives_list.add(health!.ft_obj_1);
    if (health!.ft_obj_2.isNotEmpty) objectives_list.add(health!.ft_obj_2);
    if (health!.ft_obj_3.isNotEmpty) objectives_list.add(health!.ft_obj_3);
    if (health!.ft_obj_4.isNotEmpty) objectives_list.add(health!.ft_obj_4);
    if (health!.ft_obj_5.isNotEmpty) objectives_list.add(health!.ft_obj_5);

    setState(() {});
  }

  update_health_details(bool done) async {
    bool blood_sug = fasting_blood_select == 'True' ? true : false;

    PhysioHealthModel h_data = PhysioHealthModel(
      height: height_controller.text.trim(),
      weight: weight_controller.text.trim(),
      ideal_weight: ideal_weight_controller.text.trim(),
      fat_rate: fat_rate_controller.text.trim(),
      weight_gap: weight_gap_controller.text.trim(),
      weight_target: weight_target_controller.text.trim(),
      waist: waist_controller.text.trim(),
      arm: arm_controller.text.trim(),
      chest: chest_controller.text.trim(),
      thighs: thigh_controller.text.trim(),
      hips: hip_controller.text.trim(),
      pulse_rate: pr_controller.text.trim(),
      blood_pressure: bp_controller.text.trim(),
      chl_ov: tC_observed_controller.text.trim(),
      chl_nv: tC_normal_controller.text.trim(),
      chl_rm: tC_remarks_controller.text.trim(),
      hdl_ov: hdl_observed_controller.text.trim(),
      hdl_nv: hdl_normal_controller.text.trim(),
      hdl_rm: hdl_remarks_controller.text.trim(),
      ldl_ov: ldl_observed_controller.text.trim(),
      ldl_nv: ldl_normal_controller.text.trim(),
      ldl_rm: ldl_remarks_controller.text.trim(),
      trg_ov: tg_observed_controller.text.trim(),
      trg_nv: tg_normal_controller.text.trim(),
      trg_rm: tg_remarks_controller.text.trim(),
      blood_sugar: blood_sug,
      eh_finding: eb_findings_controller.text.trim(),
      eh_recommend: eb_recommendations_controller.text.trim(),
      sh_finding: sb_findings_controller.text.trim(),
      sh_recommend: sb_recommendations_controller.text.trim(),
      ah_finding: ab_findings_controller.text.trim(),
      ah_recommend: ab_recommendations_controller.text.trim(),
      other_finding: others_findings_controller.text.trim(),
      other_recommend: others_recommendations_controller.text.trim(),
      ft_obj_1: objectives_list.length >= 1 ? objectives_list[0]! : '',
      ft_obj_2: objectives_list.length >= 2 ? objectives_list[1]! : '',
      ft_obj_3: objectives_list.length >= 3 ? objectives_list[2]! : '',
      ft_obj_4: objectives_list.length >= 4 ? objectives_list[3]! : '',
      ft_obj_5: objectives_list.length >= 5 ? objectives_list[4]! : '',
      key: health!.key,
      date: health!.date,
      done: done,
    );

    Helpers.showLoadingScreen(context: context);
    
    // set data
    // bool dt = await PhysioDatabaseHelpers.set_health_data(
    //   client!.key,
    //   health!.key,
    //   h_data.toJson(),
    // );

    Navigator.pop(context);

    // if (!dt) {
    //   Helpers.showToast(
    //     context: context,
    //     color: Colors.redAccent,
    //     toastText: 'An Error occured, Try again!',
    //     icon: Icons.error,
    //   );
    //   return false;
    // }

    Helpers.showToast(
      context: context,
      color: Colors.greenAccent,
      toastText: 'Health Data Successfully Updated',
      icon: Icons.check,
    );

    if (widget.register) {
      PhysioHealthClientModel client_h = PhysioHealthClientModel(
        key: client!.key,
        id: client!.id,
        name: client!.name,
        user_image: client!.user_image,
        hmo: client!.hmo,
        baseline_done: client!.baseline_done,
      );

      Navigator.pop(context);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ClinicTab(
      //       client: client_h,
      //       can_treat: false,
      //     ),
      //   ),
      // );
    } else {
      Navigator.pop(context, h_data);
    }
  }
}
