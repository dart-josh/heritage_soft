import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'dart:ui' as ui;
import 'package:heritage_soft/helpers/server_helpers.dart';
import 'package:heritage_soft/helpers/user_helpers.dart';
import 'package:heritage_soft/pages/staff/user_setup_page.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  // CONTROLLER && NODE
  TextEditingController search_bar_controller = TextEditingController();
  FocusNode search_bar_node = FocusNode();

  double search_box_width = 0;
  bool search_on = false;

  List<UserModel> users = [];
  List<UserModel> search_list = [];
  bool emptySearch = false;

  // search user
  void search_user(String value, {bool build = false}) {
    search_list.clear();
    emptySearch = false;

    if (value.isNotEmpty) {
      var data = users
          .where(
            (element) =>
                element.f_name
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.m_name
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.l_name
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.user_id
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.user_role.toLowerCase().contains(
                      value.toLowerCase().trim(),
                    ) ||
                element.app_role
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()) ||
                element.section
                    .toLowerCase()
                    .contains(value.toLowerCase().trim()),
          )
          .toList();

      if (data.isNotEmpty) {
        search_list = data;
      } else {
        // empty search
        emptySearch = true;
      }
    }

    if (!build) setState(() {});
  }

  // get users
  dynamic get_users(dynamic data) async {
    UserModel user = UserModel.fromMap(data);

    AppData.set(context).update_user(user);
  }

  dynamic remove_user(dynamic id) async {
    AppData.set(context).delete_user(id);
  }

  initators() async {
    await UserHelpers.get_all_users(context);
  }

  void initState() {
    initators();
    ServerHelpers.socket!.on('User', (data) {
      get_users(data);
    });
    ServerHelpers.socket!.on('UserD', (data) {
      remove_user(data);
    });

    super.initState();
  }

  @override
  void dispose() {
    ServerHelpers.socket!.off('User');
    ServerHelpers.socket!.off('UserD');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.85;
    double height = MediaQuery.of(context).size.height * 0.85;
    return Scaffold(
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'images/office.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // background cover box
          Positioned.fill(
            child: Container(
              decoration:
                  BoxDecoration(color: Color(0xFFe0d9d2).withOpacity(0.20)),
            ),
          ),

          // blur cover box
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 2.0,
                sigmaY: 2.0,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // main content (dialog box)
          Container(
            child: Center(
              child: Container(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F8E1).withOpacity(0.69),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // main content
                    Column(
                      children: [
                        // main content
                        Expanded(child: main_page()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGETS

  // main page
  Widget main_page() {
    double width = MediaQuery.of(context).size.width;
    users = AppData.get(context).users;
    UserModel? active_user = AppData.get(context).active_user ?? null;

    if (users.isNotEmpty && search_list.isNotEmpty)
      search_user(search_bar_controller.text, build: true);

    return Column(
      children: [
        // top bar
        topBar(),

        SizedBox(height: 15),

        // list
        Expanded(
          child: (users.isEmpty)
              ? Center(
                  child: Text(
                    'No user found',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                )
              : list(),
        ),

        SizedBox(height: 20),

        // new user
        if (active_user?.full_access ?? false)
          InkWell(
            onTap: () {
              if (width >= 800) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => UserSetup(),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserSetup(),
                  ),
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
                  'New User',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

        SizedBox(height: 20),
      ],
    );
  }

  // top bar
  Widget topBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF707070)),
        ),
      ),
      child: Stack(
        children: [
          // header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                'User List',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1),
              ),
            ),
          ),

          // action button
          Positioned(
            top: 10,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // serach field
                AnimatedContainer(
                  width: search_box_width,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linear,
                  onEnd: () {
                    setState(() {
                      if (search_box_width == 230) {
                        search_on = true;
                        FocusScope.of(context).requestFocus(search_bar_node);
                      } else {
                        search_on = false;
                      }
                    });
                  },
                  child: Container(
                    width: search_box_width,
                    height: 33,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: !search_on
                        ? Container()
                        : TextField(
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            onChanged: search_user,
                            controller: search_bar_controller,
                            focusNode: search_bar_node,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFF3c3c3c),
                              hintText: 'Search user...',
                              hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: Colors.white54,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFBCBCBC),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFBCBCBC),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              contentPadding: EdgeInsets.fromLTRB(0, 6, 8, 6),
                              suffixIcon: InkWell(
                                onTap: () {
                                  emptySearch = false;
                                  search_list.clear();
                                  if (search_bar_controller.text.isEmpty) {
                                    search_box_width = 0;
                                  } else {
                                    search_bar_controller.clear();
                                  }
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),

                // search button
                if (!search_on)
                  InkWell(
                    onTap: () {
                      setState(() {
                        search_on = !search_on;
                        search_box_width = 230;
                      });
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),

                SizedBox(width: 10),

                // close button
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.cancel,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // grid list
  Widget list() {
    users.removeWhere((e) => e.user_id == 'DHI-0000-ST');

    users.sort((a, b) => int.parse(a.user_id
            .toLowerCase()
            .replaceAll('dhi', '')
            .replaceAll('st', '')
            .replaceAll('-', ''))
        .compareTo(int.parse(b.user_id
            .toLowerCase()
            .replaceAll('dhi', '')
            .replaceAll('st', '')
            .replaceAll('-', ''))));

    return
        // empty serach
        emptySearch
            ? Center(
                child: Text(
                  'Search does not match any record',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              )

            // searchlist
            : search_list.isNotEmpty
                ? Container(
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                      ),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: BouncingScrollPhysics(),
                      children: search_list.map((e) => list_tile(e)).toList(),
                    ),
                  )

                // users list
                : Container(
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                      ),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                      physics: BouncingScrollPhysics(),
                      children: users.map((e) => list_tile(e)).toList(),
                    ),
                  );
  }

  // client list tile
  Widget list_tile(UserModel _user) {
    double width = MediaQuery.of(context).size.width;
    String user_name = '${_user.f_name} ${_user.l_name}';

    return InkWell(
      onTap: () {
        if (width >= 800) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => UserSetup(
              user: _user,
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserSetup(
                user: _user,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
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
                child: _user.user_image.isEmpty
                    ? Image.asset(
                        'images/icon/user-alt.png',
                        width: 50,
                        height: 50,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          _user.user_image,
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
                  // user id
                  Row(
                    children: [
                      // id
                      Text(
                        _user.user_id,
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
                    user_name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      height: 1,
                    ),
                  ),

                  SizedBox(height: 8),

                  // user role
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color.fromARGB(255, 144, 103, 19).withOpacity(0.4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: EdgeInsets.only(left: 10, top: 2),
                    child: Text(
                      _user.user_role,
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  //
}
