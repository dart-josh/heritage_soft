// personal attendance
class PersonalAttendanceModel {
  String date;
  List<PAH> sessions;

  PersonalAttendanceModel({
    required this.date,
    required this.sessions,
  });

  factory PersonalAttendanceModel.fromMap(Map map) {
    Map sess = map['sessions'];
    List<PAH> list = [];

    sess.forEach((key, value) {
      var ses = PAH.fromMap(key, value);
      list.add(ses);
    });

    return PersonalAttendanceModel(
      date: map['date'],
      sessions: list,
    );
  }
}

// attendance client model
class CAH_Model {
  String key;
  String id;
  String name;
  String sub_plan;

  CAH_Model({
    required this.key,
    required this.id,
    required this.name,
    required this.sub_plan,
  });
}

// personal attendance tile model
class PAH {
  String? session_key;
  String session;
  String time_in;
  String time_out;

  PAH({
    this.session_key,
    required this.session,
    required this.time_in,
    required this.time_out,
  });

  factory PAH.fromMap(String key, Map map) {
    return PAH(
      session_key: key,
      session: map['session'],
      time_in: map['time_in'],
      time_out: map['time_out'],
    );
  }

  Map toJson() => {
        'session': session,
        'time_in': time_in,
        'time_out': time_out,
      };
}

// general attendance tile model
class GATH {
  String date;
  List<PAH> sessions;
  String daily_time_in;
  String daily_time_out;

  GATH({
    required this.date,
    required this.sessions,
    required this.daily_time_in,
    required this.daily_time_out,
  });

  factory GATH.fromMap(Map map) {
    Map sess = map['sessions'];
    List<PAH> list = [];

    sess.forEach((key, value) {
      var ses = PAH.fromMap(key, value);
      list.add(ses);
    });

    return GATH(
      date: map['date'],
      sessions: list,
      daily_time_in: map['daily_time_in'],
      daily_time_out: map['daily_time_out'],
    );
  }
}

// attendance data key model
class At_Date {
  String title;
  int year;
  int month;

  At_Date({
    required this.title,
    required this.year,
    required this.month,
  });
}
