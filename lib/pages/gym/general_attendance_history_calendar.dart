import 'package:flutter/material.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/pages/gym/daily_attendance_list.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:month_year_picker2/month_year_picker2.dart';
import 'package:table_calendar/table_calendar.dart';

class GAH_C extends StatefulWidget {
  const GAH_C({super.key});

  @override
  State<GAH_C> createState() => _GAH_CState();
}

class _GAH_CState extends State<GAH_C> {
  // select month
  Future<DateTime?> select_month() async {
    var selected = await showMonthYearPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDay,
      lastDate: lastDay,
    );

    return selected;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.6;
    double height = MediaQuery.of(context).size.height * 0.8;
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
                          'images/att_2.jpeg',
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

  // Text controller
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  bool search_on = false;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime firstDay = DateTime(2022);
  DateTime lastDay = DateTime.now();

  bool maxMonth = true;
  bool minMonth = false;

  // WIDGETs

  // main page
  Widget main_page() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          // top bar
          topBar(),

          // calendar table
          Expanded(child: Center(child: calendar_table())),
        ],
      ),
    );
  }

  // top bar
  Widget topBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFd1cfcf)),
        ),
      ),
      child: Stack(
        children: [
          // action buttons
          Row(
            children: [
              // close button
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              Expanded(child: Container()),

              // go back to attendance table
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'images/icon/metro-table.png',
                  width: 28,
                  height: 30,
                ),
              ),
            ],
          ),

          // heading
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'General Attendance',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // calendar
  Widget calendar_table() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TableCalendar(
        firstDay: firstDay,
        lastDay: lastDay,
        focusedDay: _focusedDay,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            letterSpacing: 1.7,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: minMonth ? Color(0xFF928F8F) : Colors.white,
            size: 30,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: maxMonth ? Color(0xFF928F8F) : Colors.white,
            size: 30,
          ),
        ),
        daysOfWeekHeight: 25,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          weekendStyle: TextStyle(color: Colors.redAccent),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          disabledTextStyle: TextStyle(color: Color(0xFF928F8F)),
          weekendTextStyle: TextStyle(color: Colors.redAccent),
          todayDecoration: BoxDecoration(
            color: Color(0xFFF9C55F).withOpacity(0.53),
            shape: BoxShape.circle,
          ),
        ),
        pageJumpingEnabled: true,
        weekendDays: [DateTime.sunday],
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusday) {
            if (day.weekday != DateTime.sunday) {
              var day_int = day.day;

              // day builder eexcept sunday
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // day
                    Text(
                      day_int.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    // attendance count
                    FutureBuilder<int>(
                      future: get_date_count(day),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == 0)
                          return Container();

                        return Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Container(
                            // height: 20,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF3d83e9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                snapshot.data.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return null;
          },
        ),
        onHeaderTapped: (date) async {
          var res = await select_month();
          if (res != null) {
            _focusedDay = res;
            setState(() {});
          }
        },
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          var day = DateFormat('EEEE').format(selectedDay);
          if (day == 'Sunday') return;

          String date = getDateTitle(selectedDay);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DAL_S(
                date: date,
              ),
            ),
          );

          setState(() {
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;

          // first day
          int first_month = firstDay.month;
          int first_year = firstDay.year;

          // last day
          int last_month = lastDay.month;
          int last_year = lastDay.year;

          int month = focusedDay.month;
          int year = focusedDay.year;

          if (last_month == month && last_year == year) {
            maxMonth = true;
          } else {
            maxMonth = false;
          }

          if (first_month == month && first_year == year) {
            minMonth = true;
          } else {
            minMonth = false;
          }

          setState(() {});
        },
      ),
    );
  }

  // FUNCTIONS
  // get date title
  String getDateTitle(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;

    String mon = DateFormat('MMMM').format(DateTime(year, month));

    String title = '$day $mon, $year';
    return title;
  }

  // get date count
  Future<int> get_date_count(DateTime date) async {
    String ttl = getDateTitle(date);

    String month = ttl.substring(2).trim();

    return GymDatabaseHelpers.get_daily_attendance_list(month, ttl)
        .then((snapshot) {
      if (snapshot.value != null) {
        Map val = snapshot.value as Map;

        if (val.isNotEmpty) {
          return val.length;
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    });

    // return 0;
  }

  //
}
