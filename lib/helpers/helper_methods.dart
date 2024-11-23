import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/widgets/enter_password_dialog.dart';
import 'package:heritage_soft/widgets/loadingScreen.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:fl_toast/fl_toast.dart';

class Helpers {
  // show toast
  static void showToast(
      {required BuildContext context,
      required Color color,
      required String toastText,
      required IconData icon}) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            toastText,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );

    showStyledToast(
        backgroundColor: Colors.transparent,
        // margin: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        child: toast,
        context: context,
        duration: Duration(seconds: 2));
  }

  // enter password
  static Future<bool> enter_password(context, {required String title}) async {
    // required password
    var required_password = Provider.of<AppData>(context, listen: false)
        .passwords
        .where((element) => element.title.toLowerCase() == title.toLowerCase())
        .first
        .password;

    // universal password
    var universal = Provider.of<AppData>(context, listen: false)
        .passwords
        .where((element) => element.title.toLowerCase() == 'universal password')
        .first
        .password;

    var conf = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => EnterPasswordDialog(
            required_password: required_password, universal: universal));

    if (conf != null) {
      return conf;
    } else {
      return false;
    }
  }

  // registration date
  static String reg_date_diff(DateTime date) {
    Duration diff = DateTime.now().difference(date);

    int days = diff.inDays;

    var day = date.day;
    var month = DateFormat('MMMM').format(date);
    var year = date.year;

    if (days < 1) {
      return '- Joined today';
    } else if (days < 2) {
      return '- Joined yesterday';
    } else if (days < 30) {
      return '- Joined $days days ago';
    } else {
      return '- Member since $day $month, $year';
    }
  }

  // loading screen
  static void showLoadingScreen(
      {required BuildContext context, bool isDissmissable = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingScreen(),
    );
  }

  // bmi calculation
  static Map<String, String> calc_bmi(double height, double weight) {
    // [weight (kg) / height (cm) / height (cm)] x 10,000

    if (height <= 0 || weight <= 0) return {};

    double bmi = (weight / height / height) * 10000;

    String bmi_fig = bmi.toStringAsFixed(2);
    String bmi_class = '';

    if (bmi < 18.5) {
      bmi_class = 'Underweight';
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      bmi_class = 'Normal';
    } else if (bmi >= 25 && bmi <= 29.9) {
      bmi_class = 'Overweight';
    } else if (bmi >= 30) {
      bmi_class = 'Obese';
    }

    return {
      'bmi_class': bmi_class,
      'bmi_fig': bmi_fig,
    };
  }

  // select image from file
  static Future<Uint8List?> selectFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      Uint8List file = result.files.single.bytes!;

      return file;
    } else {
      return null;
    }
  }

  // generate client id
  static String generate_id(String xx, bool hmo) {
    // prefix
    String prx = (xx == 'gym')
        ? 'HFC'
        : (xx == 'phy')
            ? 'HPC'
            : (xx == 'stf')
                ? 'DHI'
                : '';

    // suffix
    String sfx = (hmo)
        ? 'HM'
        : (xx == 'gym')
            ? 'FT'
            : (xx == 'phy')
                ? 'PT'
                : (xx == 'stf')
                    ? 'ST'
                    : '';

    if (prx.isEmpty || sfx.isEmpty) return '';

    int last_id = 0;

    if (xx == 'gym') {
      last_id = last_ft_id;
    } else if (xx == 'phy') {
      last_id = last_pt_id;
    } else if (xx == 'stf') {
      last_id = last_st_id;
    }

    last_id++;

    String middle4Digits = '';

    if (last_id.toString().length == 1) {
      middle4Digits = '000$last_id';
    } else if (last_id.toString().length == 2) {
      middle4Digits = '00$last_id';
    } else if (last_id.toString().length == 3) {
      middle4Digits = '0$last_id';
    } else if (last_id.toString().length >= 4) {
      middle4Digits = '$last_id';
    } else {}

    return '$prx-$middle4Digits-$sfx';
  }

  // strip id
  static int strip_id(String id) {
    var ft = id
        .replaceAll('HFC', '')
        .replaceAll('HPC', '')
        .replaceAll('DHI', '')
        .replaceAll('FT', '')
        .replaceAll('PT', '')
        .replaceAll('ST', '')
        .replaceAll('HM', '')
        .replaceAll('-', '');

    return int.parse(ft);
  }

  // generate order id
  static String generate_order_id() {
    var digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String middle4Digits = '';

    for (int i = 0; i < 4; i++) {
      middle4Digits += digits[Random.secure().nextInt(digits.length)];
    }

    String id =
        '$middle4Digits${DateTime.now().microsecondsSinceEpoch.toString()}';

    return id;
  }

  // generate quote text for sign in
  static String generate_quote_text() {
    List<String> qts = [
      'Aim Stronger\nand\nwork Harder',
      'When the pain is much\ndon\'t stop\nKeep Pushing',
      'Go Hard\nor\nGo Home',
      'Work it\nand\nEnjoy it',
      'To have a strong body\nmuch work is required',
    ];
    int rand = Random().nextInt(qts.length);
    String quote = qts[rand];

    return quote;
  }

  // convert time from 12 to 24 hour
  static DateTime time12to24Format(String time) {
    int h = int.parse(time.split(":").first);
    int m = int.parse(time.split(":").last.split(" ").first);
    String meridium = time.split(":").last.split(" ").last.toLowerCase();
    if (meridium == "pm") {
      if (h != 12) {
        h = h + 12;
      }
    }
    if (meridium == "am") {
      if (h == 12) {
        h = 00;
      }
    }

    DateTime tod = DateTime.now();

    return DateTime(tod.year, tod.month, tod.day, h, m);
  }

  // format datetime to string
  static String date_format(DateTime time, {bool same_year = false}) {
    return !same_year
        ? DateFormat('E d MMM, y').format(time)
        : DateFormat('E d MMM').format(time);
  }

  // format string to datetime
  static DateTime reverse_date_format(String time, {bool same_year = false}) {
    return !same_year
        ? DateFormat('E d MMM, y').parse(time)
        : DateFormat('E d MMM').parse(time);
  }

  // format amount
  static String format_amount(int value, {bool naira = false}) => naira
      ? '₦${NumberFormat('#,###.##').format(value)}'
      : NumberFormat('#,###.##').format(value);

  // get date from string
  static DateTime getDate(String data) {
    var date_data = data.split('/');
    return DateTime(
      int.parse(date_data[2]),
      int.parse(date_data[1]),
      int.parse(date_data[0]),
    );
  }

  // format date
  static String fmt_date(String date) {
    return DateFormat('d MMM, y').format(DateFormat('dd_MM_yyyy').parse(date));
  }
  
  //
}
