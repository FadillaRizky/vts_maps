import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    //
    // const seenIntroBoxKey = 'seenIntroBox(a)';
    // if (kIsWeb && Uri.base.host.trim() == 'demo.fleaflet.dev') {
    //   SchedulerBinding.instance.addPostFrameCallback(
    //         (_) async {
    //       final prefs = await SharedPreferences.getInstance();
    //       if (prefs.getBool(seenIntroBoxKey) ?? false) return;
    //
    //       if (!mounted) return;
    //
    //       final width = MediaQuery.of(context).size.width;
    //       await showDialog<void>(
    //         context: context,
    //         builder: (context) => AlertDialog(
    //           icon: UnconstrainedBox(
    //             child: SizedBox.square(
    //               dimension: 64,
    //               child:
    //               Image.asset('assets/ProjectIcon.png', fit: BoxFit.fill),
    //             ),
    //           ),
    //           title: const Text('flutter_map Live Web Demo'),
    //           content: ConstrainedBox(
    //             constraints: BoxConstraints(
    //               maxWidth: width < 750
    //                   ? double.infinity
    //                   : (width / (width < 1100 ? 1.5 : 2.5)),
    //             ),
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 const Text(
    //                   "This is built automatically off of the latest commits to 'master', so may not reflect the latest release available on pub.dev.\nThis is hosted on Firebase Hosting, meaning there's limited bandwidth to share between all users, so please keep loads to a minimum.",
    //                   textAlign: TextAlign.center,
    //                 ),
    //                 Padding(
    //                   padding:
    //                   const EdgeInsets.only(right: 8, top: 16, bottom: 4),
    //                   child: Align(
    //                     alignment: Alignment.centerRight,
    //                     child: Text(
    //                       "This won't be shown again",
    //                       style: TextStyle(
    //                         color: Theme.of(context)
    //                             .colorScheme
    //                             .inverseSurface
    //                             .withOpacity(0.5),
    //                       ),
    //                       textAlign: TextAlign.right,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           actions: [
    //             TextButton.icon(
    //               onPressed: () => Navigator.of(context).pop(),
    //               label: const Text('OK'),
    //               icon: const Icon(Icons.done),
    //             ),
    //           ],
    //           contentPadding: const EdgeInsets.only(
    //             left: 24,
    //             top: 16,
    //             bottom: 0,
    //             right: 24,
    //           ),
    //         ),
    //       );
    //       await prefs.setBool(seenIntroBoxKey, true);
    //     },
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  bounds: LatLngBounds(
                    const LatLng(-15.7706446, 93.1003771),
                    const LatLng(8.2454688, 141.6626464),
                  ),
                  // initialCenter: const LatLng(51.5, -0.09),
                  // initialZoom: 5,
                  // cameraConstraint: CameraConstraint.contain(
                  //   bounds: LatLngBounds(
                  //     const LatLng(-90, -180),
                  //     const LatLng(50, 180),
                  //   ),)
                ),
                nonRotatedChildren: [
                  RichAttributionWidget(
                    popupInitialDisplayDuration: const Duration(seconds: 5),
                    animationConfig: const ScaleRAWA(),
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright'),
                        ),
                      ),
                      const TextSourceAttribution(
                        'This attribution is the same throughout this app, except where otherwise specified',
                        prependCopyright: false,
                      ),
                    ],
                  ),
                ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                          width: 50,
                          height: 50,
                          point: const LatLng(-7.8515680, 111.1283210),
                          builder: (ctx) => GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.fromLTRB(16, 0, 16, 5),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  "model_kapal.jpg",
                                                  height: 100,
                                                  width: 100,
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Kapal Pesiar 101-Abc',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Rute : Jakarta - Pontianak',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Image.asset("kapal.png"))),
                      Marker(
                          width: 50,
                          height: 50,
                          point: const LatLng(-7.9515680, 111.1283210),
                          builder: (ctx) => GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.fromLTRB(16, 0, 16, 5),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  "model_kapal.jpg",
                                                  height: 100,
                                                  width: 100,
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Kapal Pesiar 104-AKH',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Rute : Semarang - Surabaya',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Image.asset("kapal.png"))),
                      Marker(
                          width: 50,
                          height: 50,
                          point: const LatLng(-7.6515680, 111.1283210),
                          builder: (ctx) => GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.fromLTRB(16, 0, 16, 5),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  "model_kapal.jpg",
                                                  height: 100,
                                                  width: 100,
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Kapal Pesiar 109-KLS',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Rute : PAPUA - SURABAYA',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Image.asset("kapal.png"))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
