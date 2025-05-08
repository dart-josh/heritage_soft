import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/clinic/clinic_tab.dart';
import 'package:heritage_soft/pages/other/physio_health_details_page.dart';
import 'package:heritage_soft/pages/other/physio_health_registration_page.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/edit_name_dialog.dart';
import 'package:heritage_soft/widgets/image_box.dart';
import 'package:heritage_soft/widgets/options_dialog.dart';
import 'package:heritage_soft/pages/clinic/widgets/other_sponsor_dialog.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';

import 'package:heritage_soft/widgets/text_field.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({
    super.key,
    required this.patient,
    this.from_clinic = false,
  });

  final PatientModel patient;
  final bool from_clinic;

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
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

  Uint8List? image_file;

  late PatientModel patient;
  UserModel? active_user;

  void get_patient(PatientModel pat) {
    var res =
        AppData.get(context).patients.where((p) => p.key == pat.key).toList();

    if (res.isNotEmpty) {
      patient = res.first;
    }
    update_profile_controllers();
  }

  @override
  void initState() {
    patient = widget.patient;

    super.initState();
  }

  @override
  void dispose() {
    phone_1_controller.dispose();
    phone_2_controller.dispose();
    email_controller.dispose();
    address_controller.dispose();

    dob_controller.dispose();
    age_controller.dispose();

    hykau_controller.dispose();

    phone_1_node.dispose();
    phone_2_node.dispose();
    email_node.dispose();
    address_node.dispose();

    dob_node.dispose();
    age_node.dispose();

    refferal_code_controller.dispose();
    nature_of_work_controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    active_user = AppData.get(context).active_user;
    get_patient(patient);

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
                          'images/Physiotherapy-Patients.jpg',
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

                    // edit notifICTaion
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              // top bar
              Row(
                children: [
                  // id & subscription group
                  id_sub_group(),

                  Expanded(child: Container()),

                  // action bar
                  action_bar(),
                ],
              ),

              SizedBox(height: 10),

              // body
              Expanded(
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
            ],
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
          // profile image & name area
          profile_area(),

          // personal/contact details
          Expanded(
              child: SingleChildScrollView(
                  child: (active_user!.app_role == 'Doctor')
                      ? personal_details()
                      : contact_details())),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // personal details
                  (active_user!.app_role == 'Doctor')
                      ? Container()
                      : personal_details(),

                  // other details
                  (active_user!.app_role == 'Doctor')
                      ? Container()
                      : other_details(),

                  SizedBox(height: 10),

                  // sponsor details
                  (active_user!.app_role == 'Doctor')
                      ? Container()
                      : sponsor_details(),

                  // Doctor tab
                  Doctor_tab(),
                ],
              ),
            ),
          ),

          // submit button
          (edit) ? submit_button() : Container(height: 50),
        ],
      ),
    );
  }

  // id & hmo
  Widget id_sub_group() {
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

        // id group
        Row(
          children: [
            // client id
            Text(
              patient.patient_id,
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

            // hmo tag
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: (patient.hmo == 'No HMO')
                    ? Color.fromARGB(255, 232, 186, 93).withOpacity(0.4)
                    : Color.fromARGB(255, 232, 93, 218).withOpacity(0.4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: EdgeInsets.only(left: 10, top: 2),
              child: Text(
                (patient.hmo == 'No HMO') ? 'Walk-In' : patient.hmo,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // NAMES
  String first_name = '';
  String middle_name = '';
  String last_name = '';
  String user_image = '';

  bool user_status = true;

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
              edit && image_file != null
                  // Selected image file
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
                  : user_image.isEmpty
                      // no image
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
                      // user image from database
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
              edit
                  // edit image
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
        ],
      ),
    );
  }

  // Text controllers
  TextEditingController phone_1_controller = TextEditingController();
  TextEditingController phone_2_controller = TextEditingController();
  TextEditingController email_controller = TextEditingController();
  TextEditingController address_controller = TextEditingController();

  TextEditingController dob_controller = TextEditingController();
  TextEditingController age_controller = TextEditingController();
  TextEditingController nature_of_work_controller = TextEditingController();

  TextEditingController hykau_controller = TextEditingController();
  TextEditingController refferal_code_controller = TextEditingController();

  // Text nodes
  FocusNode phone_1_node = FocusNode();
  FocusNode phone_2_node = FocusNode();
  FocusNode email_node = FocusNode();
  FocusNode address_node = FocusNode();

  FocusNode dob_node = FocusNode();
  FocusNode age_node = FocusNode();

  // Other variables
  String hykau = '';

  String gender_select = '';
  List<String> gender_options = ['Male', 'Female'];

  String occupation_select = '';

  List<SponsorModel> sponsors = [];

  List<String> hmo = physio_hmo;

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
          Column(
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
            ],
          ),
        ],
      ),
    );
  }

  // contact details
  Widget personal_details() {
    TextEditingController temp_dob = TextEditingController();
    if (dob_controller.text.isNotEmpty)
      temp_dob.text =
          '${dob_controller.text.split('/')[0]}/${dob_controller.text.split('/')[1]}';

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

          // gender & dob & age
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
                      require: edit,
                      edit: edit,
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
                    controller: temp_dob,
                    node: dob_node,
                    hintText: '',
                    edit: true,
                    icon: (edit)
                        ? InkWell(
                            onTap: () async {
                              var date_data = dob_controller.text.split('/');
                              var date_res = dob_controller.text.isNotEmpty
                                  ? DateTime(
                                      int.parse(date_data[2]),
                                      int.parse(date_data[1]),
                                      int.parse(date_data[0]))
                                  : DateTime(2000);

                              var data = await showDatePicker(
                                context: context,
                                initialDate: date_res,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2010),
                              );

                              if (data != null) {
                                var date =
                                    DateFormat('dd/MM/yyyy').format(data);
                                dob_controller.text = date;

                                setState(() {});
                              }
                            },
                            child: Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                            ),
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
                    edit: !edit,
                    require: edit,
                  ),
                ),
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

          // nature of work
          if (occupation_select.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text_field(
                label: 'Nature of work',
                controller: nature_of_work_controller,
                edit: !edit,
              ),
            ),

          // hmo
          if (patient.hmo != 'No HMO')
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text_field(
                label: 'HMO',
                controller: TextEditingController(
                  text: patient.hmo,
                ),
                edit: true,
              ),
            ),

          // hmo id
          if (patient.hmo != 'No HMO')
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1),
              child: Text_field(
                controller: TextEditingController(
                  text: patient.hmo_id,
                ),
                edit: true,
              ),
            ),

          if (patient.hmo != 'No HMO') SizedBox(height: 8),
        ],
      ),
    );
  }

  // sponor details
  Widget sponsor_details() {
    // view mode & no sponsor
    if (!edit && patient.sponsors.isEmpty) return Container();

    // view mode with sponsor
    if (!edit && patient.sponsors.isNotEmpty)
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // main sponsor heading
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFababab)),
                ),
              ),
              child: Text(
                'Sponsors',
                style: headingStyle,
              ),
            ),

            SizedBox(height: 6),

            // sponsors list
            for (var sponsor in patient.sponsors)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFababab)),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    // sponsor details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Sponsor:', style: labelStyle),
                              SizedBox(width: 10),
                              Text(sponsor.name, style: headingStyle),
                            ],
                          ),
                          if (sponsor.role.isNotEmpty) SizedBox(height: 4),
                          if (sponsor.role.isNotEmpty)
                            Row(
                              children: [
                                Text('Role', style: labelStyle),
                                SizedBox(width: 8),
                                Text(sponsor.role, style: headingStyle),
                              ],
                            ),
                        ],
                      ),
                    ),

                    SizedBox(width: 15),

                    // view full details
                    TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => SponsorDialog(
                                sponsor: sponsor, view_only: true),
                          );
                        },
                        child: Text('Details'))
                  ],
                ),
              ),
          ],
        ),
      );

    // edit mode & no sponsor
    if (sponsors.isEmpty && edit)
      // Add sponsor
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Add Sponsor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

    // edit mode with sponsor
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // title
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFababab)),
                  ),
                ),
                child: Text(
                  'Sponsor/Accompany',
                  style: headingStyle,
                ),
              ),

              // remove sponsor
              if (edit)
                TextButton(
                  onPressed: () async {
                    bool? res = await showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        title: 'Remove Sponsor',
                        subtitle: 'Are you sure you want to proceed?',
                      ),
                    );

                    if (res != null && res) {
                      sponsors.clear();

                      setState(() {});
                    }
                  },
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 7),

          // other sponsor list
          if (sponsors.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sponsors.map((sponsor) {
                // each sponsor
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Color(0xFFBCBCBC),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // sponsor details
                      Expanded(
                        child: Text(
                          '${sponsor.name} ${(sponsor.role.isNotEmpty) ? ' -- ${sponsor.role}' : ''}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      SizedBox(width: 10),

                      // edit sponsor
                      InkWell(
                        onTap: () async {
                          var spon = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) =>
                                SponsorDialog(sponsor: sponsor),
                          );

                          if (spon != null) {
                            var ind = sponsors.indexOf(sponsor);
                            sponsors[ind] = spon;
                            setState(() {});
                          }
                        },
                        child: Icon(Icons.edit, color: Color(0xFFBCBCBC)),
                      ),

                      SizedBox(width: 6),

                      // delete sponsor
                      InkWell(
                        onTap: () async {
                          bool? res = await showDialog(
                            context: context,
                            builder: (context) => ConfirmDialog(
                              title: 'Remove Sponsor',
                              subtitle: 'Are you sure you want to proceed?',
                            ),
                          );

                          if (res != null && res) {
                            var ind = sponsors.indexOf(sponsor);
                            sponsors.removeAt(ind);

                            setState(() {});
                          }
                        },
                        child: Icon(Icons.delete, color: Colors.red.shade400),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () async {
                // max sponsor = 3
                if (sponsors.length >= 3) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.red,
                    toastText: 'Maximum number of sponsor reached!',
                    icon: Icons.error,
                  );
                  return;
                }

                var spon = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => SponsorDialog(),
                );

                if (spon != null) {
                  sponsors.add(spon);

                  setState(() {});
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Add Other Sponsor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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

  // other details
  Widget other_details() {
    // if no hykau details
    if (hykau.isEmpty) return Container();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),

          // how did you hear about us
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

          // if hykau is others
          if (hykau == 'Others')
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text_field(
                controller: hykau_controller,
                edit: true,
                require: edit,
              ),
            )

          // if hykau is referral
          else if (hykau == 'Referral')
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text_field(
                label: 'Referral Reference',
                controller: refferal_code_controller,
                edit: true,
                require: edit,
              ),
            ),

          SizedBox(height: 10),
        ],
      ),
    );
  }

  // Doctors tab
  Widget Doctor_tab() {
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
                  'Doctor\'s Tab',
                  style: headingStyle,
                ),
              ),
            ],
          ),

          SizedBox(height: 7),

          // action buttons
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Wrap(
              spacing: 15,
              runSpacing: 10,
              children: [
                // health details
                InkWell(
                  onTap: () async {
                    if (patient == null) return;

                    Helpers.showLoadingScreen(context: context);

                    List<G_PhysioHealthModel> _all = [];

                    // get all health entries from db
                    // await ClinicDatabaseHelpers.get_physio_health_info(
                    //         client!.key!)
                    //     .then((snap) async {
                    //   snap.docs.forEach((element) {
                    //     _all.add(G_PhysioHealthModel(
                    //       key: element.id,
                    //       data: PhysioHealthModel.fromMap(
                    //           element.id, element.data()),
                    //     ));
                    //   });

                    //   // remove loading scrren
                    //   Navigator.pop(context);

                    //   // if db contains health details
                    //   if (_all.isNotEmpty) {
                    //     // set baseline done if baseline date is different from today
                    //     if (_all.length == 1 && !client!.baseline_done) {
                    //       if (PhysioHelpers.fmt_date(_all[0].data.date) !=
                    //           DateFormat('d MMM, y').format(DateTime.now())) {
                    //         ClinicDatabaseHelpers.edit_physio_client(
                    //             client!.key!, {'baseline_done': true});
                    //         client!.baseline_done = true;
                    //       }
                    //     }

                    //     // if baseline is done
                    //     if (client!.baseline_done) {
                    //       var conf = await showDialog(
                    //           context: context,
                    //           builder: (context) =>
                    //               PhysioHealthSelectorDialog(list: _all));

                    //       if (conf != null) {
                    //         // new health data
                    //         if (conf[1]) {
                    //           new_health_details(
                    //               client: client_h, health: conf[0]);
                    //         }

                    //         // view health data
                    //         else {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => PhysioClientHDPage(
                    //                 client: client_h,
                    //                 health: conf[0],
                    //               ),
                    //             ),
                    //           );
                    //         }
                    //       }
                    //     }

                    //     // if baseline not done
                    //     else {
                    //       var data = _all
                    //           .where((element) => element.key == 'Baseline')
                    //           .first
                    //           .data;

                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => PhysioClientHDPage(
                    //             client: client_h,
                    //             health: data,
                    //           ),
                    //         ),
                    //       );
                    //     }
                    //   }

                    //   // if no health entries
                    //   else {
                    //     // if not CSU user
                    //     if (active_user.app_role != 'CSU' && active_user.app_role != 'ICT') {
                    //       Helpers.showToast(
                    //         context: context,
                    //         color: Colors.red,
                    //         toastText: 'No Health details',
                    //         icon: Icons.error,
                    //       );
                    //       return;
                    //     }

                    //     var bs = await showDialog(
                    //       context: context,
                    //       builder: (context) => ConfirmDialog(
                    //         title: 'Baseline Assessment',
                    //         subtitle:
                    //             'You are about to take form for baseline assessment. Would you like to proceed?',
                    //       ),
                    //     );

                    //     if (bs == null || !bs) return;

                    //     // new health details
                    //     PhysioHealthModel pty = PhysioHealthModel(
                    //       height: '',
                    //       weight: '',
                    //       ideal_weight: '',
                    //       fat_rate: '',
                    //       weight_gap: '',
                    //       weight_target: '',
                    //       waist: '',
                    //       arm: '',
                    //       chest: '',
                    //       thighs: '',
                    //       hips: '',
                    //       pulse_rate: '',
                    //       blood_pressure: '',
                    //       chl_ov: '',
                    //       chl_nv: '',
                    //       chl_rm: '',
                    //       hdl_ov: '',
                    //       hdl_nv: '',
                    //       hdl_rm: '',
                    //       ldl_ov: '',
                    //       ldl_nv: '',
                    //       ldl_rm: '',
                    //       trg_ov: '',
                    //       trg_nv: '',
                    //       trg_rm: '',
                    //       blood_sugar: false,
                    //       eh_finding: '',
                    //       eh_recommend: '',
                    //       sh_finding: '',
                    //       sh_recommend: '',
                    //       ah_finding: '',
                    //       ah_recommend: '',
                    //       other_finding: '',
                    //       other_recommend: '',
                    //       ft_obj_1: '',
                    //       ft_obj_2: '',
                    //       ft_obj_3: '',
                    //       ft_obj_4: '',
                    //       ft_obj_5: '',
                    //       key: 'Baseline',
                    //       date: DateFormat('dd_MM_yyyy').format(DateTime.now()),
                    //       done: false,
                    //     );

                    //     new_health_details(client: client_h, health: pty);
                    //   }
                    // });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.blue.withOpacity(.5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      'Health Details',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // view clinic tab
                if (!widget.from_clinic)
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClinicTab(
                            patient: patient,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: const Color.fromARGB(255, 243, 184, 33)
                            .withOpacity(.5),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text(
                        'Clinic Tab',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                //
              ],
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
        // edit icon - Only admin
        (active_user!.app_role == 'ICT' ||
                active_user!.app_role == 'CSU' ||
                active_user!.app_role == 'Admin')
            ? Padding(
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
              )
            : Container(),

        SizedBox(width: 15),

        // settings icon
        (active_user!.app_role == 'CSU' ||
                active_user!.app_role == 'ICT' ||
                active_user!.app_role == 'Admin')
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: settings_menu(
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              )
            : Container(),

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

  // submit button
  Widget submit_button() {
    return InkWell(
      onTap: () async {
        // check phone if not empty
        if (phone_1_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Primary Phone No. Empty',
            icon: Icons.error,
          );
          return;
        }

        // validate phone
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

        // validate phone 2 if not empty
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

        // validate email
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

        // check address if not empty
        if (address_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Address Empty',
            icon: Icons.error,
          );
          return;
        }

        // check gender if not empty
        if (gender_select.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Select a gender',
            icon: Icons.error,
          );
          return;
        }

        // check age if not empty
        if (age_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Enter your age',
            icon: Icons.error,
          );
          return;
        }

        // continue
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
    // add no HMO to list
    if (!hmo.contains('No HMO')) hmo.add('No HMO');

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

            PatientModel client_update = patient;
            client_update.f_name = first_name;
            client_update.m_name = middle_name;
            client_update.l_name = last_name;

            // update client details
            await ClinicDatabaseHelpers.add_update_patient(
              context,
              data: client_update.toJson(),
              showLoading: true,
              showToast: true,
            );
          }
        }

        // change type (HMO or walk-in)
        if (value == 2) {
          // open options dialog
          var response = await showDialog(
            context: context,
            builder: (context) => OptionsDialog(
              title: 'Select Patient Type',
              options: hmo,
            ),
          );

          if (response != null) {
            PatientModel client_update = patient;
            var hmo_id;

            if (response != 'No HMO') {
              // open dialog for inputing hmo ID
              hmo_id = await showDialog(
                context: context,
                builder: (context) => HmoIdDialog(
                  hmo: response,
                ),
              );

              if (hmo_id == null || hmo_id.isEmpty) return;

              client_update.hmo = response;
              client_update.hmo_id = hmo_id;
            } else {
              client_update.hmo = response;
              client_update.hmo_id = '';
            }

            // update client details
            await ClinicDatabaseHelpers.add_update_patient(
              context,
              data: client_update.toJson(),
              showLoading: true,
              showToast: true,
            );
          }
        }

        // delete user
        if (value == 0) {
          var conf = await Helpers.showConfirmation(
              context: context,
              title: 'Delete Patient',
              message:
                  'Are you sure you want to delete this Patient? This cannot be undone!');

          if (!conf) return;

          Map del = await ClinicDatabaseHelpers.delete_patient(
            context,
            patient_id: patient.key ?? '',
            showLoading: true,
            showToast: true,
          );

          if (del['status'] == true) {
            Navigator.pop(context);
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Container(
            child: Text(
              'Edit name',
              style: TextStyle(),
            ),
          ),
        ),

        // change type
        PopupMenuItem(
          value: 2,
          child: Container(
            child: Text(
              'Change type',
              style: TextStyle(),
            ),
          ),
        ),

        PopupMenuDivider(),

        // delete patient - only admin
        // if (active_user!.full_access)
        PopupMenuItem(
          value: 0,
          child: Container(
            child: Text(
              'Delete Patient',
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
  // update text controlers
  void update_profile_controllers() {
    if (edit) return;

    first_name = patient.f_name;
    middle_name = patient.m_name;
    last_name = patient.l_name;
    user_image = patient.user_image;

    phone_1_controller.text = patient.phone_1;
    phone_2_controller.text = patient.phone_2;
    email_controller.text = patient.email;
    address_controller.text = patient.address;

    dob_controller.text = patient.dob;
    age_controller.text = patient.age;
    occupation_select = patient.occupation;
    nature_of_work_controller.text = patient.nature_of_work;
    gender_select = patient.gender;

    hykau = patient.hykau;
    hykau_controller.text = patient.hykau_others;
    refferal_code_controller.text = patient.refferal_code;

    sponsors = patient.sponsors;

    if (mounted) setState(() {});
  }

  // update client info
  Future<bool?> update_client_details() async {
    // upload image
    if (image_file != null) {}

    PatientModel client_update = PatientModel(
      key: patient.key,
      f_name: patient.f_name,
      m_name: patient.m_name,
      l_name: patient.l_name,
      phone_1: phone_1_controller.text.trim(),
      phone_2: phone_2_controller.text.trim(),
      email: email_controller.text.trim(),
      address: address_controller.text.trim(),
      gender: gender_select,
      dob: dob_controller.text.trim(),
      age: age_controller.text.trim(),
      occupation: occupation_select,
      nature_of_work: nature_of_work_controller.text.trim(),
      user_image: user_image,
      hykau: hykau,
      hykau_others: hykau_controller.text.trim(),
      refferal_code: refferal_code_controller.text.trim(),
      sponsors: sponsors,
      hmo: patient.hmo,
      hmo_id: patient.hmo_id,
      patient_id: patient.patient_id,
      reg_date: patient.reg_date,
      user_status: patient.user_status,
      baseline_done: patient.baseline_done,
    );

    // update client details
    Map upd = await ClinicDatabaseHelpers.add_update_patient(
      context,
      data: client_update.toJson(),
      showLoading: true,
      showToast: true,
    );

    if (upd['status'] == true) {
      patient = upd['patient'];
    }

    return upd['status'];
  }

  // go to new health details page
  void new_health_details(
      {required PhysioHealthClientModel client,
      required PhysioHealthModel health}) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhysioHealthRegistrationPage(
          client: client,
          health: health,
        ),
      ),
    );

    if (res != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhysioClientHDPage(
            client: client,
            health: res,
          ),
        ),
      );
    }
  }

  //
}

class HmoIdDialog extends StatelessWidget {
  final String hmo;
  final TextEditingController _hmoId = TextEditingController();

  HmoIdDialog({required this.hmo});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter HMO ID',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _hmoId,
              decoration: InputDecoration(
                labelText: hmo,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _hmoId.text.trim());
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
