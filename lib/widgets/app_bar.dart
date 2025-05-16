import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/store/shop_page.dart';
import 'package:heritage_soft/pages/other/birthday_list.dart';
import 'package:heritage_soft/pages/clinic/widgets/accessories_request_list.dart';
import 'package:heritage_soft/pages/clinic/widgets/waiting_patients_list.dart';
import 'package:provider/provider.dart';

class MyAppBar extends StatefulWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  bool accessories_request_open = false;
  bool waiting_list_open = false;

  @override
  Widget build(BuildContext context) {
    UserModel? user = AppData.get(context).active_user;
    DoctorModel? doctor = AppData.get(context).active_doctor;

    if (user == null)
      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 3, 25, 43),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      );

    return Stack(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 3, 25, 43),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
          child: Center(
            child: (user.app_role == 'Doctor')
                ? doctors_row()
                : receptionist_row(),
          ),
        ),

        // pending patients
        (user.app_role == 'Doctor' && doctor != null)
            ? Positioned(
                top: 40,
                right: 20,
                child: waiting_list_open ? WaitingPatientsList() : Container(),
              )

            // accessory request list
            : (user.app_role == 'CSU' || user.full_access)
                ? Positioned(
                    top: 40,
                    right: 20,
                    child: accessories_request_open
                        ? AccessoriesRequestList()
                        : Container(),
                  )
                : Container(),
      ],
    );
  }

  // doctors row
  Widget doctors_row() {
    DoctorModel? doctor = AppData.get(context).active_doctor;
    UserModel? user = doctor?.user;

    String name = '${user!.f_name} ${user.l_name}';

    int waiting_count = doctor?.pen_patients.length ?? 0;

    return Row(
      children: [
        // profile image
        global_key.currentState == null || doctor == null
            ? Container()
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: InkWell(
                  onTap: () async {
                    doctor_force_logout = 0;
                    global_key.currentState!.openDrawer();
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFf3f0da),
                    foregroundColor: Colors.white,
                    backgroundImage: doctor.user.user_image.isNotEmpty
                        ? NetworkImage(
                            doctor.user.user_image,
                          )
                        : null,
                    child: Center(
                      child: doctor.user.user_image.isEmpty
                          ? Image.asset(
                              'images/icon/health-person.png',
                              width: 15,
                              height: 15,
                            )
                          : Container(),
                    ),
                  ),
                ),
              ),

        SizedBox(width: 15),

              // name
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),

              SizedBox(width: 15),

              Text(
                '[ ${user.user_id} ]',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            

        Expanded(child: Container()),

        // pending clients
        Container(
          padding: EdgeInsets.only(right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // waiting list label
              if (waiting_list_open)
                Padding(
                  padding: EdgeInsets.only(left: 12, right: 20, top: 10),
                  child: Text(
                    'Waiting Patients List',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1,
                    ),
                  ),
                ),

              // waiting list icon
              InkWell(
                onTap: () {
                  waiting_list_open = !waiting_list_open;
                  setState(() {});
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 8, right: 8),
                      child: Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    // notification
                    if (waiting_count > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              waiting_count.toString(),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11, height: 1),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // receptionist row
  Widget receptionist_row() {
    int request_count = Provider.of<AppData>(context).accessory_request.length;
    UserModel? user = AppData.get(context).active_user;

    String name = '${user!.f_name} ${user.l_name}';
    // int birthday_count = get_birthday();

    return Row(
      children: [
        // profile area
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              // profile image
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFf3f0da),
                foregroundColor: Colors.white,
                backgroundImage: user.user_image.isNotEmpty
                    ? NetworkImage(
                        user.user_image,
                      )
                    : null,
                child: Center(
                  child: user.user_image.isEmpty
                      ? Image.asset(
                          'images/icon/health-person.png',
                          width: 15,
                          height: 15,
                        )
                      : Container(),
                ),
              ),

              SizedBox(width: 15),

              // name
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),

              SizedBox(width: 15),

              Text(
                '[ ${user.user_id} ]',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        Expanded(child: Container()),

        // birthday
        // if (user.app_role == 'CSU' ||
        //     user.app_role == 'Admin' ||
        //     user.app_role == 'Management' ||
        //     user.app_role == 'ICT' ||
        //     user.full_access)
        //   Container(
        //     padding: EdgeInsets.only(right: 10),
        //     child: InkWell(
        //       onTap: () {
        //         if (accessories_request_open) return;

        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => BirthdayList()),
        //         );
        //       },
        //       child: Stack(
        //         children: [
        //           // birthday icon
        //           Container(
        //             padding: EdgeInsets.only(top: 12, right: 8),
        //             child: Icon(
        //               Icons.card_giftcard,
        //               color: accessories_request_open
        //                   ? Colors.white38
        //                   : birthday_count > 0
        //                       ? Colors.green
        //                       : Colors.white60,
        //               size: 24,
        //             ),
        //           ),

        //           // notification
        //           if (birthday_count > 0)
        //             Positioned(
        //               top: 0,
        //               right: 0,
        //               child: Container(
        //                 height: 18,
        //                 width: 18,
        //                 decoration: BoxDecoration(
        //                   color: Colors.red,
        //                   shape: BoxShape.circle,
        //                 ),
        //                 child: Center(
        //                   child: Text(
        //                     birthday_count.toString(),
        //                     style: TextStyle(
        //                         color: Colors.white, fontSize: 11, height: 1),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //         ],
        //       ),
        //     ),
        //   ),

        // accessories shop
        if (user.app_role == 'CSU' || user.app_role == 'Admin' || user.full_access)
          Container(
            padding: EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                if (accessories_request_open) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShopPage()),
                );
              },
              child: Container(
                padding: EdgeInsets.only(top: 10, right: 8),
                child: Icon(
                  Icons.shop,
                  color:
                      accessories_request_open ? Colors.white38 : Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

        // accessory requests
        if (user.app_role == 'CSU' || user.app_role == 'Admin' || user.full_access)
          Container(
            padding: EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // accessories request list label
                if (accessories_request_open)
                  Padding(
                    padding: EdgeInsets.only(left: 12, right: 20, top: 10),
                    child: Text(
                      'Accessories Request List',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1,
                      ),
                    ),
                  ),

                // accessory request list icon
                InkWell(
                  onTap: () {
                    accessories_request_open = !accessories_request_open;
                    setState(() {});
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 12, right: 8),
                        child: Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      // notification
                      if (request_count > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                request_count.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    height: 1),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // logout
        IconButton(
          onPressed: () async {
            var conf = await Helpers.showConfirmation(
                context: context,
                title: 'Log out',
                message: 'You are about to log out. Would you like to proceed?',
                boolean: true);

            if (!conf) return;

            Helpers.logout(context);
          },
          icon: Icon(Icons.logout, color: Colors.white),
        ),
      ],
    );
  }

  // get birthday
  int get_birthday() {
    int gym_client = Provider.of<AppData>(context, listen: false)
        .clients
        .where((element) =>
            element.dob!.isNotEmpty &&
            (element.dob == '/1900'
                ? false
                : (get_birth_Date(getDate(element.dob!)) ==
                    get_birth_Date(DateTime.now()))))
        .toList()
        .length;

    // int physio_clients = Provider.of<AppData>(context, listen: false)
    //     .physio_clients
    //     .where((element) =>
    //         element.dob!.isNotEmpty &&
    //         (element.dob == '/1900'
    //             ? false
    //             : (get_birth_Date(getDate(element.dob!)) ==
    //                 get_birth_Date(DateTime.now()))))
    //     .toList()
    //     .length;

    return 0;
  }

  // get date
  DateTime getDate(String data) {
    var date_data = data.split('/');
    return DateTime(
      date_data.length > 2 ? int.parse(date_data[2]) : 2000,
      int.parse(date_data[1]),
      int.parse(date_data[0]),
    );
  }

  // get birth date
  String get_birth_Date(DateTime data) {
    int month = data.month;
    int day = data.day;

    return '$day/$month';
  }

  //
}
