import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/attendance_model.dart';
import 'package:heritage_soft/datamodels/client_health_model.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/gym/client_health_details_page.dart';
import 'package:heritage_soft/pages/gym/client_health_registration_page.dart';
import 'package:heritage_soft/pages/gym/clients_attendance_history.dart';
import 'package:heritage_soft/pages/gym/indemnity_page.dart';
import 'package:heritage_soft/pages/gym/renewal_page.dart';
import 'package:heritage_soft/pages/gym/sub_history_page.dart';
import 'package:heritage_soft/pages/clinic/patient_pofile_page.dart';
import 'package:heritage_soft/pages/clinic/patient_registration_page.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
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
import 'package:heritage_soft/helpers/admin_database_helpers.dart';

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

  List<String> hmo = gym_hmo.map((e) => e.hmo_name).toList();

  late StreamSubscription health_summary_stream;
  late StreamSubscription client_details_stream;

  // get client details
  get_client_details() {
    client_details_stream =
        GymDatabaseHelpers.client_details_stream(widget.cl_id).listen((event) {
      if (edit) return;

      // if (event.data() != null) {
      //   Map map = event.data()!;
      //   client = ClientModel.fromMap(event.id, map);
      //   update_profile_controllers();
      // }
    });
  }

  // get health_summary_stream
  get_health_summary() {
    health_summary_stream =
        GymDatabaseHelpers.client_health_summary_stream(widget.cl_id)
            .listen((event) {
      if (edit) return;

      // if (event.data() != null) {
      //   HealthSummaryModel client_health =
      //       HealthSummaryModel.fromMap(event.data()!);

      //   update_health_controllers(client_health);
      // }
    });
  }

  @override
  void initState() {
    get_client_details();
    get_health_summary();
    super.initState();
  }

  @override
  void dispose() {
    health_summary_stream.cancel();
    client_details_stream.cancel();

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

                    // edit notifictaion
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

  // WIDGETs
  // main page
  Widget main_page() {
    if (client == null) {
      return Center(child: CircularProgressIndicator());
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
    if (client!.reg_date!.isNotEmpty) {
      var date_data = client!.reg_date!.split('/');
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
              client!.id ?? '',
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
            client!.sub_plan!.isNotEmpty
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
                              client!.sub_plan!,
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
                          client!.sub_type!,
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
            if (client!.physio_cl)
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
            !client!.pt_status!
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
                            'PT - ${client!.pt_plan}',
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

                  client != null && client!.sub_paused!
                      ? sub_paused_box()
                      : Container(),

                  // renew button
                  if (app_role == 'desk' || app_role == 'ict')
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
                      label: 'Address',
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

                  Helpers.showLoadingScreen(context: context);

                  HealthClientModel client_h = HealthClientModel(
                    key: client!.key!,
                    id: client!.id!,
                    name: '$first_name $middle_name $last_name',
                    user_image: user_image,
                    hmo: client!.hmo!,
                    baseline_done: client!.baseline_done,
                    program_type: client!.program_type_select,
                  );

                  List<G_HealthModel> _all = [];

                  await GymDatabaseHelpers.client_health_details(client!.key!)
                      .then((snap) async {
                    // snap.docs.forEach((element) {
                    //   _all.add(G_HealthModel(
                    //       key: element.id,
                    //       type: element.data()['data_type'] ?? 'basic',
                    //       data:
                    //           HealthModel.fromMap(element.id, element.data())));
                    // });

                    Navigator.pop(context);

                    // if db contains data
                    if (_all.isNotEmpty) {
                      // set baseline done if baseline date is different from today
                      if (_all.length == 1 && !client!.baseline_done) {
                        if (Helpers.fmt_date(_all[0].data.date) !=
                            DateFormat('d MMM, y').format(DateTime.now())) {
                          GymDatabaseHelpers.update_client_details(
                              client!.key!, {'baseline_done': true});
                          client!.baseline_done = true;
                        }
                      }

                      if (client!.baseline_done) {
                        var conf = await showDialog(
                            context: context,
                            builder: (context) =>
                                HealthSelectorDialog(list: _all));

                        if (conf != null) {
                          if (conf[1]) {
                            new_health_details(
                                client: client_h, health: conf[0]);
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
                      if (app_role != 'desk' && app_role != 'ict') return;

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
                  });
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
                  id: client!.id!,
                  name: client!.f_name!,
                  sub_plan: client!.sub_plan!,
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
                    id: client!.id!,
                    name: client!.f_name!,
                    sub_plan: client!.sub_plan!,
                    sub_income: client!.sub_income,
                    fullname: '${client!.f_name} ${client!.l_name}');

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
        if (client != null && (app_role == 'ict'))
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
        String name = '${client!.f_name} ${client!.l_name}';

        RenewalModel newDet = RenewalModel(
          key: client!.key!,
          id: client!.id!,
          reg_date: client!.reg_date!,
          user_image: client!.user_image!,
          name: name,
          sub_plan: client!.sub_plan!.isEmpty && client!.hmo != 'No HMO'
              ? 'HMO Plan'
              : client!.sub_plan!,
          pt_plan: client!.pt_plan!,
          pt_status: client!.pt_status!,
          boxing: client!.boxing!,
          sub_type: client!.sub_type!,
          hmo_name: client!.hmo,
          sub_income: client!.sub_income,
          program_type: client!.program_type_select,
          renew_dates: client!.renew_dates,
          registration_dates: client!.registration_dates,
          sub_date: client!.sub_date ?? '',
          registered: client!.registered,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RenewalPage(
              details: newDet,
              register: client!.sub_plan!.isEmpty,
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
            client!.sub_plan!.isEmpty ? 'Subscribe' : 'Renew',
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

        if (address_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Address Empty',
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

            Map client_name_update = {
              'f_name': first_name,
              'm_name': middle_name,
              'l_name': last_name,
            };

            Helpers.showLoadingScreen(context: context);
            bool ress = await GymDatabaseHelpers.update_client_details(
                client!.key!, client_name_update);
            Navigator.pop(context);

            if (!ress) {
              Helpers.showToast(
                context: context,
                color: Colors.redAccent,
                toastText: 'An Error occured, Try again!',
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
            sub_plan: client!.sub_plan!,
            pt_plan: client!.pt_plan!,
            sub_status: client!.sub_status!,
            pt_status: client!.pt_status!,
            sub_date: client!.sub_date!,
            pt_date: client!.pt_date!,
            boxing: client!.boxing!,
            bx_date: client!.bx_date!,
            sub_paused: client!.sub_paused!,
            paused_date: client!.paused_date!,
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
                'sub_status': false,
              };

              Helpers.showLoadingScreen(context: context);
              bool ress = await GymDatabaseHelpers.update_client_details(
                  client!.key!, new_upd);
              Navigator.pop(context);

              if (!ress) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occured, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              Sub_History_Model subhist = Sub_History_Model(
                key: '',
                sub_plan: client!.sub_plan!,
                sub_type: client!.sub_type!,
                sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                exp_date: client!.sub_date!,
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
                  client!.key!, subhist.toJson());

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
                  int inc = client!.sub_income + sub_amount;

                  Map new_upd = {
                    'pt_plan': res.toString(),
                    'pt_date': get_pt_date(),
                    'pt_status': true,
                    'sub_income': inc,
                  };

                  Helpers.showLoadingScreen(context: context);
                  bool ress = await GymDatabaseHelpers.update_client_details(
                      client!.key!, new_upd);
                  Navigator.pop(context);

                  if (!ress) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'An Error occured, Try again!',
                      icon: Icons.error,
                    );
                    return;
                  }

                  Sub_History_Model subhist = Sub_History_Model(
                    key: '',
                    sub_plan: '${new_upd['pt_plan']} Plan',
                    sub_type: '',
                    sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    exp_date: new_upd['pt_date'],
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
                      client!.key!, subhist.toJson());

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
                'pt_status': false,
              };

              Helpers.showLoadingScreen(context: context);
              bool ress = await GymDatabaseHelpers.update_client_details(
                  client!.key!, new_upd);
              Navigator.pop(context);

              if (!ress) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occured, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              Sub_History_Model subhist = Sub_History_Model(
                key: '',
                sub_plan: 'PT ${client!.pt_plan!} Plan',
                sub_type: '',
                sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                exp_date: client!.pt_date!,
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
                  client!.key!, subhist.toJson());

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

              // activate boxing
              if (box) {
                var res2 = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => BxDialog(),
                );

                if (res2 != null && res2) {
                  int inc = client!.sub_income + sub_amount;

                  new_upd = {
                    'boxing': true,
                    'bx_date': get_pt_date(),
                    'sub_income': inc,
                  };
                } else {
                  return;
                }
              }
              // deactivate boxing
              else {
                new_upd = {
                  'boxing': false,
                };
              }

              Helpers.showLoadingScreen(context: context);
              bool ress = await GymDatabaseHelpers.update_client_details(
                  client!.key!, new_upd);
              Navigator.pop(context);

              if (!ress) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occured, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              // add to sub history
              if (box) {
                Sub_History_Model subhist = Sub_History_Model(
                  key: '',
                  sub_plan: 'Monthly Boxing Plan',
                  sub_type: '',
                  sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  exp_date: new_upd['bx_date'],
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
                    client!.key!, subhist.toJson());
              } else {
                Sub_History_Model subhist = Sub_History_Model(
                  key: '',
                  sub_plan: 'Monthly Boxing Plan',
                  sub_type: '',
                  sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  exp_date: client!.bx_date!,
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
                    client!.key!, subhist.toJson());
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
              String ned = client!.sub_date!;
              Map nt = {'sub_paused': false};

              // sub plan
              if (client!.sub_status! && client!.sub_date!.isNotEmpty) {
                int sub_rem_days = get_date(client!.sub_date!)
                    .difference(get_date(client!.paused_date!))
                    .inDays;

                ned = DateFormat('dd/MM/yyyy')
                    .format(DateTime.now().add(Duration(days: sub_rem_days)));

                nt.addAll({'sub_date': ned});
              }

              // boxing plan
              if (client!.boxing! && client!.bx_date!.isNotEmpty) {
                int sub_rem_days = get_date(client!.bx_date!)
                    .difference(get_date(client!.paused_date!))
                    .inDays;

                String ned = DateFormat('dd/MM/yyyy')
                    .format(DateTime.now().add(Duration(days: sub_rem_days)));

                nt.addAll({'bx_date': ned});
              }

              // pt plan
              if (client!.pt_status! && client!.pt_date!.isNotEmpty) {
                int sub_rem_days = get_date(client!.pt_date!)
                    .difference(get_date(client!.paused_date!))
                    .inDays;

                String ned = DateFormat('dd/MM/yyyy')
                    .format(DateTime.now().add(Duration(days: sub_rem_days)));

                nt.addAll({'pt_date': ned});
              }

              Helpers.showLoadingScreen(context: context);
              bool ress = await GymDatabaseHelpers.update_client_details(
                  client!.key!, nt);
              Navigator.pop(context);

              if (!ress) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occured, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              Sub_History_Model subhist = Sub_History_Model(
                key: '',
                sub_plan: client!.sub_plan!,
                sub_type: client!.sub_type!,
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
                  client!.key!, subhist.toJson());

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
                'sub_paused': true,
                'paused_date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
              };

              Helpers.showLoadingScreen(context: context);
              bool ress = await GymDatabaseHelpers.update_client_details(
                  client!.key!, nt);
              Navigator.pop(context);

              if (!ress) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'An Error occured, Try again!',
                  icon: Icons.error,
                );
                return;
              }

              Sub_History_Model subhist = Sub_History_Model(
                key: '',
                sub_plan: client!.sub_plan!,
                sub_type: client!.sub_type!,
                sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                exp_date: client!.sub_date!,
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
                  client!.key!, subhist.toJson());

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
          if (app_role != 'desk' && app_role != 'ict') return;

          if (!client!.indemnity_verified) {
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
            builder: (context) => QRCodeDialog(user_id: client!.id!),
          );
        }

        // physio
        if (value == 5) {
          // view physio profile
          if (client!.physio_cl && client!.physio_key.isNotEmpty) {
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
            if (app_role != 'desk' && app_role != 'ict') return;

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
            //             cl_id: Helpers.generate_id(
            //                 'phy', (hmo_select != 'No HMO')),
            //             new_ft: new_pt_cl,
            //           )),
            // );
          }
        }

        // advance renewal
        if (value == 6) {
          String name = '${client!.f_name} ${client!.l_name}';

          RenewalModel newDet = RenewalModel(
            key: client!.key!,
            id: client!.id!,
            reg_date: client!.reg_date!,
            user_image: client!.user_image!,
            name: name,
            sub_plan: client!.sub_plan!.isEmpty && client!.hmo != 'No HMO'
                ? 'HMO Plan'
                : client!.sub_plan!,
            pt_plan: client!.pt_plan!,
            pt_status: client!.pt_status!,
            boxing: client!.boxing!,
            sub_type: client!.sub_type!,
            hmo_name: client!.hmo,
            sub_income: client!.sub_income,
            program_type: client!.program_type_select,
            renew_dates: client!.renew_dates,
            registration_dates: client!.registration_dates,
            sub_date: client!.sub_date ?? '',
            registered: client!.registered,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RenewalPage(
                details: newDet,
                register: client!.sub_plan!.isEmpty,
                adv_renewal: true,
              ),
            ),
          );
        }

        // delete user
        else if (value == 0) {
          var conf = await Helpers.enter_password(context,
              title: 'Delete User password');

          if (!conf) return;

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

            bool dt = await GymDatabaseHelpers.delete_client(widget.cl_id);

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
        if (app_role == 'ict')
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
        if (client!.sub_status ?? false)
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
                  client!.indemnity_verified ? Icons.verified : Icons.circle,
                  size: 16,
                  color: client!.indemnity_verified ? Colors.blue : Colors.grey,
                ),
                SizedBox(width: 5),
                Text(
                  client!.indemnity_verified
                      ? 'Verified'
                      : (app_role != 'desk' && app_role != 'ict')
                          ? 'Not Verified'
                          : 'Verify User Agreement',
                  style: TextStyle(
                    color:
                        client!.indemnity_verified ? Colors.blue : Colors.grey,
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
        if ((app_role == 'desk' || app_role == 'ict') || client!.physio_cl)
          PopupMenuItem(
            value: 5,
            child: Container(
              child: Row(
                children: [
                  Icon(Icons.health_and_safety, size: 16),
                  SizedBox(width: 5),
                  Text(
                    client!.physio_cl
                        ? 'Physio Profile'
                        : 'Register for Physio',
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
        // if (active_staff!.full_access)
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

  // FUNCTION
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

  // update text controlers
  void update_profile_controllers() {
    first_name = client!.f_name!;
    middle_name = client!.m_name!;
    last_name = client!.l_name!;
    user_image = client!.user_image!;

    phone_1_controller.text = client!.phone_1!;
    phone_2_controller.text = client!.phone_2!;
    email_controller.text = client!.email!;
    address_controller.text = client!.address!;
    ig_controller.text = client!.ig_user!;
    fb_controller.text = client!.fb_user!;

    dob_controller.text = client!.dob!;
    show_age = client!.show_age;
    occupation_select = client!.occupation!;
    gender_select = client!.gender!;
    subscription_status = client!.sub_status!;
    program_type_select = client!.program_type_select;
    corporate_type_select = client!.corporate_type_select;

    hmo_select = client!.hmo!;
    hmo_id_controller.text = client!.hmo_id!;

    hykau = client!.hykau!;
    hykau_controller.text = client!.hykau_others!;
    company_name_controller.text = client!.company_name;

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

  // update client info
  update_client_details() async {
    Helpers.showLoadingScreen(context: context);

    if (image_file != null) {
      user_image = await AdminDatabaseHelpers.uploadFile(
              image_file!, widget.cl_id, true) ??
          '';
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
      'phone_1': phone_1_controller.text.trim(),
      'phone_2': phone_2_controller.text.trim(),
      'email': email_controller.text.trim(),
      'address': address_controller.text.trim(),
      'ig_user': ig_controller.text.trim(),
      'fb_user': fb_controller.text.trim(),
      'gender': gender_select,
      'dob': dob,
      'show_age': show_age,
      'occupation': occupation_select,
      'program_type_select': program_type_select,
      'corporate_type_select': corporate_type_select,
      'company_name': company_name_controller.text.trim(),
      'hmo': hmo_select,
      'hmo_id': hmo_id_controller.text.trim(),
      'user_image': user_image,
      'hykau': hykau,
      'hykau_others': hykau_controller.text.trim(),
    };

    bool dt = await GymDatabaseHelpers.update_client_details(
        widget.cl_id, client_update_details);

    Navigator.pop(context);

    if (!dt) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'An Error occured, Try again!',
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
    var date_data = data.split('/');
    DateTime date = DateTime(
      int.parse(date_data[2]),
      int.parse(date_data[1]),
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
      int.parse(date_data[2]),
      int.parse(date_data[1]),
      int.parse(date_data[0]),
    );

    return tm.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
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
                  if (app_role != 'desk' && app_role != 'ict') return;

                  if (client.sub_status && app_role != 'ict') return;

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
                      title: 'Deactivate Subsciption',
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
                  if (app_role != 'desk' && app_role != 'ict') return;

                  if (client.pt_status && app_role != 'ict') return;

                  var res = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ConfirmDialog(
                      title: (!client.pt_status)
                          ? 'Purchase Subsciption'
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
                  if (app_role != 'desk' && app_role != 'ict') return;

                  if (client.boxing && app_role != 'ict') return;

                  var res = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ConfirmDialog(
                      title: (!client.boxing)
                          ? 'Purchase Subsciption'
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
                  if (app_role == 'desk' || app_role == 'ict')
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
