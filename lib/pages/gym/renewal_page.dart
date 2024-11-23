import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/gym/client_pofile_page.dart';
import 'package:heritage_soft/pages/gym/indemnity_page.dart';
import 'package:heritage_soft/pages/gym/print.page.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';

class RenewalPage extends StatefulWidget {
  final bool register;
  final RenewalModel details;
  final bool adv_renewal;
  const RenewalPage(
      {super.key,
      this.register = false,
      required this.details,
      this.adv_renewal = false});

  @override
  State<RenewalPage> createState() => _RenewalPageState();
}

class _RenewalPageState extends State<RenewalPage> {
  bool success_is_playing = false;
  final ConfettiController success_controller = ConfettiController();

  TextEditingController amount_controller = TextEditingController();
  FocusNode amount_node = FocusNode();

  TextEditingController total_amount_controller = TextEditingController();
  FocusNode total_amount_node = FocusNode();

  TextEditingController discount_controller = TextEditingController();

  String package_select = 'Select one';
  List<String> package_options = [
    'Daily',
    'Weekly',
    'Fortnightly',
    'Monthly',
    '2 Months',
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

  bool sp_pt = false;
  int sp_pt_value = 10000;

  bool pp_pt = false;
  int pp_pt_value = 15000;

  bool boxing = false;
  int boxing_value = 15000;

  bool registration = false;
  int registration_value = 5000;

  String sub_date = '';

  bool is_hmo = false;

  String hmo_name = '';
  int week_days = 0;

  bool hmo_hybrid = false;
  int hmo_amount = 12000;
  int hybrid_amount = 0;
  int hmo_hybrid_tot = 20000;

  int hmo_hybrid_cap = 8000;

  String hmo_act = '';

  bool addon_exp = false;

  int sub_amount = 0;

  bool done = false;

  GymSubPrintModel? printModel;

  int sub_amount_b4_discount = 0;

  List<String> sub_date_option = ['Last Subscription', 'Today'];
  String raw_sub_date_select = 'Today';
  DateTime sub_date_select = DateTime.now();

  DateTime? renew_date_select;
  String raw_renew_date_select = '';

  @override
  void initState() {
    if (widget.register && widget.details.program_type != 'Promotion')
      registration = true;

    if (widget.details.program_type == 'Promotion') {
      sub_type_select = 'Promotion';
    } else {
      sub_type_select = widget.details.sub_type;
    }

    if (widget.adv_renewal) {
      if (widget.details.sub_date.isNotEmpty) {
        raw_sub_date_select = widget.details.sub_date;
        sub_date_select = getDate(raw_sub_date_select);
      }
    }

    init_values();

    success_controller.addListener(() {
      setState(() {
        success_is_playing =
            success_controller.state == ConfettiControllerState.playing;
      });
    });

    discount_controller.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  void init_values() {
    if ((widget.details.sub_plan == 'HMO Plan' ||
            widget.details.sub_plan == 'HMO Hybrid') &&
        (widget.details.hmo_name != 'No HMO')) {
      hmo_name = widget.details.hmo_name!;
      week_days = gym_hmo
          .where((element) => element.hmo_name == hmo_name)
          .first
          .days_week;

      hmo_amount = gym_hmo
          .where((element) => element.hmo_name == hmo_name)
          .first
          .hmo_amount;

      hybrid_amount = hmo_hybrid_tot - hmo_amount;
      if (hybrid_amount < hmo_hybrid_cap) hybrid_amount = hmo_hybrid_cap;

      if (week_days == 1) {
        hmo_act = 'Once a week';
      } else {
        hmo_act = '$week_days times a week';
      }

      is_hmo = true;
      registration = false;
    } else {
      is_hmo = false;
    }
  }

  @override
  void dispose() {
    amount_controller.dispose();
    amount_node.dispose();

    total_amount_controller.dispose();
    total_amount_node.dispose();

    discount_controller.dispose();

    success_controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getSubDate(sub_date_select);
    update_func();
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
                          'images/sub.jpg',
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          // top bar
          topBar(),

          // body
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),

                      // profile area
                      profile_area(),

                      SizedBox(height: 40),

                      // subscription area
                      (done)
                          ? success_box()
                          : (!is_hmo)
                              ? subscription_area()
                              : hmo_area(),
                    ],
                  ),
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
          ),
        ],
      ),
    );
  }

  // top bar
  Widget topBar() {
    String reg_dt = '';
    if (!widget.register && widget.details.reg_date.isNotEmpty) {
      var date_data = widget.details.reg_date.split('/');
      var date_res = DateTime(
        int.parse(date_data[2]),
        int.parse(date_data[1]),
        int.parse(date_data[0]),
      );
      reg_dt = Helpers.reg_date_diff(date_res);
    }

    return Row(
      children: [
        // id & registration date
        Column(
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
                  widget.details.id,
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
                widget.register
                    ? Container()
                    : Text(
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

            widget.register
                ? Container()
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color.fromARGB(255, 232, 186, 93).withOpacity(0.4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: EdgeInsets.only(left: 10, top: 2),
                    child: Text(
                      widget.details.sub_type,
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

        Expanded(child: Container()),

        // close button
        done
            ? SizedBox()
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 30,
                ),
              ),
      ],
    );
  }

  // profile area
  Widget profile_area() {
    return Column(
      children: [
        // profile image
        CircleAvatar(
          radius: 65,
          backgroundColor: Color(0xFFF3DADA).withOpacity(0.8),
          foregroundColor: Colors.white,
          backgroundImage: (widget.details.user_image.isNotEmpty)
              ? NetworkImage(
                  widget.details.user_image,
                )
              : null,
          child: Center(
            child: (widget.details.user_image.isEmpty)
                ? Image.asset(
                    'images/icon/user-alt.png',
                    width: 73,
                    height: 73,
                  )
                : Container(),
          ),
        ),

        SizedBox(height: 6),

        // profile name
        Text(
          widget.details.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: Color(0xFF000000),
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),

        SizedBox(height: 5),

        // subscription box
        widget.register
            ? Container()
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Color(0xFF3C58E6).withOpacity(0.67),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      widget.details.sub_plan,
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
        widget.register || !widget.details.pt_status
            ? Container()
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Color(0xFF5a5a5a).withOpacity(0.7),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/icon/sentiayoga.png',
                      width: 10,
                      height: 10,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'PT - ${widget.details.pt_plan}',
                      style: TextStyle(
                        fontSize: 8,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

        widget.register || !widget.details.boxing
            ? Container()
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Color.fromARGB(255, 55, 103, 135).withOpacity(0.7),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: EdgeInsets.only(top: 5),
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
      ],
    );
  }

  // subscription area
  Widget subscription_area() {
    var value = NumberFormat('#,###');
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
                    edit: !(widget.details.program_type == 'Promotion'),
                    setval: (val) {
                      String prv_select = sub_type_select;
                      sub_type_select = val;
                      package_select = 'Select one';
                      amount_controller.clear();
                      boxing = false;
                      sp_pt = false;
                      pp_pt = false;

                      if (sub_type_select.contains('HMO')) {
                        if (widget.details.hmo_name != null &&
                            widget.details.hmo_name != 'No HMO') {
                          hmo_name = widget.details.hmo_name!;
                          week_days = gym_hmo
                              .where((element) => element.hmo_name == hmo_name)
                              .first
                              .days_week;

                          hmo_amount = gym_hmo
                              .where((element) => element.hmo_name == hmo_name)
                              .first
                              .hmo_amount;

                          hybrid_amount = hmo_hybrid_tot - hmo_amount;

                          if (hybrid_amount < hmo_hybrid_cap)
                            hybrid_amount = hmo_hybrid_cap;

                          if (week_days == 1) {
                            hmo_act = 'Once a week';
                          } else {
                            hmo_act = '$week_days times a week';
                          }

                          is_hmo = true;
                          registration = false;
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

                      // family
                      if (sub_type_select == 'Family') {
                        if (package_select == 'Daily')
                          amount_controller.text = '2,500';
                        if (package_select == 'Weekly')
                          amount_controller.text = '7,000';
                        if (package_select == 'Fortnightly')
                          amount_controller.text = '12,000';
                        if (package_select == 'Monthly')
                          amount_controller.text = '18,750';
                        if (package_select == '2 Months')
                          amount_controller.text = '37,500';
                        if (package_select == 'Quarterly')
                          amount_controller.text = '50,000';
                        if (package_select == 'Half-Yearly')
                          amount_controller.text = '95,000';
                        if (package_select == 'Yearly')
                          amount_controller.text = '175,000';
                      }
                      // couples
                      else if (sub_type_select == 'Couples') {
                        if (package_select == 'Daily')
                          amount_controller.text = '2,750';
                        if (package_select == 'Weekly')
                          amount_controller.text = '7,500';
                        if (package_select == 'Fortnightly')
                          amount_controller.text = '13,000';
                        if (package_select == 'Monthly')
                          amount_controller.text = '19,000';
                        if (package_select == '2 Months')
                          amount_controller.text = '38,000';
                        if (package_select == 'Quarterly')
                          amount_controller.text = '52,500';
                        if (package_select == 'Half-Yearly')
                          amount_controller.text = '100,000';
                        if (package_select == 'Yearly')
                          amount_controller.text = '190,000';
                      }
                      // individual
                      else {
                        if (package_select == 'Daily')
                          amount_controller.text = '3,000';
                        if (package_select == 'Weekly')
                          amount_controller.text = '8,000';
                        if (package_select == 'Fortnightly')
                          amount_controller.text = '14,000';
                        if (package_select == 'Monthly')
                          amount_controller.text = '20,000';
                        if (package_select == '2 Months')
                          amount_controller.text = '40,000';
                        if (package_select == 'Quarterly')
                          amount_controller.text = '55,000';
                        if (package_select == 'Half-Yearly')
                          amount_controller.text = '105,000';
                        if (package_select == 'Yearly')
                          amount_controller.text = '200,000';
                      }

                      if (widget.register) registration = true;

                      if (package_select == 'Daily') {
                        registration = false;
                      }

                      if (package_select == 'Boxing') {
                        amount_controller.text = '15,000';
                        boxing = false;
                      }

                      if (package_select == 'Table Tennis') {
                        amount_controller.text = '10,000';
                        registration = false;
                      }

                      if (package_select == 'Dance class') {
                        amount_controller.text = '30,000';
                        registration = false;
                      }

                      if (widget.details.program_type == 'Promotion') {
                        amount_controller.text = '0';
                        registration = false;
                      }

                      setState(() {});
                    },
                  ),
                ),

                SizedBox(width: 20),

                // amount
                Expanded(
                  flex: 5,
                  child: Text_field(
                    label: 'Amount',
                    controller: amount_controller,
                    node: amount_node,
                    edit: true,
                    prefix: Text(
                      '₦',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
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

                            SizedBox(height: 2),

                            // amount
                            Text(
                              '₦ ${value.format(sp_pt_value)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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

                            SizedBox(height: 2),

                            // amount
                            Text(
                              '₦ ${value.format(pp_pt_value)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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

                              SizedBox(height: 2),

                              // amount
                              Text(
                                '₦ ${value.format(boxing_value)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  height: 1,
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

          if (widget.register && registration)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // checkbox
                      Checkbox(
                        value: registration,
                        onChanged: (value) {
                          setState(() {});
                        },
                        side: BorderSide(color: Colors.white70),
                      ),

                      SizedBox(width: 10),

                      // plan details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // title
                          Text(
                            'Acknowledge registration fee',
                            style: TextStyle(
                              color: Color(0xFFc3c3c3),
                              fontSize: 12,
                            ),
                          ),

                          SizedBox(height: 2),

                          // amount
                          Text(
                            '₦ ${value.format(registration_value)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

          SizedBox(height: 10),

          // discount
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text_field(
                label: 'Discount (if applicable)',
                controller: discount_controller,
                prefix: Text(
                  '₦',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                format: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ),

          SizedBox(height: 10),

          // total amount
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text_field(
                label: 'Total Amount',
                controller: total_amount_controller,
                node: total_amount_node,
                edit: true,
                prefix: Text(
                  '₦',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // select dates
          if (!widget.register)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // plan
                  Expanded(
                    child: Select_form(
                      label: 'Renewal date',
                      options: sub_date_option,
                      text_value: raw_sub_date_select,
                      edit: !widget.adv_renewal,
                      setval: (val) {
                        if (val == 'Last Subscription') {
                          if (widget.details.sub_date.isNotEmpty) {
                            raw_sub_date_select = widget.details.sub_date;
                            sub_date_select = getDate(raw_sub_date_select);
                          } else {
                            return;
                          }
                        }

                        if (val == 'Today') {
                          raw_sub_date_select = 'Today';
                          sub_date_select = DateTime.now();
                        }

                        setState(() {});
                      },
                    ),
                  ),

                  SizedBox(width: 20),

                  Expanded(
                      child: Text_field(
                    controller:
                        TextEditingController(text: raw_renew_date_select),
                    edit: true,
                    label: 'Next Renewal date',
                  )),
                ],
              ),
            ),

          SizedBox(height: 25),

          // renew button
          renew_button(),
        ],
      ),
    );
  }

  // hmo area
  Widget hmo_area() {
    var value = NumberFormat('#,###');
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
                    text_value: hmo_name,
                    edit: false,
                    setval: (val) {
                      hmo_name = val;

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
              options: ['Once a week', '2 times a week', '3 times a week'],
              text_value: hmo_act,
              // edit: false,
              setval: (val) {
                hmo_act = val;

                if (val == 'Once a week') {
                  week_days = 1;
                } else if (val == '2 times a week') {
                  week_days = 2;
                } else if (val == '3 times a week') {
                  week_days = 3;
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

                              SizedBox(height: 2),

                              // amount
                              Text(
                                '₦ ${value.format(hybrid_amount)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  height: 1,
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

                                  SizedBox(height: 2),

                                  // amount
                                  Text(
                                    '₦ ${value.format(sp_pt_value)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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

                                  SizedBox(height: 2),

                                  // amount
                                  Text(
                                    '₦ ${value.format(pp_pt_value)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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

                              SizedBox(height: 2),

                              // amount
                              Text(
                                '₦ ${value.format(boxing_value)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  height: 1,
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

          // total amount
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text_field(
                label: 'Required Amount',
                controller: total_amount_controller,
                node: total_amount_node,
                edit: true,
                prefix: Text(
                  '₦',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 25),

          // renew button
          renew_button(),
        ],
      ),
    );
  }

  // success box
  Widget success_box() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Column(
        children: [
          // box
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF7c7c7c).withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 30),
            child: Text(
              'You have successfully subscribed to our ${(package_select.contains('Plan')) ? package_select.replaceAll('Plan', '').trim() : package_select} plan. Your subscription would expire on ${sub_date}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),

          SizedBox(height: 20),

          // close button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              close_button(),
              SizedBox(width: 20),
              print_button(),
            ],
          ),
        ],
      ),
    );
  }

  // renew button
  Widget renew_button() {
    return InkWell(
      onTap: () async {
        bool pt = false;
        if (package_select == 'Select one' && !is_hmo) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Select a membership plan to proceed.',
            icon: Icons.error_outline,
          );

          return;
        }

        // update sub plan & pt plan
        String pt_plan = sp_pt
            ? 'Standard'
            : pp_pt
                ? 'Premium'
                : 'null';

        // cannot subscribe to an active pt plan
        if (widget.details.pt_status && widget.details.pt_plan == pt_plan && !widget.adv_renewal) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText:
                'You currently have an active $pt_plan Personal Training plan.',
            icon: Icons.error,
          );
          return;
        }

        // changing active pt plan
        else if (widget.details.pt_status && pt_plan != 'null') {
          var res = await showDialog(
            context: context,
            builder: (context) => ConfirmDialog(
                title: 'Personal Training',
                subtitle:
                    'You currently have an active Personal Training plan.\nWould you like to opt for a new plan?'),
          );

          if (res != null && res == true) {
            pt = true;
          } else {
            return;
          }
        }

        // new pt plan
        else if (pt_plan != 'null') {
          pt = true;
        }

        // cannot subscribe to boxing if boxing is active
        if (widget.details.boxing && boxing && !widget.adv_renewal) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'You currently have an active Boxing subscription.',
            icon: Icons.error,
          );
          return;
        }

        var res_r = await showDialog(
          context: context,
          builder: (context) => ConfirmDialog(
            title: widget.register
                ? 'Activate Subscription'
                : 'Renew Subscription',
            subtitle: widget.register
                ? 'Would you like to proceed to activate this subscription?'
                : 'Would you like to proceed to renew this subscription?',
          ),
        );

        if (res_r == null || !res_r) return;

        Map<String, dynamic> ned = {};

        // hmo client
        if (is_hmo) {
          if (hmo_hybrid)
            package_select = 'HMO Hybrid';
          else
            package_select = 'HMO Plan';

          sub_type_select = 'HMO Plan';
        }

        // get exp date base on sub plan
        String subdt = getSubDate(sub_date_select);
        sub_date = subdt.split('|').first;
        String setdt = subdt.split('|').last;

        // with pt
        if (pt) {
          String pt_date = get_pt_date(sub_date_select, widget.details.pt_status);
          ned = {
            'sub_plan': package_select,
            'sub_type': sub_type_select,
            'sub_status': true,
            'sub_date': setdt,
            'pt_plan': pt_plan,
            'pt_status': true,
            'pt_date': pt_date,
          };
        }

        // without pt
        else {
          ned = {
            'sub_plan': package_select,
            'sub_type': sub_type_select,
            'sub_status': true,
            'sub_date': setdt,
          };
        }

        // with boxing
        if (boxing) {
          String bx_date = get_pt_date(sub_date_select, widget.details.boxing);
          var t = {
            'boxing': true,
            'bx_date': bx_date,
          };

          ned.addAll(t);
        }

        // if hmo client
        if (is_hmo) {
          var t = {
            'max_days': week_days,
            'days_in': 0,
          };

          ned.addAll(t);
        }

        // add renewal date (if sub type is renewal)
        if (!widget.register) {
          ned.addAll({
            'renew_dates': (widget.details.renew_dates.isNotEmpty)
                ? '${widget.details.renew_dates},${DateFormat('dd/MM/yyyy').format(DateTime.now())}'
                : DateFormat('dd/MM/yyyy').format(DateTime.now())
          });
        }

        int inc = widget.details.sub_income + sub_amount;
        var amt = {'sub_income': inc, 'sub_paused': false};
        ned.addAll(amt);

        String history_id = Helpers.generate_order_id();

        Sub_History_Model subhist = Sub_History_Model(
          key: '',
          sub_plan: package_select,
          sub_type: sub_type_select,
          sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          exp_date: setdt,
          amount: sub_amount,
          boxing: boxing,
          pt_status: pt,
          pt_plan: pt_plan,
          hist_type: widget.register ? 'Registration' : widget.adv_renewal ? 'Advanced Renewal' : 'Renewal',
          history_id: history_id,
          sub_amount_b4_discount: (sub_amount_b4_discount != sub_amount)
              ? sub_amount_b4_discount
              : null,
        );

        printModel = GymSubPrintModel(
          date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          receipt_id: history_id,
          client_id: widget.details.id,
          client_name: widget.details.name,
          subscription_plan: package_select,
          subscription_type: sub_type_select,
          extras: [if (boxing) 'Boxing', if (pt) '$pt_plan Personal Training'],
          amount: sub_amount,
          expiry_date: setdt.replaceAll('/', '-'),
          receipt_type: widget.register ? 'Registration' : 'Renewal',
          sub_amount_b4_discount: (sub_amount_b4_discount != sub_amount)
              ? sub_amount_b4_discount
              : 0,
        );

        

        Helpers.showLoadingScreen(context: context);
        bool res = await GymDatabaseHelpers.update_client_details(
            widget.details.key, ned);

        Navigator.pop(context);

        if (!res) {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'An Error occured, Try again!',
            icon: Icons.error,
          );
          return;
        }

        // add sub history
        GymDatabaseHelpers.add_to_sub_history(
            widget.details.key, subhist.toJson());

        Helpers.showToast(
          context: context,
          color: Colors.blue,
          toastText: 'Successfully Subscribed!',
          icon: Icons.check,
        );

        if (pt) {
          widget.details.pt_plan = pt_plan;
          widget.details.pt_status = true;
        }

        if (boxing) {
          widget.details.boxing = true;
        }

        widget.details.sub_type = sub_type_select;
        // sub plan
        widget.details.sub_plan = package_select;

        setState(() {
          done = true;
          success_controller.play();
        });

        Future.delayed(Duration(seconds: 5), () {
          if (mounted) {
            success_controller.stop();
            setState(() {});
          }
        });
      },
      child: Container(
        width: widget.adv_renewal? 180 : 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF3c5bff),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Center(
          child: Text(
            widget.register
                ? 'Subscribe'
                : widget.adv_renewal
                    ? 'Advanced Renewal'
                    : 'Renew',
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

  // close button
  Widget close_button() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);

        if (widget.register) {
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ClientProfilePage(cl_id: widget.details.key),
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => indemnityPage(
                client_key: widget.details.key,
                client_name: widget.details.name,
              ),
            ),
          );
        }
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: widget.register ? Color(0xFF3c5bff) : Color(0xFFa5703b),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Center(
          child: Text(
            widget.register ? 'View Indemnity' : 'Close',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              // height: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // print button
  Widget print_button() {
    return InkWell(
      onTap: () async {
        if (printModel != null)
          await showDialog(
              context: context,
              builder: (context) => GymPrintPage(print: printModel!));
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.blue.shade400,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Center(
          child: Text(
            'Print Receipt',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              // height: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Function
  // get date
  DateTime getDate(String data) {
    var date_data = data.split('/');
    return DateTime(
      int.parse(date_data[2]),
      int.parse(date_data[1]),
      int.parse(date_data[0]),
    );
  }

  // sub date
  String getSubDate(DateTime date) {
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
    if (package_select == '2 Months') {
      duration = 2;
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

    int new_month = date.month;
    int new_year = date.year;
    int new_day = date.day;

    if (is_month) {
      int mon = date.month;
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

      date = DateTime(new_year, new_month, new_day);
    } else {
      DateTime nd = date.add(Duration(days: duration));
      date = nd;
    }

    DateTime newDate = date;

    int day = newDate.day;
    String month = DateFormat('MMMM').format(newDate);
    int year = newDate.year;

    String date_set = DateFormat('dd/MM/yyyy').format(newDate);

    renew_date_select = newDate;
    raw_renew_date_select = date_set;

    return '$day $month, $year|$date_set';
  }

  // pt date
  String get_pt_date(DateTime date, bool status) {
    int duration = 1;

    DateTime d = (widget.adv_renewal && !status) ? DateTime.now() : date;

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

  // update amounts
  void update_func() {
    int amount = (widget.details.program_type == 'Promotion')
        ? 0
        : amount_controller.text.isNotEmpty
            ? int.parse(amount_controller.text.replaceAll(',', ''))
            : 0;
    // hmo
    if (is_hmo) {
      if (hmo_hybrid) {
        amount = hybrid_amount;
      } else {
        amount = 0;
      }
    }

    if (sp_pt) {
      var tot_amount = amount + sp_pt_value;
      if (boxing) tot_amount = tot_amount + boxing_value;
      total_amount_controller.text = tot_amount.toString();
    } else if (pp_pt) {
      var tot_amount = amount + pp_pt_value;
      if (boxing) tot_amount = tot_amount + boxing_value;
      total_amount_controller.text = tot_amount.toString();
    } else {
      if (boxing) amount = amount + boxing_value;
      total_amount_controller.text = amount.toString();
    }

    int total_amount = total_amount_controller.text.isNotEmpty
        ? int.parse(total_amount_controller.text)
        : 0;

    if (registration) {
      total_amount += registration_value;
    }

    sub_amount_b4_discount = total_amount;

    if (discount_controller.text.isNotEmpty) {
      int discount = total_amount - int.parse(discount_controller.text.trim());
      total_amount = discount;
    }

    sub_amount = total_amount;

    total_amount_controller.text = NumberFormat('#,###').format(total_amount);
  }
  //
}
