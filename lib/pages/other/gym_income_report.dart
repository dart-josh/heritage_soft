import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
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
  TextEditingController search_bar_controller = TextEditingController();

  List<GymIncomeModel> income_list = [];
  List<Group_GymIncomeModel> record = [];

  List<GymIncomeModel> search_list = [];
  bool emptySearch = false;

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
        var res =
            await AdminDatabaseHelpers.old_get_income_data(client['key'], date);

        income_list += res;
        setState(() {});
      }
    }

    // new
    else {
      var e_list = await AdminDatabaseHelpers.get_income_data();
      var res = groupBy(
          e_list,
          (e) => DateFormat('MM/yyyy')
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
  void dispose() {
    search_bar_controller.dispose();
    super.dispose();
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
          // search box
          if (!isLoading)
            Container(
              height: 38,
              width: 200,
              child: TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                onChanged: search_clients,
                controller: search_bar_controller,
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
                  suffixIcon: InkWell(
                    onTap: () {
                      emptySearch = false;
                      search_list.clear();
                      search_bar_controller.clear();

                      setState(() {});
                    },
                    child: Icon(
                      Icons.clear,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

          // current date
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {},
              child: Text(
                '${DateFormat('MMMM yyyy').format(current_date)} - (${income_list.length})',
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
              // heading
              if (income_list.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white30),
                    ),
                  ),
                  child: Row(
                    children: [
                      // s/n
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.white38),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: 40,
                        child: Text(
                          'S/N',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      // id
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.white38),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: 70,
                        child: Center(
                          child: Text(
                            'Client ID',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      // name
                      Expanded(
                        child: Text(
                          'Name',
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
                            'Amount',
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
                        width: 170,
                        child: Center(
                          child: Text(
                            'Type',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
                            'Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // extras
                      Container(
                        width: 170,
                        child: Center(
                          child: Text(
                            'Extras',
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
                            'Date',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // list
              Expanded(
                child: emptySearch
                    ? Center(
                        child: Text('No Client Found',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      )
                    : search_list.isNotEmpty
                        ? ListView.separated(
                            itemBuilder: (context, index) {
                              int find = income_list.indexOf(
                                  search_list[index]);
                              int? ind = find != -1 ? find : null;
                              return _tile(search_list[index],
                                  (ind != null ? ind + 1 : null));
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox();
                            },
                            itemCount: search_list.length,
                          )
                        : income_list.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  int find = income_list.indexOf(
                                      income_list[index]);
                                  int? ind = find != -1 ? find : null;
                                  return _tile(income_list[index],
                                      (ind != null ? ind + 1 : null));
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox();
                                },
                                itemCount: income_list.length,
                              )
                            : Center(
                                child: Text('No Data to view yet...',
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
      if (e.hist_type == 'Registration') {
        if (e.extras_amount != 0) {
          int reg = e.amount - e.extras_amount;
          registration += reg;
          extras += e.extras_amount;
        } else {
          registration += e.amount;
        }
      } else if (e.hist_type == 'Renewal') {
        if (e.extras_amount != 0) {
          int ren = e.amount - e.extras_amount;
          renewal += ren;
          extras += e.extras_amount;
        } else {
          renewal += e.amount;
        }
      } else
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
  Widget _tile(GymIncomeModel model, int? index) {
    var client = Provider.of<AppData>(context, listen: false)
        .clients
        .where((e) => e.key == model.client_key);

    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white30),
          ),
        ),
        child: Row(
          children: [
            // s/n
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white38),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
              width: 40,
              child: Text(
                index?.toString() ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
              ),
            ),

            // id
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white38),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
              width: 70,
              child: Center(
                child: SelectableText(
                  (client.isNotEmpty)
                      ? '${client.first.id?.toLowerCase().replaceAll('hfc-', '').replaceAll('-ft', '').replaceAll('-hm', '') ?? ''}'
                      : '',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // name
            Expanded(
              child: SelectableText(
                (client.isNotEmpty)
                    ? '${client.first.f_name} ${client.first.l_name}'
                    : 'User Not found',
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
                  model.amount == 0
                      ? ''
                      : Helpers.format_amount(model.amount, naira: true),
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
              width: 170,
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

            // extras
            Container(
              width: 170,
              child: Center(
                child: Text(
                  (model.extras.isNotEmpty)
                      ? '${model.extras.map((e) => e).join(', ')}\n(${Helpers.format_amount(model.extras_amount, naira: true)})'
                      : '',
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

  //
  // search clients
  void search_clients(String value, {bool build = false}) {
    search_list.clear();
    emptySearch = false;

    if (value.isNotEmpty) {
      var data = income_list.where((e) =>
          (get_client_data(e.client_key)
                  ?.f_name
                  ?.toLowerCase()
                  .contains(value.toLowerCase().trim()) ??
              false) ||
          (get_client_data(e.client_key)
                  ?.l_name
                  ?.toLowerCase()
                  .contains(value.toLowerCase().trim()) ??
              false) ||
          (get_client_data(e.client_key)
                  ?.id
                  ?.toLowerCase()
                  .contains(value.toLowerCase().trim()) ??
              false));

      if (data.isNotEmpty) {
        search_list = data.toList();
      } else {
        // empty search
        emptySearch = true;
      }
    } else {
      // clear search
    }

    if (!build) setState(() {});
  }

  ClientListModel? get_client_data(String cl_key) {
    var client = Provider.of<AppData>(context, listen: false)
        .clients
        .where((e) => e.key == cl_key);

    return client.isNotEmpty ? client.first : null;
  }

  //
}
