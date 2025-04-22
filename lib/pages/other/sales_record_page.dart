import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/accessories_shop_model.dart';
import 'package:heritage_soft/datamodels/attendance_model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker2/month_year_picker2.dart';

class SalesRecord extends StatefulWidget {
  const SalesRecord({super.key});

  @override
  State<SalesRecord> createState() => _SalesRecordState();
}

class _SalesRecordState extends State<SalesRecord> {
  int _index = 0;

  At_Date? active_month;

  bool isLoading = false;

  List<ShopRecordModel> active_list = [];

  List<ShopOrderModel> active_record = [];
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

  // load details by month
  load_data() async {
    isLoading = true;
    active_list.clear();
    active_record.clear();
    active_date = '';

    await AdminDatabaseHelpers.get_accessory_sales_record(active_month!.title)
        .then((snapshot) {
      // if (snapshot.value != null) {
      //   Map map = snapshot.value as Map;

      //   if (map.isNotEmpty) {
      //     map.forEach((key, value) {
      //       Map map_2 = value as Map;
      //       List<ShopOrderModel> orders = [];

      //       map_2.forEach((key_2, value_2) {
      //         orders.add(ShopOrderModel.fromMap(value_2));
      //       });

      //       active_list.add(ShopRecordModel(date: key, record: orders));
      //     });
      //   }
      // }
    });

    isLoading = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
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
                    Tab(text: 'Fitness Sales'),
                    Tab(text: 'Physio Sales'),
                    Tab(text: 'Other Sales'),
                    Tab(text: 'Fitness Sales'),
                  ],
                ),

                SizedBox(height: 10),

                // tabs
                Expanded(
                  child: TabBarView(
                    children: [
                      record_list(),
                      record_list(),
                      record_list(),
                      record_list(),
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

  // date selector
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
  Widget record_list() {
    int total_amount = 0;
    active_record.sort(
        (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    active_record.forEach((element) {
      total_amount += element.discount_price != 0
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
  Widget record_tile(ShopOrderModel record) {
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
      DateFormat.jm().format(DateTime.parse(record.date)),
      style: TextStyle(
        color: Colors.white,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    // paymnet method
    String pmt_str = '';
    if (record.split) {
      pmt_str = '${record.payment_method}, ${record.payment_method2}';
    } else {
      pmt_str = record.payment_method;
    }

    // payment paymethod
    Widget pmt =
        // spilt payment
        (record.split)
            ? Column(
                children: [
                  // all payment methods
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
                        pmt_str,
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2),

                  // payment methods & amounts
                  Row(
                    children: [
                      // label 1
                      Text(
                        '${record.payment_method}:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(width: 4),

                      // pmt 1
                      Text(
                        Helpers.format_amount(record.amount1, naira: true),
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(width: 10),

                      // label 2
                      Text(
                        '${record.payment_method2}:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(width: 4),

                      // pmt 2
                      Text(
                        Helpers.format_amount(record.amount2, naira: true),
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              )

            // single payment method
            : Row(
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
                    pmt_str,
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              );

    // qunatity & price
    Widget qty_price = Row(
      children: [
        // label
        Text(
          'Qunatity:',
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
            fontSize: (record.discount_price != 0) ? 13 : 18,
            fontStyle: FontStyle.italic,
            fontWeight: (record.discount_price != 0)
                ? FontWeight.normal
                : FontWeight.bold,
            decoration: (record.discount_price != 0)
                ? TextDecoration.lineThrough
                : null,
            decorationColor: Colors.white,
            decorationThickness: 2,
            color: (record.discount_price != 0) ? Colors.white54 : Colors.white,
          ),
        ),

        // discounted price
        (record.discount_price != 0)
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
            children: [id, Expanded(child: Container()), time],
          ),

          SizedBox(height: 10),

          // qunatity & price & pmt
          Row(
            children: [qty_price, Expanded(child: Container()), pmt],
          ),

          if (record.customer.isNotEmpty) SizedBox(height: 5),

          // customer
          if (record.customer.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                record.customer,
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
                builder: (context) => ItemsDialog(items: record.items),
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

class ItemsDialog extends StatelessWidget {
  final List<AccessoryItemModel> items;
  const ItemsDialog({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // top bar
          Stack(
            children: [
              // title
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                height: 40,
                width: 400,
                child: Center(
                  child: Text(
                    'Items List',
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
          // list
          Container(
            decoration: BoxDecoration(),
            width: 400,
            height: 400,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: items.map((e) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 3),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // name
                        Expanded(
                          child: Text(
                            e.accessory.name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        SizedBox(width: 10),

                        // quantity
                        Text(
                          e.qty.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
