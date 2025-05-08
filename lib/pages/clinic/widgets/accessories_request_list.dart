import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/store_models/accessory_request.model.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/store/shop_page.dart';
import 'package:provider/provider.dart';

class AccessoriesRequestList extends StatefulWidget {
  const AccessoriesRequestList({super.key});

  @override
  State<AccessoriesRequestList> createState() => _AccessoriesRequestListState();
}

class _AccessoriesRequestListState extends State<AccessoriesRequestList> {
  final TextEditingController search_controller = TextEditingController();

  bool search_on = false;
  List<AccessoryRequestModel> search_list = [];

  List<AccessoryRequestModel> acc_requests = [];

  @override
  void dispose() {
    search_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height - 50;

    acc_requests = AppData.get(context).accessory_request;

    return Container(
      width: 400,
      height: height,
      decoration: BoxDecoration(),
      padding: EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          // search bar
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(81, 0, 0, 0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // search box
                Expanded(
                  child: TextField(
                    controller: search_controller,
                    onChanged: search_request,
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                ),

                // clear list
                IconButton(
                  onPressed: () async {
                    if (acc_requests.isEmpty) return;

                    var conf = await Helpers.showConfirmation(
                      context: context,
                      title: 'Clear Request',
                      message:
                          'You are about to delete all requests from the database. Would you like to proceed?',
                    );

                    if (conf) {
                      await ClinicDatabaseHelpers.delete_all_accessory_request(
                          context);
                    }
                  },
                  icon: Icon(
                    Icons.clear_all,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // empty search list
          search_on && search_list.isEmpty
              ? Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(81, 0, 0, 0),
                  ),
                  child: Center(
                    child: Text(
                      'Patient not Found !!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )

              // main list
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: (search_on)
                          ? search_list.map((e) {
                              return request_tile(e);
                            }).toList()
                          : acc_requests.map((e) {
                              return request_tile(e);
                            }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // request tile
  Widget request_tile(AccessoryRequestModel request) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(81, 0, 0, 0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopPage(
                request: request,
              ),
            ),
          );
        },
        child: Dismissible(
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            child: Align(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              alignment: Alignment.centerRight,
            ),
          ),
          onDismissed: (direction) {
            ClinicDatabaseHelpers.delete_accessory_request(context,
                data: {}, id: request.key ?? '');
          },
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              var conf = await Helpers.showConfirmation(
                context: context,
                title: 'Delete Request',
                message: 'Do you want to delete this request from the databse?',
              );

              if (conf)
                return true;
              else
                return false;
            } else {
              return false;
            }
          },
          key: Key(request.key ?? ''),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                SizedBox(width: 5),
                // patient details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // patient id
                      Text(
                        request.patient!.patient_id,
                        style: TextStyle(color: Colors.black87, fontSize: 11),
                      ),

                      // patient name
                      Text(
                        '${request.patient!.f_name} ${request.patient!.l_name}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10),

                // items quantity
                Text(
                  request.accessories.length.toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // search value
  search_request(String value) {
    search_on = true;
    search_list.clear();

    if (value.isNotEmpty) {
      search_list = Provider.of<AppData>(context, listen: false)
          .accessory_request
          .where((element) =>
              element.patient!.f_name
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element.patient!.l_name
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element.patient!.m_name
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element.patient!.patient_id
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    } else {
      search_on = false;
    }

    setState(() {});
  }

  //
}
