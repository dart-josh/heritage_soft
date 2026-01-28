import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/gym_models/client.model.dart';
import 'package:heritage_soft/pages/gym/client_profile_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GymDataReportPage extends StatefulWidget {
  const GymDataReportPage({super.key});

  @override
  State<GymDataReportPage> createState() => _GymDataReportPageState();
}

class _GymDataReportPageState extends State<GymDataReportPage> {
  bool isLoading = false;
  int _index = 0;

  TextEditingController search_controller = TextEditingController();

  bool search_on = false;
  bool empty_search = false;

  List<ClientModel> registration = [];
  List<ClientModel> renewal = [];

  List<ClientModel> search_client = [];

  DateTime current_date = DateTime.now();

  bool ini = false;

  // check for data
  get_values() {
    registration = Provider.of<AppData>(context)
        .gym_clients
        .where((element) =>
            (element.regDate!.isNotEmpty &&
            (check_date(getDate(element.regDate!)) == check_date(current_date))) || element.registrationDates!.isNotEmpty &&
              check_renewal_dates(
                  element.registrationDates!, check_date(current_date)))
        .toList();

    renewal = Provider.of<AppData>(context)
        .gym_clients
        .where(
          (element) =>
              element.renewDates!.isNotEmpty &&
              check_renewal_dates(
                  element.renewDates!, check_date(current_date)),
        )
        .toList();

    if (!ini && registration.isEmpty && renewal.isNotEmpty) {
      _index = 1;
    }

    ini = true;
  }

  DateTime getDate(String data) {
    var date_data = data.split('/');
    return DateTime(
      int.parse(date_data[2]),
      int.parse(date_data[1]),
      int.parse(date_data[0]),
    );
  }

  DateTime check_date(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  bool check_renewal_dates(String renewal_dates, DateTime current_date) {
    List<DateTime> dates = [];

    renewal_dates.split(',').forEach((e) {
      dates.add(getDate(e.trim()));
    });

    return dates.where((date) => date == current_date).isNotEmpty;
  }

  @override
  void initState() {
    // get_values();
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
    get_values();
    return DefaultTabController(
      length: 2,
      initialIndex: _index,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 2, 20, 35),
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 2, 20, 35),
          // bottom: ,
          title: Text('Gym Daily Report'),
          actions: [
            // current date
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: () {},
                child: Text(
                  DateFormat('E, d MMMM yyyy').format(current_date),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            // change date
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () async {
                  var date = await showDatePicker(
                    context: context,
                    initialDate: current_date,
                    firstDate: DateTime(2016),
                    lastDate: DateTime.now(),
                  );

                  if (date != null) {
                    setState(() {
                      current_date = date;
                    });
                  }
                },
                child: Icon(Icons.calendar_today, color: Colors.white),
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
                    Tab(
                        text:
                            'Registrations${registration.isNotEmpty ? ' -- ${registration.length}' : ''}'),
                    Tab(
                        text:
                            'Renewals${renewal.isNotEmpty ? ' -- ${renewal.length}' : ''}'),
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
                                search_client.clear();
                                search_on = false;

                                empty_search = false;
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
                      _list(registration),
                      _list(renewal),
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
  Widget _list(List<ClientModel> _list) {
    return
        // empty serach
        search_on && search_client.isEmpty
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
            : search_client.isNotEmpty
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
                      children: search_client.map((e) => list_tile(e)).toList(),
                    ),
                  )

                // clients list
                : _list.isNotEmpty
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
                          children: _list.map((e) => list_tile(e)).toList(),
                        ),
                      )

                    // empty client list
                    : Center(
                        child: Text(
                          'No Data',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      );
  }

  // client list tile
  Widget list_tile(ClientModel client) {
    String cl_name = '${client.fName} ${client.lName}';

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
                              color: Color(client.subStatus!
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
                                    color: Color(client.subStatus!
                                        ? 0xFF19F763
                                        : 0xFFFF5252),
                                    size: 8),
                                SizedBox(width: 6),
                                Text(
                                  client.subStatus! ? 'Active' : 'Inactive',
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
        ],
      ),
    );
  }

  search_value(String value, int page) {
    search_on = true;
    search_client.clear();

    if (value.isNotEmpty) {
      if (page == 0)
        search_client = registration
            .where((element) =>
                element.fName!.toLowerCase().contains(value.toLowerCase()) ||
                element.mName!.toLowerCase().contains(value.toLowerCase()) ||
                element.lName!.toLowerCase().contains(value.toLowerCase()) ||
                element.clientId!.toLowerCase().contains(value.toLowerCase()))
            .toList();
      else
        search_client = renewal
            .where((element) =>
                element.fName!.toLowerCase().contains(value.toLowerCase()) ||
                element.mName!.toLowerCase().contains(value.toLowerCase()) ||
                element.lName!.toLowerCase().contains(value.toLowerCase()) ||
                element.clientId!.toLowerCase().contains(value.toLowerCase()))
            .toList();
    } else {
      search_on = false;
    }

    // setState(() {});
  }
//
}
