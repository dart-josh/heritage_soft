import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';
import 'package:heritage_soft/datamodels/store_models/restock_accessory_record.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/store_database_helpers.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class RestockAccessoriesPage extends StatefulWidget {
  final RestockAccessoryRecordModel? record;
  const RestockAccessoriesPage({
    super.key,
    this.record,
  });

  @override
  State<RestockAccessoriesPage> createState() => _RestockAccessoriesPageState();
}

class _RestockAccessoriesPageState extends State<RestockAccessoriesPage> {
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

  int total_Q = 0;

  TextEditingController shortNote_controller = TextEditingController();
  TextEditingController supplier_controller = TextEditingController();

  get_values() {
    if (widget.record != null) {
      items = widget.record!.accessories;
      supplier_controller.text = widget.record!.supplier;
      shortNote_controller.text = widget.record!.shortNote;
    }
  }

  @override
  void initState() {
    get_values();
    Future.delayed(
      Duration(milliseconds: 300),
      () => FocusScope.of(context).requestFocus(search_node),
    );
    super.initState();
  }

  @override
  void dispose() {
    search_node.dispose();
    search_controller.dispose();
    shortNote_controller.dispose();
    supplier_controller.dispose();
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
                          'images/accessories.jpg',
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
                'Restock Accessories',
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

                Container(
                  width: 120,
                  child:
                      Center(child: Text('Quantity', style: cart_head_style)),
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
    total_Q = 0;
    items.forEach((e) {
      total_Q = total_Q + e.qty;
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
              child: Column(
                children: [
                  // shortNote
                  Container(
                    // width: 180,
                    child: Text_field(
                      controller: shortNote_controller,
                      label: 'Short note',
                    ),
                  ),

                  // quantity & supplier
                  Row(
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

                      SizedBox(width: 6),

                      Expanded(child: Container()),

                      // supplier
                      Container(
                        width: 180,
                        child: Text_field(
                          controller: supplier_controller,
                          label: 'Supplier',
                        ),
                      ),
                    ],
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
              toastText: 'Select an Item to proceed',
              icon: Icons.error,
            );
            return;
          }

          bool conf = await Helpers.showConfirmation(
            context: context,
            title: 'Submit Entry',
            message: 'You are about to submit this entry',
          );

          if (!conf) return;

          var auth_user = AppData.get(context, listen: false).active_user;

          DateTime date_st = DateTime.now();

          RestockAccessoryRecordModel restock_order =
              RestockAccessoryRecordModel(
            key: widget.record?.key,
            date: date_st,
            accessories: items,
            shortNote: shortNote_controller.text,
            enteredBy: auth_user!,
            supplier: supplier_controller.text,
          );

          var sr =
              await StoreDatabaseHelpers.add_update_accessory_restock_record(
            context,
            data: restock_order.toJson(userKey: auth_user.key ?? ''),
            showLoading: true,
            showToast: true,
          );

          if (sr != null && sr['restockRecord'] != null) {
            search_list.clear();
            search_controller.clear();
            search_on = false;
            items.clear();
            supplier_controller.clear();
            shortNote_controller.clear();
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
