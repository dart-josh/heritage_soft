import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/user_helpers.dart';
import 'package:heritage_soft/widgets/image_box.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class UserSetup extends StatefulWidget {
  final UserModel? user;

  const UserSetup({
    super.key,
    this.user,
  });

  @override
  State<UserSetup> createState() => _UserSetupState();
}

class _UserSetupState extends State<UserSetup> {
  final TextEditingController id_controller = TextEditingController();

  // bool user_active = true;
  String user_role = '';
  String staff_section = '';
  String app_role = '';

  String first_name = '';
  String middle_name = '';
  String last_name = '';
  String user_image = '';

  List<String> office_section = [
    'General Staff',
    'Heritage Physiotherapy clinic',
    'Heritage Fitness',
    'Delightsome Juice & Smoothies'
  ];

  List<String> roles = [
    'Management',
    'Admin/Accounting',
    'Customer Service Unit',
    'ICT',
    'Physiotherapist',
    'Production',
    'Sales',
  ];

  TextStyle labelStyle = TextStyle(
    color: Color(0xFFc3c3c3),
    fontSize: 11,
  );
  TextStyle nameStyle = TextStyle(
    color: Colors.white,
    height: 1,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    fontSize: 20,
    shadows: [
      Shadow(
        color: Color(0xFF000000),
        offset: Offset(0.7, 0.7),
        blurRadius: 6,
      ),
    ],
  );

  bool edit = false;

  Uint8List? image_file;

  late UserModel active_user;

  bool new_user = false;

  bool full_access = false;
  bool can_sign_in = false;

  get_values() async {
    // staff details
    if (widget.user != null) {
      id_controller.text = widget.user?.user_id ?? '';
      user_role = widget.user!.user_role;
      staff_section = widget.user!.section;
      first_name = widget.user!.f_name;
      middle_name = widget.user!.m_name;
      last_name = widget.user!.l_name;
      user_image = widget.user!.user_image;
      app_role = widget.user!.app_role;
      can_sign_in = widget.user!.can_sign_in;
      full_access = widget.user!.full_access;
    } else {
      edit = true;
    }
  }

  generate_user_id() async {
    var res = await UserHelpers.generate_user_id(context);
    if (res != '') {
      String id =
          Helpers.generate_id(xx: 'stf', hmo: false, id: int.parse(res));
      id_controller.text = id;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    new_user = widget.user == null;
    if (new_user) generate_user_id();
    get_values();
    super.initState();
  }

  @override
  void dispose() {
    id_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // get active user
    active_user = AppData.get(context).active_user!;

    if (width >= 800)
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: main_body(width)),
          ],
        ),
      );
    else
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 10, 63, 124),
        body: Expanded(child: main_body(width)),
      );
  }

  // WIDGETs

  // main body
  Widget main_body(double width) {
    return Container(
      width: width >= 800 ? width * 0.60 : width,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 10, 63, 124).withOpacity(.8),
      ),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          // top bar
          top_bar(),

          SizedBox(height: 8),

          // details
          if (!new_user) id_con(),

          Expanded(
              child: SingleChildScrollView(
                  child: Column(
            children: [
              SizedBox(height: 10),
              // form
              form(),
            ],
          ))),

          width >= 800 ? SizedBox(height: 20) : Expanded(child: Container()),

          edit || new_user ? submit_button() : Container(height: 40),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  // top bar
  Widget top_bar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white60,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Stack(
        children: [
          // heading
          Center(
            child: Text(
              new_user
                  ? 'New User Account'
                  : edit
                      ? 'Edit User'
                      : 'User Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),

          // action buttons
          Row(
            children: [
              // close button
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              Expanded(child: Container()),

              // settings button
              if (!new_user && active_user.full_access)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: edit
                      ? InkWell(
                          onTap: () {
                            edit = false;
                            setState(() {});
                          },
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 28,
                          ),
                        )
                      : settings_menu(
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                ),

              // delete button
              if (!new_user && active_user.full_access)
                IconButton(
                  onPressed: () async {
                    var conf = await Helpers.showConfirmation(
                        context: context,
                        title: 'Delete User',
                        message:
                            'You are about to delete this user from the database. Would you like to proceed?');

                    if (conf) {
                      Map del = await UserHelpers.delete_user(
                        context,
                        user_id: widget.user!.key ?? '',
                        showLoading: true,
                        showToast: true,
                      );

                      if (del['status'] == true) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // id
  Widget id_con() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // id label
          Text(
            'ID',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1,
            ),
          ),

          SizedBox(height: 2),

          // id
          Text(
            widget.user?.user_id ?? '',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // form
  Widget form() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
      child: Column(
        children: [
          // main details
          Stack(
            children: [
              // image & name
              Container(
                padding: EdgeInsets.only(top: 15, right: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // profile image
                    Stack(
                      children: [
                        // selected image
                        edit && image_file != null
                            ? Container(
                                margin: EdgeInsets.only(bottom: 6, right: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(
                                    image_file!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )

                            // no image
                            : user_image.isEmpty
                                ? Container(
                                    margin:
                                        EdgeInsets.only(bottom: 6, right: 6),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFf3f0da).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.all(30),
                                    child: Center(
                                      child: Image.asset(
                                        'images/icon/material-person.png',
                                        width: 90,
                                        height: 90,
                                      ),
                                    ),
                                  )

                                // image from db
                                : Container(
                                    margin:
                                        EdgeInsets.only(bottom: 6, right: 6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        user_image,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                        // edit image
                        if (edit)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                var res = await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => EditProfileImage(
                                    is_edit: true,
                                    user_image: user_image.isNotEmpty
                                        ? user_image
                                        : null,
                                  ),
                                );

                                if (res != null) {
                                  if (res == 'del') {
                                    user_image = '';
                                    image_file = null;
                                  } else {
                                    image_file = res;
                                  }

                                  setState(() {});
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.edit,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(width: 30),

                    // profile area
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // first name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // label
                              Text(
                                'First name',
                                style: labelStyle,
                              ),

                              // name
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 8, top: 2, bottom: 5),
                                child: Text(
                                  first_name,
                                  style: nameStyle,
                                ),
                              )
                            ],
                          ),

                          // middle name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // label
                              Text(
                                'Middle name',
                                style: labelStyle,
                              ),

                              // name
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 8, top: 2, bottom: 5),
                                child: Text(
                                  middle_name,
                                  style: nameStyle,
                                ),
                              )
                            ],
                          ),

                          // last name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // label
                              Text(
                                'Last name',
                                style: labelStyle,
                              ),

                              // name
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 8, top: 2, bottom: 5),
                                child: Text(
                                  last_name,
                                  style: nameStyle,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // edit name
              Positioned(
                top: 0,
                right: 0,
                child: !edit
                    ? Container(
                        width: 35,
                        height: 35,
                      )

                    // edit name
                    : InkWell(
                        onTap: () async {
                          var res = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => EditNameDailog(
                              fn: first_name,
                              mn: middle_name,
                              ln: last_name,
                            ),
                          );

                          if (res != null) {
                            first_name = res['first_name'];
                            middle_name = res['middle_name'];
                            last_name = res['last_name'];

                            setState(() {});
                          }
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: Center(
                            child:
                                Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
              ),
            ],
          ),

          SizedBox(height: 10),

          // id
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text_field(
              controller: id_controller,
              label: 'User ID',
              edit: !active_user.full_access && edit,
            ),
          ),

          SizedBox(height: 10),

          // role & section
          Row(
            children: [
              // role
              Expanded(
                child: Select_form(
                  label: 'Job Role',
                  options: roles,
                  text_value: user_role,
                  setval: (val) {
                    user_role = val;
                    setState(() {});
                  },
                  edit: active_user.full_access && edit,
                ),
              ),

              Container(width: 30),

              // section
              Expanded(
                child: Select_form(
                  label: 'Office section',
                  options: office_section,
                  text_value: staff_section,
                  setval: (val) {
                    staff_section = val;
                    setState(() {});
                  },
                  edit: active_user.full_access && edit,
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          // app role
          Container(
            width: 200,
            child: Select_form(
              label: 'App role',
              options: app_roles,
              text_value: app_role,
              setval: (val) {
                app_role = val;
                setState(() {});
              },
              edit: active_user.full_access && edit,
            ),
          ),

          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // can sign in
              Text('Can Sign In', style: labelStyle),

              Switch(
                value: can_sign_in,
                onChanged: (val) {
                  if (edit)
                    setState(() {
                      can_sign_in = val;
                    });
                },
              ),

              SizedBox(width: 30),

              // ful access
              Text('Full access', style: labelStyle),

              Switch(
                value: full_access,
                onChanged: (val) {
                  if (edit)
                    setState(() {
                      full_access = val;
                    });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget submit_button() {
    return InkWell(
      onTap: () async {
        if (new_user)
          create_new_account();
        else
          update_profile();
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
            new_user ? 'Create Account' : 'Update Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // settings pop up menu
  Widget settings_menu({required child}) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(0),
      offset: Offset(0, 30),
      child: child,
      enabled: !edit,
      elevation: 8,
      onSelected: (value) async {
        // edit name
        if (value == 1) {
          setState(() {
            edit = true;
          });
        }

        if (value == 2) {
          create_doctor_profile(widget.user!);
        }
      },
      itemBuilder: (context) => [
        // edit profile
        PopupMenuItem(
          value: 1,
          child: Container(
            child: Row(
              children: [
                Icon(Icons.edit, size: 22),
                SizedBox(width: 4),
                Text(
                  'Edit profile',
                  style: TextStyle(),
                ),
              ],
            ),
          ),
        ),

        // create doctor profile
        if ((user_role == 'Physiotherapist') && active_user.full_access)
          PopupMenuItem(
            value: 2,
            child: Container(
              child: Row(
                children: [
                  Icon(Icons.person, size: 22),
                  SizedBox(width: 4),
                  Text(
                    'Doctor Profile',
                    style: TextStyle(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // FUNCTIONS
  // new staff
  void create_new_account() async {
    if (id_controller.text.trim().isEmpty) {
      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'Enter user id',
        icon: Icons.error,
      );
      return;
    }

    var conf = await Helpers.showConfirmation(
        context: context,
        title: 'Create new account',
        message: 'Make sure you entered the correct info before proceeding.');

    if (conf) {
      Map data = UserModel(
        user_id: id_controller.text.trim(),
        f_name: first_name,
        m_name: middle_name,
        l_name: last_name,
        user_image: user_image,
        user_status: true,
        user_role: user_role,
        section: staff_section,
        app_role: app_role,
        full_access: full_access,
        can_sign_in: can_sign_in,
      ).toJson();

      Map ns = await UserHelpers.add_update_user(
        context,
        data: data,
        showLoading: true,
        showToast: true,
      );

      if (ns['user'] != null)
        setState(() {
          edit = false;
        });
    }
  }

  // update staff
  void update_profile() async {
    var conf = await Helpers.showConfirmation(
        context: context,
        title: 'Update User',
        message:
            'Make sure you entered the correct details before proceeding.');

    if (conf) {
      // upload image
      if (image_file != null) {
        user_image = '';
      }

      Map data = UserModel(
        key: widget.user!.key,
        user_id: id_controller.text.trim(),
        f_name: first_name,
        m_name: middle_name,
        l_name: last_name,
        user_image: user_image,
        user_status: true,
        user_role: user_role,
        section: staff_section,
        app_role: app_role,
        full_access: full_access,
        can_sign_in: can_sign_in,
      ).toJson();

      Map ns = await UserHelpers.add_update_user(
        context,
        data: data,
        showLoading: true,
        showToast: true,
      );

      if (ns['user'] != null) {
        setState(() {
          edit = false;
        });
      }
    }
  }

  // create doctor profile
  void create_doctor_profile(UserModel user) async {
    Map data_2 = DoctorModel(
      user: user,
      is_available: false,
      title: 'Physiotherapist',
      my_patients: [],
      ong_patients: [],
      pen_patients: [],
    ).toJson();

    Map dc = await UserHelpers.add_update_doctor(
      context,
      data: data_2,
      showLoading: true,
      showToast: true,
    );

    if (dc['doctor'] != null) {}
  }

  //
}

// edit name dialog
class EditNameDailog extends StatefulWidget {
  final String fn;
  final String mn;
  final String ln;
  const EditNameDailog({
    super.key,
    required this.fn,
    required this.mn,
    required this.ln,
  });

  @override
  State<EditNameDailog> createState() => _EditNameDailogState();
}

class _EditNameDailogState extends State<EditNameDailog> {
  final TextEditingController fn_controller = TextEditingController();
  final TextEditingController mn_controller = TextEditingController();
  final TextEditingController ln_controller = TextEditingController();

  @override
  void dispose() {
    fn_controller.dispose();
    mn_controller.dispose();
    ln_controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    assignName();
    super.initState();
  }

  void assignName() {
    fn_controller.text = widget.fn;
    mn_controller.text = widget.mn;
    ln_controller.text = widget.ln;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 500,
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

                    // title
                    Stack(
                      children: [
                        // title
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'User Fullname',
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
                        'Use the form below to setup your name',
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

              // first name text field
              Container(
                color: Colors.black.withOpacity(0.6),
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text_field(
                  label: 'First name',
                  controller: fn_controller,
                  require: true,
                ),
              ),

              // middle name text field
              Container(
                color: Colors.black.withOpacity(0.6),
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text_field(
                  label: 'Middle name',
                  controller: mn_controller,
                ),
              ),

              // last name text field
              Container(
                color: Colors.black.withOpacity(0.6),
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text_field(
                  label: 'Last name',
                  controller: ln_controller,
                  require: true,
                ),
              ),

              SizedBox(height: 10),

              // submit button
              InkWell(
                onTap: () {
                  if (fn_controller.text.isEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'First name empty',
                      icon: Icons.error,
                    );
                    return;
                  }

                  if (ln_controller.text.isEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Last name empty',
                      icon: Icons.error,
                    );
                    return;
                  }

                  Map name = {
                    'first_name': fn_controller.text.trim(),
                    'middle_name': mn_controller.text.trim(),
                    'last_name': ln_controller.text.trim(),
                  };

                  Navigator.pop(context, name);
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
                      'Submit',
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
