import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/datamodels/gym_models/client.model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/image_box.dart';
import 'package:heritage_soft/pages/gym/Widgets/qr_code_dialog.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class MobileClientList extends StatefulWidget {
  final List<ClientModel> clients;
  const MobileClientList({super.key, required this.clients});

  @override
  State<MobileClientList> createState() => _MobileClientListState();
}

class _MobileClientListState extends State<MobileClientList> {
  List<ClientModel> clients = [];
  List<ClientModel> search_list = [];

  TextEditingController search_controller = TextEditingController();

  bool search_on = false;

  search_value(String value) {
    search_list.clear();
    search_on = true;

    if (value.isNotEmpty) {
      search_list = clients
          .where(
            (element) =>
                element.fName!
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.mName!
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.lName!
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.clientId!
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()),
          )
          .toList();
    } else {
      search_on = false;
    }

    setState(() {});
  }

  @override
  void initState() {
    clients = widget.clients;

    search_controller.addListener(() {
      search_value(search_controller.text.trim());
    });

    super.initState();
  }

  @override
  void dispose() {
    search_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    clients.sort((a, b) => int.parse(b.clientId!.split('-')[1])
        .compareTo(int.parse(a.clientId!.split('-')[1])));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 25, 43),
        foregroundColor: Colors.white,
        title: Text('Gym Client List'),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 3, 25, 43),
      body: Column(
        children: [
          // search box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text_field(
              controller: search_controller,
              // prefix: Icon(Icons.search, color: Colors.white),
            ),
          ),

          SizedBox(height: 10),

          // empty search list
          Expanded(
            child: search_on && search_list.isEmpty
                ? Center(
                    child: Text(
                      'Search does not match any record',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )

                // main list
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: search_list.isNotEmpty
                        ? search_list.length
                        : clients.length,
                    itemBuilder: (context, index) => list_tile(
                        search_list.isNotEmpty
                            ? search_list[index]
                            : clients[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // client list tile
  Widget list_tile(ClientModel client) {
    String cl_name = '${client.fName} ${client.lName}';

    return InkWell(
      onTap: () async {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => QRCodeDialog(user_id: client.clientId!),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                child: client.userImage!.isEmpty
                    ? Image.asset(
                        'images/icon/user-alt.png',
                        width: 50,
                        height: 50,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          client.userImage!,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            SizedBox(width: 10),

            // user details
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // id, subscription & menu
                  Row(
                    children: [
                      // id
                      Text(
                        client.clientId!,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),

                      Expanded(child: Container()),

                      // subscription plan
                      client.subPlan!.isNotEmpty
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
                                    client.subPlan!,
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

                      SizedBox(width: 10),

                      // menu
                      options_menu(
                          child: Icon(Icons.menu),
                          user_image: client.userImage!,
                          user_id: client.key!)
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
                    width: 85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(client.subStatus! ? 0xFF88ECA9 : 0xFFFF5252)
                          .withOpacity(0.67),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle,
                            color: Color(
                                client.subStatus! ? 0xFF19F763 : 0xFFFF5252),
                            size: 8),
                        SizedBox(width: 6),
                        Text(
                          client.subStatus! ? 'Active' : 'Inactive',
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

  // options menu
  Widget options_menu(
      {required child, required String user_image, required String user_id}) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(0),
      offset: Offset(0, 30),
      child: child,
      elevation: 8,
      onSelected: (value) async {
        // update image
        if (value == 1) {
          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => EditProfileImage(
              is_edit: true,
              user_image: user_image.isNotEmpty ? user_image : null,
            ),
          );

          Uint8List? image_file;
          String img = '';

          if (res != null) {
            if (res == 'del') {
              image_file = null;
            } else {
              image_file = res;
            }

            Helpers.showLoadingScreen(context: context);

            // upload image
            if (image_file != null) {
              // img = await AdminDatabaseHelpers.uploadFile(
              //         image_file, user_id, true) ??
              //     '';
            }

            Map client_update_details = {
              'user_image': img,
            };

            Map ed = await GymDatabaseHelpers.update_client_details(
              context,
              data: {
                'data_type': 'image',
                'client_key': user_id,
                'client_details': client_update_details
              },
            );

            Navigator.pop(context);

            if (!ed['status']) {
              Helpers.showToast(
                context: context,
                color: Colors.redAccent,
                toastText: 'An Error occurred, Try again!',
                icon: Icons.error,
              );
              return;
            }

            Helpers.showToast(
              context: context,
              color: Colors.blue,
              toastText: 'Image Updated',
              icon: Icons.check,
            );
          }
        }
      },
      itemBuilder: (context) => [
        // update Image
        PopupMenuItem(
          value: 1,
          child: Container(
            child: Row(
              children: [
                Icon(Icons.camera, size: 22),
                SizedBox(width: 8),
                Text(
                  'Update Image',
                  style: TextStyle(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
