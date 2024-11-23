import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/password_model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:provider/provider.dart';

class ManagePasswords extends StatefulWidget {
  const ManagePasswords({super.key});

  @override
  State<ManagePasswords> createState() => _ManagePasswordsState();
}

class _ManagePasswordsState extends State<ManagePasswords> {
  @override
  Widget build(BuildContext context) {
    List<PasswordModel> passwords = Provider.of<AppData>(context).passwords;

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // top bar
          Stack(
            children: [
              // title
              Container(
                width: 400,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                ),
                child: Center(
                  child: Text(
                    'Manage Passwords',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // close button
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // main
          Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: Color.fromARGB(119, 9, 16, 18),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: passwords.map((e) => password_tile(e)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // password tile
  Widget password_tile(PasswordModel password) {
    return InkWell(
      onDoubleTap: () async {
        if (password.title.toLowerCase() == 'universal password') return;

        var conf = await showDialog(
            context: context,
            builder: (context) => EditPassword(title: password.title));

        if (conf != null) {
          Helpers.showLoadingScreen(context: context);

          bool sep = await AdminDatabaseHelpers.set_admin_passwords(
              password.key, {'password': conf});

          Navigator.pop(context);

          if (!sep) {
            Helpers.showToast(
              context: context,
              color: Colors.red,
              toastText: 'An Error occurred, Try again',
              icon: Icons.error,
            );
            return;
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 3, 18, 24),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              password.title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                password.password.isEmpty
                    ? Container()
                    : password.hidden
                        ? Text(
                            '**********',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : SelectableText(
                            password.password,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                Expanded(child: Container()),
                IconButton(
                  onPressed: () {
                    if (password.password.isEmpty) return;
                    setState(() {
                      password.hidden = !password.hidden;
                    });
                  },
                  icon: Icon(
                    password.hidden ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                password.hidden
                    ? Container(width: 38)
                    : IconButton(
                        onPressed: () {
                          if (password.password.isEmpty) return;
                          Clipboard.setData(
                              ClipboardData(text: password.password));
                          Helpers.showToast(
                            context: context,
                            color: Colors.blue,
                            toastText: 'Copied to Clipboard',
                            icon: Icons.copy_all,
                          );
                        },
                        icon: Icon(
                          Icons.copy,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditPassword extends StatefulWidget {
  final String title;
  const EditPassword({super.key, required this.title});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  final TextEditingController pass_controler = TextEditingController();
  final TextEditingController pass_2_controler = TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    pass_2_controler.dispose();
    pass_controler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // tite
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // password container
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.black87,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // password 1
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter new Password',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: pass_controler,
                        obscureText: obscure,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                // password 2
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: pass_2_controler,
                        obscureText: obscure,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                // show/hide password
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                    child: Text(
                      obscure ? 'Show Password' : 'Hide Password',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // confirm button
                IconButton(
                  onPressed: () async {
                    if (pass_controler.text.isEmpty ||
                        pass_2_controler.text.isEmpty) return;

                    if (pass_controler.text != pass_2_controler.text) {
                      Helpers.showToast(
                        context: context,
                        color: Colors.red,
                        toastText: 'Passwords do not match',
                        icon: Icons.error,
                      );
                      return;
                    }

                    var conf = await Helpers.enter_password(context,
                        title: 'universal password');

                    if (conf) {
                      Navigator.pop(context, pass_controler.text.trim());
                    }
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    height: 42,
                    // width: ,
                    child: Center(
                      child: Text(
                        'Set Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
