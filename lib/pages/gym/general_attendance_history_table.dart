import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:data_table_2/data_table_2.dart';
import 'package:heritage_soft/datamodels/attendance_model.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/gym/clients_attendance_history.dart';
import 'package:heritage_soft/pages/gym/general_attendance_history_calendar.dart';
import 'package:heritage_soft/pages/gym/personal_daily_attendance.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker2/month_year_picker2.dart';

class GAH_T extends StatefulWidget {
  const GAH_T({super.key});

  @override
  State<GAH_T> createState() => _GAH_TState();
}

class _GAH_TState extends State<GAH_T> {
  At_Date? active_month;

  // Text controller
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  List<UserM> clients = [];

  List<UserM> search_list = [];
  bool emptySearch = false;
  bool search_on = false;

  bool maxMonth = true;
  bool minMonth = false;

  DateTime firstDay = DateTime(2010);
  DateTime lastDay = DateTime.now();

  bool isLoading = false;

  @override
  void initState() {
    set_active_month();
    get_clients();
    super.initState();
  }

  @override
  void dispose() {
    searchNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  // months selector => active month
  set_active_month() {
    DateTime today = DateTime.now();

    int month = today.month;
    int year = today.year;

    String title = DateFormat('MMMM').format(today);

    At_Date newDate = At_Date(title: '$title, $year', year: year, month: month);

    active_month = newDate;
    setState(() {});
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
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.9;
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

  // WIDGETs

  // main page
  Widget main_page() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: active_month != null
          ? Column(
              children: [
                // top bar
                topBar(),

                // month selector
                month_selector(),

                SizedBox(height: 20),

                // calendar table
                Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : calendar_table()),
              ],
            )
          : Column(
              children: [
                // top bar
                topBar(),

                // calendar table
                Expanded(
                  child: Center(
                    child: Text(
                      'No active Month!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
          // action buttons & search field
          Row(
            children: [
              // close button
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              Expanded(child: Container()),

              // serach field
              Container(
                width: 230,
                height: 33,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                  onChanged: search_clients,
                  controller: searchController,
                  focusNode: searchNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF3c3c3c),
                    hintText: 'Search client...',
                    hintStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFBCBCBC),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFBCBCBC),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(0, 6, 8, 6),
                    suffixIcon: searchController.text.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              emptySearch = false;
                              search_list.clear();
                              searchController.clear();

                              setState(() {});
                            },
                            child: Icon(
                              Icons.clear,
                              size: 16,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),

              // calendar button
              InkWell(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GAH_C()),
                  );
                },
                child: Image.asset(
                  'images/icon/awesome-calendar.png',
                  width: 26,
                  height: 28,
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

  // check month
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

  // month selector
  Widget month_selector() {
    check_month();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: Row(
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
      ),
    );
  }

  // calendar table
  Widget calendar_table() {
    return
        // no client found
        emptySearch
            ? Center(
                child: Text(
                  'No Client Found!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )

            // calendar
            : Container(
                child: DataTable2(
                  columnSpacing: 0,
                  horizontalMargin: 0,
                  fixedLeftColumns: 1,
                  dataTextStyle: TextStyle(color: Colors.white),
                  headingTextStyle: TextStyle(color: Colors.white),
                  headingRowHeight: 40,
                  dataRowHeight: 35,
                  columns: get_days_in_month(
                      active_month!.year, active_month!.month),
                  rows:
                      // search llist
                      search_list.isNotEmpty
                          ? search_list.map((e) {
                              int index = search_list.indexOf(e);

                              return DataRow(
                                cells: fill_in_days(active_month!.year,
                                    active_month!.month, index.isEven, e),
                              );
                            }).toList()

                          // client list
                          : clients.map((e) {
                              int index = clients.indexOf(e);

                              return DataRow(
                                cells: fill_in_days(active_month!.year,
                                    active_month!.month, index.isEven, e),
                              );
                            }).toList(),
                ),
              );
  }

  // FUNCTIONS

  // heading => get days in month
  List<DataColumn> get_days_in_month(int year, int month) {
    int ty = DateUtils.getDaysInMonth(year, month);

    List<DataColumn> cols = [];

    // clients
    DataColumn head = DataColumn2(
      label: Container(
        height: 40,
        width: 250,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white),
            right: BorderSide(color: Colors.white),
          ),
        ),
        child: Center(
            child: Text(
          'Clients',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
      size: ColumnSize.L,
      fixedWidth: 250,
    );

    cols.add(head);

    // days
    for (var i = 1; i <= ty; i++) {
      DataColumn item = DataColumn2(
        label: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.white),
              bottom: BorderSide(color: Colors.white),
            ),
          ),
          child: Center(
              child: Text(
            (i.toString().length < 2) ? '0$i' : '$i',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ),
        fixedWidth: 40,
      );

      cols.add(item);
    }

    return cols;
  }

  // attendance history => generate data cell
  List<DataCell> fill_in_days(int year, int month, bool isEven, UserM cl) {
    int ty = DateUtils.getDaysInMonth(year, month);

    List<DataCell> cols = [];

    // clients names
    DataCell name = DataCell(
      Container(
        width: 250,
        height: 35,
        decoration: BoxDecoration(
          color: isEven
              ? Color(0xFF646464).withOpacity(0.53)
              : Color(0xFFb1b3ca).withOpacity(0.53),
          border: Border(
            right: BorderSide(color: Colors.white),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                var client = CAH_Model(
                  key: cl.key,
                  id: cl.id,
                  name: cl.f_name,
                  sub_plan: cl.sub_plan,
                );

                // go to client attendance history
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CAH(
                      month: active_month!,
                      client: client,
                    ),
                  ),
                );
              },
              child: Text(
                cl.fullname,
                style: TextStyle(),
              ),
            ),
          ),
        ),
      ),
    );

    cols.add(name);

    // days attendance
    for (var i = 1; i <= ty; i++) {
      var date = DateTime(year, month, i);
      var tt = DateFormat('EEEE').format(date);

      int tod_dy = DateTime.now().day;
      int tod_yr = DateTime.now().year;
      int tod_mn = DateTime.now().month;

      bool not_yet = false;

      if (year == tod_yr && month == tod_mn) {
        not_yet = (i > tod_dy);
      }

      if (tt == 'Sunday') not_yet = true;

      DataCell data = DataCell(
        Container(
          height: 35,
          width: 40,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.white),
            ),
            color: isEven
                ? Color(0xFF646464).withOpacity(0.53)
                : Color(0xFFb1b3ca).withOpacity(0.53),
          ),
          child: Container(
            child: not_yet
                ? null
                : FutureBuilder<bool>(
                    future: get_attendance(cl.key, i),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.connectionState == ConnectionState.waiting)
                        return Container();

                      bool ext = snapshot.data!;

                      return InkWell(
                        onTap: () {
                          if (!ext) {
                            Helpers.showToast(
                              context: context,
                              color: Colors.redAccent,
                              toastText: 'No attendance for this date',
                              icon: Icons.error,
                            );
                            return;
                          }

                          UserPDA cl_pda = UserPDA(
                            key: cl.key,
                            id: cl.id,
                            f_name: cl.f_name,
                            sub_plan: cl.sub_plan,
                          );

                          String date = '$i ${active_month!.title}';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDA(
                                client: cl_pda,
                                date: date,
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          ext ? Icons.check_circle : Icons.remove_circle,
                          color: ext ? Colors.greenAccent : Colors.redAccent,
                          size: 20,
                        ),
                      );
                    }),
          ),
        ),
      );

      cols.add(data);
    }

    return cols;
  }

  // get client details
  get_clients() async {
    var data = await GymDatabaseHelpers.ft_client_ref.get();

    clients.clear();

    data.docs.forEach((element) {
      String name =
          '${element.data()['f_name']} ${element.data()['m_name']} ${element.data()['l_name']}';

      UserM cl = UserM(
        key: element.id,
        id: element.data()['id'],
        fullname: name,
        f_name: element.data()['f_name'],
        sub_plan: element.data()['sub_plan'],
      );

      clients.add(cl);
      if (mounted) setState(() {});
    });
  }

  // get each day attendance
  Future<bool> get_attendance(String key, int day) async {
    String date = '$day ${active_month!.title}';

    String att_key = '${key}/${active_month!.title}/${date}';
    return GymDatabaseHelpers.get_client_personal_attendance_by_key(att_key)
        .then((snapshot) {
      if (snapshot.exists)
        return true;
      else
        return false;
    });
  }

  // search client
  search_clients(String value) {
    search_list.clear();
    emptySearch = false;

    if (value.isNotEmpty) {
      var sl_cl = clients
          .where((element) => element.fullname
              .toLowerCase()
              .contains(value.toLowerCase().trim()))
          .toList();

      if (sl_cl.isNotEmpty) {
        search_list = sl_cl;
      } else {
        emptySearch = true;
      }
    }

    setState(() {});
  }
  //
}

class UserM {
  String key;
  String id;
  String fullname;
  String f_name;
  String sub_plan;

  UserM({
    required this.key,
    required this.id,
    required this.fullname,
    required this.f_name,
    required this.sub_plan,
  });
}
