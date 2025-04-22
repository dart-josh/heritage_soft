import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/attendance_model.dart';
import 'package:heritage_soft/datamodels/guest_model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker2/month_year_picker2.dart';

class GuestRecord extends StatefulWidget {
  const GuestRecord({super.key});

  @override
  State<GuestRecord> createState() => _GuestRecordState();
}

class _GuestRecordState extends State<GuestRecord> {
  int _index = 0;

  At_Date? active_month;

  bool isLoading = false;

  List<GuestRecordModel> active_list = [];

  List<GuestModel> gym_record = [];
  List<GuestModel> physio_record = [];
  List<GuestModel> spa_record = [];

  List<GuestModel> active_record = [];
  String active_date = '';

  bool maxMonth = true;
  bool minMonth = false;

  DateTime firstDay = DateTime(2010);
  DateTime lastDay = DateTime.now();

  @override
  void initState() {
    active_month = get_current_month();
    load_data();

    super.initState();
  }

  At_Date get_current_month() {
    String title = DateFormat('MMMM').format(DateTime.now());

    int year = DateTime.now().year;
    int month = DateTime.now().month;

    return At_Date(title: '$title, $year', year: year, month: month);
  }

  change_month(bool prev) {
    if (isLoading) return;

    int active_mont = active_month!.month;
    int active_year = active_month!.year;

    int new_month = active_mont;
    int new_year = active_year;

    // previous
    if (prev) {
      if (minMonth) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Max History reached',
          icon: Icons.warning_rounded,
        );

        return;
      } else {
        new_month = active_mont - 1;

        if (new_month == 0) {
          new_year = active_year - 1;
          new_month = 12;
        }
      }
    }
    // next
    else {
      if (maxMonth) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'No further history yet',
          icon: Icons.warning_rounded,
        );
        return;
      } else {
        new_month = active_mont + 1;

        if (new_month == 13) {
          new_year = active_year + 1;
          new_month = 1;
        }
      }
    }

    String title = DateFormat('MMMM').format(DateTime(new_year, new_month));

    At_Date newDate =
        At_Date(title: '$title, $new_year', year: new_year, month: new_month);

    // first day
    int first_month = firstDay.month;
    int first_year = firstDay.year;

    // last day
    int last_month = lastDay.month;
    int last_year = lastDay.year;

    if (newDate.year > last_year ||
        (newDate.year == last_year && newDate.month > last_month)) return;

    if (newDate.year < first_year ||
        (newDate.year == last_year && newDate.month < first_month)) return;

    setState(() {
      active_month = newDate;
    });

    load_data();
  }

  // select month
  select_month() async {
    var selected = await showMonthYearPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDay,
      lastDate: lastDay,
    );

    if (selected != null) {
      int month = selected.month;
      int year = selected.year;

      String title = DateFormat('MMMM').format(selected);

      At_Date newDate =
          At_Date(title: '$title, $year', year: year, month: month);

      active_month = newDate;
      setState(() {});

      load_data();
    }
  }

  load_data() async {
    isLoading = true;
    active_list.clear();
    active_record.clear();
    active_date = '';

    await AdminDatabaseHelpers.get_visitors_record(active_month!.title)
        .then((snapshot) {
      // if (snapshot.value != null) {
      //   Map map = snapshot.value as Map;

      //   if (map.isNotEmpty) {
      //     map.forEach((key, value) {
      //       Map map_2 = value as Map;
      //       List<GuestModel> guests = [];

      //       map_2.forEach((key_2, value_2) {
      //         guests.add(GuestModel.fromMap(key_2, value_2));
      //       });

      //       active_list.add(GuestRecordModel(date: key, record: guests));
      //     });
      //   }
      // }
    });

    isLoading = false;

    setState(() {});
  }

  split_record() {
    gym_record = active_record
        .where((element) => element.facility.toLowerCase() == 'gym')
        .toList();

    physio_record = active_record
        .where((element) => element.facility.toLowerCase() == 'physio')
        .toList();

    spa_record = active_record
        .where((element) => element.facility.toLowerCase() == 'spa')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    split_record();
    return DefaultTabController(
      length: 4,
      initialIndex: _index,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 2, 20, 35),
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 2, 20, 35),
          // bottom: ,
          title: Text('Visitors List'),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                date_selector(),
                SizedBox(height: 10),

                // tab headers
                TabBar(
                  tabs: [
                    Tab(text: 'All Vistors'),
                    Tab(text: 'Gym Vistors'),
                    Tab(text: 'Physio Vistors'),
                    Tab(text: 'Spa Vistors'),
                  ],
                ),

                SizedBox(height: 10),

                // yabs
                Expanded(
                  child: TabBarView(
                    children: [
                      record_list(active_record),
                      record_list(gym_record),
                      record_list(physio_record),
                      record_list(spa_record),
                    ],
                  ),
                ),
              ],
            ),

            // loading
            isLoading
                ? Positioned.fill(
                    child: Container(
                      color: const Color.fromARGB(25, 0, 0, 0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  // WIDGETS

  check_month() {
    // first day
    int first_month = firstDay.month;
    int first_year = firstDay.year;

    // last day
    int last_month = lastDay.month;
    int last_year = lastDay.year;

    int month = active_month!.month;
    int year = active_month!.year;

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
  }

  // month & date selector
  Widget date_selector() {
    active_list.sort((a, b) =>
        Helpers.reverse_date_format(b.date, same_year: (b.date.length < 12))
            .compareTo(Helpers.reverse_date_format(a.date,
                same_year: (a.date.length < 12))));

    check_month();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      child: Center(
        child: Column(
          children: [
            // month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // previous button
                InkWell(
                  onTap: () {
                    change_month(true);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: minMonth ? Color(0xFF928F8F) : Colors.white,
                    size: 25,
                  ),
                ),

                SizedBox(width: 50),

                // month
                Container(
                  width: 200,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        select_month();
                      },
                      child: Text(
                        active_month!.title,
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.7,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 50),

                // next button
                InkWell(
                  onTap: () {
                    change_month(false);
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: maxMonth ? Color(0xFF928F8F) : Colors.white,
                    size: 25,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            // date selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: active_list.map((e) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () {
                        active_record = e.record;
                        active_date = e.date;
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              active_date == e.date ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        margin:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        child: Text(
                          e.date,
                          style: TextStyle(
                            color: active_date == e.date
                                ? Colors.white
                                : Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            //
          ],
        ),
      ),
    );
  }

  // record list
  Widget record_list(List<GuestModel> record) {
    int total_record = record.length;
    active_record.sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

    return Container(
      child:
          // empty list
          record.isEmpty
              ? Center(
                  child: Text(
                    'No visitors',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )

              // list & details
              : Column(
                  children: [
                    // list
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: record.map((e) {
                            int index = record.indexOf(e) + 1;
                            return record_tile(e, index);
                          }).toList(),
                        ),
                      ),
                    ),

                    // total visitors
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // label
                          Text(
                            'Total visitors:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),

                          SizedBox(width: 10),

                          // value
                          Text(
                            Helpers.format_amount(total_record),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  // record tile
  Widget record_tile(GuestModel record, int index) {
    // record id
    Widget id = Text(
      index.toString(),
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    // time
    Widget time = Text(
      DateFormat.jm().format(DateTime.parse(record.date)),
      style: TextStyle(
        color: Colors.white,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    // name & visit purpose
    Widget name_purpose = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // name
        Text(
          record.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),

        SizedBox(height: 3),

        // purpose of visit
        Row(
          children: [
            Text(
              'Purpose of Visit:',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            SizedBox(width: 4),
            Text(
              record.purpose,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );

    // facility
    Widget facility = Text(
      record.facility.toUpperCase(),
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );

    //

    // main
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(96, 45, 70, 94),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      width: double.infinity,
      child: Row(
        children: [
          // record id
          id,

          SizedBox(width: 25),

          // name & visit purpose
          Expanded(child: name_purpose),

          SizedBox(width: 20),

          // facility
          facility,

          SizedBox(width: 40),

          // time & details
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // time
              time,

              SizedBox(height: 5),

              // view details
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => GuestDetailsDialog(record: record),
                  );
                },
                child: Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  //
}

class GuestDetailsDialog extends StatelessWidget {
  final GuestModel record;
  const GuestDetailsDialog({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top bar
          Stack(
            children: [
              // heading
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                height: 40,
                width: 320,
                child: Center(
                  child: Text(
                    'Visitor\'s details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // close button
              Positioned(
                top: 0,
                right: 6,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 5),

          // details
          Container(
            decoration: BoxDecoration(),
            width: 300,
            height: 400,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(179, 29, 24, 8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    // name
                    tile('FULLNAME', record.name),

                    // phone
                    tile('PHONE', record.phone),

                    // address
                    tile('ADDRESS', record.address),

                    // purpose
                    tile('Purpose of Visit', record.purpose),

                    // facility
                    tile('Facility', record.facility),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // detail tile
  Widget tile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),

          SizedBox(height: 4),

          // value
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white38),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )),
        ],
      ),
    );
  }
}
