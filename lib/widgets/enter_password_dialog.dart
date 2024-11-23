import 'package:flutter/material.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';

class EnterPasswordDialog extends StatefulWidget {
  final String required_password;
  final String universal;
  const EnterPasswordDialog({
    super.key,
    required this.required_password,
    required this.universal,
  });

  @override
  State<EnterPasswordDialog> createState() => _EnterPasswordDialogState();
}

class _EnterPasswordDialogState extends State<EnterPasswordDialog> {
  final TextEditingController password_controler = TextEditingController();
  final FocusNode password_node = FocusNode();

  bool obscure = true;

  int failed = 0;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 200), () {
      FocusScope.of(context).requestFocus(password_node);
    });
    super.initState();
  }

  @override
  void dispose() {
    password_controler.dispose();
    password_node.dispose();
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
        children: [
          // top bar
          Stack(
            children: [
              // title
              Container(
                width: 310,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    'Enter Password',
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
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // body
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Color.fromARGB(225, 12, 28, 35),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // password box
                TextField(
                  controller: password_controler,
                  focusNode: password_node,
                  obscureText: obscure,
                  onChanged: (val) {
                    setState(() {});
                  },
                  onSubmitted: (val) {
                    submit();
                  },
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: password_controler.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              obscure = !obscure;
                              setState(() {});
                            },
                            child: Icon(
                              obscure ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),

                SizedBox(height: 20),

                // confirm btn
                InkWell(
                  onTap: () {
                    submit();
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 21, 94, 106),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                //
              ],
            ),
          ),
        ],
      ),
    );
  }

  // submit button
  void submit() {
    if (password_controler.text.isEmpty) {
      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'Enter a valid password',
        icon: Icons.error,
      );
      FocusScope.of(context).requestFocus(password_node);
      return;
    }

    if (password_controler.text != widget.required_password &&
        password_controler.text != widget.universal) {
      if (failed == 3) {
        Navigator.pop(context, false);
        Helpers.showToast(
          context: context,
          color: Colors.red,
          toastText: 'Maximum tries exceeded',
          icon: Icons.error,
        );
        return;
      }

      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'Password Incorrect, You have ${3 - failed} tries left',
        icon: Icons.error,
      );
      FocusScope.of(context).requestFocus(password_node);

      failed++;
      return;
    }

    Navigator.pop(context, true);
  }
}
