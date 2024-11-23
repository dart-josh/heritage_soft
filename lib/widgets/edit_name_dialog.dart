import 'package:flutter/material.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/text_field.dart';

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
                              'Edit Client name',
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
                        'Use the form below to change the client\'s name',
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
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text_field(
                  label: 'First name',
                  controller: fn_controller,
                  require: true,
                ),
              ),

              // middle name text field
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text_field(
                  label: 'Middle name',
                  controller: mn_controller,
                ),
              ),

              // last name text field
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text_field(
                  label: 'Last name',
                  controller: ln_controller,
                  require: true,
                ),
              ),

              SizedBox(height: 10),

              // enter button
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