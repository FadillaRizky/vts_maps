import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// import 'dart:html' as html;
// import 'dart:math';
// import 'package:http/http.dart' as http;

// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/services.dart';
// import 'package:flutter/gestures.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:latlong2/latlong.dart';

import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:vts_maps/draw/vessel_draw.dart';
import 'package:vts_maps/pages/client_page.dart';
import 'package:vts_maps/pages/maps/marker_vessel.dart';
import 'package:vts_maps/pages/maps/pipeline_layer.dart';
import 'package:vts_maps/pages/maps/vessel_detail.dart';
import 'package:vts_maps/pages/pipeline.dart';
import 'package:vts_maps/pages/vessel.dart';
import 'package:vts_maps/utils/alerts.dart';
import 'package:vts_maps/utils/text_field.dart';

import 'package:vts_maps/system/scale_bar.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:vts_maps/utils/snipping_sheet.dart';

import 'system/zoom_button.dart';
import 'api/GetPipelineResponse.dart' as PipelineResponse;
import 'api/GetAllVesselCoor.dart' as LatestVesselCoor;
import 'api/GetAllLatLangCoor.dart' as LatLangCoor;
import 'api/GetAllVessel.dart' as Vessel;
import 'api/GetKapalAndCoor.dart' as VesselCoor;

class HomePage extends StatefulWidget {
  const HomePage({Key? key, String this.idClient = "",String this.vesselClicked = ""}) : super(key: key);
  final String idClient;
  final String vesselClicked;
  @override
  State<HomePage> createState() => _HomePageState();
}

class KmlPolygon {
  final List<LatLng> points;
  final String color;

  KmlPolygon({required this.points, required this.color});
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // final GlobalKey _key = GlobalKey();
  // Controller
  final SnappingSheetController snappingSheetController =
      SnappingSheetController();
  TextEditingController SearchVessel = TextEditingController();

  /// Controller vessel list
  TextEditingController callsignController = TextEditingController();
  TextEditingController flagController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController builderController = TextEditingController();
  TextEditingController yearbuiltController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  String? vesselSize;

  /// Controller pipeline
  TextEditingController nameController = TextEditingController();

  ///variable switch
  bool isSwitched = false;

  late final MapController mapController;

  // List API
  List<LatestVesselCoor.Data> result = [];
  List<Vessel.Data> vesselResult = [];
  List<LatLangCoor.Data> latLangResult = [];

  /// Random Variable
  final pointSize = 75.0;
  final pointY = 75.0;

  LatLng? latLng;

  int vesselTotal = 0;

  num currentZoom = 15.0;

  // final GlobalKey _widgetKey = GlobalKey();
  // OverlayEntry? _overlayEntry;
  // bool isHovered = false;

  int _currentPage = 1;
  int _pageSize = 10;
  List<Vessel.Data> _dataVesselTable = [];

  // Animated Map Variable
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  int? vesselIndex;

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  LatLng predictLatLong(double latitude, double longitude, double speed,
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
    return LatLng(newLatitude, newLongitude);
  }

  void updatePoint(MapEvent? event, BuildContext context) {
    final pointX = Constants.getPointX(context);
    setState(() {
      latLng = mapController.camera.pointToLatLng(math.Point(pointX, pointY));
    });
  }

  double vesselSizes(String size) {
    switch (size) {
      case "small":
        return 4.0;
      case "medium":
        return 8.0;
      case "large":
        return 12.0;
      case "extra_large":
        return 16.0;
      default:
        return 8.0;
    }
  }

  Future<void> runNotifier() async {
    final notifier = await Provider.of<Notifier>(context, listen: false);
    notifier.initLatLangCoor();
    notifier.initPipeline(context);
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      notifier.initKalmanFilter();
    });
    Timer.periodic(const Duration(minutes: 5), (timer) {
      notifier.resetKalmanFilter();
      notifier.initLatLangCoor();
      notifier.initPipeline(context);
    });
  }

  @override
  void initState() {
    super.initState();

    runNotifier();

    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updatePoint(null, context);
    });
  }


  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

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
    return Consumer<Notifier>(
      builder: (context, value, child) {
        var readNotifier = context.read<Notifier>();

        // Future<void> searchVessel(String callSign) async {
        //   value.clickVessel(callSign, context);
        //   Future.delayed(const Duration(seconds: 1), () {
        //     print(value.searchKapal!.kapal!.callSign);
        //     value.initLatLangCoor(call_sign: callSign);
        //     _animatedMapMove(
        //         LatLng(
        //           value.searchKapal!.coor!.coorGga!.latitude!.toDouble(),
        //           value.searchKapal!.coor!.coorGga!.longitude!.toDouble(),
        //         ),
        //         13);
        //   });
        // }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF0E286C),
            iconTheme: const IconThemeData(
              color: Colors.white, // Change this color to the desired color
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton(
                  position: PopupMenuPosition.under,
                  icon: const Icon(Icons.menu),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'vesselList',
                      child: Text('Vessel List'),
                    ),
                    const PopupMenuItem(
                      value: 'pipelineList',
                      child: Text('Pipeline List'),
                    ),
                    const PopupMenuItem(
                      value: 'clientList',
                      child: Text('Client List'),
                    ),
                  ],
                  onSelected: (item) {
                    switch (item) {
                      case "vesselList":
                        value.initVessel();
                        VesselPage.vesselList(context, value,_pageSize);
                      case "pipelineList":
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            var height = MediaQuery.of(context).size.height;
                            var width = MediaQuery.of(context).size.width;

                            return Dialog(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5))),
                                    child: PipelinePage(),
                            );
                          }
                        );
                      case "clientList":
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          var height = MediaQuery.of(context).size.height;
                          var width = MediaQuery.of(context).size.width;

                          return Dialog(
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))),
                              child: ClientPage(),
                            );
                        });
                    }
                  },
                ),
                // Container(
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.blue),
                //     onPressed: () {
                //       _animatedMapMove(
                //           LatLng(
                //             -1.2437,
                //             104.79504,
                //           ),
                //           13);
                //     },
                //     child: Text(
                //       "To Overlay DWG",
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
            actions: [
              SizedBox(
                width: 300,
                height: 50,
                child: SearchField<VesselCoor.Data>(
                  controller: SearchVessel,
                  suggestions: value.vesselCoorResult
                      .map(
                        (e) => SearchFieldListItem<VesselCoor.Data>(
                          e.kapal!.callSign!,
                          item: e,
                          // Use child to show Custom Widgets in the suggestions
                          // defaults to Text widget
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(e.kapal!.callSign!),
                              ],
                            ),
                          ),
                        ),
                      )
                      .where((e) => e.searchKey
                          .toLowerCase()
                          .contains(SearchVessel.text.toLowerCase()))
                      .toList(),
                  searchInputDecoration: InputDecoration(
                    hintText: "Pilih Call Sign Kapal",
                    // labelText: "Pilih Call Sign Kapal",
                    hintStyle: const TextStyle(color: Colors.black),
                    // labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.search),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 230, 230, 230),
                    prefixIconColor: Colors.black,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 3, color: Color.fromARGB(255, 230, 230, 230)),
                      borderRadius: BorderRadius.circular(50),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 3, color: Color.fromARGB(255, 230, 230, 230)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  // searchVessel(SearchVessel.text);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.search),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (ctx) => Example(),
              //       ),
              //     );
              //   },
              //   child: Text("Example"),
              // ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Flexible(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      onMapEvent: (event) {
                        updatePoint(null, context);
                      },
                      maxZoom: 18,
                      initialZoom: 10,
                      initialCenter: const LatLng(-1.089955, 117.360343),
                      onPositionChanged: (position, hasGesture) {
                        setState(() {
                          currentZoom = (position.zoom! - 8) * 5;
                          value.changeZoom((position.zoom! - 8) * 5);
                        });
                        // readNotifier.vesselSize(position.zoom!,vesselSizes());
                      },
                    ),
                    nonRotatedChildren: [
                      /// button zoom in/out kanan bawah
                      const FlutterMapZoomButtons(
                        minZoom: 4,
                        maxZoom: 19,
                        mini: true,
                        padding: 10,
                        alignment: Alignment.bottomRight,
                      ),

                      /// widget skala kiri atas
                      ScaleLayerWidget(
                        options: ScaleLayerPluginOption(
                          lineColor: Colors.blue,
                          lineWidth: 2,
                          textStyle:
                              const TextStyle(color: Colors.blue, fontSize: 12),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),

                      /// widget berisi detail informasi kapal
                      if (value.vesselClick! != "")
                        VesselDetail(call_sign: value.vesselClick!)
                    ],
                    children: [
                      TileLayer(
                        urlTemplate:
                            // Google RoadMap
                            // 'http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}',
                            // Google Altered roadmap
                            // 'https://mt0.google.com/vt/lyrs=r&hl=en&x={x}&y={y}&z={z}',
                            // Google Satellite
                            // 'https://mt0.google.com/vt/lyrs=s&hl=en&x={x}&y={y}&z={z}',
                            // Google Terrain
                            // 'https://mt0.google.com/vt/lyrs=p&hl=en&x={x}&y={y}&z={z}',
                            // Google Hybrid
                            'https://mt0.google.com/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}',
                        // Open Street Map
                        // 'https://c.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'dev.fleaflet.flutter_map.example',
                      ),
                      // PolylineLayer(
                      //   polylines: [
                      //     Polyline(
                      //       strokeWidth: 5,
                      //       points: [
                      //         for (var x in value.latLangResult.reversed)
                      //           if (x.callSign == value.onClickVessel)
                      //             LatLng(x.latitude!, x.longitude!),
                      //         // for (var i in value.vesselCoorResult)
                      //         if (value.searchKapal != null)
                      //           if (value.searchKapal!.kapal!.callSign ==
                      //               value.onClickVessel)
                      //             LatLng(
                      //                 predictLatLong(
                      //                         value.searchKapal!.coor!.coorGga!.latitude!
                      //                             .toDouble(),
                      //                         value.searchKapal!.coor!.coorGga!
                      //                             .longitude!
                      //                             .toDouble(),
                      //                         100,
                      //                         value.searchKapal!.coor!.coorHdt!
                      //                                 .headingDegree ??
                      //                             value.searchKapal!.coor!
                      //                                 .defaultHeading!
                      //                                 .toDouble(),
                      //                         value.predictMovementVessel)
                      //                     .latitude,
                      //                 predictLatLong(
                      //                         value.searchKapal!.coor!.coorGga!
                      //                             .latitude!
                      //                             .toDouble(),
                      //                         value.searchKapal!.coor!.coorGga!
                      //                             .longitude!
                      //                             .toDouble(),
                      //                         100,
                      //                         value.searchKapal!.coor!.coorHdt!
                      //                                 .headingDegree ??
                      //                             value.searchKapal!.coor!
                      //                                 .defaultHeading!
                      //                                 .toDouble(),
                      //                         value.predictMovementVessel)
                      //                     .longitude
                      //                 // i.coorGga!.latitude!.toDouble() + (predictMovementVessel * (9.72222 / 111111.1)),
                      //                 //   i.coorGga!.longitude!.toDouble()
                      //                 ),
                      //       ],
                      //       color: Colors.blue,
                      //     ),
                      //   ],
                      // ),
                      // CircleLayer(
                      //   circles: [
                      //     for (var x in latLangResult.reversed.where((e) => e.callSign == onClickVessel))
                      //       CircleMarker(
                      //         point: LatLng(x.latitude!, x.longitude!),
                      //         radius: 3,
                      //         borderStrokeWidth: 5,
                      //         color: Colors.white,
                      //         borderColor: Colors.white,
                      //       ),
                      //   ],
                      // ),
                      
                      MarkerLayer(markers: [
                        if (latLng != null)
                          Marker(
                            width: pointSize,
                            height: pointSize,
                            point: latLng!,
                            builder: (ctx) => Image.asset(
                              "assets/compass.png",
                              width: 250,
                              height: 250,
                            ),
                          ),
                      ]),

                      // Pipeline Layers (pages/maps/pipeline_layer.dart)
                      PipelineLayer(),

                      // Vessel Marker (pages/maps/marker_vessel.dart)
                      MarkerVessel(),
                    ],
                  ),
                ),
              
              ],
            ),
          ),
        );
      },
    );
  }

}


