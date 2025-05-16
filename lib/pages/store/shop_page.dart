import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';
import 'package:heritage_soft/datamodels/store_models/accessory_request.model.dart';
import 'package:heritage_soft/datamodels/store_models/sales_record.model.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/store_database_helpers.dart';
import 'package:heritage_soft/pages/store/print.page.dart';
import 'package:heritage_soft/pages/store/widgets/complete_sale_dialog.dart';
import 'package:intl/intl.dart';

class ShopPage extends StatefulWidget {
  final AccessoryRequestModel? request;
  const ShopPage({super.key, this.request});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  TextStyle cart_head_style = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  TextStyle cart_body_style = TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  TextEditingController search_controller = TextEditingController();
  FocusNode search_node = FocusNode();

  bool search_on = false;
  List<AccessoryModel> search_list = [];

  List<AccessoryItemModel> items = [];

  int total_P = 0;
  int total_Q = 0;

  @override
  void initState() {
    Future.delayed(
      Duration(milliseconds: 300),
      () => FocusScope.of(context).requestFocus(search_node),
    );

    if (widget.request != null) {
      widget.request!.accessories.forEach((element) {
        items.add(element);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    search_node.dispose();
    search_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.9;
    double height = MediaQuery.of(context).size.height * 0.9;
    return Scaffold(
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'images/office.jpg',
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
                          'images/shop.jpg',
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

          // profile area
          Align(
            alignment: Alignment.centerLeft,
            child: profile_area(),
          ),

          // main tab
          Expanded(child: main_box()),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  // top bar
  Widget topBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFd1cfcf)),
        ),
      ),
      child: Stack(
        children: [
          // heading
          Padding(
            padding: EdgeInsets.only(top: 14, bottom: 8),
            child: Center(
              child: Text(
                'Accessories Shop',
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

          // id area
          Positioned(
            top: 0,
            left: 0,
            child: id_sub_group(),
          ),

          // action buttons
          Positioned(
            top: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // close button
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.cancel,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // id & hmo
  Widget id_sub_group() {
    return widget.request != null && widget.request!.patient != null
        ? Padding(
            padding: EdgeInsets.only(top: 5, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // label
                Text(
                  'ID',
                  style: TextStyle(
                    color: Color(0xFFAFAFAF),
                    fontSize: 14,
                    letterSpacing: 1,
                    height: 1,
                  ),
                ),

                SizedBox(height: 4),

                // id group
                Row(
                  children: [
                    // patient id
                    Text(
                      widget.request!.patient!.patient_id,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 1,
                        height: 0.8,
                        shadows: [
                          Shadow(
                            color: Color(0xFF000000),
                            offset: Offset(0.7, 0.7),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Container();
  }

  // profile
  Widget profile_area() {
    return widget.request != null && widget.request!.patient != null
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Stack(
              children: [
                // name container
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF888570).withOpacity(0.66),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(33, 6, 10, 6),
                    child: Text(
                      '${widget.request!.patient!.f_name} ${widget.request!.patient!.l_name}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // profile image
                Positioned(
                  top: 0,
                  left: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFf3f0da),
                    foregroundColor: Colors.white,
                    backgroundImage:
                        widget.request!.patient!.user_image.isNotEmpty
                            ? NetworkImage(
                                widget.request!.patient!.user_image,
                              )
                            : null,
                    child: Center(
                      child: widget.request!.patient!.user_image.isEmpty
                          ? Image.asset(
                              'images/icon/health-person.png',
                              width: 25,
                              height: 25,
                            )
                          : Container(),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  // main box
  Widget main_box() {
    return Container(
      child: Row(
        children: [
          // action
          Expanded(child: cart_action()),

          SizedBox(width: 30),

          // cart
          cart_box(),
        ],
      ),
    );
  }

  // cart
  Widget cart_box() {
    return Container(
      width: 600,
      child: Column(
        children: [
          // header
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(139, 77, 104, 112),
            ),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Row(
              children: [
                // s/n
                Container(
                  width: 50,
                  child: Center(child: Text('S/N', style: cart_head_style)),
                ),

                // item
                Expanded(
                  child: Center(
                      child: Text('Accessories', style: cart_head_style)),
                ),

                // price
                Container(
                  width: 120,
                  child: Center(
                    child: Text('Price', style: cart_head_style),
                  ),
                ),

                Container(
                  width: 120,
                  child:
                      Center(child: Text('Quantity', style: cart_head_style)),
                ),

                // total
                Container(
                  width: 120,
                  child: Center(
                    child: Text('Total', style: cart_head_style),
                  ),
                ),

                // delete all
                Container(
                  width: 50,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        items.clear();
                        setState(() {});
                      },
                      child: Icon(
                        Icons.clear_all,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // list
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: items.map((e) {
                  int index = items.indexOf(e) + 1;
                  int total_price = e.accessory.price * e.qty;

                  return Container(
                    decoration: BoxDecoration(
                      color: index.isEven
                          ? Color.fromARGB(120, 69, 62, 53)
                          : Color.fromARGB(120, 84, 82, 78),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Row(
                      children: [
                        // s/n
                        Container(
                          width: 50,
                          child: Center(
                            child:
                                Text(index.toString(), style: cart_body_style),
                          ),
                        ),

                        // item
                        Expanded(
                          child: Text(
                            e.accessory.itemName,
                            style: cart_body_style,
                          ),
                        ),

                        // price
                        Container(
                          width: 120,
                          child: Center(
                            child: Text(
                                Helpers.format_amount(e.accessory.price,
                                    naira: true),
                                style: cart_body_style),
                          ),
                        ),

                        // quantity
                        Container(
                          width: 120,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // reduce
                                InkWell(
                                  onTap: () {
                                    if (e.qty == 1) return;
                                    e.qty--;
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white70,
                                    size: 15,
                                  ),
                                ),

                                // quantity
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  width: 30,
                                  child: Center(
                                    child: Text(
                                      e.qty.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                //add
                                InkWell(
                                  onTap: () {
                                    e.qty++;
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white70,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // total price
                        Container(
                          width: 120,
                          child: Center(
                            child: Text(
                                Helpers.format_amount(total_price, naira: true),
                                style: cart_body_style),
                          ),
                        ),

                        // delete
                        Container(
                          width: 50,
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                items.remove(e);
                                setState(() {});
                              },
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // submit button
          submit_btn(),
        ],
      ),
    );
  }

  // cart action
  Widget cart_action() {
    total_P = 0;
    total_Q = 0;
    items.forEach((e) {
      int total_price = e.accessory.price * e.qty;
      total_Q = total_Q + e.qty;
      total_P = total_P + total_price;
    });

    return Container(
      padding: EdgeInsets.only(left: 12),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // label
                  Text(
                    'Search accessories',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 10),

                  // searcch box
                  Container(
                    width: 300,
                    child: Column(
                      children: [
                        TextField(
                          controller: search_controller,
                          onChanged: search_accessory,
                          focusNode: search_node,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: (search_controller.text.isNotEmpty)
                                ? InkWell(
                                    onTap: () {
                                      search_controller.clear();
                                      search_list.clear();
                                      search_on = false;
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      color: Colors.white54,
                                    ))
                                : null,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),

                        // search list
                        search_on
                            ? Container(
                                height: 250,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: search_list.map((e) {
                                      return InkWell(
                                        onTap: () {
                                          var chk = items.where((element) =>
                                              element.accessory.key == e.key);
                                          if (chk.isEmpty) {
                                            var new_acc = AccessoryItemModel(
                                              accessory: e,
                                              qty: 1,
                                            );
                                            items.add(new_acc);
                                          } else {
                                            chk.first.qty++;

                                            Helpers.showToast(
                                              context: context,
                                              color: Colors.blue,
                                              toastText:
                                                  'Item quantity increased',
                                              icon: Icons.error,
                                            );
                                          }

                                          setState(() {});
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  e.itemName,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                '(${Helpers.format_amount(e.quantity)})',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                Helpers.format_amount(e.price,
                                                    naira: true),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // total
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 30, top: 10),
              child: Row(
                children: [
                  // toatl Q label
                  Text(
                    'Total quantity:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),

                  SizedBox(width: 6),

                  // toatl Quantity
                  Text(
                    Helpers.format_amount(total_Q),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Expanded(child: Container()),

                  // total P label
                  Text(
                    'Total amount:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),

                  SizedBox(width: 6),

                  // total Price
                  Text(
                    Helpers.format_amount(total_P, naira: true),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // submit button
  Widget submit_btn() {
    return Container(
      alignment: Alignment.bottomRight,
      margin: EdgeInsets.only(top: 10, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (items.isNotEmpty)
            Container(
              margin: EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () async {
                  bool conf_print = await Helpers.showConfirmation(
                    context: context,
                    title: 'Print Ticket',
                    message: 'Would you like to print a ticket for this items?',
                    boolean: true,
                  );

                  if (!conf_print) return;

                  RequestPrintModel printModel = RequestPrintModel(
                    date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    time: DateFormat.jm().format(DateTime.now()),
                    patient: widget.request?.patient != null
                        ? '${widget.request?.patient?.f_name ?? ''} ${widget.request?.patient?.l_name ?? ''}'
                        : '',
                    items: items
                        .map((p) => PrintItemModel(
                            name: p.accessory.itemName,
                            qty: p.qty,
                            price: p.accessory.price,
                            total_price: (p.accessory.price * p.qty)))
                        .toList(),
                  );

                  showDialog(
                      context: context,
                      builder: (context) => SalesPrintPage(print2: printModel));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.blueAccent,
                  ),
                  height: 45,
                  width: 45,
                  child: Center(
                    child: Icon(
                      Icons.print,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          
          InkWell(
            onTap: () async {
              // empty cart
              if (items.isEmpty) {
                Helpers.showToast(
                  context: context,
                  color: Colors.redAccent,
                  toastText: 'Select an Item to proceed',
                  icon: Icons.error,
                );
                return;
              }

              var auth_staff = AppData.get(context, listen: false).active_user;

              DateTime date_st = DateTime.now();

              SalesRecordModel order = SalesRecordModel(
                date: date_st,
                accessories: items,
                order_price: total_P,
                patient: widget.request?.patient,
                discount_price: 0,
                shortNote: '',
                paymentMethod: '',
                splitPaymentMethod: [],
                soldBy: auth_staff!,
                saleType: '',
              );

              var res = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    CompleteSaleDialog(total: total_Q, amount: total_P),
              );

              if (res != null) {
                Map result = res;
                order.paymentMethod = result['payment_method'];
                order.discount_price = result['final_amount'];
                order.splitPaymentMethod = result['split_payment'];
                order.shortNote = result['note'];
                order.date = result['date'] ?? DateTime.now();

                var sr = await StoreDatabaseHelpers.add_sales_record(
                  context,
                  data: order.toJson(soldByKey: auth_staff.key ?? ''),
                  showLoading: true,
                  showToast: true,
                );

                if (sr != null && sr['salesRecord'] != null) {
                  if (widget.request != null) {
                    await ClinicDatabaseHelpers.delete_accessory_request(
                      context,
                      data: {},
                      id: widget.request?.key ?? '',
                      showLoading: true,
                    );
                  }

                  search_list.clear();
                  search_controller.clear();
                  search_on = false;
                  items.clear();
                  setState(() {});

                  bool conf_print = await Helpers.showConfirmation(
                    context: context,
                    title: 'Print Receipt',
                    message: 'Would you like to print a receipt for this sale?',
                    boolean: true,
                  );

                  if (conf_print) {
                    var record = SalesRecordModel.fromJson(sr['salesRecord']);
                    SalesPrintModel printModel = SalesPrintModel(
                      date: DateFormat('dd/MM/yyyy').format(record.date),
                      time: DateFormat.jm().format(record.date),
                      receipt_id: record.order_id,
                      seller: record.soldBy.f_name,
                      customer:
                          '${record.patient?.f_name ?? ''} ${record.patient?.l_name ?? ''}',
                      items: record.accessories
                          .map((p) => PrintItemModel(
                              name: p.accessory.itemName,
                              qty: p.qty,
                              price: p.accessory.price,
                              total_price: (p.accessory.price * p.qty)))
                          .toList(),
                      sub_total: record.order_price,
                      discount: record.order_price - record.discount_price,
                      total: record.discount_price,
                      pmts: record.splitPaymentMethod.isNotEmpty
                          ? record.splitPaymentMethod
                          : [
                              PaymentMethodModel(
                                paymentMethod: record.paymentMethod,
                                amount: record.discount_price,
                              )
                            ],
                    );

                    showDialog(
                        context: context,
                        builder: (context) =>
                            SalesPrintPage(print: printModel));
                  }
                }
              }
            },
            child: Container(
              width: 200,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

  // Funtion
  search_accessory(String value) {
    search_on = true;
    search_list.clear();

    if (value.isNotEmpty) {
      search_list = AppData.get(context, listen: false)
          .accessories
          .where((element) =>
              element.itemName.toLowerCase().contains(value.toLowerCase()) ||
              element.itemCode.toLowerCase().contains(value.toLowerCase()) ||
              element.itemId.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else {
      search_on = false;
    }

    setState(() {});
  }

  //
}
