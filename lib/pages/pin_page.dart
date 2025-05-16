import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinPage extends StatefulWidget {
  final String user_id;
  final String user_name;
  final int page_index;
  const PinPage({
    super.key,
    required this.user_id,
    required this.user_name,
    required this.page_index,
  });

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  TextEditingController pin_controller = TextEditingController();
  FocusNode pin_node = FocusNode();

  int pin_1_confirmation = 0;
  String? pin_1;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 300),
        () => FocusScope.of(context).requestFocus(pin_node));
    super.initState();
  }

  @override
  void dispose() {
    pin_controller.dispose();
    pin_node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: 350,
        height: 310,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 3, 25, 43),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            pin_page(widget.page_index, widget.user_id, widget.user_name),
          ],
        ),
      ),
    );
  }

  //?

  // user tile
  Widget user_tile(String staff_id, String staff_name) {
    return Container(
      width: 260,
      margin: EdgeInsets.only(bottom: 30),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white24,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // user image
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            width: 37,
            height: 37,
            child: Center(
              child: Icon(Icons.person_2_rounded,
                  size: 27, color: Colors.grey.shade700),
            ),
          ),

          SizedBox(width: 12),

          // details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // id
                Text(
                  staff_id,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: 5),

                // name
                Text(
                  staff_name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // pin page
  Widget pin_page(int _page_index, user_id, user_name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Column(
        children: [
          user_tile(user_id, user_name),
          SizedBox(height: 1),
          Text(
            _page_index == 1
                ? pin_1_confirmation == 0
                    ? 'Create 4 digit pin'
                    : 'Confrim 4 digit pin'
                : 'Enter 4 digit pin to login',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          buildPinPut(_page_index),
          Container(
            width: 300,
            margin: EdgeInsets.only(top: 10),
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                pin_controller.clear();
                if (_page_index == 1 && pin_1_confirmation == 1) {
                  pin_1_confirmation = 0;
                  pin_1 = null;

                  Future.delayed(Duration(milliseconds: 300),
                      () => FocusScope.of(context).requestFocus(pin_node));
                  setState(() {});
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text('Go back'),
            ),
          ),
        ],
      ),
    );
  }

  // pin put
  Widget buildPinPut(int _page_index) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(16, 88, 150, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white24,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(238, 114, 114, 1)),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Pinput(
        controller: pin_controller,
        focusNode: pin_node,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        errorPinTheme: errorPinTheme,
        submittedPinTheme: submittedPinTheme,
        obscureText: true,
        validator: (s) {
          if (_page_index == 1) {
            if (pin_1_confirmation == 1) {
              if (s != null && s.isNotEmpty && pin_1 != s) {
                return 'Pin do not match';
              }
            }
            return null;
          }

          return null;
        },
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        onCompleted: (_pin) {
          if (_page_index == 1 && pin_1_confirmation == 0) {
            pin_controller.clear();
            setState(() {
              pin_1_confirmation = 1;
              pin_1 = _pin;
            });
            Future.delayed(Duration(milliseconds: 300),
                () => FocusScope.of(context).requestFocus(pin_node));
          } else if (_page_index == 1 && pin_1_confirmation == 1) {
            if (pin_1 == _pin) {
              Navigator.pop(context, _pin);
            }
          } else {
            Navigator.pop(context, _pin);
          }
        });
  }

  //
}
