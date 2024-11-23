import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/gym/client_pofile_page.dart';
import 'package:heritage_soft/pages/physio/physio_pofile_page.dart';
import 'package:heritage_soft/pages/physio/widgets/physio_hmo_tag.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BirthdayList extends StatefulWidget {
  const BirthdayList({super.key});

  @override
  State<BirthdayList> createState() => _BirthdayListState();
}

class _BirthdayListState extends State<BirthdayList> {
  bool isLoading = false;
  int _index = 0;

  TextEditingController search_controller = TextEditingController();

  bool search_on = false;
  bool gym_emptySearch = false;
  bool physio_emptySearch = false;

  List<ClientListModel> gym_client = [];
  List<ClientListModel> search_gym_client = [];

  List<PhysioClientListModel> physio_clients = [];
  List<PhysioClientListModel> search_physio_clients = [];

  // check for birthdays
  get_values() {
    gym_client = Provider.of<AppData>(context, listen: false)
        .clients
        .where((element) =>
            element.dob!.isNotEmpty &&
            (element.dob == '/1900'
                ? false
                : (get_birth_Date(getDate(element.dob!)) ==
                    get_birth_Date(DateTime.now()))))
        .toList();

    physio_clients = Provider.of<AppData>(context, listen: false)
        .physio_clients
        .where((element) =>
            element.dob!.isNotEmpty &&
            (element.dob == '/1900'
                ? false
                : (get_birth_Date(getDate(element.dob!)) ==
                    get_birth_Date(DateTime.now()))))
        .toList();

    if (gym_client.isEmpty && physio_clients.isNotEmpty) {
      _index = 1;
    }
  }

  DateTime getDate(String data) {
    var date_data = data.split('/');
    return DateTime(
      int.parse(date_data[2]),
      int.parse(date_data[1]),
      int.parse(date_data[0]),
    );
  }

  String get_birth_Date(DateTime data) {
    int month = data.month;
    int day = data.day;

    return '$day/$month';
  }

  @override
  void initState() {
    get_values();
    search_controller.addListener(() {
      setState(() {});
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
    return DefaultTabController(
      length: 3,
      initialIndex: _index,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 2, 20, 35),
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 2, 20, 35),
          // bottom: ,
          title: Text('All Client\'s Birthday'),
          actions: [
            // todays date
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: () {},
                child: Text(
                  DateFormat('E, d MMMM').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // main content
            Column(
              children: [
                // tab bars head
                TabBar(
                  onTap: (val) {
                    _index = val;
                    setState(() {});
                  },
                  tabs: [
                    Tab(text: 'GYM Client\'s'),
                    Tab(text: 'Physio Client\'s'),
                    Tab(text: 'Staffs'),
                  ],
                ),

                SizedBox(height: 20),

                // search bar
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(81, 0, 0, 0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextField(
                    controller: search_controller,
                    onChanged: search_value(search_controller.text, _index),
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
                                search_gym_client.clear();
                                search_physio_clients.clear();
                                search_on = false;

                                gym_emptySearch = false;
                                physio_emptySearch = false;
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

                SizedBox(height: 20),

                // tabs
                Expanded(
                  child: TabBarView(
                    children: [
                      gym_list(),
                      physio_list(),

                      // staff
                      Container(
                        child: Center(
                          child: Text(
                            'Coming Soon !!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // loading
            isLoading
                ? Positioned.fill(
                    child: Container(
                      color: const Color.fromARGB(25, 0, 0, 0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  // list
  Widget gym_list() {
    return
        // empty serach
        search_on && search_gym_client.isEmpty
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

            // searchlist
            : search_gym_client.isNotEmpty
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                      ),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: BouncingScrollPhysics(),
                      children: search_gym_client
                          .map((e) => gym_list_tile(e))
                          .toList(),
                    ),
                  )

                // clients list
                : gym_client.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 25),
                        child: GridView(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 120,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 20,
                          ),
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                          physics: BouncingScrollPhysics(),
                          children:
                              gym_client.map((e) => gym_list_tile(e)).toList(),
                        ),
                      )

                    // empty client list
                    : Center(
                        child: Text(
                          'No Clients have their birthday today',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      );
  }

  // client list tile
  Widget gym_list_tile(ClientListModel client) {
    String cl_name = '${client.f_name} ${client.l_name}';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // clinet details
          Expanded(
            child: InkWell(
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
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

                              // subscription plan
                              client.sub_plan!.isNotEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color:
                                            Color(0xFF3C58E6).withOpacity(0.67),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                              color: Color(client.sub_status!
                                      ? 0xFF88ECA9
                                      : 0xFFFF5252)
                                  .withOpacity(0.67),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.circle,
                                    color: Color(client.sub_status!
                                        ? 0xFF19F763
                                        : 0xFFFF5252),
                                    size: 8),
                                SizedBox(width: 6),
                                Text(
                                  client.sub_status! ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
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
            ),
          ),

          // send mail button
          InkWell(
            onTap: () {
              Helpers.showToast(
                context: context,
                color: Colors.blue,
                toastText: 'This feature would be available soon',
                icon: Icons.update,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              width: 40,
              child: Center(
                child: Icon(Icons.mail, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // physio list
  Widget physio_list() {
    return search_on && search_physio_clients.isEmpty
        // empty serach
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
        : search_physio_clients.isNotEmpty
            // searchlist
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 120,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 20,
                  ),
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                  physics: BouncingScrollPhysics(),
                  children: search_physio_clients
                      .map((e) => physio_list_tile(e))
                      .toList(),
                ),
              )
            // clients list
            : physio_clients.isNotEmpty
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                      ),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: BouncingScrollPhysics(),
                      children: physio_clients
                          .map((e) => physio_list_tile(e))
                          .toList(),
                    ),
                  )
                : Center(
                    child: Text(
                      'No Clients have their birthday today',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  );
  }

  // client list tile
  Widget physio_list_tile(PhysioClientListModel client) {
    String cl_name = '${client.f_name} ${client.l_name}';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // client details
          Expanded(
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PhysioClientProfilePage(cl_id: client.key!),
                  ),
                );

                setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
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
                          // id
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

                    //
                  ],
                ),
              ),
            ),
          ),

          // send mail button
          InkWell(
            onTap: () {
              Helpers.showToast(
                context: context,
                color: Colors.blue,
                toastText: 'This feature would be available soon',
                icon: Icons.update,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              width: 40,
              child: Center(
                child: Icon(Icons.mail, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  search_value(String value, int page) {
    search_on = true;
    search_gym_client.clear();
    search_physio_clients.clear();

    if (value.isNotEmpty) {
      search_gym_client = gym_client
          .where((element) =>
              element.f_name!.toLowerCase().contains(value.toLowerCase()) ||
              element.m_name!.toLowerCase().contains(value.toLowerCase()) ||
              element.l_name!.toLowerCase().contains(value.toLowerCase()))
          .toList();

      search_physio_clients = physio_clients
          .where((element) =>
              element.f_name!.toLowerCase().contains(value.toLowerCase()) ||
              element.m_name!.toLowerCase().contains(value.toLowerCase()) ||
              element.l_name!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else {
      search_on = false;
    }

    // setState(() {});
  }
//
}
