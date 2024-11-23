
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/accessories_shop_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class AddAccessories extends StatefulWidget {
  final bool edit;
  final AccessoryModel? accessory;
  const AddAccessories({super.key, this.edit = false, this.accessory});

  @override
  State<AddAccessories> createState() => _AddAccessoriesState();
}

class _AddAccessoriesState extends State<AddAccessories> {
  final TextEditingController key_controller = TextEditingController();
  final TextEditingController name_controller = TextEditingController();
  final TextEditingController price_controller = TextEditingController();
  final TextEditingController qty_controller = TextEditingController();
  final TextEditingController code_controller = TextEditingController();
  final TextEditingController limit_controller = TextEditingController();
  final TextEditingController id_controller = TextEditingController();

  String name = '';
  String section = 'GYM';
  bool isAvailable = true;

  bool edit_mode = false;

  get_values({bool edit = false}) {
    if (widget.accessory == null) return;

    key_controller.text = widget.accessory!.key;
    name_controller.text = widget.accessory!.name;
    price_controller.text = widget.accessory!.price.toString();
    qty_controller.text = widget.accessory!.qty.toString();
    code_controller.text = widget.accessory!.code;
    section = widget.accessory!.section;
    isAvailable = widget.accessory!.isAvailable;
    limit_controller.text = widget.accessory!.limit.toString();
    id_controller.text = widget.accessory!.id;

    name = widget.accessory!.name;

    edit_mode = false;

    if (edit) setState(() {});
  }

  @override
  void initState() {
    if (widget.edit) {
      get_values();
    } else
      edit_mode = true;

    if (!name_controller.hasListeners)
      name_controller.addListener(() {
        setState(() {});
      });

    if (!code_controller.hasListeners)
      code_controller.addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    key_controller.dispose();
    name_controller.dispose();
    price_controller.dispose();
    qty_controller.dispose();
    code_controller.dispose();
    limit_controller.dispose();
    id_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.50;

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 10, 63, 124).withOpacity(.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // top bar
                top_bar(),

                SizedBox(height: 10),

                // details
                widget.edit ? details() : Container(),

                SizedBox(height: 10),

                // form
                form(),

                SizedBox(height: 20),

                edit_mode ? submit_button() : Container(height: 40),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGETS

  // top bar
  Widget top_bar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white60,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Stack(
        children: [
          // heading
          Center(
            child: Text(
              widget.edit
                  ? edit_mode
                      ? 'Edit Accessory'
                      : 'View Accessory'
                  : 'Add Accessory',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),

          // action buttons
          Row(
            children: [
              // close button
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              Expanded(child: Container()),

              // edit button
              if (widget.edit && (app_role == 'admin' || app_role == 'ict'))
                IconButton(
                  onPressed: () {
                    if (edit_mode) {
                      edit_mode = false;
                      get_values(edit: true);
                    } else {
                      setState(() {
                        edit_mode = true;
                      });
                    }
                  },
                  icon: Icon(
                    edit_mode ? Icons.check_circle : Icons.edit,
                    color: edit_mode ? Colors.green : Colors.white70,
                    size: 24,
                  ),
                ),

              // delete button
              if (widget.edit && (app_role == 'admin' || app_role == 'ict'))
                IconButton(
                  onPressed: () async {
                    var conf = await showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        title: 'Delete Accessory',
                        subtitle:
                            'You are about to delete this accessory from the database. Would you like to proceed?',
                      ),
                    );

                    if (conf != null && conf) {
                      Helpers.showLoadingScreen(context: context);

                      bool da = await AdminDatabaseHelpers.delete_accessory(
                          widget.accessory!.key);

                      Navigator.pop(context);

                      if (!da) {
                        Helpers.showToast(
                          context: context,
                          color: Colors.red,
                          toastText: 'An Error Occurred, Try again',
                          icon: Icons.error,
                        );
                        return;
                      }

                      // remove page
                      Navigator.pop(context);

                      Helpers.showToast(
                        context: context,
                        color: Colors.blue,
                        toastText: 'Accessory Deleted',
                        icon: Icons.check,
                      );
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // details
  Widget details() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
      child: Column(
        children: [
          // name
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: SelectableText(
              name,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // key
          if (full_access)
            Container(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text_field(
                controller: key_controller,
                edit: true,
              ),
            ),
        ],
      ),
    );
  }

  // form
  Widget form() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
      child: Column(
        children: [
          // main details
          Row(
            children: [
              // code
              Container(
                width: 120,
                height: 110,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 208, 145, 68),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    code_controller.text.isEmpty
                        ? get_code(name_controller.text.trim())
                        : code_controller.text.trim().length > 3
                            ? code_controller.text
                                .trim()
                                .substring(0, 3)
                                .toUpperCase()
                            : code_controller.text.trim().toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 30),

              // details
              Expanded(
                child: Column(
                  children: [
                    // id
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text_field(
                              controller: id_controller,
                              label: 'Item ID',
                              edit: !edit_mode,
                            ),
                          ),

                          SizedBox(width: 15),

                          //
                          Container(width: 100),
                        ],
                      ),
                    ),

                    // name & code
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text_field(
                              controller: name_controller,
                              label: 'Item Name',
                              edit: !edit_mode,
                            ),
                          ),

                          SizedBox(width: 15),

                          // code
                          Container(
                            width: 100,
                            child: Text_field(
                              controller: code_controller,
                              label: 'Short code',
                              edit: !edit_mode,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // price & qty
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          // price
                          Expanded(
                            child: Text_field(
                              controller: price_controller,
                              label: 'Item Price',
                              edit: !edit_mode,
                              format: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          SizedBox(width: 50),

                          // qty
                          Expanded(
                            child: Text_field(
                              controller: qty_controller,
                              label: 'Item Quantity',
                              edit: !edit_mode,
                              format: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(width: 10),

          // availability, section, limit
          Row(
            children: [
              // availabilty
              Container(
                width: 120,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Availabilty',
                        style: TextStyle(
                          color: Color(0xFFc3c3c3),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 6),
                      Switch(
                        value: isAvailable,
                        onChanged: (val) {
                          if (edit_mode)
                            setState(() {
                              isAvailable = val;
                            });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 30),

              // section
              Expanded(
                child: Select_form(
                  label: 'Section',
                  options: ['GYM', 'Physio', 'Others'],
                  text_value: section,
                  setval: (val) {
                    section = val;
                    setState(() {});
                  },
                  edit: edit_mode,
                ),
              ),

              Container(width: 30),

              // limit
              Expanded(
                child: Text_field(
                  controller: limit_controller,
                  label: 'Restock Limit',
                  edit: !edit_mode,
                  format: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // submit button
  Widget submit_button() {
    return InkWell(
      onTap: () async {
        if (name_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.red,
            toastText: 'Enter Item name',
            icon: Icons.error,
          );
          return;
        }

        if (price_controller.text.isEmpty ||
            int.parse(price_controller.text) <= 0) {
          Helpers.showToast(
            context: context,
            color: Colors.red,
            toastText: 'Enter Item price',
            icon: Icons.error,
          );
          return;
        }

        var conf = await showDialog(
          context: context,
          builder: (context) => ConfirmDialog(
            title: widget.edit ? 'Update Item' : 'Add Item',
            subtitle:
                'This would ${widget.edit ? 'update this item in the' : 'add this item to the'} database. Would you like to proceed?',
          ),
        );

        if (conf != null && conf) {
          Helpers.showLoadingScreen(context: context);

          AccessoryModel accessoryModel = AccessoryModel(
            key: key_controller.text,
            name: name_controller.text.trim(),
            code: code_controller.text.trim().length > 3
                ? code_controller.text.trim().substring(0, 3).toUpperCase()
                : code_controller.text.trim().toUpperCase(),
            qty: qty_controller.text.isEmpty
                ? 0
                : int.parse(qty_controller.text),
            price: int.parse(price_controller.text),
            isAvailable: isAvailable,
            section: section,
            limit: limit_controller.text.isEmpty
                ? 0
                : int.parse(limit_controller.text),
            id: id_controller.text.trim(),
          );

          Map<String, dynamic> data = accessoryModel.toJson();

          // add/update accessory
          bool acs = await AdminDatabaseHelpers.add_update_accessory(
            data,
            key: (widget.accessory != null) ? widget.accessory!.key : '',
            sett: !widget.edit,
          );

          Navigator.pop(context);

          if (!acs) {
            Helpers.showToast(
              context: context,
              color: Colors.red,
              toastText: 'An Error Occurred, Try again',
              icon: Icons.error,
            );
            return;
          }

          // pop page
          Navigator.pop(context);

          Helpers.showToast(
            context: context,
            color: Colors.blue,
            toastText: widget.edit ? 'Accessory Updated' : 'Accessory Added',
            icon: Icons.check,
          );
        }
      },
      child: Container(
        width: 300,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.edit ? 'Update Item' : 'Add item',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
  //

  // FUNCTIONS

  // get code
  String get_code(String value) {
    if (value.isNotEmpty) {
      var len = value.split(' ');
      ;

      var tk = len.where((element) => element.trim().isEmpty).toList();

      if (tk.isNotEmpty) {
        for (var i = 0; i < tk.length; i++) {
          var t = tk[i];
          len.remove(t);
        }
      }

      if (len.length == 0) {
        return value[0].toUpperCase();
      } else {
        if (len.length > 2) {
          return '${len[0][0]}${len[1][0]}${len[2][0]}'.toUpperCase();
        } else if (len.length > 1) {
          return '${len[0][0]}${len[1][0]}'.toUpperCase();
        } else {
          if (len[0].length < 2) return len[0][0].toUpperCase();

          return '${len[0][0]}${len[0][1]}'.toUpperCase();
        }
      }
    } else {
      return '';
    }
  }

  //
}
