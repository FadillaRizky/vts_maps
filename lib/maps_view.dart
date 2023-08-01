import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import 'api/GetAllVesselCoor.dart' as LatestVesselCoor;
import 'api/GetAllLatLangCoor.dart' as LatLangCoor;
import 'api/GetAllVessel.dart' as Vessel;
import 'api/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<LatestVesselCoor.Data> result = [];
  List<Vessel.Data> vesselResult = [];
  List<LatLangCoor.Data> latLangResult = [];
  List dummy = [1, 2, 3];
  List dummyLat = [-6.8515680, -7.8515680, -8.8515680];
  List dummyLong = [];
  int predictMovementVessel = 0;
  String? onClickVessel;
  late final MapController mapController;

  // Animated Map Variable
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  int? vesselIndex;

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

  void initKalmanFilter() {
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
  double predictLat(
      double latitude, double speed, double course, int movementTime) {
    double courseRad = degreesToRadians(course);
    double speedMps = speed / 60.0;
    double distanceM = speedMps * movementTime;
    double deltaLatitude = distanceM * math.cos(courseRad) / 111111.1;
    double newLatitude = latitude + deltaLatitude;
    return newLatitude;
  }

  double predictLong(double latitude, double longitude, double speed,
      double course, int movementTime) {
    // Convert course from degrees to radians
    double courseRad = degreesToRadians(course);

    // Convert speed from meters per minute to meters per second
    double speedMps = speed / 60.0;

    // Calculate the distance traveled in meters
    double distanceM = speedMps * movementTime;

    // Calculate the change in latitude and longitude
    double deltaLatitude = distanceM * math.cos(courseRad) / 111111.1;
    double deltaLongitude = distanceM *
        math.sin(courseRad) /
        (111111.1 * math.cos(degreesToRadians(latitude)));

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
    mapController = MapController();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
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
                mapController: mapController,
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
                        if (onClickVessel == i.callSign)
                          Polyline(
                            strokeWidth: 5,
                            points: [
                              for (var x in latLangResult.reversed)
                                LatLng(x.latitude!, x.longitude!),
                              // LatLng(37.764403, -121.996522),
                              for (var i in result)
                                LatLng(
                                    predictLat(
                                        i.coorGga!.latitude!.toDouble(),
                                        100,
                                        i.coorHdt!.headingDegree!.toDouble(),
                                        predictMovementVessel),
                                    predictLong(
                                        i.coorGga!.latitude!.toDouble(),
                                        i.coorGga!.longitude!.toDouble(),
                                        100,
                                        i.coorHdt!.headingDegree!.toDouble(),
                                        predictMovementVessel)
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
                              predictLat(
                                  i.coorGga!.latitude!.toDouble(),
                                  100,
                                  i.coorHdt!.headingDegree!.toDouble(),
                                  predictMovementVessel),
                              predictLong(
                                  i.coorGga!.latitude!.toDouble(),
                                  i.coorGga!.longitude!.toDouble(),
                                  100,
                                  i.coorHdt!.headingDegree!.toDouble(),
                                  predictMovementVessel)
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
                                _animatedMapMove(
                                    LatLng(
                                      i.coorGga!.latitude!.toDouble(),
                                      i.coorGga!.longitude!.toDouble(),
                                    ),
                                    10);
                                showModalBottomSheet(
                                    enableDrag: true,
                                    barrierColor: Colors.transparent,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    context: context,
                                    // showDragHandle: ,
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20))),
                                    builder: (BuildContext context) {
                                      return DraggableScrollableSheet(
                                          snap: true,
                                          initialChildSize: 0.3,
                                          minChildSize: 0.3,
                                          maxChildSize: 0.7,
                                          builder: (BuildContext context,
                                                  ScrollController
                                                      _controller) =>
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(20.0),
                                                  ),
                                                ),
                                                padding: EdgeInsets.fromLTRB(
                                                    16, 10, 16, 5),
                                                child: SingleChildScrollView(
                                                  controller: _controller,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(children: [
                                                        Image.asset(
                                                          "model_kapal.jpg",
                                                          width: 100,
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
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
                                                        ),
                                                      ]),
                                                    ],
                                                  ),
                                                ),
                                              ));
                                    });
                              },
                              child: Transform.rotate(
                                angle: degreesToRadians(
                                    i.coorHdt!.headingDegree!.toDouble()),
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
