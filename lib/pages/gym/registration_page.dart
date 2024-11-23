import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/client_health_model.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/gym/client_health_registration_page.dart';
import 'package:heritage_soft/pages/gym/client_pofile_page.dart';
import 'package:heritage_soft/pages/gym/renewal_page.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/image_box.dart';
import 'package:heritage_soft/widgets/options_dialog.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';

class RegistrationPage extends StatefulWidget {
  String cl_id;
  RegistrationPage({super.key, required this.cl_id});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextStyle labelStyle = TextStyle(
    color: Color(0xFFc3c3c3),
    fontSize: 11,
  );

  TextStyle headingStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  @override
  void dispose() {
    first_name_controller.dispose();
    middle_name_controller.dispose();
    last_name_controller.dispose();

    phone_1_controller.dispose();
    phone_2_controller.dispose();
    email_controller.dispose();
    address_controller.dispose();
    ig_controller.dispose();
    fb_controller.dispose();

    dob_controller.dispose();
    age_controller.dispose();

    hmo_id_controller.dispose();

    hykau_controller.dispose();

    company_name_controller.dispose();

    first_name_node.dispose();
    middle_name_node.dispose();
    last_name_node.dispose();

    phone_1_node.dispose();
    phone_2_node.dispose();
    email_node.dispose();
    address_node.dispose();
    ig_node.dispose();
    fb_node.dispose();

    dob_node.dispose();
    age_node.dispose();

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
                          'images/background2.png',
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
    if (hmo_select != 'No HMO') {
      widget.cl_id = widget.cl_id.replaceAll('FT', 'HM');
    } else {
      widget.cl_id = widget.cl_id.replaceAll('HM', 'FT');
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          // top bar
          top_bar(),

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
    );
  }

  Widget top_bar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // id & subscription group
          id_sub_group(),

          Expanded(child: Container()),

          reset_button(),

          // close button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () async {
                var res = await showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                      title: 'Cancel Registration',
                      subtitle:
                          'You are about to stop this registration process. This cannot be undone!'),
                );

                if (res == true) Navigator.pop(context);
              },
              child: Icon(
                Icons.cancel,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // left side
  Widget left_side() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Column(
          children: [
            // profile image & name area
            profile_image(),

            // profile name
            profile_details(),

            //?
            old_client_area(),
          ],
        ),
      ),
    );
  }

  // right side
  Widget right_side() {
    return Container(
      child: Column(
        children: [
          // form
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // contact details
                  contact_details(),

                  // personal details
                  personal_details(),

                  // others
                  other_details(),
                ],
              ),
            ),
          ),

          // submit button
          next_button(),
        ],
      ),
    );
  }

  // id & subscription group
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

        // client id
        Text(
          widget.cl_id,
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
      ],
    );
  }

  // text controller
  TextEditingController first_name_controller = TextEditingController();
  TextEditingController middle_name_controller = TextEditingController();
  TextEditingController last_name_controller = TextEditingController();

  TextEditingController phone_1_controller = TextEditingController();
  TextEditingController phone_2_controller = TextEditingController();
  TextEditingController email_controller = TextEditingController();
  TextEditingController address_controller = TextEditingController();
  TextEditingController ig_controller = TextEditingController();
  TextEditingController fb_controller = TextEditingController();

  TextEditingController dob_controller = TextEditingController();
  TextEditingController age_controller = TextEditingController();

  TextEditingController hykau_controller = TextEditingController();

  TextEditingController company_name_controller = TextEditingController();

  TextEditingController hmo_id_controller = TextEditingController();

  // focus node
  FocusNode first_name_node = FocusNode();
  FocusNode middle_name_node = FocusNode();
  FocusNode last_name_node = FocusNode();

  FocusNode phone_1_node = FocusNode();
  FocusNode phone_2_node = FocusNode();
  FocusNode email_node = FocusNode();
  FocusNode address_node = FocusNode();
  FocusNode ig_node = FocusNode();
  FocusNode fb_node = FocusNode();

  FocusNode dob_node = FocusNode();
  FocusNode age_node = FocusNode();

  Uint8List? image_file;
  String imageUrl = '';

  String gender_select = '';
  List<String> gender_options = ['Male', 'Female'];

  String occupation_select = '';
  String program_type_select = '';
  String corporate_type_select = '';

  String hmo_select = 'No HMO';

  String hykau = 'Select';

  bool show_age = false;

  List<String> hmo = gym_hmo.map((e) => e.hmo_name).toList();

  //?
  bool old_cl = false;
  TextEditingController reg_date_controller = TextEditingController();

  //?
  Widget old_client_area() {
    return Column(children: [
      Text('Old Client', style: labelStyle),
      // switch
      Switch(
          value: old_cl,
          onChanged: (val) {
            reg_date_controller.clear();

            old_cl = val;
            setState(() {});
          }),

      // registration date
      if (old_cl)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text_field(
            label: 'Registration Date',
            controller: reg_date_controller,
            edit: true,
            icon: InkWell(
              onTap: () async {
                var date_data = reg_date_controller.text.split('/');
                var date_res = reg_date_controller.text.isNotEmpty
                    ? DateTime(
                        (date_data.length > 2) ? int.parse(date_data[2]) : 2024,
                        int.parse(date_data[1]),
                        int.parse(date_data[0]))
                    : DateTime(2024);

                var data = await showDatePicker(
                  context: context,
                  initialDate: date_res,
                  firstDate: DateTime(2016),
                  lastDate: DateTime.now(),
                );

                if (data != null) {
                  var date = DateFormat('dd/MM/yyyy').format(data);
                  reg_date_controller.text = date;
                } else {
                  reg_date_controller.text = '';
                }

                setState(() {});
              },
              child: Icon(
                Icons.calendar_month,
                color: Colors.white,
              ),
            ),
          ),
        ),
    ]);
  }

  // profile image & name area
  Widget profile_image() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // profile image
          Stack(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 6, right: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFf3f0da).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                width: 200,
                height: 200,
                child: (image_file != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.memory(
                          image_file!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Image.asset(
                          'images/icon/material-person.png',
                          width: 120,
                          height: 120,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () async {
                    var res = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => EditProfileImage(
                        is_edit: false,
                      ),
                    );

                    if (res != null) {
                      image_file = res;
                      setState(() {});
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // profile details
  Widget profile_details() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // first name
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
                label: 'First name',
                controller: first_name_controller,
                node: first_name_node,
                hintText: '',
                require: true),
          ),

          SizedBox(height: 10),

          // middle name
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              label: 'Middle name',
              controller: middle_name_controller,
              node: middle_name_node,
              hintText: '',
            ),
          ),

          SizedBox(height: 10),

          // last name
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
                label: 'Last name',
                controller: last_name_controller,
                node: last_name_node,
                hintText: '',
                require: true),
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
                      format: [FilteringTextInputFormatter.digitsOnly],
                      require: true),
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
                require: true),
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
                  ),
                ),

                SizedBox(width: 20),

                // fb
                Expanded(
                  flex: 6,
                  child: Text_field(
                    label: 'Facebook',
                    controller: fb_controller,
                    node: fb_node,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // personal details
  Widget personal_details() {
    String age_class = '';
    if (age_controller.text.isNotEmpty) {
      int? age = int.tryParse(age_controller.text);

      // age class
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

    if (!hmo.contains('No HMO')) hmo.add('No HMO');

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
                      require: true,
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
                    icon: PopupMenuButton(
                      offset: Offset(0, 30),
                      onSelected: (val) async {
                        var date_data = dob_controller.text.split('/');
                        var date_res = dob_controller.text.isNotEmpty
                            ? DateTime(
                                (date_data.length > 2)
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
                            var date = DateFormat('dd/MM/yyyy').format(data);
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
                    ),
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
                    child: Select_form(
                      label: 'Program type',
                      options: program_type_options,
                      text_value: program_type_select,
                      setval: (val) {
                        program_type_select = val;
                        corporate_type_select = '';
                        hmo_select = 'No HMO';
                        company_name_controller.text = '';

                        setState(() {});
                      },
                      require: true,
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
                            require: true,
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
                require: true,
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
                require: true,
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
                    require: true,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  // others
  Widget other_details() {
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
              setval: (val) {
                hykau = val;

                setState(() {});
              },
            ),
          ),

          // hykau others/referral
          hykau == 'Others' || hykau == 'Referral'
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text_field(
                    label: hykau == 'Referral' ? 'Referral Reference' : '',
                    controller: hykau_controller,
                    hintText: hykau == 'Referral'
                        ? 'Client Name or ID'
                        : 'Please Specify',
                    require: true,
                  ),
                )
              : Container(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // submit button
  Widget next_button() {
    return InkWell(
      onTap: () async {
        //?
        if (old_cl) {
          if (reg_date_controller.text.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Enter registration date',
              icon: Icons.error,
            );
            return;
          }
        }

        if (first_name_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'First name Empty',
            icon: Icons.error,
          );
          return;
        }

        if (last_name_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Last name Empty',
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

        if (hmo_select != 'No HMO' && hmo_id_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'HMO ID cannot be empty',
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

        if ((hykau == 'Others' || hykau == 'Referral') &&
            hykau_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: hykau == 'Referral'
                ? 'Enter Referral reference'
                : 'Please specify others',
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
          register_client();
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
            'Proceed',
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

  // new firebase key
  String new_key = '';

  // register client
  void register_client() async {
    Helpers.showLoadingScreen(context: context);

    // assign new key
    if (new_key.isEmpty) {
      new_key = await GymDatabaseHelpers.assign_gym_registration_key();
    }

    // check client id to ensure no duplicates
    List check_id = await GymDatabaseHelpers.check_gym_client_id(widget.cl_id);

    // check for errors
    if (!check_id[0]) {
      Navigator.pop(context);
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: check_id[1],
        icon: Icons.error,
      );
      return;
    }

    // upload profile image
    if (image_file != null) {
      imageUrl =
          await AdminDatabaseHelpers.uploadFile(image_file!, new_key, true) ??
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

    //?
    String reg_date = (old_cl)
        ? reg_date_controller.text.trim()
        : DateFormat('dd/MM/yyyy').format(DateTime.now());

    var newcl = ClientModel(
      key: new_key,
      id: widget.cl_id,
      reg_date: reg_date,
      user_status: true,
      sub_type: 'Individual',
      //?
      sub_plan: old_cl ? '--' : '',
      pt_plan: '',
      sub_status: false,
      pt_status: false,
      sub_date: '',
      pt_date: '',
      boxing: false,
      bx_date: '',
      f_name: first_name_controller.text.trim(),
      m_name: middle_name_controller.text.trim(),
      l_name: last_name_controller.text.trim(),
      user_image: imageUrl,
      phone_1: phone_1_controller.text.trim(),
      phone_2: phone_2_controller.text.trim(),
      email: email_controller.text.trim(),
      address: address_controller.text.trim(),
      ig_user: ig_controller.text.trim(),
      fb_user: fb_controller.text.trim(),
      gender: gender_select,
      dob: dob,
      show_age: show_age,
      occupation: occupation_select,
      program_type_select: program_type_select,
      corporate_type_select: corporate_type_select,
      company_name: company_name_controller.text.trim(),
      hmo: hmo_select,
      hmo_id: hmo_id_controller.text.trim(),
      hykau: hykau == 'Select' ? '' : hykau,
      hykau_others: hykau_controller.text.trim(),
      sub_paused: false,
      paused_date: '',
      sub_income: 0,
      baseline_done: false,
      physio_cl: false,
      physio_key: '',
      indemnity_verified: false,
      renew_dates: '',
    );

    var cl_map = newcl.toJson();
    
    // register cleint
    bool registration =
        await GymDatabaseHelpers.register_gym_client(new_key, cl_map);

    // check for errors
    if (!registration) {
      Navigator.pop(context);
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'Error, Try again',
        icon: Icons.error,
      );
      return;
    }

    // update last gym id
    GymDatabaseHelpers.update_last_gym_id(widget.cl_id);

    // complete
    Navigator.pop(context);
    Helpers.showToast(
      context: context,
      color: Colors.blue,
      toastText: 'Client Registered',
      icon: Icons.error,
    );

    //?
    if (old_cl) {
      // remove registration page
      Navigator.pop(context);

      // go to profile page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientProfilePage(cl_id: new_key),
        ),
      );

      String name = '${newcl.f_name} ${newcl.l_name}';

      RenewalModel newDet = RenewalModel(
        key: new_key,
        id: newcl.id!,
        reg_date: newcl.reg_date!,
        user_image: newcl.user_image!,
        name: name,
        sub_plan: newcl.hmo != 'No HMO' ? 'HMO Plan' : newcl.sub_plan!,
        pt_plan: newcl.pt_plan!,
        pt_status: newcl.pt_status!,
        boxing: newcl.boxing!,
        sub_type: newcl.sub_type!,
        hmo_name: newcl.hmo,
        sub_income: newcl.sub_income,
        program_type: newcl.program_type_select,
        renew_dates: '',
        sub_date: '',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RenewalPage(
            details: newDet,
            register: false,
          ),
        ),
      );
    } else {
      // go to health form page
      var conf2 = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BaselineFormDialog(cl_id: widget.cl_id),
        ),
      );

      // remove registration page
      Navigator.pop(context);

      // go to profile page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientProfilePage(cl_id: new_key),
        ),
      );

      if (conf2 != null) {
        // register health details
        if (conf2[0]) {
          String name = '${newcl.f_name} ${newcl.l_name}';

          HealthClientModel client = HealthClientModel(
            key: newcl.key!,
            id: widget.cl_id,
            name: name,
            user_image: newcl.user_image!,
            hmo: hmo_select,
            baseline_done: false,
            program_type: newcl.program_type_select,
          );

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
            data_type: conf2[1],
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientHealthRegistrationPage(
                client: client,
                health: pty,
                register: true,
              ),
            ),
          );
        }

        // skip (go to subscription page)
        else {
          RenewalModel newDet = RenewalModel(
            key: newcl.key!,
            id: newcl.id!,
            reg_date: '',
            user_image: newcl.user_image!,
            name: '${newcl.f_name!} ${newcl.m_name!} ${newcl.l_name!}',
            sub_plan: newcl.hmo == 'No HMO' ? '' : 'HMO Plan',
            pt_plan: '',
            pt_status: false,
            boxing: false,
            sub_type: newcl.sub_type!,
            hmo_name: newcl.hmo != 'No HMO' ? newcl.hmo : null,
            sub_income: 0,
            program_type: newcl.program_type_select,
            renew_dates: '',
            sub_date: '',
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RenewalPage(
                register: true,
                details: newDet,
              ),
            ),
          );
        }
      }
    }
  }

  // reset button
  Widget reset_button() {
    return InkWell(
      onTap: () async {
        var res = await showDialog(
          context: context,
          builder: (context) => ConfirmDialog(
            title: 'Reset Form',
            subtitle:
                'This would clear this form but still retain the id.\nWould you like to proceed?',
          ),
        );

        if (res != null && !res) return;

        first_name_controller.text = '';
        middle_name_controller.text = '';
        last_name_controller.text = '';

        phone_1_controller.text = '';
        phone_2_controller.text = '';
        email_controller.text = '';
        address_controller.text = '';
        ig_controller.text = '';
        fb_controller.text = '';
        dob_controller.text = '';
        age_controller.text = '';
        occupation_select = '';
        program_type_select = '';
        corporate_type_select = '';
        gender_select = '';
        hmo_select = 'No HMO';
        hykau = 'Select one';
        hykau_controller.text = '';

        image_file = null;
        imageUrl = '';

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

  // FUNCTION
  // calculate age
  String calc_age(DateTime dob) {
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

  //
}

class BaselineFormDialog extends StatelessWidget {
  final String cl_id;
  const BaselineFormDialog({super.key, required this.cl_id});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.50;
    double height = MediaQuery.of(context).size.height * 0.95;
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
                        Expanded(child: main_page(context)),
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
  Widget main_page(context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          // id
          Align(
            alignment: Alignment.topLeft,
            child: id_sub_group(),
          ),

          // body
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 70),

                      // heading
                      Text(
                        'Baseline Health Data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
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

                      SizedBox(height: 40),

                      Icon(
                        Icons.health_and_safety,
                        size: 150,
                        color: Colors.green,
                      ),

                      SizedBox(height: 70),

                      // action
                      action_buttons(context),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //
        ],
      ),
    );
  }

  // actions
  Widget action_buttons(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // take form
        InkWell(
          onTap: () async {
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

            Navigator.pop(context, [true, data_type]);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            height: 35,
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.format_align_center, color: Colors.white, size: 24),
                SizedBox(width: 4),
                Text(
                  'Take form',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 40),

        // skip
        InkWell(
          onTap: () => Navigator.pop(context, [false]),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            height: 35,
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.skip_next, color: Colors.white, size: 24),
                SizedBox(width: 4),
                Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

        // client id
        Text(
          cl_id,
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
      ],
    );
  }
}
