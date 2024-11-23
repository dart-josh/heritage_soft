import 'package:flutter/material.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:universal_html/html.dart';

class ClientindemnityVerification extends StatefulWidget {
  final String client_key;

  const ClientindemnityVerification({
    super.key,
    required this.client_key,
  });

  @override
  State<ClientindemnityVerification> createState() =>
      _ClientindemnityVerificationState();
}

class _ClientindemnityVerificationState
    extends State<ClientindemnityVerification> {
  bool is_verified = false;

  String client_name = '';

  bool loading_user = true;
  bool user_exist = false;

  bool page_done = false;

  listen_to_verification() {
    GymDatabaseHelpers.get_client_details(widget.client_key).then((event) {
      if (event.exists) {
        is_verified = event.data()!['indemnity_verified'] ?? false;
        client_name = '${event.data()!['f_name']} ${event.data()!['l_name']}';
        user_exist = true;
      } else {
        user_exist = false;
      }

      if (is_verified) {
        window.location.replace(indemnity_replace_url);
      } else {
        loading_user = false;

        setState(() {});
      }
    });
  }

  void verify_indemnity() async {
    if (!is_verified) {
      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'Form not acknowledged',
        icon: Icons.error,
      );
      return;
    }

    Helpers.showLoadingScreen(context: context);
    bool ver = await GymDatabaseHelpers.verify_indemnity(widget.client_key);
    Navigator.pop(context);
    if (!ver) {
      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'An error occured',
        icon: Icons.error,
      );
      return;
    }

    Helpers.showToast(
        context: context,
        color: Colors.green,
        toastText: 'Verified',
        icon: Icons.check);

    remove_page();
  }

  remove_page() {
    setState(() {
      page_done = true;
    });
    window.location.replace(indemnity_replace_url);
  }

  @override
  void initState() {
    listen_to_verification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client User Agreement'),
        centerTitle: true,
      ),
      body: page_done
          ? Container()
          : loading_user
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : !user_exist
                  ? Center(
                      child: Text('Invalid User Account'),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              indemnity_write_up,
                            ),
                            SizedBox(height: 30),
                            acknowledge_area(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget acknowledge_area() {
    return Column(
      children: [
        // name & date
        Row(
          children: [
            Text(
              'Client name:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(width: 4),
            Text(
              client_name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: Container()),
            Text(
              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),

        SizedBox(height: 10),

        // acknowlegdement box
        Row(
          children: [
            Checkbox(
              value: is_verified,
              onChanged: (val) {
                is_verified = !is_verified;
                setState(() {});
              },
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                  'I acknowledge and agree to the terms of the user agreement indemnity form.'),
            ),
          ],
        ),

        SizedBox(height: 10),

        // finish box
        InkWell(
          onTap: () {
            verify_indemnity();
          },
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFF6BEF89).withOpacity(0.8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            margin: EdgeInsets.only(bottom: 5),
            child: Center(
              child: Text(
                'Finish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
