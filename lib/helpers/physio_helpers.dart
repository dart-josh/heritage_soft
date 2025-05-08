import 'package:intl/intl.dart';

class PhysioHelpers {
  // get duration
  static Duration get_duration(
      {required String treatment_duration, required DateTime start_time}) {
    if (treatment_duration.contains('Mins') &&
        treatment_duration.contains('Hr')) {
      var _lst = treatment_duration
          .replaceAll(' Mins', '')
          .replaceAll(' Hr', '')
          .split(' ');
      int hr = int.parse(_lst[0].trim());
      int min = int.parse(_lst[1].trim());

      DateTime new_t = start_time.add(Duration(hours: hr, minutes: min));

      Duration dur = new_t.difference(DateTime.now()) - (Duration(hours: 1));
      

      return dur;
    } else if (treatment_duration.contains('Mins')) {
      int min = int.parse(treatment_duration.replaceAll('Mins', '').trim());
      DateTime new_t = start_time.add(Duration(minutes: min));
      Duration dur = new_t.difference(DateTime.now()) - (Duration(hours: 1));

      return dur;
    } else if (treatment_duration.contains('Hr')) {
      int hr = int.parse(treatment_duration.replaceAll('Hr', '').trim());
      DateTime new_t = start_time.add(Duration(hours: hr));
      Duration dur = new_t.difference(DateTime.now()) - (Duration(hours: 1));
      
      return dur;
    } else {
      return Duration(minutes: 30);
    }
  }

  // update timer
  static List<String> update_timer(Duration duration) {
    int hr = 0;
    int min = 0;
    int sec = 0;

    if (duration.inMinutes > 59 || duration.inMinutes < -59) {
      hr = duration.inHours;
      min = duration.inMinutes - (hr * 60);
    } else {
      min = duration.inMinutes;
    }

    sec = duration.inSeconds - (duration.inMinutes * 60);

    String hou = (hr.toString().length == 1)
        ? '0$hr'
        : (hr.toString().contains('-') && hr.toString().length == 2)
            ? '${hr.toString().replaceAll('-', '-0')}'
            : '$hr';
    String minn = (min.toString().length == 1)
        ? '0$min'
        : (min.toString().contains('-') && min.toString().length == 2)
            ? '${min.toString().replaceAll('-', '-0')}'
            : '$min';
    String secc = (sec.toString().length == 1)
        ? '0$sec'
        : (sec.toString().contains('-') && sec.toString().length == 2)
            ? '${sec.toString().replaceAll('-', '-0')}'
            : '$sec';

    return [hou, minn, secc];
  }

  // format date
  static String fmt_date(String date) {
    return DateFormat('d MMM, y').format(DateFormat('dd_MM_yyyy').parse(date));
  }

  //
}
