import 'package:flutter/material.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';

// daily attendance list
class DAL extends StatefulWidget {
  final String date;
  final String session;
  const DAL({super.key, required this.date, required this.session});

  @override
  State<DAL> createState() => _DALState();
}

// daily attendance list
class _DALState extends State<DAL> {
  TextStyle headingStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      letterSpacing: 1,
      fontWeight: FontWeight.bold);
  TextStyle tileStyle =
      TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1);
  TextStyle option_style = TextStyle(color: Colors.white, fontSize: 13);
  TextStyle title_style = TextStyle(color: Colors.black, fontSize: 16);
  Future<List<Map>>? cll;

  // Text controller
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  bool search_on = false;
  bool empty_search = false;

  List<Map> flt_cl = [];
  List<Map> all_cl = [];
  List<Map> search_cl = [];

  bool filter_menu_open = false;
  bool filter_on = false;

  bool plan_expanded = false;
  bool plan_filter_on = false;
  String plan_filter_val = '';
  List<String> plan_values = [
    'Daily',
    'Regular',
    'HMO',
    'Clear',
  ];

  bool sub_expanded = false;
  bool sub_filter_on = false;
  String sub_filter_val = '';
  List<String> sub_values = [
    'Registration',
    'Renewal',
    'Clear',
  ];

  @override
  void initState() {
    cll = get_clients(widget.date, session: widget.session);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchNode.dispose();
    super.dispose();
  }

  // filter function
  List<Map> filter_module() {
    if (!filter_on) return all_cl;

    return all_cl
        .where((element) =>
            ((plan_filter_on) ? plan_filter(plan_filter_val, element) : true) &&
            ((sub_filter_on) ? sub_filter(sub_filter_val, element) : true))
        .toList();

    // return main_clients;
  }

  // plan filter
  bool plan_filter(String value, Map element) {
    if (value == 'Daily') {
      return (element['details']['sub_plan'] == 'Daily');
    } else if (value == 'HMO') {
      return (element['details']['sub_plan']
          .toString()
          .toLowerCase()
          .contains('hmo'));
    } else if (value == 'Regular') {
      return (!element['details']['sub_plan']
              .toString()
              .toLowerCase()
              .contains('hmo')) &&
          (element['details']['sub_plan'] != 'Daily');
    } else {
      return false;
    }
  }

  // subscription filter
  bool sub_filter(String value, Map element) {
    if (value == 'Registration') {
      if (element['details']['reg_date'].toString().isNotEmpty)
        return (getDate(element['details']['reg_date']) ==
            DateFormat("d MMMM, yyyy").parse(widget.date));
      else
        return false;
    } else if (value == 'Renewal') {
      if (element['details']['renew_date'].toString().isNotEmpty)
        return (getDate(element['details']['renew_date']) ==
            DateFormat("d MMMM, yyyy").parse(widget.date));
      else
        return false;
    } else {
      return false;
    }
  }

  // get date
  DateTime getDate(String data) {
    var date_data = data.split('/');
    return DateTime(
      int.parse(date_data[2]),
      int.parse(date_data[1]),
      int.parse(date_data[0]),
    );
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
      child: Column(
        children: [
          // top bar
          topBar(),

          // main box
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    // filter area
                    filter_area(),

                    // session title
                    session_title(),

                    // calendar table
                    Expanded(
                      child: history_list(),
                    ),
                  ],
                ),

                //
                Positioned(
                  top: 45,
                  left: 20,
                  child: filter_menu_open ? filter_menu() : Container(),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFd1cfcf)),
        ),
      ),
      child: Stack(
        children: [
          // id area and action buttons
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

              // search field
              search_on
                  ? Container(
                      width: 180,
                      height: 30,
                      padding:
                          EdgeInsets.symmetric(horizontal: search_on ? 0 : 10),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        controller: searchController,
                        focusNode: searchNode,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Enter ID...',
                          hintStyle: TextStyle(
                            color: Color(0xFFc3c3c3),
                            fontSize: 12,
                            letterSpacing: 0.6,
                            fontStyle: FontStyle.italic,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFBCBCBC),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFBCBCBC),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(0, 2, 8, 6),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: Icon(Icons.search,
                                size: 20, color: Color(0xFFdddddd)),
                          ),
                          filled: true,
                          fillColor: Color(0xFFf7f7f7).withOpacity(0.4),
                        ),
                        onChanged: search_clients,
                      ),
                    )
                  : SizedBox(),

              // Search button
              InkWell(
                onTap: () {
                  search_cl.clear();
                  empty_search = false;
                  if (searchController.text.isNotEmpty) {
                    searchController.clear();
                  } else {
                    setState(() {
                      search_on = !search_on;
                    });
                  }

                  if (search_on) {
                    Future.delayed(Duration(milliseconds: 400), () {
                      FocusScope.of(context).requestFocus(searchNode);
                    });
                  }
                },
                child: Icon(
                  search_on ? Icons.close : Icons.search,
                  color: search_on ? Color(0xFFaaaaaa) : Colors.white,
                  size: search_on ? 20 : 25,
                ),
              ),
            ],
          ),

          // heading (date)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${widget.date} -- (${all_cl.length})',
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

  // session title
  Widget session_title() {
    return (widget.session.isNotEmpty)
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFd1cfcf)),
                  ),
                ),
                child: Text(
                  '${widget.session} Session',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.7,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          )
        : Container(height: 20);
  }

  // history list
  Widget history_list() {
    return Container(
      child: Column(
        children: [
          // heading
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFfffcff)),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 50),
                // clients
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: Text('Clients', style: headingStyle),
                  ),
                ),

                // time in
                Expanded(
                  flex: 3,
                  child: Center(child: Text('Time In', style: headingStyle)),
                ),

                // time out
                Expanded(
                  flex: 3,
                  child: Center(child: Text('Time Out', style: headingStyle)),
                ),
              ],
            ),
          ),

          // list
          Expanded(
            child: FutureBuilder<List<Map>>(
                future: cll,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return Center(
                      child: Text(
                        'No Clients came in this ${(widget.session.isEmpty) ? 'day' : widget.session}.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    );

                  all_cl = snapshot.data!;

                  all_cl.forEach((element) async {
                    all_cl[all_cl.indexOf(all_cl
                            .where((ele) => ele['key'] == element['key'])
                            .first)]
                        .addAll({
                      'details': await get_cl_details(element['key']),
                    });
                    if (mounted) setState(() {});
                  });

                  flt_cl = filter_module();

                  return
                      // empty search
                      empty_search
                          ? Center(
                              child: Text(
                                'No Clients found!!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            )

                          // search list
                          : search_cl.isNotEmpty
                              ? ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: search_cl.length,
                                  itemBuilder: (context, index) =>
                                      attendance_tile(
                                          search_cl[index], index, true),
                                )

                              // client list
                              : ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: flt_cl.length,
                                  itemBuilder: (context, index) =>
                                      attendance_tile(
                                          flt_cl[index], index, false),
                                );
                }),
          ),
        ],
      ),
    );
  }

  // attendance tile
  Widget attendance_tile(Map map, int index, bool search) {
    return Container(
      decoration: BoxDecoration(
        color: index.isEven
            ? Color(0xFF696d93).withOpacity(0.59)
            : Color(0xFFb087b3).withOpacity(0.59),
      ),
      child: Row(
        children: [
          // S/N
          Container(
            width: 45,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFd0d0d0))),
            ),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Center(
              child: Text((index + 1).toString(), style: tileStyle),
            ),
          ),

          // name
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              child: map['details'] != null
                  ? Text(map['details']['name'].toString(), style: tileStyle)
                  : Container(),
            ),
          ),

          // time in
          FutureBuilder(
            future: get_att(widget.date, map['val'], session: widget.session),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return Container();

              String time_in = snapshot.data!['time_in'];

              return Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Center(
                    child: Text(time_in, style: tileStyle),
                  ),
                ),
              );
            },
          ),

          // time out
          FutureBuilder(
            future: get_att(widget.date, map['val'], session: widget.session),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return Container();

              String time_out = snapshot.data!['time_out'];

              return Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Center(
                    child: Text(time_out, style: tileStyle),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // filter area
  Widget filter_area() {
    var nt = NumberFormat('#,###');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // filter button
          TextButton(
            onPressed: () {
              setState(() {
                filter_menu_open = !filter_menu_open;
              });
            },
            child: Text(
              filter_menu_open ? 'Close menu' : 'Filter',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),

          SizedBox(width: 10),

          // filter list
          Expanded(
            child: (filter_on)
                ? Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      // type status
                      if (plan_filter_on)
                        Container(
                          decoration: BoxDecoration(
                            color: (plan_filter_val != 'HMO')
                                ? Color.fromARGB(255, 144, 103, 19)
                                : Color.fromARGB(255, 165, 19, 151),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            plan_filter_val,
                            style: option_style,
                          ),
                        ),

                      // sub
                      if (sub_filter_on)
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 144, 103, 19),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            sub_filter_val,
                            style: option_style,
                          ),
                        ),
                    ],
                  )
                : Container(),
          ),

          SizedBox(width: 10),

          // total filter client counts
          if (filter_on)
            Container(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                nt.format(flt_cl.length),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  // fontSize: 14,
                ),
              ),
            ),

          // clear filter
          if (filter_on)
            TextButton(
              onPressed: () {
                setState(() {
                  filter_on = false;
                  filter_menu_open = false;

                  plan_filter_on = false;
                  sub_filter_on = false;
                });
              },
              child: Text('Clear'),
            ),
        ],
      ),
    );
  }

  // filter menu
  Widget filter_menu() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            offset: Offset(0.7, 0.7),
            color: Colors.black26,
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // type
          InkWell(
            onTap: () {
              setState(() {
                plan_expanded = !plan_expanded;
              });
            },
            hoverColor: Colors.grey.shade400,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Package',
                    style: title_style,
                  ),
                  Icon(
                    plan_expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // type options
          if (plan_expanded)
            Container(
              margin: EdgeInsets.only(left: 25, right: 8),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: plan_values
                    .map(
                      (element) => InkWell(
                        onTap: () {
                          if (element == 'Clear') {
                            setState(() {
                              plan_expanded = false;
                              plan_filter_on = false;
                              plan_filter_val = '';
                            });
                          } else {
                            setState(() {
                              plan_filter_val = element;
                              plan_filter_on = true;
                              filter_on = true;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (element == 'Clear')
                                ? Colors.red.shade400
                                : (element != 'HMO')
                                    ? Color.fromARGB(255, 144, 103, 19)
                                    : Color.fromARGB(255, 165, 19, 151),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          child: (element == 'Clear')
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      element,
                                      style: option_style,
                                    ),
                                  ],
                                )
                              : Text(
                                  element,
                                  style: option_style,
                                ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // sub
          InkWell(
            onTap: () {
              setState(() {
                sub_expanded = !sub_expanded;
              });
            },
            hoverColor: Colors.grey.shade400,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscription',
                    style: title_style,
                  ),
                  Icon(
                    sub_expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // sub options
          if (sub_expanded)
            Container(
              margin: EdgeInsets.only(left: 25, right: 8),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: sub_values
                    .map(
                      (element) => InkWell(
                        onTap: () {
                          if (element == 'Clear') {
                            setState(() {
                              sub_expanded = false;
                              sub_filter_on = false;
                              sub_filter_val = '';
                            });
                          } else {
                            setState(() {
                              sub_filter_val = element;
                              sub_filter_on = true;
                              filter_on = true;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (element == 'Clear')
                                ? Colors.red.shade400
                                : Color.fromARGB(255, 144, 103, 19),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          child: (element == 'Clear')
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      element,
                                      style: option_style,
                                    ),
                                  ],
                                )
                              : Text(
                                  element,
                                  style: option_style,
                                ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // Functions

  // get clients with attendance
  Future<List<Map>> get_clients(String date, {String session = ''}) async {
    String month = date.substring(2).trim();

    return GymDatabaseHelpers.get_daily_attendance_list(month, date)
        .then((snap) {
      // if (snap.exists) {
      //   Map val = snap.value as Map;
      //   List<Map> cls = [];

      //   val.forEach((key, value) {
      //     if (session.isEmpty) {
      //       cls.add({
      //         'key': key,
      //         'val': value,
      //       });
      //     } else {
      //       Map vv = value['sessions'];

      //       if (vv.toString().toLowerCase().contains(session.toLowerCase())) {
      //         cls.add({
      //           'key': key,
      //           'val': value,
      //         });
      //       }
      //     }
      //   });

      //   return cls;
      // } else {
      return [];
      // }
    });
  }

  // map out client details
  Future<Map> get_cl_details(String key) async {
    return GymDatabaseHelpers.get_client_details(key).then((snap) {
      // if (snap.exists) {
      //   String fn = snap.data()!['f_name'];
      //   String mn = snap.data()!['m_name'];
      //   String ln = snap.data()!['l_name'];

      //   Map details = {
      //     'name': '$fn $mn $ln',
      //     'sub_plan': snap.data()!['sub_plan'] ?? '',
      //     'reg_date': snap.data()!['reg_date'] ?? '',
      //     'renew_date': snap.data()!['renew_date'] ?? '',
      //   };
      //   return details;
      // } else
      return {};
    });
  }

  // get attendance
  Future<Map> get_att(String date, Map map, {String session = ''}) async {
    if (map.isNotEmpty) {
      // all session
      if (session == '') {
        String time_in = map['daily_time_in'] ?? '';
        String time_out = map['daily_time_out'] ?? '';

        return {
          'time_in': time_in,
          'time_out': time_out,
        };
      }

      // by each session
      else {
        Map sess = map['sessions'];

        String time_in = '';
        String time_out = '';

        sess.forEach((key, value) {
          if (value['session'] == session.toLowerCase()) {
            DateTime? tm_in;
            DateTime? tm_out;
            if (value['time_in'] != null && value['time_in'] != '')
              tm_in = Helpers.time12to24Format(value['time_in']);

            if (value['time_out'] != null && value['time_out'] != '')
              tm_out = Helpers.time12to24Format(value['time_out']);

            if (time_in.isEmpty) {
              time_in = value['time_in'] ?? '';
            } else {
              DateTime prv_time_in = Helpers.time12to24Format(time_in);
              if (tm_in != null) {
                if (tm_in.compareTo(prv_time_in) == -1) {
                  time_in = value['time_in'];
                }
              }
            }

            if (time_out.isEmpty) {
              time_out = value['time_out'] ?? '';
            } else {
              DateTime prv_time_out = Helpers.time12to24Format(time_out);
              if (tm_out != null) {
                if (tm_out.compareTo(prv_time_out) == 1) {
                  time_out = value['time_out'];
                }
              }
            }
          }
        });

        if (time_in.isNotEmpty || time_out.isNotEmpty) {
          return {
            'time_in': time_in,
            'time_out': time_out,
          };
        } else
          return {};
      }
    } else {
      return {};
    }
  }

  // search clients
  search_clients(String value) {
    search_cl.clear();
    empty_search = false;

    if (value.isNotEmpty) {
      var ss = flt_cl
          .where((element) => element['details']['name']
              .toString()
              .trim()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();

      if (ss.isNotEmpty) {
        search_cl = ss;
      } else {
        empty_search = true;
      }
    }

    setState(() {});
  }
  //
}

// daily session selector
class DAL_S extends StatefulWidget {
  final String date;
  const DAL_S({super.key, required this.date});

  @override
  State<DAL_S> createState() => _DAL_SState();
}

// daily session selector
class _DAL_SState extends State<DAL_S> {
  // check date for attendance
  Future<bool> check_date(String date) async {
    String month = date.substring(2).trim();

    return GymDatabaseHelpers.get_daily_attendance_list(month, date)
        .then((snap) {
      // if (snap.exists) {
      //   Map val = snap.value as Map;

      //   if (val.length > 0)
      //     return true;
      //   else
      //     return false;
      // } else {
      return false;
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;
    double height = MediaQuery.of(context).size.height * 0.7;
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

  // WIDGETS
  Widget main_page() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          // top bar
          topBar(),

          // main page
          FutureBuilder<bool>(
            future: check_date(widget.date),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done)
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );

              if (!snapshot.hasData || !snapshot.data!)
                return Expanded(
                  child: Center(
                    child: Text(
                      'No Clients came in today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                );

              return Expanded(child: Center(child: selector()));
            },
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
          // date heading
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(
              child: Text(
                widget.date,
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

          // close button
          Positioned(
            top: 0,
            left: 0,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.cancel,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // selector
  Widget selector() {
    double width = MediaQuery.of(context).size.width * 0.8;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // session selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              selector_tile('Morning'),
              selector_tile('Afternoon'),
              selector_tile('Evening'),
            ],
          ),

          SizedBox(height: 10),

          // all day
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DAL(
                    date: widget.date,
                    session: '',
                  ),
                ),
              );
            },
            child: Container(
              width: width / 1.5,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(.7),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Center(
                child: Text(
                  'All DAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // selector tile
  Widget selector_tile(String title) {
    Color color = Color(0xFF3560c7);
    if (title == 'Morning') {
      color = Color(0xFF3560c7);
    } else if (title == 'Afternoon') {
      color = Color(0xFF35c2c7);
    } else {
      color = Color(0xFF9b35c7);
    }

    return Padding(
      padding: EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DAL(
                date: widget.date,
                session: title,
              ),
            ),
          );
        },
        child: Container(
          width: 200,
          height: 220,
          decoration: BoxDecoration(
            color: color.withOpacity(0.49),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/icon/map-gym-xl.png',
                    width: 70, height: 70),
                SizedBox(height: 15),
                // title
                Text(
                  '$title Session'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //
}
