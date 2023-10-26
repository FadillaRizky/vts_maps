import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/auth/Authentication.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:vts_maps/home.dart';
import 'package:vts_maps/maps_view.dart';
import 'package:vts_maps/pages/client/client_maps.dart';
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
          home = VtsMaps();
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
    return MaterialApp.router(
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
        routerConfig: _router,

        // routes: {
        //   "/": (context) => HomePage(),
        //   "/login": (context) => Login(),
        //   // "/client-map-view": (context) => HomePage(),
        // },
        // initialRoute: "/",
        // onGenerateRoute: (settings) {
        //   if (settings.name!.contains("/client-map-view")) {
        //     final settingsUri = Uri.parse(settings.name.toString());
        //     if (settingsUri.queryParametersAll.isNotEmpty) {
        //       final clientID = settingsUri.queryParameters['client'];
        //       print(clientID);

        //       return MaterialPageRoute(
        //         builder: (context) => HomePage(idClient:clientID.toString())
        //       );
        //     }
        //   }
        // },
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

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const VtsMaps();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'client-map-view/:client',
          builder: (BuildContext context, GoRouterState state) {
            return ClientMaps(idClient:state.pathParameters['client'].toString());
          },
        ),
      ],
    ),
  ],
);
