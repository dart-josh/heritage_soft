import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/pages/gym/print.page.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';

class SubHistoryPage extends StatefulWidget {
  final Sub_CL_Model client;
  const SubHistoryPage({super.key, required this.client});

  @override
  State<SubHistoryPage> createState() => _SubHistoryPageState();
}

class _SubHistoryPageState extends State<SubHistoryPage> {
  Sub_CL_Model? client;
  List<Sub_History_Model> active_record = [];
  List<GroupedSubHistory> sub_history = [];

  bool isLoading = false;

  int active_year = DateTime.now().year;

  bool maxYear = true;
  bool minYear = false;

  DateTime firstDay = DateTime(2020);
  DateTime lastDay = DateTime.now();

  @override
  void initState() {
    client = widget.client;
    load_data();

    super.initState();
  }

  // get all history
  load_data() async {
    isLoading = true;

    await GymDatabaseHelpers.get_sub_history(client!.key).then((snapshot) {
      List<Sub_History_Model> sub_h = [];

      snapshot.docs.forEach((element) {
        Sub_History_Model rec =
            Sub_History_Model.fromMap(element.id, element.data());
        sub_h.add(rec);
      });

      isLoading = false;

      if (sub_h.isNotEmpty) {
        sub_history = groupRec(sub_h);
        var chk = sub_history
            .where((element) => element.year == active_year)
            .toList();

        if (chk.isNotEmpty) {
          active_record = chk.first.record;
        } else {
          active_record.clear();
        }
      } else {}

      setState(() {});
      return;
    });
  }

  // group history
  List<GroupedSubHistory> groupRec(List<Sub_History_Model> ll) {
    List<GroupedSubHistory> lgl = [];
    var ll_group = groupBy(ll, (e) => get_year(e.sub_date));

    ll_group.forEach((key, value) {
      GroupedSubHistory gsl = GroupedSubHistory(year: key, record: value);
      lgl.add(gsl);
    });

    lgl.sort((a, b) => b.year.compareTo(a.year));

    return lgl;
  }

  int get_year(String date) {
    String res = date.split('/').last;
    return int.parse(res);
  }

  change_year(bool prev) {
    if (isLoading) return;

    // previous
    if (prev) {
      if (minYear) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'Max History reached',
          icon: Icons.warning_rounded,
        );

        return;
      } else {
        active_year = active_year - 1;
      }
    }

    // next
    else {
      if (maxYear) {
        Helpers.showToast(
          context: context,
          color: Colors.redAccent,
          toastText: 'No further history yet',
          icon: Icons.warning_rounded,
        );
        return;
      } else {
        active_year = active_year + 1;
      }
    }

    var chk =
        sub_history.where((element) => element.year == active_year).toList();

    if (chk.isNotEmpty) {
      active_record = chk.first.record;
    } else {
      active_record = [];
    }

    setState(() {});
  }

  // select year
  select_year() async {
    int? selected = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Year"),
          content: Container(
            width: 200,
            height: 400,
            child: YearPicker(
              firstDate: firstDay,
              lastDate: lastDay,
              selectedDate: DateTime(active_year),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );

    if (selected != null) {
      active_year = selected;

      var chk =
          sub_history.where((element) => element.year == active_year).toList();

      if (chk.isNotEmpty) {
        active_record = chk.first.record;
      } else {
        active_record = [];
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.85;
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
    return Column(
      children: [
        // top bar
        topBar(),

        SizedBox(height: 8),

        // total income
        Container(
          padding: EdgeInsets.only(left: 40),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Total Income:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 4),
              Text(
                Helpers.format_amount(client!.sub_income, naira: true),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),

        // year selector
        year_selector(),

        // record list
        Expanded(child: record_list()),

        SizedBox(height: 10),
      ],
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
              // id & subscription
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ID
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // id label
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
                        client!.id,
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

                  // subscription
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
                          client!.sub_plan,
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

              Expanded(child: Container()),

              SizedBox(width: 10),

              // close button
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 30,
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
                '${client!.name}\'s Subscription History',
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

  // check year
  check_year() {
    int first_year = firstDay.year;
    int last_year = lastDay.year;

    int current_year = active_year;

    if (last_year == current_year) {
      maxYear = true;
    } else {
      maxYear = false;
    }

    if (first_year == current_year) {
      minYear = true;
    } else {
      minYear = false;
    }

    setState(() {});
  }

  // year selector
  Widget year_selector() {
    check_year();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // previous button
            InkWell(
              onTap: () {
                change_year(true);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: minYear ? Color(0xFF928F8F) : Colors.white,
                size: 25,
              ),
            ),

            SizedBox(width: 50),

            // year
            Container(
              width: 200,
              child: Center(
                child: InkWell(
                  onTap: () {
                    select_year();
                  },
                  child: Text(
                    active_year.toString(),
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
                change_year(false);
              },
              child: Icon(
                Icons.arrow_forward_ios,
                color: maxYear ? Color(0xFF928F8F) : Colors.white,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // history list
  Widget record_list() {
    int year_total = 0;

    active_record.sort((a, b) => DateTime.parse(b.time_stamp ?? '')
        .compareTo(DateTime.parse(a.time_stamp ?? '')));

    active_record.forEach((element) {
      year_total += element.amount;
    });
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : active_record.isNotEmpty
            ? Column(
                children: [
                  // total income for this year
                  Container(
                    padding: EdgeInsets.only(right: 40),
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total amount paid:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          Helpers.format_amount(year_total, naira: true),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // record list
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: active_record.length,
                      itemBuilder: (context, index) =>
                          history_tile(active_record[index]),
                    ),
                  ),
                ],
              )

            // no subscription
            : Center(
                child: Text(
                  'No Subscription record for this year',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              );
  }

  // history tile
  Widget history_tile(Sub_History_Model history) {
    bool extras = history.boxing || history.pt_status;

    bool is_p_r = history.hist_type == 'Subscription Paused' ||
        history.hist_type == 'Subscription Resumed';

    bool extra_sub = history.hist_type == 'Boxing' ||
        history.hist_type == 'Personal Training';

    bool deact = history.hist_type == 'Deactivated';

    String sub_date = DateFormat('E, d MMM')
        .format(DateFormat('dd/MM/yyyy').parse(history.sub_date));
    String exp_date = history.exp_date.isNotEmpty
        ? DateFormat('E, d MMM')
            .format(DateFormat('dd/MM/yyyy').parse(history.exp_date))
        : '--';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
      child: Stack(
        children: [
          // main contents
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 146, 108, 54).withOpacity(0.75),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.fromLTRB(24, 25, 24, 15),
            margin: EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // heading
                Row(
                  children: [
                    // sub plan
                    Text(
                      history.sub_plan,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(width: 8),

                    // sub type
                    if (history.sub_type.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color.fromARGB(255, 232, 186, 93)
                              .withOpacity(0.4),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          history.sub_type,
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    Expanded(child: Container()),

                    // sub date
                    Text(
                      sub_date,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(width: 5),

                    // print icon
                    InkWell(
                      onTap: () async {
                        GymSubPrintModel printModel = GymSubPrintModel(
                          date: history.sub_date,
                          receipt_id: history.history_id,
                          client_id: client!.id,
                          client_name: client!.fullname,
                          subscription_plan: history.sub_plan,
                          subscription_type: history.sub_type,
                          extras: [
                            if (history.boxing) 'Boxing',
                            if (history.pt_status)
                              '${history.pt_plan} Personal Training'
                          ],
                          amount: history.amount,
                          expiry_date: history.exp_date.replaceAll('/', '-'),
                          receipt_type: history.hist_type,
                          sub_amount_b4_discount: history.sub_amount_b4_discount ?? 0,
                        );

                        await showDialog(
                            context: context,
                            builder: (context) => GymPrintPage(print: printModel));
                      },
                      child:
                          Icon(Icons.receipt, color: Colors.white70, size: 20),
                    ),
                  ],
                ),

                // exp date
                Row(
                  children: [
                    Text(
                      'Expiry date:',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    SizedBox(width: 6),
                    Text(
                      exp_date,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // SizedBox(height: 4),

                // amount
                if ((!is_p_r || extra_sub) && !deact && history.amount != 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        Helpers.format_amount(history.amount, naira: true),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),

                // if discount
                if ((!is_p_r || extra_sub) &&
                    !deact &&
                    history.amount != 0 &&
                    (history.sub_amount_b4_discount != null &&
                        history.sub_amount_b4_discount != history.amount && history.sub_amount_b4_discount != 0))
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding:
                          EdgeInsets.only(top: 4),
                      child: Text(
                        Helpers.format_amount(history.sub_amount_b4_discount!, naira: true),
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          decorationStyle: TextDecorationStyle.solid,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),

                if ((!is_p_r || extra_sub) && !deact) SizedBox(height: 2),

                // extras
                is_p_r || extra_sub || deact
                    ? Container()
                    : extras
                        ? Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 10,
                            spacing: 12,
                            children: [
                              // boxing
                              if (history.boxing)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Color.fromARGB(255, 55, 103, 135)
                                        .withOpacity(0.7),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/icon/boxglove.png',
                                        width: 13,
                                        height: 13,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Boxing',
                                        style: TextStyle(
                                          fontSize: 13,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // personal training
                              if (history.pt_status)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Color(0xFF5a5a5a).withOpacity(0.7),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/icon/sentiayoga.png',
                                        width: 13,
                                        height: 13,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'PT - ${history.pt_plan}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          )
                        : Container(),
              ],
            ),
          ),

          // hist type
          Positioned(
            top: 0,
            left: 70,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: deact
                    ? Colors.red
                    : extra_sub
                        ? Colors.deepPurple
                        : is_p_r
                            ? (history.hist_type == 'Subscription Paused')
                                ? Colors.red
                                : Colors.green
                            : Colors.blue,
              ),
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Center(
                child: Text(
                  history.hist_type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
}

class GroupedSubHistory {
  int year;
  List<Sub_History_Model> record;

  GroupedSubHistory({
    required this.year,
    required this.record,
  });
}

class Sub_CL_Model {
  String key;
  String id;
  String name;
  String fullname;
  String sub_plan;
  int sub_income;

  Sub_CL_Model({
    required this.key,
    required this.id,
    required this.name,
    required this.fullname,
    required this.sub_plan,
    required this.sub_income,
  });
}
