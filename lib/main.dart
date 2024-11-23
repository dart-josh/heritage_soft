import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/pages/gym/client_indemnity_verifiaction_page.dart';
import 'package:heritage_soft/pages/sign_in_page.dart';
import 'package:heritage_soft/widgets/notification_center.dart';
import 'package:month_year_picker2/month_year_picker2.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:html';

String page = 'main_app';
String indemnity_key = '';

void getParams() {
  // todo check the base url if not for user agreement skip
  // if (!window.location.href.contains('heritageuseragreement')) {
  //   return;
  // }

  var uri = Uri.dataFromString(window.location.href);
  Map<String, String> params = uri.queryParameters;
  var indemnity = params['indemnity'] ?? 'false';

  if (indemnity == 'true') {
    var key = params['key'] ?? '';

    if (key != '') {
      indemnity_key = key;
      page = 'indemnity';
    }
    //  else {
    //   window.location.replace(indemnity_replace_url);
    // }
  }
  //  else {
  //   window.location.replace(indemnity_replace_url);
  // }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  getParams();
  runApp(MyApp(page: page, page_key: indemnity_key));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.page, required this.page_key});

  final String page;
  final String page_key;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          MonthYearPickerLocalizations.delegate,
        ],
        title: 'Delightsome Heritage',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
        home: (widget.page == 'main_app')
            ? VerifyLogin()
            : ClientindemnityVerification(
                client_key: widget.page_key,
              ),
        builder: ((context, child) {
          if (widget.page != 'main_app') return child!;
          return Stack(
            children: [
              child!,

              // notification
              Positioned(
                left: 0,
                right: 0,
                top: 20,
                child: Center(
                  child: NotificationCenter(
                    client: Provider.of<AppData>(context).sign_in_cl,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
