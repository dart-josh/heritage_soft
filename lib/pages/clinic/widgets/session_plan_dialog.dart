import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class SessionPlanDialog extends StatefulWidget {
  final bool session_set;
  final String? total_session;
  final bool add_session;
  final Map? session_details;
  const SessionPlanDialog({
    super.key,
    required this.session_set,
    this.total_session,
    this.add_session = false,
    this.session_details,
  });

  @override
  State<SessionPlanDialog> createState() => _SessionPlanDialogState();
}

class _SessionPlanDialogState extends State<SessionPlanDialog> {
  final TextEditingController total_controller = TextEditingController();
  final TextEditingController frequency_controller = TextEditingController();

  final TextEditingController add_sess_controller = TextEditingController();

  final FocusNode total_node = FocusNode();
  final FocusNode frequency_node = FocusNode();

  @override
  void initState() {
    if (widget.session_details != null) {
      total_sess = widget.session_details?['total_sess']?.toString() ?? '';
      frequency = widget.session_details?['frequency'] ?? '';
      total_controller.text = total_sess;
      return;
    }

    if (widget.total_session != null) {
      total_controller.text = widget.total_session!;
    } else {
      Future.delayed(Duration(milliseconds: 300), () {
        FocusScope.of(context).requestFocus(total_node);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    total_controller.dispose();
    frequency_controller.dispose();
    add_sess_controller.dispose();
    total_node.dispose();
    frequency_node.dispose();
    super.dispose();
  }

  String total_sess = '';
  String frequency = '';

  String? frequency_select;
  List<String> frequency_options = [
    'Weekly',
    'Bi-Weekly',
    'Monthly',
    'Bi-Monthly',
    'Quarterly',
  ];

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
          width: 300,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade400.withOpacity(.8),
            borderRadius: BorderRadius.circular(6),
          ),
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
                        // heading
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              (widget.add_session)
                                  ? 'Add Treatment Session'
                                  : widget.session_set
                                      ? 'Change Session Frequency'
                                      : 'Treatment Session Setup',
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
                        (widget.add_session)
                            ? 'Use the form below to add treatment sessions to the existing sessions'
                            : 'Use the form below to setup a treatment plan',
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

              SizedBox(height: 20),

              // add sessions
              if (widget.add_session)
                Column(
                  children: [
                    // total label
                    Text(
                      'Total Session',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // total
                    Text(
                      total_sess,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),

                    // frequency label
                    Text(
                      'Session Frequency',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // frequency
                    Text(
                      frequency,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),

                    // add label
                    Text(
                      'No. of Session',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 2),

                    // add session controller
                    Container(
                      width: 80,
                      child: Text_field(
                        label: '',
                        controller: add_sess_controller,
                        text_align: TextAlign.center,
                        format: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                )

              // session setup
              else
                Column(
                  children: [
                    // total label
                    Text(
                      'Total Session',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 2),

                    // total session controller
                    Container(
                      width: 80,
                      child: Text_field(
                        label: '',
                        controller: total_controller,
                        node: total_node,
                        text_align: TextAlign.center,
                        format: [FilteringTextInputFormatter.digitsOnly],
                        edit: widget.session_set,
                      ),
                    ),

                    SizedBox(height: 20),

                    // frequency label
                    Text(
                      'Session Frequency',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 2),

                    // frequency
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // frequency amount controller
                        Container(
                          width: 50,
                          child: Text_field(
                            label: '',
                            controller: frequency_controller,
                            node: frequency_node,
                            text_align: TextAlign.center,
                            format: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),

                        SizedBox(width: 10),

                        // times label
                        Text(
                          'times',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(width: 10),

                        // frequency select
                        Container(
                          width: 145,
                          child: DropdownButtonFormField<String>(
                            // itemHeight: 40,
                            dropdownColor: Colors.black87,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 1),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white70,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white70,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            value: frequency_select,
                            items: frequency_options
                                .map((e) => DropdownMenuItem<String>(
                                    value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                frequency_select = val;

                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              SizedBox(height: 40),

              // submit button
              InkWell(
                onTap: () async {
                  // add session
                  if (widget.add_session) {
                    if (add_sess_controller.text.isEmpty ||
                        int.parse(add_sess_controller.text) == 0) {
                      Helpers.showToast(
                        context: context,
                        color: Colors.redAccent,
                        toastText: 'Number of Session Empty',
                        icon: Icons.error,
                      );
                      return;
                    }

                    int new_sess = (total_sess != '' ? int.parse(total_sess) : 0) +
                        int.parse(add_sess_controller.text);

                    Navigator.pop(context, new_sess);
                  }

                  // session setup
                  else {
                    if (total_controller.text.isEmpty) {
                      Helpers.showToast(
                        context: context,
                        color: Colors.redAccent,
                        toastText: 'Number of Session Empty',
                        icon: Icons.error,
                      );
                      return;
                    }

                    if (frequency_controller.text.isEmpty ||
                        frequency_select == null) {
                      Helpers.showToast(
                        context: context,
                        color: Colors.redAccent,
                        toastText: 'Select frequency',
                        icon: Icons.error,
                      );
                      return;
                    }

                    String occur = (frequency_controller.text.isNotEmpty &&
                            (int.parse(frequency_controller.text) > 0))
                        ? (int.parse(frequency_controller.text) == 1)
                            ? 'once ${frequency_select}'
                            : '${frequency_controller.text} times ${frequency_select}'
                        : '';

                    Map rt_map = {
                      'total': int.parse(total_controller.text),
                      'frequency': occur
                    };

                    Navigator.pop(context, rt_map);
                  }
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    color: Color(0xFF3c5bff).withOpacity(0.6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Center(
                    child: Text(
                      (widget.add_session)
                          ? 'Add Session'
                          : (widget.session_set)
                              ? 'Update Frequency'
                              : 'Set Sessions',
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
