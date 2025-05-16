import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/store_models/sales_record.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/server_helpers.dart';
import 'package:heritage_soft/helpers/store_database_helpers.dart';
import 'package:heritage_soft/pages/store/print.page.dart';
import 'package:heritage_soft/pages/store/widgets/accessory_item_dialog.dart';
import 'package:intl/intl.dart';

class SalesRecord extends StatefulWidget {
  const SalesRecord({super.key});

  @override
  State<SalesRecord> createState() => _SalesRecordState();
}

class _SalesRecordState extends State<SalesRecord> {
  int _index = 0;

  bool isLoading = false;

  List<G_SalesRecordModel> g_record = [];
  List<SalesRecordModel> active_record = [];
  String active_date = '';

  String selected_date = '';

  // fetch data
  load_data() async {
    isLoading = true;
    setState(() {});

    var response = await StoreDatabaseHelpers.get_sales_record(context);

    if (response.isNotEmpty) {
      g_record.clear();
      var g_rec = response.groupListsBy((e) => get_date(e.date));

      g_rec.forEach((key, value) {
        g_record.add(G_SalesRecordModel(date: key, record: value));
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
    SalesRecordModel rec = SalesRecordModel.fromJson(data);

    var chk = g_record.indexWhere((e) => e.date == get_date(rec.date));

    if (chk != -1) {
      g_record[chk].record.add(rec);
    } else {
      g_record.add(G_SalesRecordModel(date: get_date(rec.date), record: [rec]));
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

    ServerHelpers.socket!.on('SalesRecord', (data) {
      get_rec(data);
    });
    ServerHelpers.socket!.on('SalesRecordD', (data) {
      remove_rec(data);
    });

    super.initState();
  }

  @override
  void dispose() {
    ServerHelpers.socket!.off('SalesRecord');
    ServerHelpers.socket!.off('SalesRecordD');
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
      length: 1,
      initialIndex: _index,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 2, 20, 35),
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 2, 20, 35),
          title: Text('Sales Record'),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // date selector
                date_selector(),

                SizedBox(height: 10),

                // tab header
                TabBar(
                  tabs: [
                    Tab(text: 'All Sales'),
                    // Tab(text: 'Physio Sales'),
                    // Tab(text: 'Other Sales'),
                    // Tab(text: 'Fitness Sales'),
                  ],
                ),

                SizedBox(height: 10),

                // tabs
                Expanded(
                  child: TabBarView(
                    children: [
                      record_list(),
                      // record_list(),
                      // record_list(),
                      // record_list(),
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
  Widget record_list() {
    int total_amount = 0;
    active_record.sort((a, b) => b.date.compareTo(a.date));

    active_record.forEach((element) {
      total_amount += (element.discount_price != 0 &&
              element.discount_price != element.order_price)
          ? element.discount_price
          : element.order_price;
    });

    return Container(
      child:
          // empty list
          active_record.isEmpty
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
                          children: active_record.map((e) {
                            return record_tile(e);
                          }).toList(),
                        ),
                      ),
                    ),

                    // total amount
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total amount:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            Helpers.format_amount(total_amount, naira: true),
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
  Widget record_tile(SalesRecordModel record) {
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

    // payment paymethod
    Widget pmt = Column(
      children: [
        // main payment methods
        Row(
          children: [
            // label
            Text(
              'Payment method:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),

            SizedBox(width: 4),

            // pmt
            Text(
              record.paymentMethod,
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),

        if (record.splitPaymentMethod.isNotEmpty) SizedBox(height: 2),

        // payment methods & amounts
        if (record.splitPaymentMethod.isNotEmpty)
          Row(
            children: record.splitPaymentMethod.map((rec) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    // label 1
                    Text(
                      '${rec.paymentMethod}:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(width: 4),

                    // pmt 1
                    Text(
                      Helpers.format_amount(rec.amount, naira: true),
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
      ],
    );

    // quantity & price
    Widget qty_price = Row(
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
          'Price:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),

        SizedBox(width: 4),

        // price
        Text(
          Helpers.format_amount(record.order_price, naira: true),
          style: TextStyle(
            fontSize: (record.discount_price != 0 &&
                    record.discount_price != record.order_price)
                ? 13
                : 18,
            fontStyle: FontStyle.italic,
            fontWeight: (record.discount_price != 0 &&
                    record.discount_price != record.order_price)
                ? FontWeight.normal
                : FontWeight.bold,
            decoration: (record.discount_price != 0 &&
                    record.discount_price != record.order_price)
                ? TextDecoration.lineThrough
                : null,
            decorationColor: Colors.white,
            decorationThickness: 2,
            color: (record.discount_price != 0 &&
                    record.discount_price != record.order_price)
                ? Colors.white54
                : Colors.white,
          ),
        ),

        // discounted price
        (record.discount_price != 0 &&
                record.discount_price != record.order_price)
            ? Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  Helpers.format_amount(record.discount_price, naira: true),
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : SizedBox(),
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
              IconButton(
                  onPressed: () async {
                    SalesPrintModel printModel = SalesPrintModel(
                      date: DateFormat('dd/MM/yyyy').format(record.date),
                      time: DateFormat.jm().format(record.date),
                      receipt_id: record.order_id,
                      seller: record.soldBy.f_name,
                      customer: '${record.patient?.f_name ?? ''} ${record.patient?.l_name ?? ''}',
                      items: record.accessories.map((p) => PrintItemModel(name: p.accessory.itemName, qty: p.qty, price: p.accessory.price, total_price: (p.accessory.price * p.qty))).toList(),
                      sub_total: record.order_price,
                      discount: record.order_price - record.discount_price,
                      total: record.discount_price,
                      pmts: record.splitPaymentMethod.isNotEmpty ? record.splitPaymentMethod : [PaymentMethodModel(paymentMethod: record.paymentMethod, amount: record.discount_price,)],
                    );

                    showDialog(
                        context: context,
                        builder: (context) =>
                            SalesPrintPage(print: printModel));
                  },
                  icon: Icon(
                    Icons.receipt,
                    color: Colors.white70,
                  )),
              if (active_user?.full_access ?? false)
                IconButton(
                    onPressed: () async {
                      bool conf = await Helpers.showConfirmation(
                        context: context,
                        title: 'Delete record',
                        message:
                            'You are about to delete this record, This cannot be undone!',
                      );

                      if (conf) {
                        await StoreDatabaseHelpers.delete_sales_record(context,
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

          // quantity & price & pmt
          Row(
            children: [qty_price, Expanded(child: Container()), pmt],
          ),

          if (record.patient != null) SizedBox(height: 5),

          // customer
          if (record.patient != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Patient: ${record.patient?.f_name ?? ''} ${record.patient?.l_name ?? ''}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),

          SizedBox(height: 10),

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

class G_SalesRecordModel {
  String date;
  List<SalesRecordModel> record;

  G_SalesRecordModel({
    required this.date,
    required this.record,
  });
}
