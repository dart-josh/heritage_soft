import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:heritage_soft/pages/gym/welcome_goodbye_page.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';

class ClSignInPage extends StatefulWidget {
  final ClientSignInModel client;
  const ClSignInPage({super.key, required this.client});

  @override
  State<ClSignInPage> createState() => _ClSignInPageState();
}

class _ClSignInPageState extends State<ClSignInPage> {
  final ConfettiController success_controller_1 = ConfettiController();
  final ConfettiController success_controller_2 = ConfettiController();

  final AudioPlayer player_1 = AudioPlayer();
  final AudioPlayer player_2 = AudioPlayer();

  bool can_sign_in = false;
  bool hmo_days_done = false;
  bool bx_only = false;

  @override
  void initState() {
    in_out = widget.client.in_out;

    // get last activity
    last_activity = get_last_activity(widget.client.last_activity);

    can_sign_in = confirm_active();
    birth_day = check_birthday();

    // birthday celebration
    if (can_sign_in)
      Future.delayed(Duration(milliseconds: 50), () {
        if (birth_day) celebrate_birth_day();
      });

    // sign in after 4sec
    if (can_sign_in) {
      Future.delayed(Duration(seconds: 4), () {
        if (!pause_page && mounted) check_in_out();
      });
    }

    // close page after 30sec
    Future.delayed(Duration(seconds: 30), () {
      if (!pause_page && mounted) Navigator.pop(context);
    });

    refresh();
    super.initState();
  }

  @override
  void dispose() {
    player_1.dispose();
    player_2.dispose();
    success_controller_1.dispose();
    success_controller_2.dispose();
    super.dispose();
  }

  // refresh for time
  refresh() {
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) setState(() {});
      refresh();
    });
  }

  String last_activity = '';
  String duration = '';

  bool pause_page = false;

  bool birth_day = false;

  bool confirm_active() {
    ClientSignInModel client = widget.client;

    if (client.in_out) {
      if (client.sub_status || client.boxing) {
        if (!client.boxing && client.sub_plan == 'HMO Plan') {
          if (client.days_in < client.max_days) {
            can_sign_in = true;
          } else {
            hmo_days_done = true;
            can_sign_in = false;
          }
        } else {
          if (!client.sub_status || client.sub_plan == 'Boxing')
            bx_only = true;
          else
            bx_only = false;
          can_sign_in = true;
        }
      } else {
        can_sign_in = false;
      }
    } else {
      can_sign_in = true;
    }

    return can_sign_in;
  }

  bool check_birthday() {
    if (widget.client.dob!.isNotEmpty) if (get_birth_Date(
            getDate(widget.client.dob!)) ==
        get_birth_Date(DateTime.now()))
      return true;
    else
      return false;
    else
      return false;
  }

  DateTime getDate(String data) {
    var date_data = data.split('/');
    return DateTime(
      int.parse(date_data[2]),
      int.parse(date_data[1]),
      int.parse(date_data[0]),
    );
  }

  String get_birth_Date(DateTime data) {
    int month = data.month;
    int day = data.day;

    return '$day/$month';
  }

  // celebrate birthday
  celebrate_birth_day() async {
    if (in_out) {
      pause_page = true;

      // play pop sound
      await player_1.play(AssetSource('pop-sound.mp3'));

      // show confetti
      success_controller_1.play();
      success_controller_2.play();

      // play birthday tune
      player_2.play(AssetSource('happy-birthday.mp3'));

      // show birthday message
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BirthdayDialog(),
      );

      // stop
      success_controller_1.stop();
      success_controller_2.stop();
      player_1.stop();
      player_2.stop();
      pause_page = false;

      // sign in after 3 mins
      Future.delayed(Duration(seconds: 3), () {
        if (!pause_page && mounted) check_in_out();
      });
    }
  }

  // get last activity
  String get_last_activity(Map<String, dynamic> lst_act) {
    if (lst_act.isEmpty) return '';

    if (lst_act['date_time'] == 'absent') {
      return 'You failed to sign out the last time';
    }

    if (lst_act['date_time'] == null) {
      return '';
    }

    DateTime dt = DateTime.parse(lst_act['date_time']);
    duration = lst_act['duration'];

    int prv_day = dt.day;
    int prv_mont = dt.month;
    int prv_year = dt.year;

    int tod_day = DateTime.now().day;
    int tod_mont = DateTime.now().month;
    int tod_year = DateTime.now().year;

    Duration diff = DateTime.now().difference(dt);

    int days = diff.inDays;

    String tim = '';

    if (duration == '') {
      int hr = diff.inHours - (diff.inDays * 24);
      int mn = diff.inMinutes;

      if (hr < 1) {
        duration = '$mn Mins';
      } else if (hr == 1) {
        duration = '$hr Hour';
      } else {
        duration = '$hr Hours';
      }
    }

    int day_s = tod_day - prv_day;

    if (tod_mont == prv_mont && tod_year == prv_year) {
      if (day_s < 1) {
        tim = 'Today -- $duration';
      } else if (day_s < 2) {
        tim = 'Yesterday -- $duration';
      } else {
        tim = '$day_s days ago -- $duration';
      }
    } else {
      if (days < 2) {
        tim = 'Yesterday -- $duration';
      } else if (days < 121) {
        tim = '$days days ago -- $duration';
      } else {
        tim = 'A long time ago';
      }
    }

    return tim;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.75;
    double height = MediaQuery.of(context).size.height * 0.85;
    return Scaffold(
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'images/attendance_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // background cover box
          Positioned.fill(
            child: Container(
              decoration:
                  BoxDecoration(color: Color(0xFF202020).withOpacity(0.20)),
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
                      child: Image.asset(
                        'images/gym_sign_in.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF202020).withOpacity(0.69),
                        ),
                      ),
                    ),

                    // main content
                    Column(
                      children: [
                        // top
                        top_bar(),

                        // SizedBox(height: 10),

                        main_page(),
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
    return Stack(
      children: [
        // main box
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              // quote box
              Expanded(
                flex: 5,
                child: quote_box(),
              ),

              // client details
              Expanded(
                flex: 5,
                child: profile_area(),
              ),
            ],
          ),
        ),

        // time
        Positioned(
          top: 15,
          left: 20,
          child: Container(
            width: 130,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromARGB(255, 145, 96, 24).withOpacity(0.6),
            ),
            child: Center(
              child: Text(
                DateFormat.jm().format(DateTime.now()),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ),

        // confetti
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConfettiWidget(
                  confettiController: success_controller_1,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: true,
                  numberOfParticles: 40,
                  gravity: 0.4,
                  emissionFrequency: 0.08,
                ),
                SizedBox(width: 600),
                ConfettiWidget(
                  confettiController: success_controller_2,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: true,
                  numberOfParticles: 40,
                  gravity: 0.4,
                  emissionFrequency: 0.08,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // top bar
  Widget top_bar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // id & subscription
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // client id
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

                      // client id
                      Text(
                        widget.client.id,
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

                  SizedBox(width: 6),

                  // subscription plan
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(0xFF3C58E6).withOpacity(0.67),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Image.asset(
                          'images/icon/map-gym.png',
                          width: 11,
                          height: 11,
                        ),
                        SizedBox(width: 2),
                        Text(
                          widget.client.sub_plan,
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3),

              // extras
              Row(
                children: [
                  // boxing
                  if (widget.client.boxing)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color:
                            Color.fromARGB(255, 55, 103, 135).withOpacity(0.7),
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
                  if (widget.client.pt_status)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Color(0xFF5a5a5a).withOpacity(0.7),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: EdgeInsets.only(top: 2, left: 8),
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
                            'PT - ${widget.client.pt_plan}',
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
                ],
              ),
            ],
          ),

          Expanded(child: Container()),

          SizedBox(width: 10),

          // close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.all(0),
            icon: Icon(
              Icons.cancel,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // quote box
  Widget quote_box() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Color(0xFF414141).withOpacity(0.71),
          ),
          child: Stack(
            children: [
              // text
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: '...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 26,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0xFF000000),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      children: [
                        // main text
                        TextSpan(
                          text: birth_day
                              ? 'HAPPY BIRTHDAY'
                              : Helpers.generate_quote_text(),
                        ),
                        TextSpan(text: '...'),
                      ],
                    ),
                  ),
                ),
              ),

              // quote left
              Positioned(
                top: 0,
                left: 0,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Image.asset(
                    'images/icon/quote-left.png',
                    width: 20.8,
                    height: 18.6,
                  ),
                ),
              ),

              // quote right
              Positioned(
                bottom: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Image.asset(
                    'images/icon/quote-right.png',
                    width: 20.8,
                    height: 18.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // profile area
  Widget profile_area() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          SizedBox(height: 10),

          // profile details
          profile_details(),

          SizedBox(height: 30),

          // activity box
          Align(
            alignment: Alignment.centerLeft,
            child: activity_box(),
          ),

          SizedBox(height: 50),

          // sign in box
          check_in_out_box(),
        ],
      ),
    );
  }

  // profile details
  Widget profile_details() {
    return Column(
      children: [
        // profile image
        CircleAvatar(
          radius: 65,
          backgroundColor: Color(0xFFF3DADA).withOpacity(0.8),
          foregroundColor: Colors.white,
          backgroundImage: widget.client.user_image.isEmpty
              ? null
              : NetworkImage(
                  widget.client.user_image,
                ),
          child: (widget.client.user_image.isEmpty)
              ? Center(
                  child: Image.asset(
                    'images/icon/user-alt.png',
                    width: 73,
                    height: 73,
                  ),
                )
              : Container(),
        ),

        SizedBox(height: 6),

        // profile name
        Text(
          widget.client.name,
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

        // status box
        Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Color(widget.client.sub_status ? 0xFF88ECA9 : 0xFFFF5252)
                .withOpacity(0.67),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle,
                  color:
                      Color(widget.client.sub_status ? 0xFF19F763 : 0xFFFF5252),
                  size: 8),
              SizedBox(width: 4),
              Text(
                widget.client.sub_status ? 'Active' : 'Inactive',
                style: TextStyle(fontSize: 14, height: 1, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget activity_box() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(26),
          ),
          color: Color(0xFF403C3C).withOpacity(0.78),
        ),
        padding: EdgeInsets.symmetric(horizontal: 23, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            Text(
              'Last Activity',
              style: TextStyle(
                color: Color(0xFFAFAFAF),
                fontStyle: FontStyle.italic,
                fontSize: 12,
                height: 1,
              ),
            ),

            SizedBox(height: 7),

            // main text
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                last_activity,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),

            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  bool in_out = true;

  // check in/out
  Widget check_in_out_box() {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: !in_out
            ? Color.fromARGB(255, 105, 64, 6)
            : can_sign_in
                ? bx_only
                    ? Colors.deepPurple
                    : Colors.blue
                : hmo_days_done
                    ? Colors.grey
                    : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Center(
        child: Text(
          !in_out
              ? 'GOODBYE'
              : can_sign_in
                  ? bx_only
                      ? '...only BOXING'
                      : 'OPEN TO GYM'
                  : hmo_days_done
                      ? 'Activity for this week Completed'
                      : 'CANNOT ACCESS GYM',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // FUNCTION
  //check in/out
  void check_in_out() {
    var cl_key = widget.client.key;

    // mark attendance
    GymDatabaseHelpers.mark_attendance(
      in_out,
      cl_key,
      widget.client.last_activity['date_time'] ?? '',
      duration: duration,
      cl: widget.client,
    );

    // increase days checked in for hmo plan clients
    if (in_out && widget.client.sub_plan == 'HMO Plan') {
      int new_d = widget.client.days_in + 1;
      GymDatabaseHelpers.update_client_details(cl_key, {'days_in': new_d});
    }

    // resume sub if paused
    if (in_out && widget.client.sub_paused) {
      String ned = widget.client.sub_date;
      Map<String, dynamic> nt = {'sub_paused': false};

      // sub plan
      if (widget.client.sub_status && widget.client.sub_date.isNotEmpty) {
        int sub_rem_days = getDate(widget.client.sub_date)
            .difference(getDate(widget.client.paused_date))
            .inDays;

        ned = DateFormat('dd/MM/yyyy')
            .format(DateTime.now().add(Duration(days: sub_rem_days)));

        nt.addAll({'sub_date': ned});
      }

      // boxing plan
      if (widget.client.boxing && widget.client.bx_date.isNotEmpty) {
        int sub_rem_days = getDate(widget.client.bx_date)
            .difference(getDate(widget.client.paused_date))
            .inDays;

        String ned = DateFormat('dd/MM/yyyy')
            .format(DateTime.now().add(Duration(days: sub_rem_days)));

        nt.addAll({'bx_date': ned});
      }

      // pt plan
      if (widget.client.pt_status && widget.client.pt_date.isNotEmpty) {
        int sub_rem_days = getDate(widget.client.pt_date)
            .difference(getDate(widget.client.paused_date))
            .inDays;

        String ned = DateFormat('dd/MM/yyyy')
            .format(DateTime.now().add(Duration(days: sub_rem_days)));

        nt.addAll({'pt_date': ned});
      }

      // update user
      GymDatabaseHelpers.update_client_details(cl_key, nt);

      Sub_History_Model subhist = Sub_History_Model(
        key: '',
        sub_plan: widget.client.sub_plan,
        sub_type: widget.client.sub_type,
        sub_date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        exp_date: ned,
        amount: 0,
        boxing: widget.client.boxing,
        pt_status: widget.client.pt_status,
        pt_plan: '',
        hist_type: 'Subscription Resumed',
        history_id: Helpers.generate_order_id(),
      );

      GymDatabaseHelpers.add_to_sub_history(
          widget.client.key, subhist.toJson());
    }

    // remove sign in page
    Navigator.pop(context);

    // go to welcome/goodbye page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WpGp(
          wp: in_out,
          client: widget.client,
          time_in: widget.client.last_activity['date_time'] ?? '',
        ),
      ),
    );
  }

  //
}

class BirthdayDialog extends StatefulWidget {
  const BirthdayDialog({super.key});

  @override
  State<BirthdayDialog> createState() => _BirthdayDialogState();
}

class _BirthdayDialogState extends State<BirthdayDialog> {
  @override
  void initState() {
    // close page after 30 secs
    Future.delayed(Duration(seconds: 30), () {
      if (mounted) Navigator.pop(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              // birthday image
              Container(
                width: 400,
                height: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color.fromARGB(158, 237, 67, 124),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/birthday_1.jpg',
                    width: 400,
                    height: 360,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // close button
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Color.fromARGB(238, 237, 67, 124),
                      ),
                      height: 40,
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.celebration_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'THANK YOU',
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
