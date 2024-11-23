import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/physio_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/physio_helpers.dart';
import 'package:heritage_soft/pages/physio/clinic_tab.dart';
import 'package:heritage_soft/pages/physio/physio_health_details_page.dart';
import 'package:heritage_soft/pages/physio/physio_health_registration_page.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/edit_name_dialog.dart';
import 'package:heritage_soft/pages/physio/widgets/physio_health_selector_dialog.dart';
import 'package:heritage_soft/widgets/image_box.dart';
import 'package:heritage_soft/widgets/options_dialog.dart';
import 'package:heritage_soft/pages/physio/widgets/other_sponsor_dialog.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';

import 'package:heritage_soft/widgets/text_field.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';

class PhysioClientProfilePage extends StatefulWidget {
  const PhysioClientProfilePage({
    super.key,
    required this.cl_id,
    this.from_clinic = false,
    this.can_treat = false,
  });

  final String cl_id;
  final bool from_clinic;
  final bool can_treat;

  @override
  State<PhysioClientProfilePage> createState() =>
      _PhysioClientProfilePageState();
}

class _PhysioClientProfilePageState extends State<PhysioClientProfilePage> {
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

  late StreamSubscription client_stream;
  late StreamSubscription sponsor_stream;

  @override
  void initState() {
    client_stream = get_client_details(widget.cl_id);
    sponsor_stream = get_other_sponsor_details(widget.cl_id);

    Future.delayed(Duration(milliseconds: 400), () {
      sponsor_name_controller.addListener(() {
        if (sponsor_name_controller.text.isEmpty) other_sponsors.clear();
      });
    });

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

    sponsor_name_controller.dispose();
    sponsor_phone_controller.dispose();
    sponsor_addr_controller.dispose();
    sponsor_role_controller.dispose();

    refferal_code_controller.dispose();
    nature_of_work_controller.dispose();

    client_stream.cancel();
    sponsor_stream.cancel();

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

  StreamSubscription get_client_details(String key) {
    return PhysioDatabaseHelpers.physio_client_details_stream(key)
        .listen((event) {
      Map? map = event.data();

      if (map != null) {
        client = PhysioClientModel.fromMap(event.id, map);
        update_profile_controllers();
      }
    });
  }

  StreamSubscription get_other_sponsor_details(String key) {
    return PhysioDatabaseHelpers.physio_sponsor_stream(key).listen((event) {
      other_sponsors.clear();
      event.docs.forEach((e) {
        other_sponsors.add(SponsorModel.fromMap(e.id, e.data()));
      });

      Future.delayed(Duration(milliseconds: 400), () {
        setState(() {});
      });
    });
  }

  PhysioClientModel? client;

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
                  client != null ? id_sub_group() : Container(height: 30),

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
                  child: (app_role == 'doctor')
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
                  (app_role == 'doctor') ? Container() : personal_details(),

                  // other details
                  (app_role == 'doctor') ? Container() : other_details(),

                  SizedBox(height: 10),

                  // sponsor details
                  (app_role == 'doctor') ? Container() : sponsor_details(),

                  // doctor tab
                  doctor_tab(),
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

            // hmo tag
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: (client!.hmo! == 'No HMO')
                    ? Color.fromARGB(255, 232, 186, 93).withOpacity(0.4)
                    : Color.fromARGB(255, 232, 93, 218).withOpacity(0.4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: EdgeInsets.only(left: 10, top: 2),
              child: Text(
                (client!.hmo! == 'No HMO') ? 'Walk-In' : client!.hmo!,
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

  TextEditingController sponsor_name_controller = TextEditingController();
  TextEditingController sponsor_phone_controller = TextEditingController();
  TextEditingController sponsor_addr_controller = TextEditingController();
  TextEditingController sponsor_role_controller = TextEditingController();

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

  bool sponsor = false;

  List<SponsorModel> other_sponsors = [];

  List<String> hmo = physio_hmo.map((e) => e.hmo_name).toList();

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
        ],
      ),
    );
  }

  // sponor details
  Widget sponsor_details() {
    // view mode & no sponsor
    if (!edit && !sponsor) return Container();

    // view mode with sponsor
    if (!edit && sponsor)
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
                'Main Sponsors',
                style: headingStyle,
              ),
            ),

            SizedBox(height: 6),

            // main sponsor
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFababab)),
                ),
              ),
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
                            Text(sponsor_name_controller.text,
                                style: headingStyle),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Role', style: labelStyle),
                            SizedBox(width: 8),
                            Text(sponsor_role_controller.text,
                                style: headingStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 15),

                  // View full details
                  TextButton(
                      onPressed: () {
                        SponsorModel sponsor = SponsorModel(
                          sponsor_name: sponsor_name_controller.text,
                          sponsor_phone: sponsor_phone_controller.text,
                          sponsor_addr: sponsor_addr_controller.text,
                          sponsor_role: sponsor_role_controller.text,
                        );

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => OtherSponsor(
                            sponsor: sponsor,
                            view_only: true,
                          ),
                        );
                      },
                      child: Text('Details'))
                ],
              ),
            ),

            if (other_sponsors.isNotEmpty) SizedBox(height: 8),

            // other sponsor heading
            if (other_sponsors.isNotEmpty)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFababab)),
                  ),
                ),
                child: Text(
                  'Other Sponsors',
                  style: headingStyle,
                ),
              ),

            if (other_sponsors.isNotEmpty) SizedBox(height: 8),

            // other sponsors list
            for (var sponsor in other_sponsors)
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
                              Text(sponsor.sponsor_name, style: headingStyle),
                            ],
                          ),
                          if (sponsor.sponsor_role.isNotEmpty)
                            SizedBox(height: 4),
                          if (sponsor.sponsor_role.isNotEmpty)
                            Row(
                              children: [
                                Text('Role', style: labelStyle),
                                SizedBox(width: 8),
                                Text(sponsor.sponsor_role, style: headingStyle),
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
                            builder: (context) =>
                                OtherSponsor(sponsor: sponsor, view_only: true),
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
    if (!sponsor && edit)
      // Add sponsor
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  sponsor = true;
                });
              },
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
                      sponsor_name_controller.clear();
                      sponsor_phone_controller.clear();
                      sponsor_addr_controller.clear();
                      sponsor_role_controller.clear();
                      sponsor = false;

                      // delete other sponsor from database
                      if (other_sponsors.isNotEmpty) {
                        other_sponsors.forEach((e) {
                          PhysioDatabaseHelpers.delete_physio_sponsor(
                              widget.cl_id, e.key!);
                        });
                      }

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

          // sponsor name
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              label: 'Sponsor Fullname',
              controller: sponsor_name_controller,
              edit: !edit,
              require: true,
            ),
          ),

          // sponsor no.
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              label: 'Sponsor Phone no.',
              controller: sponsor_phone_controller,
              format: [FilteringTextInputFormatter.digitsOnly],
              edit: !edit,
              require: true,
            ),
          ),

          // sponsor role
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              label: 'Sponsor Role',
              controller: sponsor_role_controller,
              edit: !edit,
            ),
          ),

          // sponsor address
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              label: 'Sponsor Address',
              controller: sponsor_addr_controller,
              maxLine: 3,
              edit: !edit,
            ),
          ),

          // other sponsor heading
          if (other_sponsors.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFababab)),
                  ),
                ),
                child: Text(
                  'Other Sponsors',
                  style: headingStyle,
                ),
              ),
            ),

          // other sponsor list
          if (other_sponsors.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: other_sponsors.map((sponsor) {
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
                          '${sponsor.sponsor_name} ${(sponsor.sponsor_role.isNotEmpty) ? ' -- ${sponsor.sponsor_role}' : ''}',
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
                                OtherSponsor(sponsor: sponsor),
                          );

                          if (spon != null) {
                            var ind = other_sponsors.indexOf(sponsor);
                            other_sponsors[ind] = spon;

                            SponsorModel spn = spon;

                            // update sponsor in database
                            PhysioDatabaseHelpers.add_physio_sponsor(
                              widget.cl_id,
                              sponsor.key,
                              spn.toJson(),
                            );

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
                            var ind = other_sponsors.indexOf(sponsor);
                            other_sponsors.removeAt(ind);

                            // delete sponsor from database
                            PhysioDatabaseHelpers.delete_physio_sponsor(
                                widget.cl_id, sponsor.key!);

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

          // add other sponsors
          if (sponsor_name_controller.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () async {
                  // max sponsor = 2
                  if (other_sponsors.length >= 2) {
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
                    builder: (context) => OtherSponsor(),
                  );

                  if (spon != null) {
                    other_sponsors.add(spon);
                    SponsorModel spn = spon;

                    PhysioDatabaseHelpers.add_physio_sponsor(
                      widget.cl_id,
                      null,
                      spn.toJson(),
                    );

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

  // doctors tab
  Widget doctor_tab() {
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

              // Expanded(child: Container()),
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
                    if (client == null) return;

                    Helpers.showLoadingScreen(context: context);

                    PhysioHealthClientModel client_h = PhysioHealthClientModel(
                      key: client!.key!,
                      id: client!.id!,
                      name: '$first_name $middle_name $last_name',
                      user_image: user_image,
                      hmo: client!.hmo!,
                      baseline_done: client!.baseline_done,
                    );

                    List<G_PhysioHealthModel> _all = [];

                    // get all health entries from db
                    await PhysioDatabaseHelpers.get_physio_health_info(
                            client!.key!)
                        .then((snap) async {
                      snap.docs.forEach((element) {
                        _all.add(G_PhysioHealthModel(
                          key: element.id,
                          data: PhysioHealthModel.fromMap(
                              element.id, element.data()),
                        ));
                      });

                      // remove loading scrren
                      Navigator.pop(context);

                      // if db contains health details
                      if (_all.isNotEmpty) {
                        // set baseline done if baseline date is different from today
                        if (_all.length == 1 && !client!.baseline_done) {
                          if (PhysioHelpers.fmt_date(_all[0].data.date) !=
                              DateFormat('d MMM, y').format(DateTime.now())) {
                            PhysioDatabaseHelpers.edit_physio_client(
                                client!.key!, {'baseline_done': true});
                            client!.baseline_done = true;
                          }
                        }

                        // if baseline is done
                        if (client!.baseline_done) {
                          var conf = await showDialog(
                              context: context,
                              builder: (context) =>
                                  PhysioHealthSelectorDialog(list: _all));

                          if (conf != null) {
                            // new health data
                            if (conf[1]) {
                              new_health_details(
                                  client: client_h, health: conf[0]);
                            }

                            // view health data
                            else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhysioClientHDPage(
                                    client: client_h,
                                    health: conf[0],
                                  ),
                                ),
                              );
                            }
                          }
                        }

                        // if baseline not done
                        else {
                          var data = _all
                              .where((element) => element.key == 'Baseline')
                              .first
                              .data;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhysioClientHDPage(
                                client: client_h,
                                health: data,
                              ),
                            ),
                          );
                        }
                      }

                      // if no health entries
                      else {
                        // if not desk user
                        if (app_role != 'desk' && app_role != 'ict') {
                          Helpers.showToast(
                            context: context,
                            color: Colors.red,
                            toastText: 'No Health details',
                            icon: Icons.error,
                          );
                          return;
                        }

                        var bs = await showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: 'Baseline Assessment',
                            subtitle:
                                'You are about to take form for baseline assessment. Would you like to proceed?',
                          ),
                        );

                        if (bs == null || !bs) return;

                        // new health details
                        PhysioHealthModel pty = PhysioHealthModel(
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
                        );

                        new_health_details(client: client_h, health: pty);
                      }
                    });
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
                      if (client == null) return;

                      PhysioHealthClientModel client_h =
                          PhysioHealthClientModel(
                        key: client!.key!,
                        id: client!.id!,
                        name: '$first_name $middle_name $last_name',
                        user_image: user_image,
                        hmo: client!.hmo!,
                        baseline_done: client!.baseline_done,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClinicTab(
                            client: client_h,
                            can_treat: false,
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
        client != null && (app_role == 'ict')
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
        client != null && (app_role == 'desk' || app_role == 'ict')
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

        // check sponsor
        if (sponsor) {
          // check name if not empty
          if (sponsor_name_controller.text.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Enter sponsor name',
              icon: Icons.error,
            );
            return;
          }

          // check phone if not empty
          if (sponsor_phone_controller.text.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Enter sponsor contact',
              icon: Icons.error,
            );
            return;
          }

          // validate phone
          if (sponsor_phone_controller.text.length > 11 ||
              sponsor_phone_controller.text.length < 10) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Sponsor contact Invalid',
              icon: Icons.error,
            );
            return;
          }
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

            Map<String, dynamic> client_name_update = {
              'f_name': first_name,
              'm_name': middle_name,
              'l_name': last_name,
            };

            Helpers.showLoadingScreen(context: context);

            // update physio client
            bool ress = await PhysioDatabaseHelpers.edit_physio_client(
                client!.key!, client_name_update);
            Navigator.pop(context);

            // if error
            if (!ress) {
              Helpers.showToast(
                context: context,
                color: Colors.redAccent,
                toastText: 'An Error occured, Try again!',
                icon: Icons.error,
              );
              return;
            }

            // successful
            Helpers.showToast(
              context: context,
              color: Colors.greenAccent,
              toastText: 'Name updated successfully',
              icon: Icons.check,
            );

            setState(() {});
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
            Helpers.showLoadingScreen(context: context);

            // update client details
            bool ress = await PhysioDatabaseHelpers.edit_physio_client(
                widget.cl_id, {'hmo': response});
            Navigator.pop(context);

            // if error
            if (!ress) {
              Helpers.showToast(
                context: context,
                color: Colors.redAccent,
                toastText: 'An Error occured, Try again!',
                icon: Icons.error,
              );
              return;
            }

            // successful
            Helpers.showToast(
              context: context,
              color: Colors.blue,
              toastText: 'Patient Type updated',
              icon: Icons.check,
            );
          }
        }

        // delete user
        if (value == 0) {
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

            bool del =
                await PhysioDatabaseHelpers.delete_physio_client(widget.cl_id);

            Navigator.pop(context);

            if (!del) {
              Helpers.showToast(
                context: context,
                color: Colors.redAccent,
                toastText: 'Error, Try again',
                icon: Icons.error,
              );
              return;
            }

            // successful
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
        // edit name - only admin
        if (app_role == 'ict')
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

        // delete user - only admin
        if (active_staff!.full_access)
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
  // update text controlers
  void update_profile_controllers() {
    if (edit) return;

    first_name = client!.f_name!;
    middle_name = client!.m_name!;
    last_name = client!.l_name!;
    user_image = client!.user_image!;

    phone_1_controller.text = client!.phone_1!;
    phone_2_controller.text = client!.phone_2!;
    email_controller.text = client!.email!;
    address_controller.text = client!.address!;

    dob_controller.text = client!.dob;
    age_controller.text = client!.age;
    occupation_select = client!.occupation!;
    nature_of_work_controller.text = client!.nature_of_work!;
    gender_select = client!.gender!;

    sponsor_name_controller.text = client!.sponsor_name;
    sponsor_phone_controller.text = client!.sponsor_phone;
    sponsor_addr_controller.text = client!.sponsor_addr;
    sponsor_role_controller.text = client!.sponsor_role;
    sponsor = client!.sponsor;

    hykau = client!.hykau!;
    hykau_controller.text = client!.hykau_others!;
    refferal_code_controller.text = client!.refferal_code;

    setState(() {});
  }

  // update client info
  update_client_details() async {
    Helpers.showLoadingScreen(context: context);

    // upload image
    if (image_file != null) {
      user_image = await AdminDatabaseHelpers.uploadFile(
              image_file!, widget.cl_id, false) ??
          '';
    }

    // client details
    Map<String, dynamic> client_update_details = {
      'phone_1': phone_1_controller.text.trim(),
      'phone_2': phone_2_controller.text.trim(),
      'email': email_controller.text.trim(),
      'address': address_controller.text.trim(),
      'gender': gender_select,
      'dob': dob_controller.text.trim(),
      'age': age_controller.text.trim(),
      'occupation': occupation_select,
      'nature_of_work': nature_of_work_controller.text.trim(),
      'user_image': user_image,
      'sponsor_name': sponsor_name_controller.text.trim(),
      'sponsor_phone': sponsor_phone_controller.text.trim(),
      'sponsor_addr': sponsor_addr_controller.text.trim(),
      'sponsor': sponsor,
      'hykau': hykau,
      'hykau_others': hykau_controller.text.trim(),
      'refferal_code': refferal_code_controller.text.trim(),
      'sponsor_role': sponsor_role_controller.text.trim(),
    };

    // update client details
    bool upd = await PhysioDatabaseHelpers.edit_physio_client(
        widget.cl_id, client_update_details);

    Navigator.pop(context);

    // error
    if (!upd) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'An Error occured, Try again!',
        icon: Icons.error,
      );
      return false;
    }

    // successful
    Helpers.showToast(
      context: context,
      color: Colors.greenAccent,
      toastText: 'Profile Successfully Updated',
      icon: Icons.check,
    );
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
