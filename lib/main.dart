import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vts_maps/auth/Authentication.dart';
import 'package:vts_maps/maps_view.dart';
import 'package:vts_maps/utils/shared_pref.dart';

import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? home;

  Future<void> authCheck() async {
    Auth.AuthCheck().then((value) {
      if (value.message != null) {
        if (value.message!.contains("Unauthenticated") &&
            LoginPref.checkPref() == true) {
          LoginPref.removePref();
          EasyLoading.showError("Renew your login session", dismissOnTap: true);
        }
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
      home = home;
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VTS Maps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.robotoTextTheme()
            .copyWith(titleSmall: GoogleFonts.roboto()),
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
      home: home != null
          ? home
          : Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
      // HomePage(),
    );
  }
}
