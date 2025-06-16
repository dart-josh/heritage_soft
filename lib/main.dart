import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/pages/sign_in_page.dart';
import 'package:heritage_soft/widgets/notification_center.dart';
import 'package:month_year_picker2/month_year_picker2.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
        title: 'Heritage Data Center',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
        home: SignInToApp(),
        builder: ((context, child) {
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
