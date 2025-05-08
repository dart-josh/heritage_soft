import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/store_models/restock_accessory_record.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/server_helpers.dart';
import 'package:heritage_soft/helpers/store_database_helpers.dart';
import 'package:heritage_soft/pages/store/restock_accessories_page.dart';
import 'package:heritage_soft/pages/store/widgets/accessory_item_dialog.dart';
import 'package:intl/intl.dart';

class RestockAccessoryRecordPage extends StatefulWidget {
  const RestockAccessoryRecordPage({super.key});

  @override
  State<RestockAccessoryRecordPage> createState() =>
      _RestockAccessoryRecordPageState();
}

class _RestockAccessoryRecordPageState
    extends State<RestockAccessoryRecordPage> {
  int _index = 0;

  bool isLoading = false;

  List<RestockAccessoryRecordModel> pending_record = [];
  List<G_RestockAccessoryRecordModel> g_record = [];
  List<RestockAccessoryRecordModel> active_record = [];
  String active_date = '';

  String selected_date = '';

  // fetch data
  load_data() async {
    isLoading = true;
    setState(() {});

    var response =
        await StoreDatabaseHelpers.get_accessory_restock_record(context);

    if (response.isNotEmpty) {
      pending_record = response.where((rec) => !rec.verified).toList();
      var verified_record = response.where((rec) => rec.verified).toList();

      g_record.clear();
      var g_rec = verified_record.groupListsBy((e) => get_date(e.date));

      g_rec.forEach((key, value) {
        g_record.add(G_RestockAccessoryRecordModel(date: key, record: value));
      });

      if (active_date.isNotEmpty) {
        var chk = g_record.where((rec) => rec.date == active_date).toList();

        if (chk.isNotEmpty) {
          active_record = chk.first.record.map((e) => e).toList();
        }
      } else {
        var chk = g_record
            .where((rec) => rec.date == get_date(DateTime.now()))
            .toList();

        if (chk.isNotEmpty) {
          active_record = chk.first.record.map((e) => e).toList();
          active_date = chk.first.date;
        }
      }
    }

    isLoading = false;
    setState(() {});
  }

  dynamic get_rec(dynamic data) async {
    RestockAccessoryRecordModel rec =
        RestockAccessoryRecordModel.fromJson(data);

    var chk = g_record.indexWhere((e) => e.date == get_date(rec.date));

    if (chk != -1) {
      g_record[chk].record.add(rec);
    } else {
      g_record.add(G_RestockAccessoryRecordModel(
          date: get_date(rec.date), record: [rec]));
    }

    if (active_date.isNotEmpty && active_date == get_date(rec.date)) {
      var chk = g_record.where((rec) => rec.date == active_date).toList();

      if (chk.isNotEmpty) {
        active_record = chk.first.record.map((e) => e).toList();
      }
    }

    setState(() {});
  }

  dynamic remove_rec(dynamic id) async {
    g_record.forEach((e) {
      var rec_chk = e.record.indexWhere((rec) => rec.key == id);
      if (rec_chk != -1) {
        e.record.removeAt(rec_chk);

        if (active_date.isNotEmpty && active_date == e.date) {
          var a_chk = active_record.indexWhere((rec) => rec.key == id);

          if (a_chk != -1) {
            active_record.removeAt(a_chk);
          }
        }

        setState(() {});
        return;
      }
    });
  }

  @override
  void initState() {
    load_data();

    // todo
    // ServerHelpers.socket!.on('RestockAccessoryRecord', (data) {
    //   get_rec(data);
    // });
    // ServerHelpers.socket!.on('RestockAccessoryRecordD', (data) {
    //   remove_rec(data);
    // });

    super.initState();
  }

  @override
  void dispose() {
    // ServerHelpers.socket!.off('RestockAccessoryRecord');
    // ServerHelpers.socket!.off('RestockAccessoryRecordD');
    super.dispose();
  }

  // select month
  select_date() async {
    var selected = await showDatePicker(
      context: context,
      initialDate: (active_date.isNotEmpty)
          ? reverse_date(active_date)
          : (selected_date.isNotEmpty)
              ? reverse_date(selected_date)
              : DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      selected_date = get_date(selected);
      var chk =
          g_record.where((rec) => rec.date == get_date(selected)).toList();

      if (chk.isNotEmpty) {
        active_record = chk.first.record.map((e) => e).toList();
        active_date = chk.first.date;
      } else {
        active_record.clear();
        active_date = '';
      }
    } else {
      selected_date = '';
    }

    setState(() {});
  }

  // extract date format
  String get_date(DateTime date) {
    if (date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      return DateFormat('d MMM, yyyy').format(date);
    } else {
      return DateFormat('MMMM, yyyy').format(date);
    }
  }

  // rever date
  DateTime reverse_date(String date) {
    if (date.split(' ').length > 2) {
      return DateFormat('d MMM, yyyy').parse(date);
    } else {
      return DateFormat('MMMM, yyyy').parse(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _index,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 2, 20, 35),
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 2, 20, 35),
          title: Text('Restock Accessories Record'),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // tab header
                TabBar(
                  onTap: (val) {
                    setState(() {
                      _index = val;
                    });
                  },
                  tabs: [
                    Tab(text: 'Pending Record'),
                    Tab(text: 'Verified Record'),
                  ],
                ),

                SizedBox(height: 10),

                // date selector
                if (_index == 1) date_selector(),

                SizedBox(height: 10),

                // tabs
                Expanded(
                  child: TabBarView(
                    children: [
                      record_list(pending_record, 'pen'),
                      record_list(active_record, 'ver'),
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

  // date selector
  Widget date_selector() {
    g_record
        .sort((a, b) => reverse_date(b.date).compareTo(reverse_date(a.date)));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: g_record.map((e) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () {
                        active_record = e.record.map((e) => e).toList();
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
          ),

          SizedBox(width: 10),

          // select date
          Container(
            // width: 200,
            child: InkWell(
              onTap: () {
                select_date();
              },
              child: Row(
                children: [
                  Text(
                    (active_date.isNotEmpty) ? active_date : selected_date,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.7,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.calendar_month, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // record list
  Widget record_list(List<RestockAccessoryRecordModel> record, String key) {
    int total_qty = 0;
    record.sort((a, b) => b.date.compareTo(a.date));

    record.forEach((element) {
      total_qty += element.order_qty;
    });

    return Container(
      key: Key(key),
      child:
          // empty list
          record.isEmpty
              ? Center(
                  child: Text(
                    'No record',
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
                            return record_tile(e);
                          }).toList(),
                        ),
                      ),
                    ),

                    // total quantity
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total quantity:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            Helpers.format_amount(total_qty),
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
  Widget record_tile(RestockAccessoryRecordModel record) {
    UserModel? active_user = AppData.get(context).active_user;

    // order id
    Widget id = Text(
      record.order_id,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );

    // time
    Widget time = Text(
      '${DateFormat.jm().format(record.date)}, ${DateFormat('dd/MM/yy').format(record.date)}',
      style: TextStyle(
        color: Colors.white,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    // quantity & suppier
    Widget qty_suppier = Row(
      children: [
        // label
        Text(
          'Quantity:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),

        SizedBox(width: 4),

        // quantity
        Text(
          Helpers.format_amount(record.order_qty),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),

        SizedBox(width: 15),

        // label
        Text(
          'Supplier:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),

        SizedBox(width: 4),

        // suppier
        Expanded(
          child: Text(
            record.supplier,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
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
      child: Column(
        children: [
          // id & btime
          Row(
            children: [
              id,
              Expanded(child: Container()),
              time,
              if (!record.verified)
                IconButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RestockAccessoriesPage(record: record)),
                      );
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white70,
                    )),
              if (active_user?.full_access ?? false || !record.verified)
                IconButton(
                    onPressed: () async {
                      bool conf = await Helpers.showConfirmation(
                        context: context,
                        title: 'Delete record',
                        message:
                            'You are about to delete this record, This cannot be undone!',
                      );

                      if (conf) {
                        await StoreDatabaseHelpers
                            .delete_accessory_restock_record(context,
                                data: {}, id: record.key ?? '');
                      }
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
            ],
          ),

          SizedBox(height: 10),

          // quantity & supplier
          qty_suppier,

          // short note
          Row(
            children: [
              // label
              Text(
                'Short note:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),

              SizedBox(width: 4),

              // suppier
              Expanded(
                child: Text(
                  record.shortNote,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),
          if (record.verified)
            Container(
              child: Row(
                children: [
                  // label
                  Text(
                    'Verified by:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(width: 4),

                  // suppier
                  Expanded(
                    child: Text(
                      record.verifiedBy?.f_name ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () async {
                  bool conf = await Helpers.showConfirmation(
                    context: context,
                    title: 'Verify Record',
                    message: 'Do you want to verify this record?',
                  );
              
                  if (conf) {
                    await StoreDatabaseHelpers.verify_accessory_restock_record(
                      context,
                      data: record.toJson_verify(userKey: active_user?.key ?? ''),
                      showLoading: true,
                      showToast: true,
                    );
                  }
                },
                child: Container(
                  width: 80,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(
                    child: Text(
                      'Verify',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // view items
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) =>
                    AccessoryItemDialog(items: record.accessories),
              );
            },
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  'View Items',
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
    );
  }

  //
}

class G_RestockAccessoryRecordModel {
  String date;
  List<RestockAccessoryRecordModel> record;

  G_RestockAccessoryRecordModel({
    required this.date,
    required this.record,
  });
}
