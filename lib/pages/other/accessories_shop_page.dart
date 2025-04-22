import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/datamodels/accessories_shop_model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AccessoriesShopPage extends StatefulWidget {
  final A_ShopModel? shop;
  const AccessoriesShopPage({super.key, this.shop});

  @override
  State<AccessoriesShopPage> createState() => _AccessoriesShopPageState();
}

class _AccessoriesShopPageState extends State<AccessoriesShopPage> {
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

    if (widget.shop != null) {
      widget.shop!.accessories.forEach((element) {
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: profile_area(),
            ),
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
    return widget.shop != null && widget.shop!.patient != null
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
                      widget.shop!.patient!.patient_id,
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
    return widget.shop != null && widget.shop!.patient != null
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                      widget.shop!.patient!.f_name,
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
                    backgroundImage: widget.shop!.patient!.user_image.isNotEmpty
                        ? NetworkImage(
                            widget.shop!.patient!.user_image,
                          )
                        : null,
                    child: Center(
                      child: widget.shop!.patient!.user_image.isEmpty
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
                            e.accessory.name,
                            style: cart_body_style,
                          ),
                        ),

                        // price
                        Container(
                          width: 120,
                          child: Center(
                            child: Text(
                                Helpers.format_amount(e.accessory.price, naira: true),
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

                                // qunatity
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
                                              color: Colors.redAccent,
                                              toastText: 'Item added already',
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
                                                  e.name,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                '(${Helpers.format_amount(e.qty)})',
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

                  // toatl Qunatity
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
      child: InkWell(
        onTap: () async {
          // empty cart
          if (items.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'No Item is this cart',
              icon: Icons.error,
            );
            return;
          }

          DateTime date_st = DateTime.now();

          ShopOrderModel order = ShopOrderModel(
            order_id: Helpers.generate_order_id(),
            date: date_st.toString(),
            items: items,
            order_price: total_P,
            order_qty: total_Q,
            sold_by: '',
          );

          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ShopConfirmDialog(order: order),
          );

          if (res != null) {
            Map result = res;
            if (result['split'] == true) {
              order.split = true;
              order.payment_method = result['payment_method'];
              order.discount_price = result['newPrice'];
              order.payment_method2 = result['payment_method2'];
              order.amount1 = result['amt1'];
              order.amount2 = result['amt2'];
            } else {
              order.payment_method = result['payment_method'];
              order.discount_price = result['newPrice'];
              order.split = false;
            }

            Helpers.showLoadingScreen(context: context);

            String title = DateFormat('MMMM').format(date_st);
            int year = date_st.year;
            String month = '$title, $year';

            String date = Helpers.date_format(date_st, same_year: true);

            bool sr = await AdminDatabaseHelpers.add_accessory_sales_record(
                '$month/$date', order.toJson());

            if (!sr) {
              Navigator.pop(context);
              Helpers.showToast(
                context: context,
                color: Colors.redAccent,
                toastText: 'An Error Occured',
                icon: Icons.error,
              );
              return;
            }

            if (widget.shop != null) {
              AdminDatabaseHelpers.remove_accessory_request(widget.shop!.key ?? '');
            }

            // success
            Navigator.pop(context);
            Helpers.showToast(
              context: context,
              color: Colors.blueAccent,
              toastText: 'Successful',
              icon: Icons.done,
            );

            search_list.clear();
            search_controller.clear();
            search_on = false;
            items.clear();
            setState(() {});
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
    );
  }
  //

  // Funtion
  search_accessory(String value) {
    search_on = true;
    search_list.clear();

    if (value.isNotEmpty) {
      search_list = Provider.of<AppData>(context, listen: false)
          .accessories
          .where((element) =>
              element.name.toLowerCase().contains(value.toLowerCase()) ||
              element.code.toLowerCase().contains(value.toLowerCase()) ||
              element.id.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else {
      search_on = false;
    }

    setState(() {});
  }

  //
}

class ShopConfirmDialog extends StatefulWidget {
  final ShopOrderModel order;
  const ShopConfirmDialog({super.key, required this.order});

  @override
  State<ShopConfirmDialog> createState() => _ShopConfirmDialogState();
}

class _ShopConfirmDialogState extends State<ShopConfirmDialog> {
  String? payment_method;
  String? payment_method2;
  List<String> payment_option = ['POS', 'Cash', 'Transfer'];

  TextStyle labelStyle = TextStyle(
    color: Color(0xFFc3c3c3),
    fontSize: 12,
  );

  final TextEditingController discount_controller = TextEditingController();
  final TextEditingController amt1_controller = TextEditingController();
  final TextEditingController amt2_controller = TextEditingController();

  @override
  void initState() {
    discount_controller.addListener(() {
      if (discount_controller.text.isNotEmpty) {
        newPrice =
            widget.order.order_price - int.parse(discount_controller.text);
      } else {
        newPrice = 0;
      }

      int pp = newPrice != 0 ? newPrice : widget.order.order_price;

      int amt1 =
          amt1_controller.text.isNotEmpty ? int.parse(amt1_controller.text) : 0;

      int amt2 =
          amt2_controller.text.isNotEmpty ? int.parse(amt2_controller.text) : 0;

      bal_split = pp - (amt1 + amt2);

      setState(() {});
    });

    amt1_controller.addListener(() {
      if (amt1_controller.text.isEmpty) {
        amt2_controller.clear();
        payment_method2 = null;

        bal_split = newPrice != 0 ? newPrice : widget.order.order_price;
      } else {
        int pp = newPrice != 0 ? newPrice : widget.order.order_price;

        int amt1 = int.parse(amt1_controller.text);

        int amt2 = amt2_controller.text.isNotEmpty
            ? int.parse(amt2_controller.text)
            : 0;

        bal_split = pp - (amt1 + amt2);
      }
      setState(() {});
    });

    amt2_controller.addListener(() {
      if (amt2_controller.text.isNotEmpty) {
        int pp = newPrice != 0 ? newPrice : widget.order.order_price;

        int amt1 = int.parse(amt1_controller.text);
        int amt2 = int.parse(amt2_controller.text);

        bal_split = pp - (amt1 + amt2);
      } else {
        int pp = newPrice != 0 ? newPrice : widget.order.order_price;

        int amt1 = int.parse(amt1_controller.text);
        int amt2 = 0;

        bal_split = pp - (amt1 + amt2);
      }
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    discount_controller.dispose();
    amt1_controller.dispose();
    amt2_controller.dispose();
    super.dispose();
  }

  int newPrice = 0;

  bool split = false;
  int bal_split = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: 300,
        // height: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // body
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                  color: Color.fromARGB(255, 147, 138, 112).withOpacity(.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2),

                    // title
                    Stack(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Confrim order',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        // close button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 38,
                                child: Center(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),

                    // horizontal line
                    Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white38),
                        ),
                      ),
                    ),

                    SizedBox(height: 4),

                    // quantity label
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(
                        'Total qunatity',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    // quantity
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        Helpers.format_amount(widget.order.order_qty),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // price label
                    Align(
                      child: Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // price
                    Align(
                      child: Column(
                        children: [
                          Text(
                            Helpers.format_amount(widget.order.order_price,
                                naira: true),
                            style: TextStyle(
                              fontSize: (discount_controller.text.isNotEmpty)
                                  ? 14
                                  : 25,
                              color: Colors.white,
                              fontWeight: (discount_controller.text.isNotEmpty)
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              decoration: (discount_controller.text.isNotEmpty)
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: Colors.white,
                            ),
                          ),

                          // discount price
                          (discount_controller.text.isNotEmpty)
                              ? Text(
                                  Helpers.format_amount(newPrice, naira: true),
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // discount box
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text_field(
                        controller: discount_controller,
                        label: 'Discount',
                        format: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),

                    SizedBox(height: 20),

                    // payment method
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: split
                          ? split_form()
                          : Column(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment method', style: labelStyle),
                                SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                  dropdownColor: Colors.black87,
                                  style: TextStyle(color: Colors.white),
                                  value: payment_method,
                                  items: payment_option.isNotEmpty
                                      ? payment_option
                                          .map(
                                            (e) => DropdownMenuItem<String>(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList()
                                      : [],
                                  onChanged: (val) {
                                    if (val != null) {
                                      payment_method = val;
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                    ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          amt1_controller.clear();
                          amt2_controller.clear();
                          payment_method = null;
                          payment_method2 = null;

                          bal_split = newPrice != 0
                              ? newPrice
                              : widget.order.order_price;
                          setState(() {
                            split = !split;
                          });
                        },
                        child: Text(split ? 'Single Payment' : 'Split Payment'),
                      ),
                    ),

                    SizedBox(height: 20),

                    // info
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Confirm the order has been paid in full before proceeding',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    SizedBox(height: 20),

                    // confirm button
                    InkWell(
                      onTap: () {
                        if (split) {
                          if (payment_method == null ||
                              amt1_controller.text.isEmpty) {
                            Helpers.showToast(
                              context: context,
                              color: Colors.redAccent,
                              toastText: 'First payment empty',
                              icon: Icons.error,
                            );
                            return;
                          }

                          if (payment_method2 == null ||
                              amt2_controller.text.isEmpty) {
                            Helpers.showToast(
                              context: context,
                              color: Colors.redAccent,
                              toastText: 'Second payment empty',
                              icon: Icons.error,
                            );
                            return;
                          }

                          if (payment_method == payment_method2) {
                            Helpers.showToast(
                              context: context,
                              color: Colors.redAccent,
                              toastText: 'Split payment error',
                              icon: Icons.error,
                            );
                            return;
                          }

                          int amt = int.parse(amt1_controller.text) +
                              int.parse(amt2_controller.text);

                          if (newPrice != 0) {
                            if (amt != newPrice) {
                              Helpers.showToast(
                                context: context,
                                color: Colors.redAccent,
                                toastText: 'Amount do not tally',
                                icon: Icons.error,
                              );
                              return;
                            }
                          } else {
                            if (amt != widget.order.order_price) {
                              Helpers.showToast(
                                context: context,
                                color: Colors.redAccent,
                                toastText: 'Amount do not tally',
                                icon: Icons.error,
                              );
                              return;
                            }
                          }

                          Map map = {
                            'payment_method': payment_method,
                            'newPrice': newPrice,
                            'split': true,
                            'payment_method2': payment_method2,
                            'amt1': int.parse(amt1_controller.text),
                            'amt2': int.parse(amt2_controller.text),
                          };

                          Navigator.pop(context, map);
                        } else {
                          if (payment_method == null) {
                            Helpers.showToast(
                              context: context,
                              color: Colors.redAccent,
                              toastText: 'Select a payment method',
                              icon: Icons.error,
                            );
                            return;
                          }

                          Map map = {
                            'payment_method': payment_method,
                            'newPrice': newPrice,
                            'split': false,
                          };

                          Navigator.pop(context, map);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        margin: EdgeInsets.all(8),
                        child: Center(
                            child: Text(
                          'Confirm',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // split form
  Widget split_form() {
    return Column(
      children: [
        Text(
          'Payment 1',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 4),
        // pmt 1
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Text_field(
                controller: amt1_controller,
                hintText: 'Amount',
                format: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 5,
              child: DropdownButtonFormField<String>(
                itemHeight: 40,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white54,
                    ),
                  ),
                ),
                dropdownColor: Colors.black87,
                style: TextStyle(color: Colors.white),
                value: payment_method,
                items: payment_option.isNotEmpty
                    ? payment_option
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList()
                    : [],
                onChanged: (val) {
                  if (val != null) {
                    payment_method = val;
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 10),

        Text(
          'Payment 2',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 4),
        // pmt 2
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Text_field(
                controller: amt2_controller,
                hintText: 'Amount',
                format: [FilteringTextInputFormatter.digitsOnly],
                edit: !((payment_method != null) &&
                    amt1_controller.text.isNotEmpty),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 5,
              child: DropdownButtonFormField<String>(
                onTap: () {
                  if (payment_method == null) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Fill Payment 1 first',
                      icon: Icons.error,
                    );
                  }
                },
                itemHeight: 40,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white54,
                    ),
                  ),
                ),
                dropdownColor: Colors.black87,
                style: TextStyle(color: Colors.white),
                value: payment_method2,
                items: payment_method != null &&
                        amt1_controller.text.isNotEmpty &&
                        payment_option.isNotEmpty
                    ? payment_option
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList()
                    : [],
                onChanged: (val) {
                  if (val != null) {
                    payment_method2 = val;
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 10),

        Text(
          'Balance: ${Helpers.format_amount(bal_split, naira: true)}',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  //
}
