import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/pages/gym/client_pofile_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ClientsList extends StatefulWidget {
  const ClientsList({super.key});

  @override
  State<ClientsList> createState() => _ClientsListState();
}

class _ClientsListState extends State<ClientsList> {
  // CONTROLLER && NODE
  TextEditingController search_bar_controller = TextEditingController();
  FocusNode search_bar_node = FocusNode();

  TextStyle option_style = TextStyle(color: Colors.white, fontSize: 13);
  TextStyle title_style = TextStyle(color: Colors.black, fontSize: 16);

  List<ClientListModel> main_clients = [];
  List<ClientListModel> clients = [];
  List<ClientListModel> search_list = [];
  bool emptySearch = false;

  int client_count = 0;
  int filter_client_count = 0;

  double search_box_width = 0;
  bool search_on = false;

  bool filter_menu_open = false;
  bool filter_on = false;

  bool status_expanded = false;
  bool status_filter_on = false;
  bool status_filter_val = false;

  bool sub_type_expanded = false;
  bool sub_type_filter_on = false;
  String sub_type_filter_val = '';
  List<String> sub_type_values = [
    'Individual',
    'Couples',
    'Family',
    'HMO Plan',
    'Clear',
  ];

  bool sub_plan_expanded = false;
  bool sub_plan_filter_on = false;
  String sub_plan_filter_val = '';
  List<String> sub_plan_values = [
    'Daily',
    'Weekly',
    'Fortnightly',
    'Monthly',
    '2 Months',
    'Quarterly',
    'Half-Yearly',
    'Yearly',
    'Boxing',
    'HMO Plan',
    'HMO Hybrid',
    'Clear',
  ];

  bool addons_expanded = false;
  bool addons_filter_on = false;
  bool addons_bx_val = false;
  bool addons_pt_val = false;
  bool addons_pt_sp_val = false;
  bool addons_pt_pp_val = false;
  bool addons_physio_val = false;

  @override
  void initState() {
    refresh_hmo_week();
    super.initState();
  }

  refresh_hmo_week() {
    GymDatabaseHelpers.reset_week_for_hmo_plan_clients(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.85;
    double height = MediaQuery.of(context).size.height * 0.85;
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
                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F8E1).withOpacity(0.69),
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

  // filter function
  List<ClientListModel> filter_module() {
    if (!filter_on) return main_clients;

    return main_clients
        .where((element) =>
            ((status_filter_on)
                ? element.sub_status == status_filter_val
                : true) &&
            ((sub_type_filter_on)
                ? element.sub_type!.toLowerCase() ==
                    sub_type_filter_val.toLowerCase()
                : true) &&
            ((sub_plan_filter_on)
                ? element.sub_plan!.toLowerCase() ==
                    sub_plan_filter_val.toLowerCase()
                : true) &&
            filter_addons(element))
        .toList();

    // return main_clients;
  }

  // filter addons function
  bool filter_addons(ClientListModel element) {
    if (addons_filter_on) {
      return (((addons_bx_val) ? element.boxing! : true) &&
          ((addons_pt_val) ? element.pt_status! : true) &&
          ((addons_pt_sp_val)
              ? (element.pt_status! &&
                  element.pt_plan!.toLowerCase().contains('standard'))
              : true) &&
          ((addons_pt_pp_val)
              ? (element.pt_status! &&
                  element.pt_plan!.toLowerCase().contains('premium'))
              : true) &&
          ((addons_physio_val) ? element.physio_cl! : true));
    } else {
      return true;
    }
  }

  // WIDGETS

  // main page
  Widget main_page() {
    main_clients = Provider.of<AppData>(context).clients;
    clients = filter_module();

    client_count = main_clients.length;
    filter_client_count = clients.length;

    if (clients.isNotEmpty && search_list.isNotEmpty)
      search_clients(search_bar_controller.text, build: true);

    return Column(
      children: [
        // top bar
        topBar(),

        // body area
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  // filter area
                  filter_area(),

                  // list
                  Expanded(
                    child: (clients.isEmpty)
                        ? Center(
                            child: Text(
                              'NO CLIENTS',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : list(),
                  ),
                ],
              ),
              Positioned(
                top: 45,
                left: 20,
                child: filter_menu_open ? filter_menu() : Container(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // search clients
  void search_clients(String value, {bool build = false}) {
    search_list.clear();
    emptySearch = false;

    if (value.isNotEmpty) {
      var data = clients.where(
        (element) =>
            element.f_name!
                .toLowerCase()
                .contains(value.toLowerCase().trim()) ||
            element.m_name!
                .toLowerCase()
                .contains(value.toLowerCase().trim()) ||
            element.l_name!
                .toLowerCase()
                .contains(value.toLowerCase().trim()) ||
            element.id!.toLowerCase().contains(value.toLowerCase().trim()),
      );

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

  // top bar
  Widget topBar() {
    var nt = NumberFormat('#,###');
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF707070)),
        ),
      ),
      child: Stack(
        children: [
          // header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                'Client List - (${nt.format(client_count)})',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1),
              ),
            ),
          ),

          // action button
          Positioned(
            top: 10,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // serach field
                AnimatedContainer(
                  width: search_box_width,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linear,
                  onEnd: () {
                    setState(() {
                      if (search_box_width == 230) {
                        search_on = true;
                        FocusScope.of(context).requestFocus(search_bar_node);
                      } else {
                        search_on = false;
                      }
                    });
                  },
                  child: Container(
                    width: search_box_width,
                    height: 33,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: !search_on
                        ? Container()
                        : TextField(
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            onChanged: search_clients,
                            controller: search_bar_controller,
                            focusNode: search_bar_node,
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
                                  if (search_bar_controller.text.isEmpty) {
                                    search_box_width = 0;
                                  } else {
                                    search_bar_controller.clear();
                                  }
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
                ),

                // search button
                !search_on
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            search_on = !search_on;
                            search_box_width = 230;
                          });
                        },
                        child: Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 24,
                        ),
                      )
                    : Container(),

                SizedBox(width: 10),

                // close button
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.cancel,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // filter area
  Widget filter_area() {
    var nt = NumberFormat('#,###');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // filter button
          TextButton(
            onPressed: () {
              setState(() {
                filter_menu_open = !filter_menu_open;
              });
            },
            child: Text(
              filter_menu_open ? 'Close menu' : 'Filter',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),

          SizedBox(width: 10),

          // active filter list
          Expanded(
            child: (filter_on)
                ? Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      // sub status
                      if (status_filter_on)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            status_filter_val ? 'Active' : 'Inactive',
                            style: option_style,
                          ),
                        ),

                      // sub type
                      if (sub_type_filter_on)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            sub_type_filter_val,
                            style: option_style,
                          ),
                        ),

                      // sub plan
                      if (sub_plan_filter_on)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            sub_plan_filter_val,
                            style: option_style,
                          ),
                        ),

                      // boxing
                      if (addons_bx_val)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            'Boxing',
                            style: option_style,
                          ),
                        ),

                      // pt
                      if (addons_pt_val)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            'Personal Training',
                            style: option_style,
                          ),
                        ),

                      // pt standard
                      if (addons_pt_sp_val)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            'PT Standard',
                            style: option_style,
                          ),
                        ),

                      // pt premium
                      if (addons_pt_pp_val)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            'PT Premium',
                            style: option_style,
                          ),
                        ),

                      // physio
                      if (addons_physio_val)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Text(
                            'Physio',
                            style: option_style,
                          ),
                        ),
                    ],
                  )
                : Container(),
          ),

          SizedBox(width: 10),

          // filter list count
          if (filter_on)
            Container(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                nt.format(filter_client_count),
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  // fontSize: 14,
                ),
              ),
            ),

          // clear filter
          if (filter_on)
            TextButton(
              onPressed: () {
                setState(() {
                  filter_on = false;
                  filter_menu_open = false;
                  status_filter_on = false;
                  sub_type_filter_on = false;
                  sub_plan_filter_on = false;
                  addons_filter_on = false;
                  addons_expanded = false;
                  addons_bx_val = false;
                  addons_pt_val = false;
                  addons_pt_sp_val = false;
                  addons_pt_pp_val = false;
                  addons_physio_val = false;
                });
              },
              child: Text('Clear'),
            ),
        ],
      ),
    );
  }

  // filter menu
  Widget filter_menu() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            offset: Offset(0.7, 0.7),
            color: Colors.black26,
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // status
          InkWell(
            onTap: () {
              setState(() {
                status_expanded = !status_expanded;
              });
            },
            hoverColor: Colors.grey.shade400,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscription Status',
                    style: title_style,
                  ),
                  Icon(
                    status_expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // status options
          if (status_expanded)
            Container(
              margin: EdgeInsets.only(left: 25, right: 8),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  // active
                  InkWell(
                    onTap: () {
                      setState(() {
                        status_filter_val = true;
                        status_filter_on = true;
                        status_expanded = false;
                        filter_on = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Text(
                        'Active',
                        style: option_style,
                      ),
                    ),
                  ),

                  // expired
                  InkWell(
                    onTap: () {
                      setState(() {
                        status_filter_val = false;
                        status_filter_on = true;
                        status_expanded = false;
                        filter_on = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Text(
                        'Inactive',
                        style: option_style,
                      ),
                    ),
                  ),

                  // clear
                  InkWell(
                    onTap: () {
                      setState(() {
                        status_filter_on = false;
                        status_expanded = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: option_style,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // sub type
          InkWell(
            onTap: () {
              setState(() {
                sub_type_expanded = !sub_type_expanded;
              });
            },
            hoverColor: Colors.grey.shade400,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscription Type',
                    style: title_style,
                  ),
                  Icon(
                    sub_type_expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // sub type options
          if (sub_type_expanded)
            Container(
              margin: EdgeInsets.only(left: 25, right: 8),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: sub_type_values
                    .map(
                      (element) => InkWell(
                        onTap: () {
                          if (element == 'Clear') {
                            setState(() {
                              sub_type_filter_val = '';
                              sub_type_filter_on = false;
                              sub_type_expanded = false;
                            });
                          } else {
                            setState(() {
                              sub_type_filter_val = element;
                              sub_type_filter_on = true;
                              sub_type_expanded = false;
                              filter_on = true;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (element == 'Clear')
                                ? Colors.red.shade400
                                : Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          child: (element == 'Clear')
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      element,
                                      style: option_style,
                                    ),
                                  ],
                                )
                              : Text(
                                  element,
                                  style: option_style,
                                ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // sub plan
          InkWell(
            onTap: () {
              setState(() {
                sub_plan_expanded = !sub_plan_expanded;
              });
            },
            hoverColor: Colors.grey.shade400,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscription Plan',
                    style: title_style,
                  ),
                  Icon(
                    sub_plan_expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // sub plan options
          if (sub_plan_expanded)
            Container(
              margin: EdgeInsets.only(left: 25, right: 8),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: sub_plan_values
                    .map(
                      (element) => InkWell(
                        onTap: () {
                          if (element == 'Clear') {
                            setState(() {
                              sub_plan_filter_val = '';
                              sub_plan_filter_on = false;
                              sub_plan_expanded = false;
                            });
                          } else {
                            setState(() {
                              sub_plan_filter_val = element;
                              sub_plan_filter_on = true;
                              sub_plan_expanded = false;
                              filter_on = true;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (element == 'Clear')
                                ? Colors.red.shade400
                                : Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          child: (element == 'Clear')
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      element,
                                      style: option_style,
                                    ),
                                  ],
                                )
                              : Text(
                                  element,
                                  style: option_style,
                                ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // addons
          InkWell(
            onTap: () {
              setState(() {
                addons_expanded = !addons_expanded;
              });
            },
            hoverColor: Colors.grey.shade400,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Extras',
                    style: title_style,
                  ),
                  Icon(
                    addons_expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // addons options
          if (addons_expanded)
            Container(
              margin: EdgeInsets.only(left: 25, right: 8),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  // boxing
                  InkWell(
                    onTap: () {
                      setState(() {
                        addons_filter_on = true;
                        filter_on = true;
                        addons_bx_val = !addons_bx_val;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            addons_bx_val
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.white70,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Boxing',
                            style: option_style,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // personal training
                  InkWell(
                    onTap: () {
                      setState(() {
                        addons_filter_on = true;
                        filter_on = true;
                        addons_pt_val = !addons_pt_val;
                        if (!addons_pt_val) {
                          addons_pt_sp_val = false;
                          addons_pt_pp_val = false;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            addons_pt_val
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.white70,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Personal Training',
                            style: option_style,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // pt standard
                  if (addons_pt_val)
                    InkWell(
                      onTap: () {
                        setState(() {
                          addons_filter_on = true;
                          filter_on = true;
                          addons_pt_sp_val = !addons_pt_sp_val;
                          addons_pt_pp_val = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              addons_pt_sp_val
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: Colors.white70,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PT Standard',
                              style: option_style,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // pt premium
                  if (addons_pt_val)
                    InkWell(
                      onTap: () {
                        setState(() {
                          addons_filter_on = true;
                          filter_on = true;
                          addons_pt_pp_val = !addons_pt_pp_val;
                          addons_pt_sp_val = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              addons_pt_pp_val
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: Colors.white70,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PT Premium',
                              style: option_style,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // physio
                  InkWell(
                    onTap: () {
                      setState(() {
                        addons_filter_on = true;
                        filter_on = true;
                        addons_physio_val = !addons_physio_val;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            addons_physio_val
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.white70,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Pysio',
                            style: option_style,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // clear
                  InkWell(
                    onTap: () {
                      setState(() {
                        addons_filter_on = false;
                        addons_expanded = false;

                        addons_bx_val = false;
                        addons_pt_val = false;
                        addons_pt_sp_val = false;
                        addons_pt_pp_val = false;
                        addons_physio_val = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: option_style,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // client list
  Widget list() {
    clients.sort((a, b) => int.parse(b.id!.split('-')[1])
        .compareTo(int.parse(a.id!.split('-')[1])));

    return
        // empty serach
        emptySearch
            ? Center(
                child: Text(
                  'Search does not match any record',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              )

            // searchlist
            : search_list.isNotEmpty
                ? Container(
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                      ),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: BouncingScrollPhysics(),
                      children: search_list.map((e) => list_tile(e)).toList(),
                    ),
                  )

                // clients list
                : Container(
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                      ),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: BouncingScrollPhysics(),
                      children: clients.map((e) => list_tile(e)).toList(),
                    ),
                  );
  }

  // client list tile
  Widget list_tile(ClientListModel client) {
    String cl_name = '${client.f_name} ${client.l_name}';

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientProfilePage(cl_id: client.key!),
          ),
        );

        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            // profile image
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Color(0xFFf97ecf),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: client.user_image!.isEmpty
                    ? Image.asset(
                        'images/icon/user-alt.png',
                        width: 50,
                        height: 50,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          client.user_image!,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            SizedBox(width: 15),

            // user details
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // id & subscription
                  Row(
                    children: [
                      // id
                      Text(
                        client.id!,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),

                      Expanded(child: Container()),

                      // subscription
                      client.sub_plan!.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Color(0xFF3C58E6).withOpacity(0.67),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'images/icon/map-gym.png',
                                    width: 10,
                                    height: 10,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    client.sub_plan!,
                                    style: TextStyle(
                                      fontSize: 8,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),

                  SizedBox(height: 6),

                  // name
                  Text(
                    cl_name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      height: 1,
                    ),
                  ),

                  SizedBox(height: 8),

                  // status
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(client.sub_status! ? 0xFF88ECA9 : 0xFFFF5252)
                          .withOpacity(0.67),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle,
                            color: Color(
                                client.sub_status! ? 0xFF19F763 : 0xFFFF5252),
                            size: 8),
                        SizedBox(width: 6),
                        Text(
                          client.sub_status! ? 'Active' : 'Inactive',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //
          ],
        ),
      ),
    );
  }

  //
}

class FilterModel {
  bool active;
  String title;

  FilterModel({
    required this.active,
    required this.title,
  });
}
