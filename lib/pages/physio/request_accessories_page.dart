import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/accessories_shop_model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/physio_database_helpers.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:provider/provider.dart';

class RequestAccessoriesPage extends StatefulWidget {
  final PatientModel patient;
  const RequestAccessoriesPage({super.key, required this.patient});

  @override
  State<RequestAccessoriesPage> createState() => _RequestAccessoriesPageState();
}

class _RequestAccessoriesPageState extends State<RequestAccessoriesPage> {
  TextStyle cart_head_style = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  TextStyle cart_body_style = TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  List<AccessoryItemModel> items = [];

  TextEditingController search_controller = TextEditingController();
  FocusNode search_node = FocusNode();

  bool search_on = false;
  List<AccessoryModel> search_list = [];

  int total_Q = 0;

  @override
  void initState() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;
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
                'Accessories',
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
    return Padding(
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
                widget.patient.patient_id,
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
    );
  }

  // profile
  Widget profile_area() {
    return Container(
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
                widget.patient.f_name.trim(),
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
              backgroundImage: widget.patient.user_image.isNotEmpty
                  ? NetworkImage(
                      widget.patient.user_image,
                    )
                  : null,
              child: Center(
                child: widget.patient.user_image.isEmpty
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
    );
  }

  // main box
  Widget main_box() {
    return Container(
      child: Row(
        children: [
          // action
          Expanded(child: search_area()),

          SizedBox(width: 20),

          // cart
          cart_box(),
        ],
      ),
    );
  }

  // cart
  Widget cart_box() {
    return Container(
      width: 540,
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

                // quantity
                Container(
                  width: 120,
                  child:
                      Center(child: Text('Quantity', style: cart_head_style)),
                ),

                // clear cart
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
                            e.accessory.name,
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

                                SizedBox(width: 5),

                                // quantity
                                Container(
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
                                SizedBox(width: 5),

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
          Container(
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

                var res = await showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Confirm Request',
                    subtitle:
                        'You are about to send a request for the following items, would you like to proceed?',
                  ),
                );

                if (res != null && res == true) {
                  A_ShopModel shop = A_ShopModel(
                    key: Helpers.generate_order_id(),
                    accessories: items,
                    patient: widget.patient,
                  );

                  Helpers.showLoadingScreen(context: context);

                  bool dt = await PhysioDatabaseHelpers.add_update_accessory_request(
                      context, data: shop.toJson());

                  Navigator.pop(context);

                  if (!dt) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'An Error Occured',
                      icon: Icons.error,
                    );
                    return;
                  }

                  search_list.clear();
                  search_controller.clear();
                  search_on = false;
                  items.clear();

                  // remove page
                  Navigator.pop(context);

                  Helpers.showToast(
                    context: context,
                    color: Colors.blueAccent,
                    toastText: 'Request Sent',
                    icon: Icons.done,
                  );
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
          ),
        ],
      ),
    );
  }

  // search area
  Widget search_area() {
    total_Q = 0;
    items.forEach((e) {
      total_Q = total_Q + e.qty;
    });
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          // search area
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
                            suffixIcon: search_controller.text.isNotEmpty
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
                                      size: 20,
                                    ),
                                  )
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

                                          // item already exist
                                          if (chk.isNotEmpty) {
                                            chk.first.qty++;
                                            Helpers.showToast(
                                              context: context,
                                              color: Colors.blue,
                                              toastText:
                                                  'Item quantity increased',
                                              icon: Icons.text_increase,
                                            );
                                          }
                                          // new item
                                          else {
                                            var new_acc = AccessoryItemModel(
                                              accessory: e,
                                              qty: 1,
                                            );
                                            items.add(new_acc);
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
                                              // item name
                                              Expanded(
                                                child: Text(
                                                  e.name,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
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

          // total quantity
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 30, top: 10),
              child: Row(
                children: [
                  Text(
                    'Total quantity:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    Helpers.format_amount(total_Q),
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

  //

  // Funtion
  // search accessory
  search_accessory(String value) {
    search_on = true;
    search_list.clear();

    if (value.isNotEmpty) {
      search_list = Provider.of<AppData>(context, listen: false)
          .accessories
          .where((element) =>
              element.name.toLowerCase().contains(value.toLowerCase()) ||
              element.code.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else {
      search_on = false;
    }

    setState(() {});
  }

  //
}
