import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/helpers/physio_database_helpers.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/gym/client_pofile_page.dart';
import 'package:heritage_soft/pages/physio/clinic_tab.dart';
import 'package:heritage_soft/pages/physio/physio_pofile_page.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/image_box.dart';
import 'package:heritage_soft/pages/physio/widgets/other_sponsor_dialog.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';

class PhysioRegistrationPage extends StatefulWidget {
  String cl_id;
  final Ft_Pt_Model? new_ft;
  PhysioRegistrationPage({
    super.key,
    required this.cl_id,
    this.new_ft,
  });

  @override
  State<PhysioRegistrationPage> createState() => _PhysioRegistrationPageState();
}

class _PhysioRegistrationPageState extends State<PhysioRegistrationPage> {
  TextStyle labelStyle = TextStyle(
    color: Color(0xFFc3c3c3),
    fontSize: 11,
  );

  TextStyle headingStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  new_ft_cl() {
    first_name_controller.text = widget.new_ft!.first_name;
    middle_name_controller.text = widget.new_ft!.middle_name;
    last_name_controller.text = widget.new_ft!.last_name;
    imageUrl = widget.new_ft!.image_file;
    phone_1_controller.text = widget.new_ft!.phone_1;
    phone_2_controller.text = widget.new_ft!.phone_2;
    email_controller.text = widget.new_ft!.email;
    address_controller.text = widget.new_ft!.address;
    dob_controller.text = widget.new_ft!.dob;
    age_controller.text = widget.new_ft!.age;
    occupation_select = widget.new_ft!.occupation;
    gender_select = widget.new_ft!.gender_select;
    hmo_select = widget.new_ft!.hmo_select;
    hmo_id_controller.text = widget.new_ft!.hmo_id;
  }

  @override
  void initState() {
    if (widget.new_ft != null) new_ft_cl();

    hmo_id_controller.addListener(() {
      setState(() {});
    });

    sponsor_name_controller.addListener(() {
      if (sponsor_name_controller.text.isEmpty) other_sponsors.clear();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    first_name_controller.dispose();
    middle_name_controller.dispose();
    last_name_controller.dispose();

    phone_1_controller.dispose();
    phone_2_controller.dispose();
    email_controller.dispose();
    address_controller.dispose();

    dob_controller.dispose();
    age_controller.dispose();

    first_name_node.dispose();
    middle_name_node.dispose();
    last_name_node.dispose();

    phone_1_node.dispose();
    phone_2_node.dispose();
    email_node.dispose();
    address_node.dispose();

    dob_node.dispose();
    age_node.dispose();

    hmo_id_controller.dispose();

    sponsor_name_controller.dispose();
    sponsor_phone_controller.dispose();
    sponsor_addr_controller.dispose();
    sponsor_role_controller.dispose();

    refferal_code_controller.dispose();
    nature_of_work_controller.dispose();
    hykau_controller.dispose();
    temp_dob.dispose();

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
                          'images/pt_clients.jpeg',
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
      widget.cl_id = widget.cl_id.replaceAll('PT', 'HM');
    } else {
      widget.cl_id = widget.cl_id.replaceAll('HM', 'PT');
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          // top bar
          top_bar(),

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

          // reset button
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

  // left side (profile details)
  Widget left_side() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Column(
        children: [
          // profile image & name area
          profile_image(),

          // profile name
          Expanded(
            child: SingleChildScrollView(child: profile_details()),
          ),
        ],
      ),
    );
  }

  // right side (contact, sponsor, personal, others, submit)
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

                  // sponsor details
                  sponsor_details(),

                  // personal details
                  personal_details(),

                  // others
                  other_details()
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

  // Text controllers
  TextEditingController first_name_controller = TextEditingController();
  TextEditingController middle_name_controller = TextEditingController();
  TextEditingController last_name_controller = TextEditingController();

  TextEditingController phone_1_controller = TextEditingController();
  TextEditingController phone_2_controller = TextEditingController();
  TextEditingController email_controller = TextEditingController();
  TextEditingController address_controller = TextEditingController();

  TextEditingController dob_controller = TextEditingController();
  TextEditingController age_controller = TextEditingController();

  TextEditingController nature_of_work_controller = TextEditingController();

  TextEditingController hmo_id_controller = TextEditingController();

  TextEditingController sponsor_name_controller = TextEditingController();
  TextEditingController sponsor_phone_controller = TextEditingController();
  TextEditingController sponsor_addr_controller = TextEditingController();
  TextEditingController sponsor_role_controller = TextEditingController();

  TextEditingController hykau_controller = TextEditingController();
  TextEditingController refferal_code_controller = TextEditingController();

  TextEditingController temp_dob = TextEditingController();

  // Text nodes
  FocusNode first_name_node = FocusNode();
  FocusNode middle_name_node = FocusNode();
  FocusNode last_name_node = FocusNode();

  FocusNode phone_1_node = FocusNode();
  FocusNode phone_2_node = FocusNode();
  FocusNode email_node = FocusNode();
  FocusNode address_node = FocusNode();

  FocusNode dob_node = FocusNode();
  FocusNode age_node = FocusNode();

  // Other variables
  Uint8List? image_file;
  String imageUrl = '';

  String hykau = 'Select';

  String gender_select = '';
  List<String> gender_options = ['Male', 'Female'];

  String occupation_select = '';

  String hmo_select = 'No HMO';

  bool sponsor = false;

  List<SponsorModel> other_sponsors = [];

  List<String> hmo = physio_hmo.map((e) => e.hmo_name).toList();

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
                child:
                    // Selected image file
                    (image_file != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.memory(
                              image_file!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        // image from database
                        : (imageUrl.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  imageUrl,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              )
                            // No image
                            : Center(
                                child: Image.asset(
                                  'images/icon/material-person.png',
                                  width: 120,
                                  height: 120,
                                ),
                              ),
              ),
              // Edit Image
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
              require: true,
            ),
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
              require: true,
            ),
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                // phone
                Expanded(
                  flex: 5,
                  child: Text_field(
                    label: 'Primary Phone no.',
                    controller: phone_1_controller,
                    node: phone_1_node,
                    hintText: 'xxxx xxx xxxx',
                    format: [FilteringTextInputFormatter.digitsOnly],
                    require: true,
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
              require: true,
            ),
          ),

          SizedBox(height: 2),
        ],
      ),
    );
  }

  // personal details
  Widget personal_details() {
    if (!hmo.contains('No HMO')) hmo.add('No HMO');

    // show only day & month for dob
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
                    controller: temp_dob,
                    node: dob_node,
                    hintText: '',
                    edit: true,
                    icon: InkWell(
                      onTap: () async {
                        var data = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2010),
                        );

                        if (data != null) {
                          var date = DateFormat('dd/MM/yyyy').format(data);
                          dob_controller.text = date;

                          setState(() {});
                        }
                      },
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),
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
                    require: true,
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
              ),
            ),

          // hmo
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Select_form(
              label: 'HMO',
              options: hmo,
              text_value: hmo_select,
              setval: (val) {
                hmo_select = val;

                setState(() {});
              },
            ),
          ),

          // hmo id
          if (hmo_select != 'No HMO')
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text_field(
                label: 'HMO ID',
                controller: hmo_id_controller,
                hintText: '',
                require: true,
              ),
            ),
        ],
      ),
    );
  }

  // sponsor details
  Widget sponsor_details() {
    if (!sponsor)
      // Add Sponsor
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
              TextButton(
                onPressed: () {
                  sponsor_name_controller.clear();
                  sponsor_phone_controller.clear();
                  sponsor_addr_controller.clear();
                  sponsor_role_controller.clear();
                  sponsor = false;
                  other_sponsors.clear();

                  setState(() {});
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
              require: true,
            ),
          ),

          // sponsor role
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              label: 'Sponsor Role',
              controller: sponsor_role_controller,
            ),
          ),

          // sponsor address
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              label: 'Sponsor Address',
              controller: sponsor_addr_controller,
              maxLine: 3,
            ),
          ),

          if (other_sponsors.isNotEmpty)
            // Other Sponsor heading
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

          if (other_sponsors.isNotEmpty)
            // Other sponsors list
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: other_sponsors.map((sponsor) {
                // each sponsor tile
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
                      // sponsor details (name, role)
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

          if (sponsor_name_controller.text.isNotEmpty)
            // Add other sponsor
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () async {
                  // max length of sponsor -2
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          // How you heard about us hykau
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

          if (hykau == 'Others')
            // Others hykau
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text_field(
                controller: hykau_controller,
                hintText: 'Please Specify',
                require: true,
              ),
            )
          else if (hykau == 'Referral')
            // referral hykau
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text_field(
                label: 'Referral Reference',
                sample: 'Hospital-Doctor-Contact',
                controller: refferal_code_controller,
                require: true,
              ),
            ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // Key to save document
  String new_key = '';

  // submit button
  Widget next_button() {
    return InkWell(
      onTap: () async {
        // check first name if empty
        if (first_name_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'First name Empty',
            icon: Icons.error,
          );
          return;
        }

        // check last name if empty
        if (last_name_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Last name Empty',
            icon: Icons.error,
          );
          return;
        }

        // check phone if empty
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

        // check address if empty
        if (address_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Address Empty',
            icon: Icons.error,
          );
          return;
        }

        // check gender if empty
        if (gender_select.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Select a gender',
            icon: Icons.error,
          );
          return;
        }

        // check age if empty
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
          // sponsor name if empty
          if (sponsor_name_controller.text.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Enter sponsor name',
              icon: Icons.error,
            );
            return;
          }

          // sponsor phone if empty
          if (sponsor_phone_controller.text.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Enter sponsor contact',
              icon: Icons.error,
            );
            return;
          }

          // validate sponsor phone
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

        // check hmo id if hmo selected
        if (hmo_select != 'No HMO' && hmo_id_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'HMO ID cannot be empty',
            icon: Icons.error,
          );
          return;
        }

        // check hykau others if hykau is others
        if (hykau == 'Others' && hykau_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Please specify others',
            icon: Icons.error,
          );
          return;
        }

        // check hykau referral if hykau is referral
        if (hykau == 'Referral' && refferal_code_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Enter Referral reference',
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
          register_client();
        }
      },
      child: Container(
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

        first_name_controller.text = '';
        middle_name_controller.text = '';
        last_name_controller.text = '';

        phone_1_controller.text = '';
        phone_2_controller.text = '';
        email_controller.text = '';
        address_controller.text = '';
        dob_controller.text = '';
        age_controller.text = '';
        occupation_select = '';
        gender_select = '';
        hmo_select = 'No HMO';
        nature_of_work_controller.text = '';
        hykau = 'Select one';
        hykau_controller.text = '';

        image_file = null;
        imageUrl = '';

        sponsor_name_controller.text = '';
        sponsor_phone_controller.text = '';
        sponsor_addr_controller.text = '';
        sponsor_role_controller.text = '';
        sponsor = false;
        other_sponsors.clear();

        temp_dob.text = '';

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
  // register client
  void register_client() async {
    Helpers.showLoadingScreen(context: context);

    // assign new key
    if (new_key.isEmpty) {
      new_key = await PhysioDatabaseHelpers.assign_physio_registration_key();
    }

    // check client id to ensure no duplicates
    List check_id =
        await PhysioDatabaseHelpers.check_physio_client_id(widget.cl_id);

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
          await AdminDatabaseHelpers.uploadFile(image_file!, new_key, false) ??
              '';
    }

    // assign registration date
    var reg_date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // new client model
    var newcl = PhysioClientModel(
      key: new_key,
      id: widget.cl_id,
      reg_date: reg_date,
      user_status: true,
      f_name: first_name_controller.text.trim(),
      m_name: middle_name_controller.text.trim(),
      l_name: last_name_controller.text.trim(),
      user_image: imageUrl,
      phone_1: phone_1_controller.text.trim(),
      phone_2: phone_2_controller.text.trim(),
      email: email_controller.text.trim(),
      address: address_controller.text.trim(),
      gender: gender_select,
      dob: dob_controller.text.trim(),
      age: age_controller.text.trim(),
      occupation: occupation_select,
      nature_of_work: nature_of_work_controller.text.trim(),
      hykau: hykau == 'Select' ? '' : hykau,
      hykau_others: hykau_controller.text.trim(),
      hmo: hmo_select,
      baseline_done: false,
      sponsor_name: sponsor_name_controller.text.trim(),
      sponsor_phone: sponsor_phone_controller.text.trim(),
      sponsor_addr: sponsor_addr_controller.text.trim(),
      sponsor_role: sponsor_role_controller.text.trim(),
      sponsor: sponsor,
      refferal_code: refferal_code_controller.text.trim(),
      current_doctor: '',
    );

    var cl_map = newcl.toJson();

    // register cleint
    bool registration =
        await PhysioDatabaseHelpers.register_physio_client(new_key, cl_map);

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

    // add sponsors
    if (newcl.sponsor && other_sponsors.isNotEmpty) {
      other_sponsors.forEach((sponsor) {
        PhysioDatabaseHelpers.add_physio_sponsor(
            new_key, null, sponsor.toJson());
      });
    }

    // update gym profile if registration is from gym profile
    if (widget.new_ft != null) {
      GymDatabaseHelpers.update_client_details(widget.new_ft!.user_key, {
        'physio_key': new_key,
        'physio_cl': true,
      });
    }

    // update last physio ID
    PhysioDatabaseHelpers.update_last_physio_id(widget.cl_id);

    // complete
    Navigator.pop(context);
    Helpers.showToast(
      context: context,
      color: Colors.blue,
      toastText: 'Client Registered',
      icon: Icons.error,
    );

    // remove registration page
    Navigator.pop(context);
    // Go to Profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhysioClientProfilePage(
          cl_id: newcl.key!,
        ),
      ),
    );

    // create health model
    PhysioHealthClientModel client_h = PhysioHealthClientModel(
      key: newcl.key!,
      id: newcl.id!,
      name: '${newcl.f_name} ${newcl.m_name} ${newcl.l_name}',
      user_image: newcl.user_image!,
      hmo: newcl.hmo!,
      baseline_done: false,
    );

    // Go to clinic tab
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClinicTab(
          client: client_h,
          can_treat: false,
        ),
      ),
    );
  }

  //
}
