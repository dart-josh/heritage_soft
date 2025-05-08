import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/store_database_helpers.dart';
import 'package:heritage_soft/pages/store/manage_accessory_dialog.dart';

class AccessoriesList extends StatefulWidget {
  const AccessoriesList({super.key});

  @override
  State<AccessoriesList> createState() => _AccessoriesListState();
}

class _AccessoriesListState extends State<AccessoriesList> {
  final TextEditingController search_controller = TextEditingController();

  List<AccessoryModel> accessory_list = [];

  List<AccessoryModel> search_list = [];
  bool search_on = false;

  @override
  void initState() {
    StoreDatabaseHelpers.get_all_accessories(context);
    super.initState();
  }

  @override
  void dispose() {
    search_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    accessory_list = AppData.get(context).accessories;
    UserModel? active_user = AppData.get(context).active_user;

    accessory_list.sort((a, b) => a.itemName.compareTo(b.itemName));

    if (search_on) search_value(search_controller.text);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 25, 43),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: Text('Accessories'),
      ),
      floatingActionButton: (active_user?.app_role == 'Admin' ||
              active_user?.app_role == 'ICT' ||
              active_user?.app_role == 'CSU' ||
              active_user?.full_access == true)
          ? floating_button()
          : null,
      backgroundColor: Color.fromARGB(255, 3, 25, 43),
      body: Column(
        children: [
          // search bar
          search_bar(),

          SizedBox(height: 20),

          // list
          Expanded(child: list_view()),

          // footer
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              'HERITAGE FITNESS & WELLNESS CENTRE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'MsLineDraw',
                color: Color(0xFFC6C6C6),
                fontSize: 27,
                shadows: [
                  Shadow(
                    color: Color(0xFF000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }

  // WIDgETS

  // list
  Widget list_view() {
    return Container(
      child:
          // empty search
          search_on && search_list.isEmpty
              ? Center(
                  child: Text(
                    'No Item Found!!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                )

              // empty accessory list
              : accessory_list.isEmpty
                  ? Center(
                      child: Text(
                        'No Accessory in the Database',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    )

                  // accessory/serach list
                  : GridView(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        mainAxisExtent: 200,
                        mainAxisSpacing: 25,
                        crossAxisSpacing: 25,
                      ),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: BouncingScrollPhysics(),
                      children: search_list.isNotEmpty
                          ? search_list.map((e) => item_tile(e)).toList()
                          : accessory_list.map((e) => item_tile(e)).toList(),
                    ),
    );
  }

  // item tile
  Widget item_tile(AccessoryModel accessory) {
    bool warning = accessory.quantity <= accessory.restockLimit;
    bool out_of_stock = accessory.quantity <= 0;
    bool is_available = accessory.isAvailable;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ManageAccessory(
            edit: true,
            accessory: accessory,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: !is_available
                  ? Colors.white24
                  : out_of_stock
                      ? Colors.redAccent
                      : warning
                          ? Colors.amber
                          : Colors.green.withOpacity(.6)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // short code
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                color: !is_available
                    ? Color.fromARGB(114, 208, 145, 68)
                    : Color.fromARGB(255, 208, 145, 68),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  accessory.itemCode.isEmpty
                      ? get_code(accessory.itemName)
                      : accessory.itemCode,
                  style: TextStyle(
                    color: !is_available ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            // name
            Text(
              accessory.itemName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: !is_available ? Colors.white38 : Colors.white,
                  fontSize: accessory.itemName.length > 65 ? 13 : 14),
            ),

            SizedBox(height: 10),

            // price
            Text(
              Helpers.format_amount(accessory.price, naira: true),
              style: TextStyle(
                color: !is_available ? Colors.white38 : Colors.greenAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: 5),

            // qty
            Text(
              accessory.quantity.toString(),
              style: TextStyle(
                color: !is_available ? Colors.white38 : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // search bar
  Widget search_bar() {
    return Container(
      width: 400,
      decoration: BoxDecoration(),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: search_controller,
        onChanged: (val) {
          search_value(search_controller.text);
        },
        style: TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white54,
            size: 20,
          ),
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
      ),
    );
  }

  // floating button (add accessory)
  Widget floating_button() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(181, 102, 81, 17),
      ),
      padding: EdgeInsets.all(1),
      child: IconButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ManageAccessory(),
          );
        },
        icon: Icon(Icons.add, color: Colors.white, size: 50),
      ),
    );
  }

  // FUNCTIONS

  search_value(String value) {
    search_on = true;
    search_list.clear();

    if (value.isNotEmpty) {
      search_list = accessory_list
          .where((element) =>
              element.itemName.toLowerCase().contains(value.toLowerCase()) ||
              element.itemCode.toLowerCase().contains(value.toLowerCase()) ||
              element.itemId.toLowerCase().contains(value.toLowerCase()) ||
              get_code(element.itemName)
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    } else {
      search_on = false;
    }

    setState(() {});
  }

  // get code
  String get_code(String value) {
    if (value.isNotEmpty) {
      var len = value.split(' ');

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
}
