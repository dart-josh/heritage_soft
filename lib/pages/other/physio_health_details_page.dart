import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/other/physio_health_registration_page.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';

class PhysioClientHDPage extends StatefulWidget {
  final PhysioHealthModel health;
  final PhysioHealthClientModel client;
  const PhysioClientHDPage({
    super.key,
    required this.health,
    required this.client,
  });

  @override
  State<PhysioClientHDPage> createState() => _PhysioClientHDPageState();
}

class _PhysioClientHDPageState extends State<PhysioClientHDPage> {
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
      ],
    );
  }

  // top bar
  Widget topBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        children: [
          // id area, edit button & return button
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

              // edit button (only desk user)
              if (app_role == 'desk' || app_role == 'ict') edit_button(),

              SizedBox(width: 10),

              // return button
              InkWell(
                onTap: () {
                  Navigator.pop(context);
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
                  '${health!.key == 'Baseline' ? 'Baseline ' : ''}Health Details [${fmt_date(health!.date)}]',
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

  // fasting blood
  String fasting_blood_select = '';

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
                            edit: true,
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
                            edit: true,
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
                            edit: true,
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
                            edit: true,
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
                            edit: true,
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
                            edit: true,
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
                            edit: true,
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
                            edit: true,
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
                            edit: true,
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
                            edit: true,
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
                            edit: true,
                          ),
                        ),

                        SizedBox(width: 20),

                        // chest
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
                            edit: true,
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
                            edit: true,
                          ),
                        ),

                        SizedBox(width: 20),

                        // chest
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

  List<String?> objectives_list = [];

  // objectives
  Widget objectives() {
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
        ],
      ),
    );
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
        options: [],
        text_value: fasting_blood_select,
        edit: false,
        setval: (val) {},
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
                          edit: true,
                        ),
                      ),

                      SizedBox(width: 20),

                      // normal value
                      Expanded(
                        flex: 6,
                        child: Text_field(
                          label: 'Normal value',
                          controller: normal_controller,
                          edit: true,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Text_field(
                    label: 'Remarks',
                    controller: remarks_controller,
                    edit: true,
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
                    edit: true,
                  ),
                  SizedBox(height: 12),
                  Text_field(
                    label: 'Recommendations',
                    controller: recommendations_controller,
                    edit: true,
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

  // edit button
  Widget edit_button() {
    if (health == null) return Container();

    if (health!.date != DateFormat('dd_MM_yyyy').format(DateTime.now()))
      return Container();

    if (health!.done)
      return Container(
        child: Icon(Icons.check_circle, color: Colors.green, size: 24),
      );

    return InkWell(
      onTap: () async {
        var res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhysioHealthRegistrationPage(
              client: widget.client,
              health: health!,
            ),
          ),
        );

        if (res != null) {
          health = res;

          update_health_controllers();
        }
      },
      child: Container(
        // width: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF3c5bff).withOpacity(0.5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Center(
          child: Text(
            'Edit',
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
  //

  //update text controllers
  void update_health_controllers() {
    if (health == null) return;

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

  //
}
