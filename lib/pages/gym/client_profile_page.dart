import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/attendance_model.dart';
import 'package:heritage_soft/datamodels/gym_models/client_health.model.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/datamodels/gym_models/client.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/clinic/patient_pofile_page.dart';
import 'package:heritage_soft/pages/clinic/patient_registration_page.dart';
import 'package:heritage_soft/pages/gym/client_health_details_page.dart';
import 'package:heritage_soft/pages/gym/client_health_registration_page.dart';
import 'package:heritage_soft/pages/gym/clients_attendance_history.dart';
import 'package:heritage_soft/pages/gym/indemnity_page.dart';
import 'package:heritage_soft/pages/gym/renewal_page.dart';
import 'package:heritage_soft/pages/gym/sub_history_page.dart';
import 'package:heritage_soft/widgets/confirm_dialog.dart';
import 'package:heritage_soft/widgets/edit_name_dialog.dart';
import 'package:heritage_soft/pages/gym/Widgets/gym_health_selector_dialog.dart';
import 'package:heritage_soft/widgets/image_box.dart';
import 'package:heritage_soft/widgets/options_dialog.dart';
import 'package:heritage_soft/pages/gym/Widgets/qr_code_dialog.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/helpers/gym_database_helpers.dart';

import 'package:intl/intl.dart';

import 'package:heritage_soft/widgets/text_field.dart';
import 'package:provider/provider.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key, required this.cl_id});

  final String cl_id;

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  TextStyle labelStyle = TextStyle(
    color: Color(0xFFc3c3c3),
    fontSize: 11,
  );

  TextStyle headingStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  UserModel? active_user;

  bool edit = false;

  bool success_is_playing = false;
  final ConfettiController success_controller = ConfettiController();

  Uint8List? image_file;

  ClientModel? client;

  // NAMES
  String first_name = '';
  String middle_name = '';
  String last_name = '';
  String user_image = '';

  bool subscription_status = true;

  // text controller
  TextEditingController phone_1_controller = TextEditingController();
  TextEditingController phone_2_controller = TextEditingController();
  TextEditingController email_controller = TextEditingController();
  TextEditingController address_controller = TextEditingController();
  TextEditingController ig_controller = TextEditingController();
  TextEditingController fb_controller = TextEditingController();

  TextEditingController dob_controller = TextEditingController();
  TextEditingController age_controller = TextEditingController();

  TextEditingController hykau_controller = TextEditingController();

  TextEditingController height_controller = TextEditingController();
  TextEditingController weight_controller = TextEditingController();
  TextEditingController bmi_controller = TextEditingController();

  TextEditingController company_name_controller = TextEditingController();

  TextEditingController hmo_id_controller = TextEditingController();

  // focus node
  FocusNode phone_1_node = FocusNode();
  FocusNode phone_2_node = FocusNode();
  FocusNode email_node = FocusNode();
  FocusNode address_node = FocusNode();
  FocusNode ig_node = FocusNode();
  FocusNode fb_node = FocusNode();

  FocusNode dob_node = FocusNode();
  FocusNode age_node = FocusNode();

  FocusNode height_node = FocusNode();
  FocusNode weight_node = FocusNode();
  FocusNode bmi_node = FocusNode();

  String gender_select = '';
  List<String> gender_options = ['Male', 'Female'];

  String program_type_select = '';
  String corporate_type_select = '';

  String occupation_select = '';

  String bmi_select = '';
  List<String> bmi_options = [];

  String hmo_select = 'No HMO';

  String hykau = '';

  bool show_age = false;

  List<String> hmo = [];

  // get client details
  get_client_details() {
    if (edit) return;
    var clx = Provider.of<AppData>(context)
        .gym_clients
        .where((cl) => cl.key == widget.cl_id);

    if (clx.isNotEmpty) client = clx.first;
    update_profile_controllers();
    // HealthSummaryModel client_health = HealthSummaryModel(
    //     height: client!.healthData!.last.data.height,
    //     weight: client!.healthData!.last.data.weight);

    // update_health_controllers(client_health);
  }

  @override
  void dispose() {
    phone_1_controller.dispose();
    phone_2_controller.dispose();
    email_controller.dispose();
    address_controller.dispose();
    ig_controller.dispose();
    fb_controller.dispose();

    dob_controller.dispose();
    age_controller.dispose();

    hykau_controller.dispose();

    height_controller.dispose();
    weight_controller.dispose();
    bmi_controller.dispose();

    hmo_id_controller.dispose();

    company_name_controller.dispose();

    phone_1_node.dispose();
    phone_2_node.dispose();
    email_node.dispose();
    address_node.dispose();
    ig_node.dispose();
    fb_node.dispose();

    dob_node.dispose();
    age_node.dispose();

    height_node.dispose();
    weight_node.dispose();
    bmi_node.dispose();

    success_controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    active_user = AppData.get(context).active_user;
    get_client_details();
    var hmm = AppData.get(context).gym_hmo;
    hmo = hmm.map((e) => e.hmo_name).toList();
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
                          'images/gym_profile.png',
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

                    // edit notificataion
                    (edit)
                        ? Positioned(
                            top: 10,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: Color(0xFFceaf65).withOpacity(0.3),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 6),
                                child: Center(
                                  child: Text(
                                    'Edit mode',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //? WIDGETs

  // main page
  Widget main_page() {
    if (client == null) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.cancel,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Row(
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

          // success animation
          ConfettiWidget(
            confettiController: success_controller,
            blastDirectionality: BlastDirectionality.explosive,
            // shouldLoop: true,
            numberOfParticles: 30,
            gravity: 0.1,
            emissionFrequency: 0.02,
          ),
        ],
      ),
    );
  }

  // left side
  Widget left_side() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Column(
        children: [
          // id & subscription group
          client != null ? id_sub_group() : Container(height: 30),

          // profile image & name area
          profile_area(),

          // contact details
          Expanded(child: contact_details()),
        ],
      ),
    );
  }

  // right side
  Widget right_side() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Column(
        children: [
          // form
          Expanded(
            child: Column(
              children: [
                // action bar
                action_bar(),

                // form
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // personal details
                        personal_details(),

                        // others
                        other_details(),

                        // health summary
                        health_summary(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // submit button
          (edit) ? submit_button() : Container(height: 50),
        ],
      ),
    );
  }

  // id & subscription group
  Widget id_sub_group() {
    String reg_dt = '';
    if (client!.regDate!.isNotEmpty) {
      var date_data = client!.regDate!.split('/');
      var date_res = DateTime(
        int.parse(date_data[2]),
        int.parse(date_data[1]),
        int.parse(date_data[0]),
      );
      reg_dt = Helpers.reg_date_diff(date_res);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label
        Text(
          'ID',
          style: TextStyle(
            color: Color(0xFFAFAFAF),
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),

        // id & reg date
        Row(
          children: [
            // client id
            Text(
              client!.clientId ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
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

            SizedBox(width: 6),

            // registration date
            Text(
              reg_dt,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
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
          ],
        ),

        // subscriptions & physio
        Row(
          children: [
            // sub plan & type
            client!.subPlan!.isNotEmpty
                ? Row(
                    children: [
                      // sub plan
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color(0xFF3C58E6).withOpacity(0.67),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: EdgeInsets.only(left: 6, top: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/icon/map-gym.png',
                              width: 11,
                              height: 11,
                            ),
                            SizedBox(width: 2),
                            Text(
                              client!.subPlan!,
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // sub type
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color.fromARGB(255, 232, 186, 93)
                              .withOpacity(0.4),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: EdgeInsets.only(left: 10, top: 2),
                        child: Text(
                          client!.subType!,
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),

            // physio tag
            if (client!.physioCl)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.green.withOpacity(0.4),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: EdgeInsets.only(left: 20, top: 2),
                child: Text(
                  'Physio',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),

        // extras
        Row(
          children: [
            // boxing
            !client!.boxing!
                ? Container()
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color.fromARGB(255, 55, 103, 135).withOpacity(0.7),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: EdgeInsets.only(top: 2, left: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/icon/boxglove.png',
                          width: 11,
                          height: 11,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Boxing',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

            // personal training
            !client!.ptStatus!
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(left: 8, top: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Color(0xFF5a5a5a).withOpacity(0.7),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/icon/sentiayoga.png',
                            width: 10,
                            height: 10,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'PT - ${client!.ptPlan}',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  // profile image & name area
  Widget profile_area() {
    TextStyle nameStyle = TextStyle(
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
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // profile image
          Stack(
            children: [
              // selected image
              edit && image_file != null
                  ? Container(
                      margin: EdgeInsets.only(bottom: 6, right: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          image_file!,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )

                  // no user image
                  : user_image.isEmpty
                      ? Container(
                          margin: EdgeInsets.only(bottom: 6, right: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFf3f0da).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.all(30),
                          child: Center(
                            child: Image.asset(
                              'images/icon/material-person.png',
                              width: 120,
                              height: 120,
                            ),
                          ),
                        )

                      // user image from db
                      : Container(
                          margin: EdgeInsets.only(bottom: 6, right: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              user_image,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

              // edit icon
              edit
                  ? Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () async {
                          var res = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => EditProfileImage(
                              is_edit: true,
                              user_image:
                                  user_image.isNotEmpty ? user_image : null,
                            ),
                          );

                          if (res != null) {
                            if (res == 'del') {
                              user_image = '';
                              image_file = null;
                            } else {
                              image_file = res;
                            }

                            setState(() {});
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          padding: EdgeInsets.all(8),
                          child:
                              Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),

          SizedBox(width: 30),

          // profile area
          Column(
            children: [
              // profile details
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // first name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // label
                        Text(
                          'First name',
                          style: labelStyle,
                        ),

                        // name
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 2, bottom: 4),
                          child: Text(
                            first_name,
                            style: nameStyle,
                          ),
                        )
                      ],
                    ),

                    // middle name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // label
                        Text(
                          'Middle name',
                          style: labelStyle,
                        ),

                        // name
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 2, bottom: 4),
                          child: Text(
                            middle_name,
                            style: nameStyle,
                          ),
                        )
                      ],
                    ),

                    // last name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // label
                        Text(
                          'Last name',
                          style: labelStyle,
                        ),

                        // name
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 2, bottom: 4),
                          child: Text(
                            last_name,
                            style: nameStyle,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // status area
              Column(
                children: [
                  // status
                  client == null
                      ? Container()
                      : (!subscription_status)
                          ? expired_box()
                          : active_box(),

                  client != null && client!.subPaused!
                      ? sub_paused_box()
                      : Container(),

                  // renew button
                  if (active_user!.app_role == 'CSU' ||
                      active_user!.app_role == 'ICT')
                    client == null
                        ? Container()
                        : (!subscription_status && !edit)
                            ? Container(height: 40, child: renew_button())
                            : Container(
                                height: 40,
                                width: 160,
                              ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // contact details
  Widget contact_details() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
              'Contact Details',
              style: headingStyle,
            ),
          ),

          SizedBox(height: 7),

          // form
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // phone
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        // phone
                        Expanded(
                          flex: 6,
                          child: Text_field(
                            label: 'Primary Phone no.',
                            controller: phone_1_controller,
                            node: phone_1_node,
                            hintText: 'xxxx xxx xxxx',
                            edit: !edit,
                            format: [FilteringTextInputFormatter.digitsOnly],
                            require: edit,
                          ),
                        ),

                        SizedBox(width: 20),

                        // phone 2
                        Expanded(
                          flex: 6,
                          child: Text_field(
                            label: 'WhatsApp no.',
                            controller: phone_2_controller,
                            node: phone_2_node,
                            hintText: 'xxxx xxx xxxx',
                            edit: !edit,
                            format: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // email
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text_field(
                      label: 'Email',
                      controller: email_controller,
                      node: email_node,
                      hintText: 'johndoe@gmail.com',
                      edit: !edit,
                    ),
                  ),

                  // address
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text_field(
                      label: 'Addres_2',
                      controller: address_controller,
                      node: address_node,
                      maxLine: 3,
                      edit: !edit,
                      require: edit,
                    ),
                  ),

                  SizedBox(height: 2),

                  // ig & fb
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // ig
                        Expanded(
                          flex: 5,
                          child: Text_field(
                            label: 'Instagram',
                            controller: ig_controller,
                            node: ig_node,
                            edit: !edit,
                          ),
                        ),

                        SizedBox(width: 20),

                        // facebook
                        Expanded(
                          flex: 6,
                          child: Text_field(
                            label: 'Facebook',
                            controller: fb_controller,
                            node: fb_node,
                            edit: !edit,
                          ),
                        ),
                      ],
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

  // personal details
  Widget personal_details() {
    String age_class = '';
    // age class
    if (age_controller.text.isNotEmpty) {
      int? age = int.tryParse(age_controller.text);

      if (age != null) {
        if (age >= 65)
          age_class = 'Elderly';
        else if (age >= 45)
          age_class = 'Senior Adult';
        else if (age >= 25)
          age_class = 'Adult';
        else if (age >= 16)
          age_class = 'Young Adult';
        else
          age_class = 'Child';
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),

          // heading
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'Personal Details',
              style: headingStyle,
            ),
          ),

          SizedBox(height: 7),

          // gender & dob
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // gender
                Expanded(
                  flex: 5,
                  child: Container(
                    // width: 100,
                    child: Select_form(
                      label: 'Gender',
                      options: gender_options,
                      text_value: gender_select,
                      edit: edit,
                      require: edit,
                      setval: (val) {
                        gender_select = val;

                        setState(() {});
                      },
                    ),
                  ),
                ),

                SizedBox(width: 20),

                // dob
                Expanded(
                  flex: 6,
                  child: Text_field(
                    label: 'Date of Birth',
                    controller: dob_controller,
                    node: dob_node,
                    hintText: '',
                    edit: true,
                    icon: (edit)
                        ? PopupMenuButton(
                            offset: Offset(0, 30),
                            onSelected: (val) async {
                              var date_data = dob_controller.text.split('/');
                              var date_res = dob_controller.text.isNotEmpty
                                  ? DateTime(
                                      date_data.length > 2
                                          ? int.parse(date_data[2])
                                          : 1900,
                                      int.parse(date_data[1]),
                                      int.parse(date_data[0]))
                                  : DateTime(2000);

                              var data = await showDatePicker(
                                context: context,
                                initialDate: date_res,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(DateTime.now().year - 9),
                              );

                              if (data != null) {
                                if (val == 1) {
                                  var date =
                                      DateFormat('dd/MM/yyyy').format(data);
                                  dob_controller.text = date;
                                  String age = calc_age(data);
                                  age_controller.text = age;
                                  show_age = true;
                                } else {
                                  var date = DateFormat('dd/MM').format(data);
                                  dob_controller.text = date;
                                  age_controller.text = '';
                                  show_age = false;
                                }

                                setState(() {});
                              }
                            },
                            child: Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text('Select Age'),
                                value: 1,
                              ),
                              PopupMenuItem(
                                child: Text('Select Birthday'),
                                value: 2,
                              ),
                            ],
                          )
                        : null,
                  ),
                ),

                SizedBox(width: 20),

                // age
                Expanded(
                  flex: 2,
                  child: Text_field(
                    label: 'Age',
                    controller: age_controller,
                    node: age_node,
                    hintText: '',
                    edit: true,
                  ),
                ),
              ],
            ),
          ),

          // age classification
          if (show_age)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text('Age Classification:', style: labelStyle),
                  SizedBox(width: 15),
                  Text(age_class, style: headingStyle),
                ],
              ),
            ),

          // occupation
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Select_form(
              label: 'Occupation',
              options: occupation_options,
              text_value: occupation_select,
              edit: edit,
              setval: (val) {
                occupation_select = val;

                setState(() {});
              },
            ),
          ),

          // program type
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // program type
                Expanded(
                  flex: 5,
                  child: Container(
                    // width: 100,
                    child: Select_form(
                      label: 'Program type',
                      options: program_type_options,
                      text_value: program_type_select,
                      edit: edit,
                      require: edit,
                      setval: (val) {
                        program_type_select = val;
                        corporate_type_select = '';
                        hmo_select = 'No HMO';
                        company_name_controller.text = '';

                        setState(() {});
                      },
                    ),
                  ),
                ),

                SizedBox(width: 40),

                // corporate type
                Expanded(
                  flex: 6,
                  child: (program_type_select == 'Corporate')
                      ? Container(
                          // width: 100,
                          child: Select_form(
                            label: 'Coporate type',
                            options: corporate_type_options,
                            text_value: corporate_type_select,
                            edit: edit,
                            require: edit,
                            setval: (val) {
                              corporate_type_select = val;
                              if (corporate_type_select != 'HMO') {
                                hmo_select = 'No HMO';
                              }

                              if (corporate_type_select != 'Company') {
                                company_name_controller.text = '';
                              }

                              setState(() {});
                            },
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),

          // company name
          if (corporate_type_select == 'Company')
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text_field(
                label: 'Company name',
                controller: company_name_controller,
                require: edit,
                edit: !edit,
              ),
            ),

          // hmo
          if (corporate_type_select == 'HMO')
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Select_form(
                label: 'HMO',
                options: hmo,
                text_value: hmo_select,
                edit: edit,
                require: edit,
                setval: (val) {
                  hmo_select = val;

                  setState(() {});
                },
              ),
            ),

          // hmo id
          hmo_select != 'No HMO'
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text_field(
                    label: 'HMO ID',
                    controller: hmo_id_controller,
                    hintText: '',
                    require: edit,
                    edit: !edit,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  // others
  Widget other_details() {
    if (hykau.isEmpty) return Container();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          // hykau
          Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Select_form(
              label: 'How did you hear about us?',
              options: hykau_options,
              text_value: hykau,
              edit: false,
              setval: (val) {
                hykau = val;

                setState(() {});
              },
            ),
          ),

          // hykau others/referral
          (hykau == 'Others' || hykau == 'Referral')
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text_field(
                    controller: hykau_controller,
                    edit: true,
                  ),
                )
              : Container(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // health summary
  Widget health_summary() {
    if (!hmo.contains('No HMO')) hmo.add('No HMO');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),

          // heading
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // title
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFababab)),
                  ),
                ),
                child: Text(
                  'Health Summary',
                  style: headingStyle,
                ),
              ),

              Expanded(child: Container()),

              // full health details
              InkWell(
                onTap: () async {
                  if (client == null) return;

                  HealthClientModel client_h = HealthClientModel(
                    key: client!.key!,
                    id: client!.clientId!,
                    name: '$first_name $middle_name $last_name',
                    user_image: user_image,
                    hmo: client!.hmo!,
                    baseline_done: client!.baselineDone,
                    program_type: client!.programTypeSelect ?? "",
                  );

                  List<G_HealthModel> _all = client?.healthData ?? [];

                  // if db contains data
                  if (_all.isNotEmpty) {
                    if (client!.baselineDone) {
                      var conf = await showDialog(
                          context: context,
                          builder: (context) =>
                              HealthSelectorDialog(list: _all));

                      if (conf != null) {
                        if (conf[1]) {
                          new_health_details(client: client_h, health: conf[0]);
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientHDPage(
                                client: client_h,
                                health: conf[0],
                              ),
                            ),
                          );

                          setState(() {});
                        }
                      }
                    } else {
                      var data = _all
                          .where((element) => element.key == 'Baseline')
                          .first
                          .data;

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientHDPage(
                            client: client_h,
                            health: data,
                          ),
                        ),
                      );

                      setState(() {});
                    }
                  }

                  // if no data in db
                  else {
                    if (active_user!.app_role != 'CSU' &&
                        active_user!.app_role != 'ICT') return;

                    var bs = await showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        title: 'Baseline Assessment',
                        subtitle:
                            'You are about to take form for baseline assessment. Would you like to proceed?',
                      ),
                    );

                    if (bs == null || !bs) return;

                    String dt_type = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => OptionsDialog(
                        title: 'Health Form Type',
                        options: ['Basic form', 'Comprehensive from'],
                        dismiss: false,
                      ),
                    );

                    var data_type =
                        (dt_type == 'Basic form') ? 'basic' : 'comprehensive';

                    HealthModel pty = HealthModel(
                      height: '',
                      weight: '',
                      ideal_weight: '',
                      fat_rate: '',
                      weight_gap: '',
                      weight_target: '',
                      waist: '',
                      arm: '',
                      chest: '',
                      thighs: '',
                      hips: '',
                      pulse_rate: '',
                      blood_pressure: '',
                      sugar_level: '',
                      chl_ov: '',
                      chl_nv: '',
                      chl_rm: '',
                      hdl_ov: '',
                      hdl_nv: '',
                      hdl_rm: '',
                      ldl_ov: '',
                      ldl_nv: '',
                      ldl_rm: '',
                      trg_ov: '',
                      trg_nv: '',
                      trg_rm: '',
                      blood_sugar: false,
                      eh_finding: '',
                      eh_recommend: '',
                      sh_finding: '',
                      sh_recommend: '',
                      ah_finding: '',
                      ah_recommend: '',
                      other_finding: '',
                      other_recommend: '',
                      ft_obj_1: '',
                      ft_obj_2: '',
                      ft_obj_3: '',
                      ft_obj_4: '',
                      ft_obj_5: '',
                      key: 'Baseline',
                      date: DateFormat('dd_MM_yyyy').format(DateTime.now()),
                      done: false,
                      data_type: data_type,
                    );

                    new_health_details(client: client_h, health: pty);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFc3c3c3)),
                    ),
                  ),
                  child: Text(
                    'Full Health Details',
                    style: TextStyle(
                      color: Color(0xFFc3c3c3),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 7),

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
                    ontap: () {
                      if (edit)
                        Helpers.showToast(
                          context: context,
                          color: Colors.purpleAccent,
                          toastText:
                              'You cannot edit health details on this page',
                          icon: Icons.error,
                        );
                    },
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
                    ontap: () {
                      if (edit)
                        Helpers.showToast(
                          context: context,
                          color: Colors.purpleAccent,
                          toastText:
                              'You cannot edit health details on this page',
                          icon: Icons.error,
                        );
                    },
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
                    ontap: () {
                      if (edit)
                        Helpers.showToast(
                          context: context,
                          color: Colors.purpleAccent,
                          toastText:
                              'You cannot edit health details on this page',
                          icon: Icons.error,
                        );
                    },
                  ),
                ),
              ],
            ),
          ),

          // bmi class
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Select_form(
              label: 'BMI Class',
              options: bmi_options,
              text_value: bmi_select,
              edit: false,
              setval: (val) {},
            ),
          ),
        ],
      ),
    );
  }

  // action bar
  Widget action_bar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // calendar
        if (client != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () async {
                At_Date month = set_active_month();

                CAH_Model client_att = CAH_Model(
                  key: client!.key!,
                  id: client!.clientId!,
                  name: client!.fName!,
                  sub_plan: client!.subPlan!,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CAH(
                      month: month,
                      client: client_att,
                    ),
                  ),
                );
              },
              child: Image.asset(
                'images/icon/metro-calendar.png',
                width: 21,
                height: 21,
              ),
            ),
          ),

        // sub history
        if (client != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () async {
                Sub_CL_Model client_att = Sub_CL_Model(
                  key: client!.key!,
                  id: client!.clientId!,
                  name: client!.fName!,
                  sub_plan: client!.subPlan!,
                  sub_income: client!.subIncome,
                  fullname: '${client!.fName} ${client!.lName}',
                  history: client!.sub_history ?? [],
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubHistoryPage(client: client_att),
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

        // edit icon
        if (client != null &&
            (active_user!.app_role == 'ICT' || active_user!.app_role == 'CSU'))
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () {
                setState(() {
                  edit = !edit;
                });
              },
              child: (!edit)
                  ? Image.asset(
                      'images/icon/user-edit.png',
                      width: 26,
                      height: 26,
                    )
                  : Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 26,
                    ),
            ),
          ),

        SizedBox(width: 15),

        // settings icon
        if (client != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: settings_menu(
              child: Icon(
                Icons.settings,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

        // close button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: InkWell(
            onTap: () {
              if (edit) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'Exit Edit mode',
                  icon: Icons.error,
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(
              Icons.cancel,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  // active box
  Widget active_box() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color(0xFF88ECA9).withOpacity(0.67),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle, color: Color(0xFF19F763), size: 8),
            SizedBox(width: 4),
            Text(
              'Active',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // sub paused
  Widget sub_paused_box() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.red.withOpacity(0.67),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pause, color: Colors.white60, size: 12),
            SizedBox(width: 4),
            Text(
              'PAUSED',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // expired box
  Widget expired_box() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color(0xFFec8888).withOpacity(0.69),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle, color: Color(0xFFef6b6b), size: 8),
            SizedBox(width: 4),
            Text(
              'Inactive',
              style: TextStyle(fontSize: 11, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // renew button
  Widget renew_button() {
    return InkWell(
      onTap: () {
        String name = '${client!.fName} ${client!.lName}';

        RenewalModel newDet = RenewalModel(
          key: client!.key!,
          id: client!.clientId!,
          reg_date: client!.regDate!,
          user_image: client!.userImage!,
          name: name,
          sub_plan: client!.subPlan!.isEmpty && client!.hmo != 'No HMO'
              ? 'HMO Plan'
              : client!.subPlan!,
          pt_plan: client!.ptPlan!,
          pt_status: client!.ptStatus!,
          boxing: client!.boxing!,
          sub_type: client!.subType!,
          hmo_name: client!.hmo,
          sub_income: client!.subIncome,
          program_type: client!.programTypeSelect ?? "",
          renew_dates: client!.renewDates ?? "",
          registration_dates: client!.registrationDates ?? "",
          sub_date: client!.subDate ?? '',
          registered: client!.registered,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RenewalPage(
              details: newDet,
              register: client!.subPlan!.isEmpty,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF3c5bff),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Center(
          child: Text(
            client!.subPlan!.isEmpty ? 'Subscribe' : 'Renew',
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

  // submit button
  Widget submit_button() {
    return InkWell(
      onTap: () async {
        if (hmo_select != 'No HMO' && hmo_id_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'HMO ID cannot be empty',
            icon: Icons.error,
          );
          return;
        }

        if (phone_1_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Primary Phone No. Empty',
            icon: Icons.error,
          );
          return;
        }

        if (phone_1_controller.text.length > 11 ||
            phone_1_controller.text.length < 10) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Primary Phone Invalid',
            icon: Icons.error,
          );
          return;
        }

        if (phone_2_controller.text.isNotEmpty &&
            (phone_2_controller.text.length > 11 ||
                phone_2_controller.text.length < 10)) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'WhatsApp No Invalid',
            icon: Icons.error,
          );
          return;
        }

        if (email_controller.text.isNotEmpty) {
          bool emailValid = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(email_controller.text.trim());

          if (!emailValid) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Invalid Email',
              icon: Icons.error,
            );
            return;
          }
        }

        if (address_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Addres_2 Empty',
            icon: Icons.error,
          );
          return;
        }

        if (gender_select.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Select a gender',
            icon: Icons.error,
          );
          return;
        }

        if (program_type_select.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Select a program type',
            icon: Icons.error,
          );
          return;
        }

        if (program_type_select != 'Private' && corporate_type_select.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Select a corporate option',
            icon: Icons.error,
          );
          return;
        }

        if (corporate_type_select == 'Company' &&
            company_name_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Enter Company name',
            icon: Icons.error,
          );
          return;
        }

        if (corporate_type_select == 'HMO' &&
            (hmo_select.isEmpty || hmo_select == 'No HMO')) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Select HMO',
            icon: Icons.error,
          );
          return;
        }

        bool? res = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ConfirmDialog(
            title: 'Submit details',
            subtitle: 'Are you sure you want to proceed?',
          ),
        );

        if (res != null && res) {
          var rt = await update_client_details();

          if (rt != null && !rt) return;

          setState(() {
            edit = false;
          });
        }
      },
      child: Container(
        // width: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF3c5bff).withOpacity(0.5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: EdgeInsets.only(top: 10),
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

  // settings pop up menu
  Widget settings_menu({required child}) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(0),
      offset: Offset(0, 30),
      child: child,
      enabled: !edit,
      elevation: 8,
      onSelected: (value) async {
        // edit name
        if (value == 1) {
          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => EditNameDailog(
              fn: first_name,
              mn: middle_name,
              ln: last_name,
            ),
          );

          if (res != null) {
            first_name = res['first_name'];
            middle_name = res['middle_name'];
            last_name = res['last_name'];

            Map client_update_details = {
              'client_details.f_name': first_name,
              'client_details.m_name': middle_name,
              'client_details.l_name': last_name,
            };

            Map res_2 =
                await GymDatabaseHelpers.update_client_details(context, data: {
              'data_type': 'name',
              'client_key': widget.cl_id,
              'client_details': client_update_details
            });

            if (!res_2['status']) {
              Helpers.showToast(
                context: context,
                color: Colors.redAccent,
                toastText: 'An Error occurred, Try again!',
                icon: Icons.error,
              );
              return;
            }

            Helpers.showToast(
              context: context,
              color: Colors.greenAccent,
              toastText: 'Name updated successfully',
              icon: Icons.check,
            );

            setState(() {});
          }
        }

        // subscriptions
        if (value == 2) {
          ClientSubModel cl = ClientSubModel(
            sub_plan: client?.subPlan ?? '',
            pt_plan: client?.ptPlan ?? '',
            sub_status: client?.subStatus ?? false,
            pt_status: client?.ptStatus ?? false,
            sub_date: client?.subDate ?? '',
            pt_date: client?.ptDate ?? '',
            boxing: client?.boxing ?? false,
            bx_date: client?.bxDate ?? '',
            sub_paused: client?.subPaused ?? false,
            paused_date: client?.pausedDate ?? '',
          );

          var res = await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => SubscriptionDates(client: cl),
          );

          if (res != null) {
            // deactivate gym sub
            if (res == 'sub') {
              Map new_upd = {
                'sub_details.sub_status': false,
              };

              Map res_2 = await GymDatabaseHelpers.update_client_details(
                context,
                data: {
                  'data_type': 'deactivate_sub',
                  'client_key': widget.cl_id,
                  'client_details': new_upd
                },
              );

              if (!res_2['status']) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occurred, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              Sub_History_Model sub_hist = Sub_History_Model(
                key: '',
                sub_plan: client!.subPlan!,
                sub_type: client!.subType!,
                sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                exp_date: client!.subDate!,
                amount: 0,
                extras_amount: 0,
                boxing: false,
                pt_status: false,
                pt_plan: '',
                hist_type: 'Deactivated',
                history_id: Helpers.generate_order_id(),
              );

              // add to sub history
              GymDatabaseHelpers.add_to_sub_history(
                context,
                data: {
                  'client_key': widget.cl_id,
                  'sub_details': sub_hist.toJson(),
                },
              );

              Helpers.showToast(
                context: context,
                color: Colors.purpleAccent,
                toastText: 'Subscription plan inactive',
                icon: Icons.check,
              );
            }

            // activate personal training
            if (res == 'pt-a') {
              var res = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => PT_Dialog(),
              );

              if (res != null) {
                if (res != 'none') {
                  int sub_amount = (res == 'Standard')
                      ? standard_pt
                      : (res == 'Premium')
                          ? premium_pt
                          : 0;
                  int inc = client!.subIncome + sub_amount;

                  String pt_plan = res.toString();
                  String pt_date = get_pt_date();

                  Map new_upd = {
                    'sub_details.pt_plan': pt_plan,
                    'sub_details.pt_date': pt_date,
                    'sub_details.pt_status': true,
                    'sub_income': inc,
                  };

                  Map res_2 = await GymDatabaseHelpers.update_client_details(
                    context,
                    data: {
                      'data_type': 'activate_pt',
                      'client_key': widget.cl_id,
                      'client_details': new_upd
                    },
                  );

                  if (!res_2['status']) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'An Error occurred, Try again!',
                      icon: Icons.error,
                    );
                    return;
                  }

                  Sub_History_Model sub_hist = Sub_History_Model(
                    key: '',
                    sub_plan: '${pt_plan} Plan',
                    sub_type: '',
                    sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    exp_date: pt_date,
                    amount: sub_amount,
                    extras_amount: 0,
                    boxing: false,
                    pt_status: false,
                    pt_plan: '',
                    hist_type: 'Personal Training',
                    history_id: Helpers.generate_order_id(),
                  );

                  // add to sub history
                  GymDatabaseHelpers.add_to_sub_history(
                    context,
                    data: {
                      'client_key': widget.cl_id,
                      'sub_details': sub_hist.toJson(),
                    },
                  );

                  // play success animation
                  success_controller.play();

                  Helpers.showToast(
                    context: context,
                    color: Colors.blue,
                    toastText: 'Personal Training Activated',
                    icon: Icons.check,
                  );

                  Future.delayed(Duration(seconds: 3), () {
                    success_controller.stop();
                  });
                } else {}

                setState(() {});
              }
            }

            // deactivate personal training
            else if (res == 'pt-d') {
              Map new_upd = {
                'sub_details.pt_status': false,
              };

              Map res_2 = await GymDatabaseHelpers.update_client_details(
                context,
                data: {
                  'data_type': 'deactivate_pt',
                  'client_key': widget.cl_id,
                  'client_details': new_upd
                },
              );

              if (!res_2['status']) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occurred, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              Sub_History_Model sub_hist = Sub_History_Model(
                key: '',
                sub_plan: 'PT ${client!.ptPlan!} Plan',
                sub_type: '',
                sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                exp_date: client!.ptDate!,
                amount: 0,
                extras_amount: 0,
                boxing: false,
                pt_status: false,
                pt_plan: '',
                hist_type: 'Deactivated',
                history_id: Helpers.generate_order_id(),
              );

              // add to sub history
              GymDatabaseHelpers.add_to_sub_history(
                context,
                data: {
                  'client_key': widget.cl_id,
                  'sub_details': sub_hist.toJson(),
                },
              );

              Helpers.showToast(
                context: context,
                color: Colors.purpleAccent,
                toastText: 'Personal Training Deactivated',
                icon: Icons.check,
              );
            }

            // boxing
            if (res.toString().split(',').first == 'boxing') {
              bool box =
                  (res.toString().split(',').last == 'true') ? true : false;

              Map new_upd = {};
              int sub_amount = boxing_fee;

              String bx_date = get_pt_date();

              // activate boxing
              if (box) {
                var res2 = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => BxDialog(),
                );

                if (res2 != null && res2) {
                  int inc = client!.subIncome + sub_amount;

                  new_upd = {
                    'sub_details.boxing': true,
                    'sub_details.bx_date': bx_date,
                    'sub_income': inc,
                  };
                } else {
                  return;
                }
              }
              // deactivate boxing
              else {
                new_upd = {
                  'sub_details.boxing': false,
                };
              }

              Map res_2 = await GymDatabaseHelpers.update_client_details(
                context,
                data: {
                  'data_type': 'update_bx',
                  'client_key': widget.cl_id,
                  'client_details': new_upd
                },
              );

              if (!res_2['status']) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occurred, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              // add to sub history
              if (box) {
                Sub_History_Model sub_hist = Sub_History_Model(
                  key: '',
                  sub_plan: 'Monthly Boxing Plan',
                  sub_type: '',
                  sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  exp_date: bx_date,
                  amount: sub_amount,
                  extras_amount: 0,
                  boxing: false,
                  pt_status: false,
                  pt_plan: '',
                  hist_type: 'Boxing',
                  history_id: Helpers.generate_order_id(),
                );

                // add to sub history
                GymDatabaseHelpers.add_to_sub_history(
                  context,
                  data: {
                    'client_key': widget.cl_id,
                    'sub_details': sub_hist.toJson(),
                  },
                );
              } else {
                Sub_History_Model sub_hist = Sub_History_Model(
                  key: '',
                  sub_plan: 'Monthly Boxing Plan',
                  sub_type: '',
                  sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  exp_date: client!.bxDate!,
                  amount: 0,
                  extras_amount: 0,
                  boxing: false,
                  pt_status: false,
                  pt_plan: '',
                  hist_type: 'Deactivated',
                  history_id: Helpers.generate_order_id(),
                );

                // add to sub history
                GymDatabaseHelpers.add_to_sub_history(
                  context,
                  data: {
                    'client_key': widget.cl_id,
                    'sub_details': sub_hist.toJson(),
                  },
                );
              }

              // success animation
              if (box) {
                success_controller.play();
              }

              Helpers.showToast(
                context: context,
                color: Colors.purpleAccent,
                toastText: !box ? 'Boxing Deactivated' : 'Boxing Activated',
                icon: Icons.check,
              );

              if (box) {
                Future.delayed(Duration(seconds: 3), () {
                  success_controller.stop();
                });
              }
            }

            // resume sub
            if (res == 'resume_sub') {
              String ned = client!.subDate!;
              Map nt = {'sub_details.sub_paused': false};

              // sub plan
              if (client!.subStatus! && client!.subDate!.isNotEmpty) {
                int sub_rem_days = get_date(client!.subDate!)
                    .difference(get_date(client!.pausedDate!))
                    .inDays;

                ned = DateFormat('dd/MM/yyyy')
                    .format(DateTime.now().add(Duration(days: sub_rem_days)));

                nt.addAll({'sub_details.sub_date': ned});
              }

              // boxing plan
              if (client!.boxing! && client!.bxDate!.isNotEmpty) {
                int sub_rem_days = get_date(client!.bxDate!)
                    .difference(get_date(client!.pausedDate!))
                    .inDays;

                String ned = DateFormat('dd/MM/yyyy')
                    .format(DateTime.now().add(Duration(days: sub_rem_days)));

                nt.addAll({'sub_details.bx_date': ned});
              }

              // pt plan
              if (client!.ptStatus! && client!.ptDate!.isNotEmpty) {
                int sub_rem_days = get_date(client!.ptDate!)
                    .difference(get_date(client!.pausedDate!))
                    .inDays;

                String ned = DateFormat('dd/MM/yyyy')
                    .format(DateTime.now().add(Duration(days: sub_rem_days)));

                nt.addAll({'sub_details.pt_date': ned});
              }

              Map res_2 = await GymDatabaseHelpers.update_client_details(
                context,
                data: {
                  'data_type': 'resume_sub',
                  'client_key': widget.cl_id,
                  'client_details': nt
                },
              );

              if (!res_2['status']) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occurred, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              Sub_History_Model sub_hist = Sub_History_Model(
                key: '',
                sub_plan: client!.subPlan!,
                sub_type: client!.subType!,
                sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                exp_date: ned,
                amount: 0,
                extras_amount: 0,
                boxing: false,
                pt_status: false,
                pt_plan: '',
                hist_type: 'Subscription Resumed',
                history_id: Helpers.generate_order_id(),
              );

              // add to sub history
              GymDatabaseHelpers.add_to_sub_history(
                context,
                data: {
                  'client_key': widget.cl_id,
                  'sub_details': sub_hist.toJson(),
                },
              );

              Helpers.showToast(
                context: context,
                color: Colors.purpleAccent,
                toastText: 'All Subscriptions active',
                icon: Icons.check,
              );
            }

            // pause sub
            if (res == 'pause_sub') {
              Map nt = {
                'sub_details.sub_paused': true,
                'sub_details.paused_date':
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
              };

              Map res_2 = await GymDatabaseHelpers.update_client_details(
                context,
                data: {
                  'data_type': 'pause_sub',
                  'client_key': widget.cl_id,
                  'client_details': nt
                },
              );

              if (!res_2['status']) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occurred, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              Sub_History_Model sub_hist = Sub_History_Model(
                key: '',
                sub_plan: client!.subPlan!,
                sub_type: client!.subType!,
                sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                exp_date: client!.subDate!,
                amount: 0,
                extras_amount: 0,
                boxing: false,
                pt_status: false,
                pt_plan: '',
                hist_type: 'Subscription Paused',
                history_id: Helpers.generate_order_id(),
              );

              // add to sub history
              GymDatabaseHelpers.add_to_sub_history(
                context,
                data: {
                  'client_key': widget.cl_id,
                  'sub_details': sub_hist.toJson(),
                },
              );

              Helpers.showToast(
                context: context,
                color: Colors.purpleAccent,
                toastText: 'All Subscriptions paused',
                icon: Icons.check,
              );
            }
          }
        }

        // indemnity verification
        if (value == 3) {
          if (active_user!.app_role != 'CSU' && active_user!.app_role != 'ICT')
            return;

          if (!client!.indemnityVerified) {
            String name = '$first_name $last_name';

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => indemnityPage(
                  client_key: client!.key!,
                  client_name: name,
                ),
              ),
            );
          } else {
            Helpers.showToast(
              context: context,
              color: Colors.black,
              toastText: 'User Verified',
              icon: Icons.verified,
            );
          }
        }

        // qr code
        if (value == 4) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => QRCodeDialog(user_id: client!.clientId!),
          );
        }

        // physio
        if (value == 5) {
          // view physio profile
          if (client!.physioCl && client!.physioKey!.isNotEmpty) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         PatientProfilePage(cl_id: client!.physio_key),
            //   ),
            // );
          }

          // register for physio
          else {
            if (active_user!.app_role != 'CSU' &&
                active_user!.app_role != 'ICT') return;

            var conf = await showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                title: 'Register Physio',
                subtitle:
                    'You are about to register this client for physiotherapy. Would you like to proceed?',
              ),
            );

            if (conf == null || !conf) return;

            Ft_Pt_Model new_pt_cl = Ft_Pt_Model(
              first_name: first_name,
              middle_name: middle_name,
              last_name: last_name,
              image_file: user_image,
              phone_1: phone_1_controller.text,
              phone_2: phone_2_controller.text,
              email: email_controller.text,
              address: address_controller.text,
              dob: dob_controller.text,
              age: age_controller.text,
              occupation: occupation_select,
              gender_select: gender_select,
              hmo_select: hmo_select,
              hmo_id: hmo_id_controller.text,
              user_key: client!.key!,
            );

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => PatientRegistrationPage(
            //             new_ft: new_pt_cl,
            //           )),
            // );
          }

          Helpers.showToast(
              context: context,
              color: Colors.black,
              toastText: 'Not available',
              icon: Icons.info_outline);
        }

        // advance renewal
        if (value == 6) {
          String name = '${client!.fName} ${client!.lName}';

          RenewalModel newDet = RenewalModel(
            key: client!.key!,
            id: client!.clientId!,
            reg_date: client!.regDate!,
            user_image: client!.userImage!,
            name: name,
            sub_plan: client!.subPlan!.isEmpty && client!.hmo != 'No HMO'
                ? 'HMO Plan'
                : client!.subPlan!,
            pt_plan: client!.ptPlan!,
            pt_status: client!.ptStatus!,
            boxing: client!.boxing!,
            sub_type: client!.subType!,
            hmo_name: client!.hmo,
            sub_income: client!.subIncome,
            program_type: client!.programTypeSelect ?? "",
            renew_dates: client!.renewDates ?? "",
            registration_dates: client!.registrationDates ?? "",
            sub_date: client!.subDate ?? '',
            registered: client!.registered,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RenewalPage(
                details: newDet,
                register: client!.subPlan!.isEmpty,
                adv_renewal: true,
              ),
            ),
          );
        }

        // delete user
        else if (value == 0) {
          // var conf = await Helpers.enter_password(context,
          //     title: 'Delete User password');

          // if (!conf) return;

          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ConfirmDialog(
              title: 'Delete User',
              subtitle:
                  'You are about to delete this client\'s profile, This cannot be undone.\nWould you like to proceed?',
            ),
          );

          if (res != null && res == true) {
            Helpers.showLoadingScreen(context: context);

            Map dt = await GymDatabaseHelpers.delete_client(context,
                client_id: widget.cl_id);

            Navigator.pop(context);

            if (!dt['status']) {
              Helpers.showToast(
                context: context,
                color: Colors.redAccent,
                toastText: 'Error, Try again',
                icon: Icons.error,
              );
              return;
            }

            // remove page
            Navigator.pop(context);
            Helpers.showToast(
              context: context,
              color: Colors.blue,
              toastText: 'User Deleted',
              icon: Icons.check,
            );
          }
        }
      },
      itemBuilder: (context) => [
        // edit name
        if (active_user!.app_role == 'ICT' || active_user!.app_role == 'CSU')
          PopupMenuItem(
            value: 1,
            child: Container(
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 5),
                  Text(
                    'Edit name',
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
          ),

        // subscriptions
        PopupMenuItem(
          value: 2,
          child: Container(
            child: Row(
              children: [
                Icon(Icons.workspace_premium, size: 16),
                SizedBox(width: 5),
                Text(
                  'Subscriptions',
                  style: TextStyle(),
                ),
              ],
            ),
          ),
        ),

        // advance renewal
        if (client!.subStatus ?? false)
          PopupMenuItem(
            value: 6,
            child: Container(
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, size: 16),
                  SizedBox(width: 5),
                  Text(
                    'Advanced Renewal',
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
          ),

        // indemnity verification
        PopupMenuItem(
          value: 3,
          child: Container(
            child: Row(
              children: [
                Icon(
                  client!.indemnityVerified ? Icons.verified : Icons.circle,
                  size: 16,
                  color: client!.indemnityVerified ? Colors.blue : Colors.grey,
                ),
                SizedBox(width: 5),
                Text(
                  client!.indemnityVerified
                      ? 'Verified'
                      : (active_user!.app_role != 'CSU' &&
                              active_user!.app_role != 'ICT')
                          ? 'Not Verified'
                          : 'Verify User Agreement',
                  style: TextStyle(
                    color:
                        client!.indemnityVerified ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        // qr code
        PopupMenuItem(
          value: 4,
          child: Container(
            child: Row(
              children: [
                Icon(Icons.qr_code, size: 16),
                SizedBox(width: 5),
                Text(
                  'View QR Code',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),

        PopupMenuDivider(),

        // physio
        if ((active_user!.app_role == 'CSU' ||
                active_user!.app_role == 'ICT') ||
            client!.physioCl)
          PopupMenuItem(
            value: 5,
            child: Container(
              child: Row(
                children: [
                  Icon(Icons.health_and_safety, size: 16),
                  SizedBox(width: 5),
                  Text(
                    client!.physioCl ? 'Physio Profile' : 'Register for Physio',
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),

        PopupMenuDivider(),

        // delete user
        if (active_user!.app_role == 'Admin' || active_user!.app_role == 'ICT')
          PopupMenuItem(
            value: 0,
            child: Container(
              child: Text(
                'Delete User',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
      ],
    );
  }

  //? FUNCTION

  // calculate age
  String calc_age(DateTime dob) {
    // return
    DateTime currentDate = DateTime.now();

    int age = currentDate.year - dob.year;
    int month1 = currentDate.month;
    int month2 = dob.month;

    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = dob.day;

      if (day2 > day1) {
        age--;
      }
    }

    return age.toString();
  }

  // months selector => active month
  At_Date set_active_month() {
    DateTime today = DateTime.now();

    int month = today.month;
    int year = today.year;

    String mon = DateFormat('MMMM').format(today);

    At_Date newDate = At_Date(title: '$mon, $year', year: year, month: month);

    return newDate;
  }

  // update text controllers
  void update_profile_controllers() {
    if (client == null) return;
    first_name = client?.fName ?? "";
    middle_name = client?.mName ?? "";
    last_name = client?.lName ?? "";
    user_image = client?.userImage ?? "";

    phone_1_controller.text = client?.phone1 ?? "";
    phone_2_controller.text = client?.phone2 ?? "";
    email_controller.text = client?.email ?? "";
    address_controller.text = client?.address ?? "";
    ig_controller.text = client?.igUser ?? "";
    fb_controller.text = client?.fbUser ?? "";

    dob_controller.text = client!.dob!;
    show_age = client!.showAge;
    occupation_select = client!.occupation!;
    gender_select = client!.gender!;
    subscription_status = client!.subStatus!;
    program_type_select = client!.programTypeSelect ?? "";
    corporate_type_select = client!.corporateTypeSelect ?? "";

    hmo_select = client!.hmo!;
    hmo_id_controller.text = client!.hmoId!;

    hykau = client!.hykau!;
    hykau_controller.text = client!.hykauOthers ?? "";
    company_name_controller.text = client!.companyName ?? "";

    // age calculator
    if (dob_controller.text.isNotEmpty) {
      var date_data = dob_controller.text.split('/');
      var date_res = DateTime(
        int.parse(date_data[2]),
        int.parse(date_data[1]),
        int.parse(date_data[0]),
      );

      if (show_age) {
        age_controller.text = calc_age(date_res);
      } else {
        dob_controller.text =
            '${dob_controller.text.split('/')[0]}/${dob_controller.text.split('/')[1]}';
      }
    } else {
      age_controller.clear();
    }

    if (mounted) setState(() {});
  }

  void update_health_controllers(HealthSummaryModel client_health) async {
    height_controller.text = client_health.height;
    weight_controller.text = client_health.weight;

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

    if (mounted) setState(() {});
  }

  //? update client info
  update_client_details() async {
    if (image_file != null) {
      // user_image = await AdminDatabaseHelpers.uploadFile(
      //         image_file!, widget.cl_id, true) ??
      //     '';
    }

    String dob = dob_controller.text.trim();
    if (dob.isNotEmpty) {
      if (dob.split('/').length > 2) {
        dob = dob;
      } else {
        dob += '/1900';
      }
    }

    Map client_update_details = {
      'user_image': user_image,
      'contact_details.phone_1': phone_1_controller.text.trim(),
      'contact_details.phone_2': phone_2_controller.text.trim(),
      'contact_details.email': email_controller.text.trim(),
      'contact_details.address': address_controller.text.trim(),
      'contact_details.ig_user': ig_controller.text.trim(),
      'contact_details.fb_user': fb_controller.text.trim(),
      'personal_details.gender': gender_select,
      'personal_details.dob': dob,
      'personal_details.show_age': show_age,
      'personal_details.occupation': occupation_select,
      'program_details.program_type_select': program_type_select,
      'program_details.corporate_type_select': corporate_type_select,
      'program_details.company_name': company_name_controller.text.trim(),
      'program_details.hmo': hmo_select,
      'program_details.hmo_id': hmo_id_controller.text.trim(),
      'program_details.hykau': hykau,
      'program_details.hykau_others': hykau_controller.text.trim(),
    };

    Map dt = await GymDatabaseHelpers.update_client_details(context, data: {
      'data_type': 'profile',
      'client_key': widget.cl_id,
      'client_details': client_update_details
    });

    if (!dt['status']) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'An Error occurred, Try again!',
        icon: Icons.error,
      );
      return false;
    }

    Helpers.showToast(
      context: context,
      color: Colors.blue,
      toastText: 'Profile Successfully Updated',
      icon: Icons.check,
    );
  }

  // edit health
  void new_health_details(
      {required HealthClientModel client, required HealthModel health}) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientHealthRegistrationPage(
          client: client,
          health: health,
        ),
      ),
    );

    if (res != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientHDPage(
            client: client,
            health: res,
          ),
        ),
      );

      setState(() {});
    }
  }

  // get date
  DateTime get_date(String data) {
    var date_data = data.split('/');
    return DateTime(
      int.parse(date_data[2]),
      int.parse(date_data[1]),
      int.parse(date_data[0]),
    );
  }

  String get_pt_date() {
    int duration = 1;

    DateTime d = DateTime.now();

    int new_month = d.month;
    int new_year = d.year;
    int new_day = d.day;

    int mon = d.month;
    int n_mon = mon + duration;

    if (n_mon > 12) {
      int rem = n_mon - 12;
      new_month = rem;
      new_year++;
    } else {
      new_month = n_mon;
    }

    if (new_month == 2 && new_day > 28) {
      new_day = 28;
    }

    if ((new_month == 4 ||
            new_month == 6 ||
            new_month == 9 ||
            new_month == 11) &&
        new_day > 30) {
      new_day = 30;
    }

    d = DateTime(new_year, new_month, new_day);

    DateTime newDate = d;

    String date_set = DateFormat('dd/MM/yyyy').format(newDate);

    return date_set;
  }

  //
}

// personal training dialog
class PT_Dialog extends StatefulWidget {
  const PT_Dialog({super.key});

  @override
  State<PT_Dialog> createState() => _PT_DialogState();
}

class _PT_DialogState extends State<PT_Dialog> {
  bool sp_pt = false;
  int sp_pt_value = standard_pt;

  bool pp_pt = false;
  int pp_pt_value = premium_pt;

  bool none = false;

  @override
  Widget build(BuildContext context) {
    var value = NumberFormat('#,###');
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 700,
        ),
        child: Container(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading
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
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Personal Training',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(
                        'If you like to opt for Personal training\nselect one of the options below.',
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

              SizedBox(height: 5),

              // standard plan
              InkWell(
                onTap: () {
                  sp_pt = !sp_pt;
                  none = false;

                  if (sp_pt && pp_pt) {
                    pp_pt = false;
                  }

                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  color: sp_pt ? Colors.blueAccent : Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      // color: sp_pt ? Colors.blueAccent : Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        // radio
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sp_pt ? Colors.white : Colors.blueAccent,
                            // border: Border.all(
                            //   color: Colors.black45,
                            // ),
                          ),
                        ),

                        // title
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Standard Plan',
                            style: TextStyle(
                              color: sp_pt ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        Expanded(child: Container()),

                        Text(
                          '₦ ${value.format(sp_pt_value)}',
                          style: TextStyle(
                            color: sp_pt ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // premium
              InkWell(
                onTap: () {
                  pp_pt = !pp_pt;
                  none = false;

                  if (pp_pt && sp_pt) {
                    sp_pt = false;
                  }

                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  color: pp_pt ? Colors.blueAccent : Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      // color: pp_pt ? Colors.blueAccent : Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        // radio
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pp_pt ? Colors.white : Colors.blueAccent,
                            // border: Border.all(
                            //   color: Colors.black45,
                            // ),
                          ),
                        ),

                        // title
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Premium Plan',
                            style: TextStyle(
                              color: pp_pt ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        Expanded(child: Container()),

                        Text(
                          '₦ ${value.format(pp_pt_value)}',
                          style: TextStyle(
                            color: pp_pt ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // none
              InkWell(
                onTap: () {
                  none = !none;

                  sp_pt = false;
                  pp_pt = false;

                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  color: none ? Colors.blueAccent : Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        // radio
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: none ? Colors.white : Colors.blueAccent,
                          ),
                        ),

                        // title
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'None',
                            style: TextStyle(
                              color: none ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // selected plan
              Text(
                'Selected Plan: ${(sp_pt) ? 'Standard Plan' : (pp_pt) ? 'Premium Plan' : 'None'}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),

              SizedBox(height: 10),

              // proceed button
              (!pp_pt && !sp_pt && !none)
                  ? Container(
                      height: 32,
                    )
                  : InkWell(
                      onTap: () {
                        Navigator.pop(
                            context,
                            (sp_pt)
                                ? 'Standard'
                                : (pp_pt)
                                    ? 'Premium'
                                    : (none)
                                        ? 'none'
                                        : null);
                      },
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF3c5bff).withOpacity(0.6),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Center(
                          child: Text(
                            (none) ? 'Cancel' : 'Select',
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
      ),
    );
  }
}

class BxDialog extends StatelessWidget {
  const BxDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var value = NumberFormat('#,###');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 400,
        ),
        child: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading
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
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Boxing',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(
                        'If you like to purchase the monthly boxing plan please proceed',
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

              SizedBox(height: 5),

              // boxing plan
              InkWell(
                onTap: () {},
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  color: Colors.blueAccent,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      // color: sp_pt ? Colors.blueAccent : Colors.white,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        // radio
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),

                        // title
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Monthly Boxing Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // selected plan
              Text(
                '₦ ${value.format(boxing_fee)}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              SizedBox(height: 10),

              // proceed button
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, false);
                      },
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              Color.fromARGB(255, 255, 60, 60).withOpacity(0.6),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Center(
                          child: Text(
                            'Cancel',
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
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF3c5bff).withOpacity(0.6),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Center(
                          child: Text(
                            'Confirm',
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// subscription dates
class SubscriptionDates extends StatelessWidget {
  const SubscriptionDates({
    super.key,
    required this.client,
  });

  final ClientSubModel client;

  String getDate(String data) {
    if (data.isEmpty) return "";
    var date_data = data.split('/');
    DateTime date = DateTime(
      (date_data.length > 2) ? int.parse(date_data[2]) : DateTime.now().year,
      (date_data.length > 1) ? int.parse(date_data[1]) : DateTime.now().month,
      int.parse(date_data[0]),
    );

    var day = date.day;
    var month = DateFormat('MMMM').format(date);
    var year = date.year;

    return '$day $month, $year';
  }

  bool check_date(String time) {
    var date_data = time.split('/');
    DateTime tm = DateTime(
      (date_data.length > 2) ? int.parse(date_data[2]) : DateTime.now().year,
      (date_data.length > 1) ? int.parse(date_data[1]) : DateTime.now().month,
      int.parse(date_data[0]),
    );

    return tm.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    UserModel? active_user = AppData.get(context).active_user;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 700,
        ),
        child: Container(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading
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

                    // top bar
                    Stack(
                      children: [
                        // title
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Subscriptions',
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(
                        'Below are the subscriptions and their renewal dates.',
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

              SizedBox(height: 10),

              // Gym Subscription
              GestureDetector(
                onDoubleTap: () async {
                  if (active_user!.app_role != 'CSU' &&
                      active_user.app_role != 'ICT') return;

                  if (client.sub_status && active_user.app_role != 'ICT')
                    return;

                  if (!client.sub_status && client.sub_date.isEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText:
                          'You have no subscription yet. Please Purchase!',
                      icon: Icons.error_rounded,
                    );
                    return;
                  }

                  if (!client.sub_status) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText:
                          'This subscription is not active. Please Renew!',
                      icon: Icons.error_rounded,
                    );
                    return;
                  }

                  var res = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ConfirmDialog(
                      title: 'Deactivate Subscription',
                      subtitle:
                          'This action would terminate the current subscription plan of this client.\nWould you like to proceed?',
                    ),
                  );

                  if (res != null && res == true) {
                    Navigator.pop(context, 'sub');
                  }
                },
                child: Stack(
                  children: [
                    // main box
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(top: 12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          // name
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              client.sub_plan,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),

                          Expanded(child: Container()),

                          // date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(height: 20),
                              Text(
                                client.sub_date.isEmpty
                                    ? ''
                                    : !client.sub_status
                                        ? !check_date(client.sub_date)
                                            ? 'Deactivated'
                                            : 'Expired ${getDate(client.sub_date)}'
                                        : getDate(client.sub_date),
                                style: TextStyle(
                                  color: !client.sub_status
                                      ? Colors.redAccent
                                      : Colors.black,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // title
                    Positioned(
                      top: 0,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (!client.sub_status)
                              ? (client.sub_date.isEmpty)
                                  ? Colors.grey
                                  : Colors.redAccent
                              : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          'Gym Membership',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

              // personal training
              GestureDetector(
                onDoubleTap: () async {
                  if (active_user!.app_role != 'CSU' &&
                      active_user.app_role != 'ICT') return;

                  if (client.pt_status && active_user.app_role != 'ICT') return;

                  var res = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ConfirmDialog(
                      title: (!client.pt_status)
                          ? 'Purchase Subscription'
                          : 'Deactivate Subscription',
                      subtitle: 'Would you like to proceed?',
                    ),
                  );

                  if (res != null && res == true) {
                    Navigator.pop(
                      context,
                      (!client.pt_status) ? 'pt-a' : 'pt-d',
                    );
                  }
                },
                child: Stack(
                  children: [
                    // main box
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(top: 12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          // name
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              client.pt_plan,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Container(),
                          ),

                          // date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(height: 20),
                              Text(
                                client.pt_date.isEmpty
                                    ? ''
                                    : !client.pt_status
                                        ? !check_date(client.pt_date)
                                            ? 'Deactivated'
                                            : 'Expired '
                                        : '' + getDate(client.pt_date),
                                style: TextStyle(
                                  color: !client.pt_status
                                      ? Colors.redAccent
                                      : Colors.black,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // title
                    Positioned(
                      top: 0,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (!client.pt_status)
                              ? (client.pt_date.isEmpty)
                                  ? Colors.grey
                                  : Colors.redAccent
                              : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          'Personal Training',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

              // boxing
              GestureDetector(
                onDoubleTap: () async {
                  if (active_user!.app_role != 'CSU' &&
                      active_user!.app_role != 'ICT') return;

                  if (client.boxing && active_user!.app_role != 'ICT') return;

                  var res = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ConfirmDialog(
                      title: (!client.boxing)
                          ? 'Purchase Subscription'
                          : 'Deactivate Subscription',
                      subtitle: 'Would you like to proceed?',
                    ),
                  );

                  if (res != null && res == true) {
                    Navigator.pop(
                        context, 'boxing,${!client.boxing ? 'true' : 'false'}');
                  }
                },
                child: Stack(
                  children: [
                    // main box
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(top: 12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          // name
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              'Boxing',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Container(),
                          ),

                          // date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(height: 20),
                              Text(
                                client.bx_date.isEmpty
                                    ? ''
                                    : !client.boxing
                                        ? !check_date(client.bx_date)
                                            ? 'Deactivated'
                                            : 'Expired '
                                        : '' + getDate(client.bx_date),
                                style: TextStyle(
                                  color: !client.boxing
                                      ? Colors.redAccent
                                      : Colors.black,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // title
                    Positioned(
                      top: 0,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (!client.boxing)
                              ? (client.bx_date.isEmpty)
                                  ? Colors.grey
                                  : Colors.redAccent
                              : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          'Gym Extras',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

              SizedBox(height: 15),

              // pause/resume all sub
              Row(
                children: [
                  !client.sub_paused
                      ? Container()
                      : Container(
                          height: 36,
                          padding: EdgeInsets.only(right: 12),
                          child: Row(
                            children: [
                              Text(
                                'Paused on',
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 12),
                              ),
                              SizedBox(width: 5),
                              Text(
                                getDate(client.paused_date),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              )
                            ],
                          ),
                        ),
                  if (active_user!.app_role == 'CSU' ||
                      active_user!.app_role == 'ICT')
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (!client.sub_paused) {
                            // ||
                            if (!client.sub_status) {
                              Helpers.showToast(
                                context: context,
                                color: Colors.red,
                                toastText: 'No active subscription',
                                icon: Icons.error,
                              );
                              return;
                            }
                          }

                          var conf = await showDialog(
                            context: context,
                            builder: (context) => ConfirmDialog(
                              title: (client.sub_paused)
                                  ? 'Resume Subscription'
                                  : 'Pause Subscription',
                              subtitle:
                                  'You are about to ${(client.sub_paused) ? 'resume your paused' : 'pause all active'} subscriptions. Would you like to proceed?',
                            ),
                          );

                          if (conf != null && conf) {
                            // resume
                            if (client.sub_paused) {
                              Navigator.pop(context, 'resume_sub');
                            }

                            // pause
                            else {
                              Navigator.pop(context, 'pause_sub');
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: client.sub_paused ? Colors.blue : Colors.red,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          height: 36,
                          child: Center(
                            child: Text(
                              client.sub_paused
                                  ? 'Resume Subscriptions'
                                  : 'Pause active Subscriptions',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Gym to Physio model
class Ft_Pt_Model {
  String first_name;
  String middle_name;
  String last_name;
  String image_file;
  String phone_1;
  String phone_2;
  String email;
  String address;
  String dob;
  String age;
  String occupation;
  String gender_select;
  String hmo_select;
  String hmo_id;
  String user_key;

  Ft_Pt_Model({
    required this.first_name,
    required this.middle_name,
    required this.last_name,
    required this.image_file,
    required this.phone_1,
    required this.phone_2,
    required this.email,
    required this.address,
    required this.dob,
    required this.age,
    required this.occupation,
    required this.gender_select,
    required this.hmo_select,
    required this.hmo_id,
    required this.user_key,
  });
}
