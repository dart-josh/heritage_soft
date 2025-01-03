import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/income_model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker2/month_year_picker2.dart';
import 'package:provider/provider.dart';

class GymIncomeReport extends StatefulWidget {
  const GymIncomeReport({super.key});

  @override
  State<GymIncomeReport> createState() => _GymIncomeReportState();
}

class _GymIncomeReportState extends State<GymIncomeReport> {
  List<GymIncomeModel> income_list = [];
  List<Group_GymIncomeModel> record = [];

  DateTime current_date = DateTime.now();
  bool isLoading = true;

  List<Map> clients = [];

  get_data({bool old = false, String date = ''}) async {
    income_list.clear();
    isLoading = true;
    setState(() {});

    // 2024
    if (old) {
      clients = Provider.of<AppData>(context, listen: false)
          .clients
          .map((e) => {'key': e.key!, 'f_name': e.f_name, 'l_name': e.l_name})
          .toList();

      for (var client in clients) {
        var res = await AdminDatabaseHelpers.old_get_income_data(
            client['key'],
            date);

        income_list += res;
        setState(() {});
      }
    }

    // new
    else {
      var e_list = await AdminDatabaseHelpers.get_income_data();
      var res = groupBy(
          e_list,
          (e) => DateFormat('MMMM, yyyy')
              .format(DateFormat('dd/MM/yyyy').parse(e.sub_date)));

      res.forEach((key, value) {
        record.add(Group_GymIncomeModel(month: key, record: value));
      });

      var rec = record
          .where((e) => e.month == DateFormat('MM/yyyy').format(current_date));

      if (rec.isNotEmpty) {
        income_list = rec.first.record;
      } else {
        income_list = [];
      }
    }

    record.sort((a, b) => a.month.compareTo(b.month));
    income_list.sort((a, b) => a.sub_date.compareTo(b.sub_date));

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    get_data();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    income_list.sort((a, b) => a.sub_date.compareTo(b.sub_date));
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 2, 20, 35),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 2, 20, 35),
        // bottom: ,
        title: Text('Gym Income Report'),
        actions: [
          // current date
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {},
              child: Text(
                DateFormat('MMMM yyyy').format(current_date),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          // change date
          if (isLoading)
            Container(
              padding: EdgeInsets.only(right: 10),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () async {
                  var date = await showMonthYearPicker(
                    context: context,
                    initialDate: current_date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );

                  if (date != null) {
                    setState(() {
                      current_date = date;
                    });

                    if (date.year == 2024) {
                      String date_s =
                          '${current_date.year}-${current_date.month}';
                      get_data(old: true, date: date_s);
                    } else {
                      var rec = record.where(
                          (e) => e.month == DateFormat('MM/yyyy').format(date));

                      if (rec.isNotEmpty) {
                        income_list = rec.first.record;
                      } else {
                        income_list = [];
                      }

                      setState(() {});
                    }
                  }
                },
                child: Icon(Icons.calendar_today, color: Colors.white),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // main content
          Column(
            children: [
              // list
              Expanded(
                child: income_list.isNotEmpty
                    ? ListView.separated(
                        itemBuilder: (context, index) {
                          return _tile(income_list[index], index + 1);
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox();
                        },
                        itemCount: income_list.length,
                      )
                    : Center(
                        child: Text('No Data for this month',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
              ),

              totals(),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGETS
  Widget totals() {
    int total = 0;
    int registration = 0;
    int renewal = 0;
    int extras = 0;

    income_list.forEach((e) {
      if (e.hist_type == 'Registration')
        registration += e.amount;
      else if (e.hist_type == 'Renewal')
        renewal += e.amount;
      else
        extras += e.amount;

      total += e.amount;
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          total_tile('Total', total),
          total_tile('Registration', registration),
          total_tile('Renewal', renewal),
          total_tile('Extras', extras),
        ],
      ),
    );
  }

  // list tile
  Widget _tile(GymIncomeModel model, int index) {
    var client = Provider.of<AppData>(context, listen: false)
        .clients
        .where((e) => e.key == model.client_key);

    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white30),
          ),
        ),
        child: Row(
          children: [
            // s/n
            Container(
              width: 40,
              child: Text(
                index.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
              ),
            ),

            // name
            Expanded(
              child: Text(
                (client.isNotEmpty) ? '${client.first.f_name} ${client.first.l_name}' : 'User Not found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            // amount
            Container(
              width: 100,
              child: Center(
                child: Text(
                  Helpers.format_amount(model.amount, naira: true),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // type
            Container(
              width: 150,
              child: Center(
                child: Text(
                  model.hist_type,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // plan
            Container(
              width: 150,
              child: Center(
                child: Text(
                  model.sub_plan,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // date
            Container(
              width: 100,
              child: Center(
                child: Text(
                  model.sub_date,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  // total tile
  Widget total_tile(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        Text(
          Helpers.format_amount(value, naira: true),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
  //
}
