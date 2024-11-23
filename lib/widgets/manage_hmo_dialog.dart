import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/hmo_model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:provider/provider.dart';

class ManageHMO extends StatefulWidget {
  const ManageHMO({super.key});

  @override
  State<ManageHMO> createState() => _ManageHMOState();
}

class _ManageHMOState extends State<ManageHMO> with TickerProviderStateMixin {
  late TabController _tab_controller;

  List<HMO_Model> active_list = [];
  List<HMO_Model> gym_list = [];
  List<HMO_Model> physio_list = [];

  // get hmos
  get_hmos() {
    gym_list = Provider.of<AppData>(context).gym_hmo;
    physio_list = Provider.of<AppData>(context).physio_hmo;
    active_list = (_tab_controller.index == 0) ? gym_list : physio_list;
  }

  @override
  void initState() {
    super.initState();
    _tab_controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    get_hmos();
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                width: 320,
                child: Center(
                  child: Text(
                    'Manage HMO\'s',
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
          Stack(
            children: [
              // main body
              Container(
                decoration: BoxDecoration(),
                width: 350,
                height: 400,
                child: Column(
                  children: [
                    SizedBox(height: 10),

                    // tabs
                    Container(
                      color: Colors.deepPurple.shade300,
                      child: TabBar(
                        controller: _tab_controller,
                        labelColor: Colors.white,
                        indicatorColor: Colors.blue,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        onTap: (val) {
                          if (val == 0) {
                            active_list = gym_list;
                          } else {
                            active_list = physio_list;
                          }

                          setState(() {});
                        },
                        tabs: [
                          Tab(text: 'GYM HMO\'s'),
                          Tab(text: 'Physio HMO\'s'),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // list
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: active_list.isNotEmpty
                              ? active_list
                                  .map((e) =>
                                      hmo_tile(e, (_tab_controller.index == 0)))
                                  .toList()
                              : [],
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ),

              // add button
              Positioned(
                bottom: 10,
                right: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  width: 45,
                  height: 45,
                  child: Center(
                    child: add_button(
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // add button
  Widget add_button(Widget child) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(0),
      offset: Offset(0, 30),
      child: child,
      elevation: 8,
      onSelected: (value) async {
        var ed = await showDialog(
          context: context,
          builder: (context) => EditHMODialog(
            hmo: HMO_Model(
              hmo_name: '',
              key: '',
              days_week: 2,
              hmo_amount: 12000,
            ),
          ),
        );

        if (ed != null) {
          Helpers.showLoadingScreen(context: context);

          HMO_Model dd = ed;

          bool ahm = await AdminDatabaseHelpers.add_hmo(
              (value == 1) ? 'Gym HMO' : 'Physio HMO', dd.toJson(), '',
              sett: true);

          Navigator.pop(context);

          if (!ahm) {
            Helpers.showToast(
              context: context,
              color: Colors.red,
              toastText: 'An Error Occurred, Try again',
              icon: Icons.error,
            );
            return;
          }

          Navigator.pop(context);
        }
      },
      itemBuilder: (context) => [
        // gym
        PopupMenuItem(
          value: 1,
          child: Container(
            child: Text(
              'GYM HMO',
              style: TextStyle(),
            ),
          ),
        ),

        // physio
        PopupMenuItem(
          value: 2,
          child: Container(
            child: Text(
              'Physio HMO',
              style: TextStyle(),
            ),
          ),
        ),
      ],
    );
  }

  Widget hmo_tile(HMO_Model hmo, bool gym_type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      child: Row(
        children: [
          // hmo name
          Expanded(
            child: Container(
              width: double.infinity,
              child: Text(
                hmo.hmo_name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: 20),

          // edit
          IconButton(
            onPressed: () async {
              var ed = await showDialog(
                context: context,
                // barrierDismissible: false,
                builder: (context) => EditHMODialog(hmo: hmo),
              );

              if (ed != null) {
                Helpers.showLoadingScreen(context: context);

                HMO_Model dd = ed;

                bool uhm = await AdminDatabaseHelpers.add_hmo(
                    gym_type ? 'Gym HMO' : 'Physio HMO', dd.toJson(), hmo.key);

                Navigator.pop(context);

                if (!uhm) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.red,
                    toastText: 'An Error Occurred, Try again',
                    icon: Icons.error,
                  );
                  return;
                }
              }
            },
            icon: Icon(
              Icons.edit,
              size: 20,
              color: Colors.white70,
            ),
          ),

          // delete
          IconButton(
            onPressed: () async {
              var conf = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => ConfirmDialog(
                  title: 'Delete HMO (${hmo.hmo_name})',
                  subtitle:
                      'You are about to delete this HMO from the database. This would not affect the old users with the above hmo. Woukd you like to proceed?',
                ),
              );

              if (conf != null && conf) {
                Helpers.showLoadingScreen(context: context);

                bool dhm = await AdminDatabaseHelpers.delete_hmo(
                    gym_type ? 'Gym HMO' : 'Physio HMO', hmo.key);

                Navigator.pop(context);

                if (!dhm) {
                  Helpers.showToast(
                    context: context,
                    color: Colors.red,
                    toastText: 'An Error Occurred, Try again',
                    icon: Icons.error,
                  );
                  return;
                }
              }
            },
            icon: Icon(
              Icons.delete,
              size: 20,
              color: Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class EditHMODialog extends StatefulWidget {
  final HMO_Model hmo;
  const EditHMODialog({super.key, required this.hmo});

  @override
  State<EditHMODialog> createState() => _EditHMODialogState();
}

class _EditHMODialogState extends State<EditHMODialog> {
  final TextEditingController hmo_name_controller = TextEditingController();
  final TextEditingController hmo_days_controller = TextEditingController();
  final TextEditingController hmo_amount_controller = TextEditingController();

  final FocusNode hmo_name_node = FocusNode();
  final FocusNode hmo_days_node = FocusNode();
  final FocusNode hmo_amount_node = FocusNode();

  @override
  void initState() {
    hmo_name_controller.text = widget.hmo.hmo_name;
    hmo_days_controller.text = widget.hmo.days_week.toString();
    hmo_amount_controller.text = widget.hmo.hmo_amount.toString();

    Future.delayed(Duration(milliseconds: 200), () {
      FocusScope.of(context).requestFocus(hmo_name_node);
    });
    super.initState();
  }

  @override
  void dispose() {
    hmo_name_controller.dispose();
    hmo_days_controller.dispose();
    hmo_amount_controller.dispose();

    hmo_name_node.dispose();
    hmo_days_node.dispose();
    hmo_amount_node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.black87,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // name field
                Text_field(
                  controller: hmo_name_controller,
                  node: hmo_name_node,
                ),

                SizedBox(height: 12),

                // details
                Row(
                  children: [
                    // no of days
                    Expanded(
                      flex: 3,
                      child: Text_field(
                        label: 'No. of Days',
                        controller: hmo_days_controller,
                        node: hmo_days_node,
                        format: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),

                    SizedBox(width: 20),

                    // hmo amount
                    Expanded(
                      flex: 6,
                      child: Text_field(
                        label: 'HMO Amount',
                        controller: hmo_amount_controller,
                        node: hmo_amount_node,
                        format: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                /// submit
                InkWell(
                  onTap: () {
                    if (hmo_name_controller.text.isEmpty) return;

                    HMO_Model hmo = HMO_Model(
                      hmo_name: hmo_name_controller.text,
                      key: widget.hmo.key,
                      days_week: hmo_days_controller.text.isNotEmpty
                          ? int.parse(hmo_days_controller.text)
                          : 0,
                      hmo_amount: hmo_amount_controller.text.isNotEmpty
                          ? int.parse(hmo_amount_controller.text)
                          : 0,
                    );

                    Navigator.pop(context, hmo);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
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
          ),
        ],
      ),
    );
  }
}
