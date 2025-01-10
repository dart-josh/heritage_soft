import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/gym/client_pofile_page.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';

class BackDateRegistration extends StatefulWidget {
  final String cl_id;
  BackDateRegistration({super.key, required this.cl_id});

  @override
  State<BackDateRegistration> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<BackDateRegistration> {
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
  void initState() {
    cl_id_controller.text = widget.cl_id;
    cl_id = widget.cl_id;
    
    cl_id_controller.addListener(() {
      setState(() {
        cl_id = cl_id_controller.text.trim();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    cl_id_controller.removeListener(() {});
    cl_id_controller.dispose();
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

    if (hmo_select == 'No HMO') {
      is_hmo = false;
      hmo_hybrid = false;
    } else {
      is_hmo = true;
    }

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
      cl_id = cl_id.replaceAll('FT', 'HM');
    } else {
      cl_id = cl_id.replaceAll('HM', 'FT');
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
            // profile name
            profile_details(),
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

  // text controller
  TextEditingController cl_id_controller = TextEditingController();
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

  String gender_select = '';
  List<String> gender_options = ['Male', 'Female'];

  String occupation_select = '';
  String program_type_select = '';
  String corporate_type_select = '';

  String hmo_select = 'No HMO';

  String hykau = 'Select';

  bool show_age = false;

  List<String> hmo = gym_hmo.map((e) => e.hmo_name).toList();

  // !

  TextEditingController reg_date_controller = TextEditingController();

  String package_select = '';
  List<String> package_options = [
    'Daily',
    'Weekly',
    'Fortnightly',
    'Monthly',
    'Quarterly',
    'Half-Yearly',
    'Yearly',
    'Boxing',
    'Table Tennis',
    'Dance class',
  ];

  String sub_type_select = 'Individual';
  List<String> sub_type_options = [
    'Individual',
    'Couples',
    'Family',
    'HMO Plan'
  ];

  bool is_hmo = false;
  int week_days = 0;
  bool hmo_hybrid = false;

  String hmo_act = '';

  bool sp_pt = false;
  bool pp_pt = false;
  bool boxing = false;

  bool addon_exp = false;

  DateTime? sub_date;
  DateTime? pt_date;
  DateTime? bx_date;

  TextEditingController sub_date_controller = TextEditingController();
  TextEditingController pt_date_controller = TextEditingController();
  TextEditingController bx_date_controller = TextEditingController();

  bool sub_status = false;

  String cl_id = '';

  // profile details
  Widget profile_details() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // registration date
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
                          (date_data.length > 2)
                              ? int.parse(date_data[2])
                              : 1900,
                          int.parse(date_data[1]),
                          int.parse(date_data[0]))
                      : DateTime(2016);

                  var data = await showDatePicker(
                    context: context,
                    initialDate: date_res,
                    firstDate: DateTime(2016),
                    lastDate: DateTime.now(),
                  );

                  if (data != null) {
                    var date = DateFormat('dd/MM/yyyy').format(data);
                    reg_date_controller.text = date;

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

          // cl id
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              label: 'Client ID',
              controller: cl_id_controller,
              hintText: '',
              require: true,
            ),
          ),

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

          SizedBox(height: 20),

          // heading
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'Subscription Details',
              style: headingStyle,
            ),
          ),

          SizedBox(height: 20),

          (!is_hmo) ? subscription_area() : hmo_area(),

          // SizedBox(height: 10),

          Text('Sub Status', style: labelStyle),

          Switch(
            value: sub_status,
            onChanged: (_) {
              setState(() {
                sub_status = !sub_status;
              });
            },
          ),

          sub_dates(),

          SizedBox(height: 20),

          Text('Update ID', style: labelStyle),

          Switch(
            value: increase_id,
            onChanged: (_) {
              setState(() {
                increase_id = !increase_id;
              });
            },
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

  // sub details
  Widget subscription_area() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // type heading
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'Select a Plan type',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ),

          SizedBox(height: 7),

          // type form
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // plan
                Expanded(
                  flex: 5,
                  child: Select_form(
                    label: 'Type',
                    options: sub_type_options,
                    text_value: sub_type_select,
                    edit: !(program_type_select == 'Promotion'),
                    setval: (val) {
                      String prv_select = sub_type_select;
                      sub_type_select = val;
                      package_select = 'Select one';
                      boxing = false;
                      sp_pt = false;
                      pp_pt = false;

                      if (sub_type_select.contains('HMO')) {
                        if (hmo_select != 'No HMO') {
                          week_days = gym_hmo
                              .where(
                                  (element) => element.hmo_name == hmo_select)
                              .first
                              .days_week;

                          if (week_days == 1) {
                            hmo_act = 'Once a week';
                          } else {
                            hmo_act = '$week_days times a week';
                          }

                          is_hmo = true;
                        } else {
                          sub_type_select = prv_select;
                        }
                      }

                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // plan heading
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'Select a new Plan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ),

          SizedBox(height: 7),

          // plan form
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // plan
                Expanded(
                  flex: 5,
                  child: Select_form(
                    label: 'Package',
                    options: package_options,
                    text_value: package_select,
                    setval: (val) {
                      package_select = val;

                      if (package_select == 'Boxing') {
                        boxing = false;
                      }

                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // personal training
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    'Personal Training',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                SizedBox(height: 5),

                // title
                Text(
                  'Would you like to opt for Personal Training?',
                  style: TextStyle(
                    color: Color(0xFFc3c3c3),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    // standard plan
                    Row(
                      children: [
                        // plan details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // name
                            Text(
                              'Standard Plan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 10),

                        // checkbox
                        Checkbox(
                          value: sp_pt,
                          onChanged: (value) {
                            sp_pt = value!;

                            if (sp_pt && pp_pt) {
                              pp_pt = false;
                            }

                            setState(() {});
                          },
                          side: BorderSide(color: Colors.white70),
                          shape: CircleBorder(
                            eccentricity: 1,
                          ),
                        ),
                      ],
                    ),

                    Expanded(child: Container()),

                    // premium plan
                    Row(
                      children: [
                        // plan details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // name
                            Text(
                              'Premium Plan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 10),

                        // checkbox
                        Checkbox(
                          value: pp_pt,
                          onChanged: (value) {
                            pp_pt = value!;

                            if (pp_pt && sp_pt) {
                              sp_pt = false;
                            }

                            setState(() {});
                          },
                          side: BorderSide(color: Colors.white70),
                          shape: CircleBorder(
                            eccentricity: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // boxing
          (package_select == 'Boxing')
              ? Container()
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          'Boxing',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      SizedBox(height: 5),

                      Row(
                        children: [
                          // plan details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // title
                              Text(
                                'Would you like to opt for Boxing?',
                                style: TextStyle(
                                  color: Color(0xFFc3c3c3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 10),

                          // checkbox
                          Checkbox(
                            value: boxing,
                            onChanged: (value) {
                              boxing = value!;

                              setState(() {});
                            },
                            side: BorderSide(color: Colors.white70),
                            shape: CircleBorder(
                              eccentricity: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

          SizedBox(height: 10),
        ],
      ),
    );
  }

  // hmo area
  Widget hmo_area() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // hmo heading
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFababab)),
              ),
            ),
            child: Text(
              'HMO Plan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ),

          SizedBox(height: 7),

          // hmo name
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // plan
                Expanded(
                  flex: 5,
                  child: Select_form(
                    label: 'HMO Name',
                    options: [],
                    text_value: hmo_select,
                    edit: false,
                    setval: (val) {
                      hmo_select = val;

                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // hmo activity
          Container(
            width: 200,
            child: Select_form(
              label: 'HMO Activity',
              options: ['Once a week', '2 times a week'],
              text_value: hmo_act,
              // edit: false,
              setval: (val) {
                hmo_act = val;

                if (val == 'Once a week') {
                  week_days = 1;
                } else if (val == '2 times a week') {
                  week_days = 2;
                }

                setState(() {});
              },
            ),
          ),

          SizedBox(height: 15),

          // addons
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFababab)),
                  ),
                ),
                child: Text(
                  'Addons',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(child: Container()),
              IconButton(
                onPressed: () {
                  setState(() {
                    addon_exp = !addon_exp;
                  });
                },
                icon: Icon(
                  addon_exp ? Icons.remove : Icons.add,
                  color: Colors.white54,
                ),
              ),
            ],
          ),

          SizedBox(height: 7),

          // hybrid
          !addon_exp
              ? Container()
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          'Hybrid Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      SizedBox(height: 5),

                      Row(
                        children: [
                          // plan details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // title
                              Text(
                                'Would you like to opt for HMO hybrid plan?',
                                style: TextStyle(
                                  color: Color(0xFFc3c3c3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 10),

                          // checkbox
                          Checkbox(
                            value: hmo_hybrid,
                            onChanged: (value) {
                              hmo_hybrid = value!;

                              setState(() {});
                            },
                            side: BorderSide(color: Colors.white70),
                            shape: CircleBorder(
                              eccentricity: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

          !addon_exp ? Container() : SizedBox(height: 10),

          // personal training
          !addon_exp
              ? Container()
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          'Personal Training',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      SizedBox(height: 5),

                      // title
                      Text(
                        'Would you like to opt for Personal Training?',
                        style: TextStyle(
                          color: Color(0xFFc3c3c3),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          // standard plan
                          Row(
                            children: [
                              // plan details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // name
                                  Text(
                                    'Standard Plan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(width: 10),

                              // checkbox
                              Checkbox(
                                value: sp_pt,
                                onChanged: (value) {
                                  sp_pt = value!;

                                  if (sp_pt && pp_pt) {
                                    pp_pt = false;
                                  }

                                  setState(() {});
                                },
                                side: BorderSide(color: Colors.white70),
                                shape: CircleBorder(
                                  eccentricity: 1,
                                ),
                              ),
                            ],
                          ),

                          Expanded(child: Container()),

                          // premium plan
                          Row(
                            children: [
                              // plan details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // name
                                  Text(
                                    'Premium Plan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(width: 10),

                              // checkbox
                              Checkbox(
                                value: pp_pt,
                                onChanged: (value) {
                                  pp_pt = value!;

                                  if (pp_pt && sp_pt) {
                                    sp_pt = false;
                                  }

                                  setState(() {});
                                },
                                side: BorderSide(color: Colors.white70),
                                shape: CircleBorder(
                                  eccentricity: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

          // boxing
          !addon_exp
              ? Container()
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          'Boxing',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      SizedBox(height: 5),

                      Row(
                        children: [
                          // plan details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // title
                              Text(
                                'Would you like to opt for Boxing?',
                                style: TextStyle(
                                  color: Color(0xFFc3c3c3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 10),

                          // checkbox
                          Checkbox(
                            value: boxing,
                            onChanged: (value) {
                              boxing = value!;

                              setState(() {});
                            },
                            side: BorderSide(color: Colors.white70),
                            shape: CircleBorder(
                              eccentricity: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // sub date
  Widget sub_dates() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // SUB date
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              label: 'SUB Date',
              controller: sub_date_controller,
              edit: true,
              icon: InkWell(
                onTap: () async {
                  var data = await showDatePicker(
                    context: context,
                    initialDate: sub_date,
                    firstDate: DateTime(2016),
                    lastDate: DateTime(2028),
                  );

                  sub_date = data;

                  if (data != null) {
                    var date = DateFormat('dd/MM/yyyy').format(data);
                    sub_date_controller.text = date;
                  } else {
                    sub_date_controller.text = '';
                    sub_date = null;
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

          // PT date
          if (sp_pt || pp_pt)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text_field(
                label: 'PT Date',
                controller: pt_date_controller,
                edit: true,
                icon: InkWell(
                  onTap: () async {
                    var data = await showDatePicker(
                      context: context,
                      initialDate: pt_date,
                      firstDate: DateTime(2016),
                      lastDate: DateTime(2028),
                    );

                    pt_date = data;

                    if (data != null) {
                      var date = DateFormat('dd/MM/yyyy').format(data);
                      pt_date_controller.text = date;
                    } else {
                      pt_date_controller.text = '';
                      pt_date = null;
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

          // SUB date
          if (boxing)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text_field(
                label: 'Boxing Date',
                controller: bx_date_controller,
                edit: true,
                icon: InkWell(
                  onTap: () async {
                    var data = await showDatePicker(
                      context: context,
                      initialDate: bx_date,
                      firstDate: DateTime(2016),
                      lastDate: DateTime(2028),
                    );

                    bx_date = data;

                    if (data != null) {
                      var date = DateFormat('dd/MM/yyyy').format(data);
                      bx_date_controller.text = date;
                    } else {
                      bx_date_controller.text = '';
                      bx_date = null;
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
        ],
      ),
    );
  }

  // personal details
  Widget personal_details() {
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
                          } else {
                            var date = DateFormat('dd/MM').format(data);
                            dob_controller.text = date;
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
        if (cl_id.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Client ID Empty',
            icon: Icons.error,
          );
          return;
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

        if (reg_date_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Enter Registration date',
            icon: Icons.error,
          );
          return;
        }

        if ((package_select == '' || package_select == 'Select one') &&
            !sub_type_select.toLowerCase().contains('hmo')) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Select a Subscription Plan',
            icon: Icons.error,
          );
          return;
        }

        if (sub_date == null) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Enter subscription date',
            icon: Icons.error,
          );
          return;
        }

        if ((pp_pt || sp_pt) && pt_date == null) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Enter PT date',
            icon: Icons.error,
          );
          return;
        }

        if (boxing && bx_date == null) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Enter Boxing date',
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

  bool increase_id = false;

  // register client
  void register_client() async {
    Helpers.showLoadingScreen(context: context);

    // check client id to ensure no duplicates
    List check_id = await GymDatabaseHelpers.check_gym_client_id(cl_id);

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

    // assign new key
    if (new_key.isEmpty) {
      new_key = await GymDatabaseHelpers.assign_gym_registration_key();
    }

    String dob = dob_controller.text.trim();
    if (dob.isNotEmpty) {
      if (dob.split('/').length > 2) {
        dob = dob;
      } else {
        dob += '/1900';
      }
    }

    // hmo client
    if (is_hmo) {
      if (hmo_hybrid)
        package_select = 'HMO Hybrid';
      else
        package_select = 'HMO Plan';

      sub_type_select = 'HMO Plan';
    }

    bool pt = false;

    // update sub plan & pt plan
    String pt_plan = sp_pt
        ? 'Standard'
        : pp_pt
            ? 'Premium'
            : 'null';

    if (pt_plan != 'null') {
      pt = true;
    }

    // get exp date base on sub plan
    String sub_dt = getSubDate(sub_date);
    String pt_dt = get_pt_date(pt_date);
    String bx_dt = get_pt_date(bx_date);

    var newcl = ClientModel(
      key: new_key,
      id: cl_id,
      reg_date: reg_date_controller.text.trim(),
      user_status: true,
      sub_type: sub_type_select,
      sub_plan: package_select,
      pt_plan: pt_plan,
      sub_status: sub_status,
      pt_status: pt,
      sub_date: sub_dt,
      pt_date: pt_dt,
      boxing: boxing,
      bx_date: bx_dt,
      f_name: first_name_controller.text.trim(),
      m_name: middle_name_controller.text.trim(),
      l_name: last_name_controller.text.trim(),
      user_image: '',
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
      max_days: week_days,
      renew_dates: '',
      registration_dates: '',
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
    if (increase_id) GymDatabaseHelpers.update_last_gym_id(cl_id);

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

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientProfilePage(cl_id: new_key),
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
        hykau = '';
        hykau_controller.text = '';

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
  String calc_age_(DateTime dob) {
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

  String getSubDate(DateTime? d) {
    if (d == null) return '';

    int duration = 1;
    bool is_month = true;

    if (package_select == 'Daily') {
      duration = 1;
      is_month = false;
    }
    if (package_select == 'Weekly') {
      duration = 7;
      is_month = false;
    }
    if (package_select == 'Fortnightly') {
      duration = 14;
      is_month = false;
    }

    // month
    if (package_select == 'Monthly') {
      duration = 1;
      is_month = true;
    }
    if (package_select == 'Quarterly') {
      duration = 3;
      is_month = true;
    }
    if (package_select == 'Half-Yearly') {
      duration = 6;
      is_month = true;
    }
    if (package_select == 'Yearly') {
      duration = 12;
      is_month = true;
    }
    if (package_select == 'Boxing') {
      duration = 1;
      is_month = true;
    }

    if (package_select.contains('HMO')) {
      duration = 1;
      is_month = true;
    }

    int new_month = d.month;
    int new_year = d.year;
    int new_day = d.day;

    if (is_month) {
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
    } else {
      DateTime nd = d.add(Duration(days: duration));
      d = nd;
    }

    DateTime newDate = d;

    String date_set = DateFormat('dd/MM/yyyy').format(newDate);

    return date_set;
  }

  // pt date
  String get_pt_date(DateTime? d) {
    if (d == null) return '';

    int duration = 1;

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
