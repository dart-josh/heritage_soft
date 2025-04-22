// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:heritage_soft/datamodels/client_model.dart';
// import 'package:heritage_soft/global_variables.dart';
// import 'package:heritage_soft/helpers/gym_database_helpers.dart';
// import 'package:heritage_soft/helpers/helper_methods.dart';
// import 'package:heritage_soft/pages/other/get_barcode.dart';
// import 'package:heritage_soft/pages/other/mobile_client_list.dart';
// import 'package:heritage_soft/pages/other/mobile_physio_cllist.dart';

// class MobileTab extends StatefulWidget {
//   const MobileTab({super.key});

//   @override
//   State<MobileTab> createState() => _MobileTabState();
// }

// class _MobileTabState extends State<MobileTab> {
//   bool is_loading = false;

//   late StreamSubscription sub;

//   List<ClientListModel> clients = [];

//   get_clients() async {
//     is_loading = true;

//     sub = GymDatabaseHelpers.clients_stream().listen((snap) {
//       clients.clear();
//       // snap.docs.forEach((e) {
//       //   ClientListModel cli = ClientListModel.fromMap(e.id, e.data());

//       //   clients.add(cli);
//       // });

//       is_loading = false;
//       setState(() {});
//     });
//   }

//   @override
//   void initState() {
//     get_clients();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     sub.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 3, 25, 43),
//         foregroundColor: Colors.white,
//         title: Text('Mobile Tab'),
//         centerTitle: true,
//       ),
//       backgroundColor: Color.fromARGB(255, 3, 25, 43),
//       body: active_staff != null
//           ? SingleChildScrollView(
//               child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.min,
//                     children: (active_staff!.role == 'Desk Officer')
//                         ? tabs()
//                         : (active_staff!.role == 'Admin')
//                             ? tabs()
//                             : [
//                                 Text(
//                                   'NOT ALLOWED',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                   )),
//             )
//           : Center(
//               child: Text(
//                 'NOT ALLOWED',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//     );
//   }

//   List<Widget> tabs() {
//     return [
//       // client list
//       tab_tile(
//           label: 'Gym Client List',
//           icon: Icons.people,
//           func: () {
//             if (is_loading) {
//               Helpers.showToast(
//                 context: context,
//                 color: Colors.red,
//                 toastText: 'Loading...',
//                 icon: Icons.timelapse,
//               );
//               return;
//             }

//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => MobileClientList(clients: clients)),
//             );
//           }),

//       // physio client list
//       tab_tile(
//           label: 'Physio Client List',
//           icon: Icons.people,
//           func: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => MobilePhysioClientList()),
//             );
//           }),

//       // get barcode
//       tab_tile(
//         label: 'Get Barcode',
//         icon: Icons.generating_tokens,
//         func: () {
//           if (is_loading) {
//             Helpers.showToast(
//               context: context,
//               color: Colors.red,
//               toastText: 'Loading...',
//               icon: Icons.timelapse,
//             );
//             return;
//           }
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => GetBarcode(clients: clients)),
//           );
//         },
//       ),

//       // scan barcode
//       tab_tile(
//         label: 'Scan Barcode',
//         icon: Icons.barcode_reader,
//         func: () {},
//       ),
//     ];
//   }

//   Widget tab_tile(
//       {required String label,
//       required IconData icon,
//       required Function() func}) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//       child: InkWell(
//         onTap: func,
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           margin: EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 color: Colors.blue,
//                 size: 20,
//               ),
//               SizedBox(width: 10),
//               Text(
//                 label,
//                 style: TextStyle(color: Colors.black, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
