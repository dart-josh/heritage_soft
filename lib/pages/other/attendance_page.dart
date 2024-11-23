import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/staff_database_helpers.dart';
import 'package:heritage_soft/pages/gym/client_sign-in_page.dart';
import 'package:heritage_soft/pages/other/guest_sign_in.dart';
import 'package:heritage_soft/pages/staff/staff_sign_in_page.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AttendancePage extends StatefulWidget {
  final bool home;
  const AttendancePage({super.key, this.home = false});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  void initState() {
    if (!widget.home) GymDatabaseHelpers.get_gym_clients(context);
    if (!widget.home) StaffDatabaseHelpers.get_all_staff(context);
    if (!widget.home) AdminDatabaseHelpers.get_news();
    refresh();
    super.initState();
  }

  // refresh for the time
  refresh() {
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) setState(() {});
      refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'images/attendance_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // contents
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // logo area
                Expanded(
                  flex: 6,
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Expanded(child: Container()),

                        // main text
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black12.withOpacity(.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          height: 150,
                          width: 600,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // welcome text
                              Text(
                                'Welcome'.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Century',
                                  color: Colors.white,
                                  fontSize: 40,
                                  letterSpacing: 5,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFF000000),
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),

                              // sub text
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 60),
                                  child: Text(
                                    '...to Gym',
                                    style: TextStyle(
                                      fontFamily: 'DancingScript',
                                      color: Colors.white,
                                      fontSize: 30,
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
                              ),
                            ],
                          ),
                        ),

                        Expanded(child: Container()),

                        // bottom text
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
                      ],
                    ),
                  ),
                ),

                // main box
                Expanded(
                  flex: 4,
                  child: main_box(),
                ),
              ],
            ),
          ),

          widget.home
              ? Positioned(
                  top: 20,
                  left: 20,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                )
              : Container(),

          // time
          Positioned(
            top: 80,
            left: 80,
            child: Container(
              width: 130,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromARGB(255, 145, 96, 24).withOpacity(0.6),
              ),
              child: Center(
                child: Text(
                  DateFormat.jm().format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // widgets

  // main box
  Widget main_box() {
    return Container(
      color: Color(0xFFB1987F).withOpacity(0.54),
      child: Column(
        children: [
          SizedBox(height: 100),

          // scan box
          Image.asset(
            'images/Scan box.png',
            width: 163,
            height: 154,
          ),

          SizedBox(height: 30),

          // scan id text
          Text(
            'Quickly scan your card\nOR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Color(0xFF000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),

          SizedBox(height: 25),

          // id box
          InkWell(
            onTap: () async {
              var response = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => IdBoxDialog(),
              );

              if (response != null) {
                String val = response;

                var staf_check = Provider.of<AppData>(context, listen: false)
                    .staffs
                    .where(
                      (element) =>
                          element.user_id.toLowerCase() == val.toLowerCase(),
                    );

                // staff sign in
                if (staf_check.isNotEmpty) {
                  var staff = staf_check.first;

                  if (staff.f_name.isEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.red,
                      toastText: 'Setup your profile use this feature!',
                      icon: Icons.error,
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffSignInPage(staff: staff),
                    ),
                  );
                }

                // client sign in
                else {
                  // name search
                  var chk = Provider.of<AppData>(context, listen: false)
                      .client_list
                      .where(
                        (element) =>
                            element.name
                                .toLowerCase()
                                .contains(val.toLowerCase()) ||
                            element.id.toLowerCase() == val.toLowerCase() ||
                            element.id
                                    .toLowerCase()
                                    .replaceAll('dhi', '')
                                    .replaceAll('hm', '')
                                    .replaceAll('hfc', '')
                                    .replaceAll('hpc', '')
                                    .replaceAll('pt', '')
                                    .replaceAll('ft', '')
                                    .replaceAll('-', '') ==
                                val.toLowerCase(),
                      )
                      .toList();

                  var res = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => SearchList(
                      name_list: chk,
                    ),
                  );

                  if (res != null) {
                    ClientSignInModel cl = res;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClSignInPage(client: cl),
                      ),
                    );
                  }
                }
              }
            },
            child: Container(
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFFF0E3DA).withOpacity(0.76),
              ),
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Text(
                'Enter ID...',
                style: TextStyle(
                  fontFamily: 'DancingScript',
                  color: Color(0xFF403F3F),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          Expanded(child: Container()),

          SizedBox(height: 30),

          // not a client text
          Text(
            'Not a client?',
            style: TextStyle(
              fontFamily: '',
              color: Color(0xFFFFFFFF),
              letterSpacing: 2,
            ),
          ),

          SizedBox(height: 10),

          // guest sign in
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuestSI(),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Color(0xFF9F9F9F),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              child: Text(
                'Enter as guest',
                style: TextStyle(
                  fontFamily: '',
                  color: Color(0xFFFFFFFF),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          SizedBox(height: 15),
        ],
      ),
    );
  }

  //
}

// id box dialog
class IdBoxDialog extends StatefulWidget {
  IdBoxDialog({super.key});

  @override
  State<IdBoxDialog> createState() => _IdBoxDialogState();
}

// id box dialog
class _IdBoxDialogState extends State<IdBoxDialog> {
  final TextEditingController id_controller = TextEditingController();

  final FocusNode id_node = FocusNode();

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(id_node);
    });
    super.initState();
  }

  @override
  void dispose() {
    id_controller.dispose();
    id_node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 300,
        ),
        child: Container(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2),

                    // heading
                    Stack(
                      children: [
                        // title
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Client ID',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        // close button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // horizontal line
                    Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),

                    SizedBox(height: 4),

                    // subtitle
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(
                        'Please Input your ID in the box below',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 5),

              // text field
              Container(
                child: Text_field(
                  label: 'Client ID',
                  controller: id_controller,
                  node: id_node,
                ),
              ),

              SizedBox(height: 5),

              // enter button
              InkWell(
                onTap: () {
                  if (id_controller.text.isEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Enter a valid ID',
                      icon: Icons.error,
                    );
                    return;
                  }

                  Navigator.pop(context, id_controller.text.trim());
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF3c5bff).withOpacity(0.6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Center(
                    child: Text(
                      'Enter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// search list
class SearchList extends StatelessWidget {
  final List<ClientSignInModel> name_list;
  const SearchList({super.key, required this.name_list});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.90;
    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: height,
        ),
        child: Container(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2),

                    // heading
                    Stack(
                      children: [
                        // title
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Client search',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        // close button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // horizontal line
                    Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),

                    SizedBox(height: 4),

                    // subtitle
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(
                        'Select one the users below to continue',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 5),

              // empty list
              name_list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 30),
                      child: Center(
                        child: Text(
                          'Client not found !!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    )

                  // list
                  : Expanded(
                      child: ListView(
                        physics: ScrollPhysics(),
                        children: name_list
                            .map(
                              (name) => list_tile(context, name),
                            )
                            .toList(),
                      ),
                    ),

              //
            ],
          ),
        ),
      ),
    );
  }

  // list tile
  Widget list_tile(context, ClientSignInModel name) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context, name);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: Colors.white,
        ),
        margin: EdgeInsets.only(top: 12),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // profile image
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Color(0xFFf97ecf),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: name.user_image.isEmpty
                    ? Image.asset(
                        'images/icon/user-alt.png',
                        width: 25,
                        height: 25,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          name.user_image,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            SizedBox(width: 8),

            // name
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  name.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ),

            // id
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(height: 20),
                SelectableText(
                  name.id,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
