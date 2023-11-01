import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/api/api.dart';
import 'package:vts_maps/auth/Authentication.dart';
import 'package:vts_maps/auth/auth_check_response.dart';
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
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..userInteractions = true
    ..animationStyle = EasyLoadingAnimationStyle.scale
    ..maskType = EasyLoadingMaskType.black;
    // ..customAnimation = CustomAnimation();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          // return Login();
          return VtsMaps();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return Login();
          // ClientMaps(idClient:state.pathParameters['client'].toString());
        },
      ),
      GoRoute(
        path: '/client-map-view/:client',
        builder: (BuildContext context, GoRouterState state) {
          return ClientMaps(
              idClient: state.pathParameters['client'].toString());

          // ClientMaps(idClient:state.pathParameters['client'].toString());
        },
      ),
      GoRoute(
        path: '/login-client/:client',
        builder: (BuildContext context, GoRouterState state) {
          return Login(idClient: state.pathParameters['client'].toString());
          // ClientMaps(idClient:state.pathParameters['client'].toString());
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
