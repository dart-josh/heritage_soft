import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/image_box.dart';
import 'package:heritage_soft/pages/clinic/widgets/physio_hmo_tag.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';

class MobilePhysioClientList extends StatefulWidget {
  const MobilePhysioClientList({super.key});

  @override
  State<MobilePhysioClientList> createState() => _MobilePhysioClientListState();
}

class _MobilePhysioClientListState extends State<MobilePhysioClientList> {
  List<PhysioClientListModel> clients = [];
  List<PhysioClientListModel> search_list = [];

  TextEditingController search_controller = TextEditingController();

  StreamSubscription? sub;

  bool is_loading = false;

  get_clients() async {
    is_loading = true;

    // sub = ClinicDatabaseHelpers.physio_clients_stream().listen((snap) {
    //   clients.clear();
    //   snap.docs.forEach((e) {
    //     PhysioClientListModel cli =
    //         PhysioClientListModel.fromMap(e.id, e.data());

    //     clients.add(cli);
    //   });

    //   is_loading = false;
    //   setState(() {});
    // });
  }

  bool search_on = false;

  search_value(String value) {
    search_list.clear();
    search_on = true;

    if (value.isNotEmpty) {
      search_list = clients
          .where(
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
          )
          .toList();
    } else {
      search_on = false;
    }

    setState(() {});
  }

  @override
  void initState() {
    get_clients();

    search_controller.addListener(() {
      search_value(search_controller.text.trim());
    });

    super.initState();
  }

  @override
  void dispose() {
    search_controller.dispose();
    sub!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    clients.sort((a, b) => int.parse(b.id!.split('-')[1])
        .compareTo(int.parse(a.id!.split('-')[1])));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 25, 43),
        foregroundColor: Colors.white,
        title: Text('Physio Client List'),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 3, 25, 43),
      body: is_loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
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

                // list
                Expanded(
                  child:
                      // empty search
                      search_on && search_list.isEmpty
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

                          // list
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
  Widget list_tile(PhysioClientListModel client) {
    String cl_name = '${client.f_name} ${client.l_name}';

    return InkWell(
      onTap: () async {},
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
                  // id & menu
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

                      options_menu(
                        child: Icon(Icons.menu),
                        user_image: client.user_image!,
                        user_id: client.key!,
                      ),
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

                  // hmo tag
                  PhysioHMOTag(hmo: client.hmo!),
                ],
              ),
            ),
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
              img = await AdminDatabaseHelpers.uploadFile(
                      image_file, user_id, false) ??
                  '';
            }

            Map client_update_details = {
              'user_image': img,
            };

            // bool ed = await ClinicDatabaseHelpers.edit_physio_client(
            //     user_id, client_update_details);

            // Navigator.pop(context);

            // if (!ed) {
            //   Helpers.showToast(
            //     context: context,
            //     color: Colors.redAccent,
            //     toastText: 'An Error occured, Try again!',
            //     icon: Icons.error,
            //   );
            //   return;
            // }

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
