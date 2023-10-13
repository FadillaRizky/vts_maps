import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/auth/Authentication.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:vts_maps/home.dart';
import 'package:vts_maps/maps_view.dart';
import 'package:vts_maps/utils/shared_pref.dart';

import 'login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => Notifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget home = Login();
  bool load = false;

  Future<void> authCheck() async {
    Auth.AuthCheck().then((value) async {
      if (value.message != null) {
        if (value.message!.contains("Unauthenticated") &&
            await LoginPref.checkPref() == true) {
          LoginPref.removePref();
          EasyLoading.showError("Renew your login session", dismissOnTap: true);
        }
        home = Login();
      } else {
        setState(() {
          EasyLoading.showSuccess("Selamat Datang Kembali ${value.name}");
          home = HomePage();
        });
      }
    });
  }

  @override
  void initState() {
    authCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        load = true;
      });
    });
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AVTS',
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              fontFamily: 'Roboto',
          // textTheme: GoogleFonts.robotoTextTheme()
          //     .copyWith(titleSmall: GoogleFonts.roboto()),
          useMaterial3: true,
        ),
        scrollBehavior: MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown
          },
        ),
        builder: EasyLoading.init(),
        routes: {
          "/": (context) => HomePage(),
          // "/client-map-view": (context) => HomePage(),
          "/login": (context) => Login(),
        },
        initialRoute: "/",
        onGenerateRoute: (settings) {
          if (settings.name!.contains("/client-map-view")) {
            final settingsUri = Uri.parse(settings.name.toString());
            if (settingsUri.queryParametersAll.isNotEmpty) {
              final clientID = settingsUri.queryParameters['client'];
              print(clientID); //will print "123"

              return MaterialPageRoute(
                builder: (context) => HomePage(idClient:clientID.toString())
              );
            }
          }
        },
        // home: HomePage(), 
        // load == true
        //     ? home
        //     : Scaffold(
        //         body: Center(
        //           child: CircularProgressIndicator(),
        //         ),
        //       ),
        // HomePage(),
    );
  }
}
