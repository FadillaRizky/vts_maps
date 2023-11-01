import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/api/api.dart';
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
  Notifier readNotifier = Notifier();
  @override
  void initState() {
    readNotifier.authCheck();
      // print("id_user 123 = ${readNotifier.userAuth!.user!.idUser}");

    // print(readNotifier.userAuth!.user!.idUser);
    // print("object123");

    // authCheck();
    super.initState();
  }
  late final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          // return Login();
          return VtsMaps();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return
                // VtsMaps();
                Login();
              // ClientMaps(idClient:state.pathParameters['client'].toString());
            },
          ),
          GoRoute(
            path: 'client-map-view/:client',
            builder: (BuildContext context, GoRouterState state) {
              return ClientMaps(
                  idClient: state.pathParameters['client'].toString());

              // ClientMaps(idClient:state.pathParameters['client'].toString());
            },
          ),
          GoRoute(
            path: 'client-map-view/:client/login',
            builder: (BuildContext context, GoRouterState state) {
              return Login(idClient: state.pathParameters['client'].toString());
              // ClientMaps(idClient:state.pathParameters['client'].toString());
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (!readNotifier.loggedIn) {
        var client = state.pathParameters['client'];
        if (client != null) {
          return "/client-map-view/${state.pathParameters['client']}/login";
        }
        return '/login';
      }
      if(readNotifier.userAuth != null){
        if(readNotifier.userAuth!.user!.level == "client"){
          return "/client-map-view/${readNotifier.userAuth!.client!.idClient}";
        }else{
          return "/";
        }
      }
      return null;
    },
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
