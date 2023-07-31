import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api/GetAllVesselCoor.dart' as LatestVesselCoor;
import 'api/GetAllLatLangCoor.dart' as LatLangCoor;
import 'api/GetAllVessel.dart' as Vessel;
import 'api/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<LatestVesselCoor.Data> result = [];
  List<Vessel.Data> vesselResult = [];
  List<LatLangCoor.Data> latLangResult = [];
  List dummy = [1, 2, 3];
  List dummyLat = [-6.8515680, -7.8515680, -8.8515680];
  List dummyLong = [];
  int predictMovementVessel = 0;
  String? onClickVessel;

  int? vesselIndex;
  DraggableScrollableController dragController = DraggableScrollableController();

  bool _isSheetOpen = false;

  void _toggleSheet() {
    setState(() {
      _isSheetOpen = !_isSheetOpen;
    });
  }

  initCoorVessel() {
    result.clear();
    setState(() {
      predictMovementVessel = 0;
    });
    Api.getAllVesselLatestCoor().then((value) {
      if (value.total! == 0) {
        setState(() {
          result = [];
        });
      }
      if (value.total! > 0) {
        setState(() {
          result.addAll(value.data!);
        });
      }
    });
    Timer.periodic(Duration(minutes: 5), (timer) {
      result.clear();
      setState(() {
        predictMovementVessel = 0;
      });
      Api.getAllVesselLatestCoor().then((value) {
        if (value.total! == 0) {
          setState(() {
            result = [];
          });
        }
        if (value.total! > 0) {
          setState(() {
            result.addAll(value.data!);
          });
        }
      });
    });
  }

  void initVessel() {
    vesselResult.clear();
    Api.getAllVessel().then((value) {
      if (value.total! == 0) {
        setState(() {
          vesselResult = [];
        });
      }
      if (value.total! > 0) {
        setState(() {
          vesselResult.addAll(value.data!);
        });
      }
    });
  }

  void initLatLangCoor() {
    latLangResult.clear();
    Api.getAllLatLangCoor().then((value) {
      if (value.total! == 0) {
        setState(() {
          latLangResult = [];
        });
      }
      if (value.total! > 0) {
        setState(() {
          latLangResult.addAll(value.data!);
        });
      }
    });
  }
  void initKalmanFilter(){
    Timer.periodic(Duration(milliseconds: 1000), ((timer) {
      setState(() {
        predictMovementVessel += 1;
      });
    }));
  }
  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
  // Speed per minutes
  double predictLat(double latitude,double speed,double course,int movementTime) {
    double courseRad = degreesToRadians(course);
    double speedMps = speed / 60.0;
    double distanceM = speedMps * movementTime;
    double deltaLatitude = distanceM * math.cos(courseRad) / 111111.1;
    double newLatitude = latitude + deltaLatitude;
    return newLatitude;
  }
  double predictLong(double latitude,double longitude,double speed,double course,int movementTime){
  // Convert course from degrees to radians
    double courseRad = degreesToRadians(course);

    // Convert speed from meters per minute to meters per second
    double speedMps = speed / 60.0;

    // Calculate the distance traveled in meters
    double distanceM = speedMps * movementTime;

    // Calculate the change in latitude and longitude
    double deltaLatitude = distanceM * math.cos(courseRad) / 111111.1;
    double deltaLongitude = distanceM * math.sin(courseRad) / (111111.1 * math.cos(degreesToRadians(latitude)));

    // Calculate the new latitude and longitude
    double newLatitude = latitude + deltaLatitude;
    double newLongitude = longitude + deltaLongitude;

    return newLongitude;
  }

  @override
  void initState() {
    super.initState();
    initVessel();
    initCoorVessel();
    initLatLangCoor();
    initKalmanFilter();
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
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                    maxZoom: 18,
                    // bounds: LatLngBounds(
                    //   const LatLng(-15.7706446, 93.1003771),
                    //   const LatLng(8.2454688, 141.6626464),
                    // ),
                    // initialCenter: const LatLng(51.5, -0.09),
                    zoom: 10,
                    center: LatLng(37.764403, -122.412687)
                    // cameraConstraint: CameraConstraint.contain(
                    //   bounds: LatLngBounds(
                    //     const LatLng(-90, -180),
                    //     const LatLng(50, 180),
                    //   ),)
                    ),
                // nonRotatedChildren: [
                //   RichAttributionWidget(
                //     popupInitialDisplayDuration: const Duration(seconds: 5),
                //     animationConfig: const ScaleRAWA(),
                //     attributions: [
                //       TextSourceAttribution(
                //         'OpenStreetMap contributors',
                //         onTap: () => launchUrl(
                //           Uri.parse('https://openstreetmap.org/copyright'),
                //         ),
                //       ),
                //       const TextSourceAttribution(
                //         'This attribution is the same throughout this app, except where otherwise specified',
                //         prependCopyright: false,
                //       ),
                //     ],
                //   ),
                // ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  PolylineLayer(
                    polylines: [
                      for (var i in result)
                        if(onClickVessel == i.callSign)
                        Polyline(
                          strokeWidth: 5,
                          points: [
                            for (var x in latLangResult)
                              LatLng(x.latitude!, x.longitude!),
                            LatLng(37.764403, -121.996522),
                            for (var i in result)
                            LatLng(
                              predictLat(i.coorGga!.latitude!.toDouble(),35,i.coorHdt!.headingDegree!.toDouble(),predictMovementVessel),
                              predictLong(i.coorGga!.latitude!.toDouble(),i.coorGga!.longitude!.toDouble(),35,i.coorHdt!.headingDegree!.toDouble(),predictMovementVessel)
                              // i.coorGga!.latitude!.toDouble() + (predictMovementVessel * (9.72222 / 111111.1)),
                              //   i.coorGga!.longitude!.toDouble()
                                ),
                          ],
                          color: Colors.blue,
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      for (var i in result)
                        Marker(
                          width: 75,
                          height: 75,
                          point: LatLng(
                            predictLat(i.coorGga!.latitude!.toDouble(),35,i.coorHdt!.headingDegree!.toDouble(),predictMovementVessel),
                            predictLong(i.coorGga!.latitude!.toDouble(),i.coorGga!.longitude!.toDouble(),35,i.coorHdt!.headingDegree!.toDouble(),predictMovementVessel)
                            // i.coorGga!.latitude!.toDouble() + (predictMovementVessel * (9.72222 / 111111.1)),
                            //   i.coorGga!.longitude!.toDouble()
                              ),
                          rotateOrigin: Offset(10, -10),
                          builder: (context) {
                            var vessel = vesselResult.where((e) {
                              if (e.callSign == i.callSign!) {
                                return true;
                              }
                              return false;
                            });
                            // print(vessel.first.callSign);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  onClickVessel = i.callSign!;
                                });
                                showModalBottomSheet(
                                  enableDrag:true,
                                    barrierColor: Colors.transparent,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                    ),
                                    builder: (BuildContext context) {
                                      return DraggableScrollableSheet(
                                          initialChildSize: 0.3,
                                          minChildSize: 0.2,
                                          maxChildSize: 0.7,
                                          builder: (BuildContext context,ScrollController _controller)
                                      =>   Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0),
                                          ),
                                        ),
                                        padding:
                                        EdgeInsets.fromLTRB(16, 10, 16, 5),
                                        child: SingleChildScrollView(
                                          controller: _controller,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                  "model_kapal.jpg",
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
                                                      'Call Sign : ${vessel.first.callSign}',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Negara : ${vessel.first.flag}',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Kelas : ${vessel.first.kelas}',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Tahun : ${vessel.first.yearBuilt}',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Buatan : ${vessel.first.builder}',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Buatan : ${vessel.first.builder}',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Buatan : ${vessel.first.builder}',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Buatan : ${vessel.first.builder}',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      'Buatan : ${vessel.first.builder}',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ],
                                                ),]
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      );

                                    });
                              },
                              child: Transform.rotate(
                                angle: double.parse(i.coorHdt!.headingDegree!.toString()) / 180 * math.pi,
                                child: Image.asset("ship.png"),
                              ),
                            );
                          },
                        ),
                      // Marker(
                      //     width: 50,
                      //     height: 50,
                      //     point: const LatLng(-7.9515680, 111.1283210),
                      //     builder: (ctx) =>
                      //         GestureDetector(
                      //             onTap: () {
                      //               showModalBottomSheet(
                      //                   backgroundColor: Colors.transparent,
                      //                   context: context,
                      //                   builder: (BuildContext context) {
                      //                     return Container(
                      //                       width: double.infinity,
                      //                       decoration: BoxDecoration(
                      //                         color: Colors.white,
                      //                         borderRadius: BorderRadius
                      //                             .vertical(
                      //                           top: Radius.circular(20.0),
                      //                         ),
                      //                       ),
                      //                       padding: EdgeInsets.fromLTRB(
                      //                           16, 0, 16, 5),
                      //                       child: Column(
                      //                         mainAxisSize: MainAxisSize.min,
                      //                         children: [
                      //                           Row(
                      //                             children: [
                      //                               Image.asset(
                      //                                 "model_kapal.jpg",
                      //                                 height: 100,
                      //                                 width: 100,
                      //                               ),
                      //                               SizedBox(
                      //                                 width: 20,
                      //                               ),
                      //                               Column(
                      //                                 crossAxisAlignment:
                      //                                 CrossAxisAlignment.start,
                      //                                 children: [
                      //                                   Text(
                      //                                     'Kapal Pesiar 104-AKH',
                      //                                     style: TextStyle(
                      //                                         fontSize: 20),
                      //                                   ),
                      //                                   Text(
                      //                                     'Rute : Semarang - Surabaya',
                      //                                     style: TextStyle(
                      //                                         fontSize: 20),
                      //                                   )
                      //                                 ],
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     );
                      //                   });
                      //             },
                      //             child: Image.asset("kapal.png"))),
                      // Marker(
                      //     width: 50,
                      //     height: 50,
                      //     point: const LatLng(-7.6515680, 111.1283210),
                      //     builder: (ctx) =>
                      //         GestureDetector(
                      //             onTap: () {
                      //               showModalBottomSheet(
                      //                   backgroundColor: Colors.transparent,
                      //                   context: context,
                      //                   builder: (BuildContext context) {
                      //                     return Container(
                      //                       width: double.infinity,
                      //                       decoration: BoxDecoration(
                      //                         color: Colors.white,
                      //                         borderRadius: BorderRadius
                      //                             .vertical(
                      //                           top: Radius.circular(20.0),
                      //                         ),
                      //                       ),
                      //                       padding: EdgeInsets.fromLTRB(
                      //                           16, 0, 16, 5),
                      //                       child: Column(
                      //                         mainAxisSize: MainAxisSize.min,
                      //                         children: [
                      //                           Row(
                      //                             children: [
                      //                               Image.asset(
                      //                                 "model_kapal.jpg",
                      //                                 height: 100,
                      //                                 width: 100,
                      //                               ),
                      //                               SizedBox(
                      //                                 width: 20,
                      //                               ),
                      //                               Column(
                      //                                 crossAxisAlignment:
                      //                                 CrossAxisAlignment.start,
                      //                                 children: [
                      //                                   Text(
                      //                                     'Kapal Pesiar 109-KLS',
                      //                                     style: TextStyle(
                      //                                         fontSize: 20),
                      //                                   ),
                      //                                   Text(
                      //                                     'Rute : PAPUA - SURABAYA',
                      //                                     style: TextStyle(
                      //                                         fontSize: 20),
                      //                                   )
                      //                                 ],
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     );
                      //                   });
                      //             },
                      //             child: Image.asset("kapal.png"))),
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
