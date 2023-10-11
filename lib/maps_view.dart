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
  const HomePage({Key? key}) : super(key: key);

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
    notifier.initVesselCoor();
    notifier.initLatLangCoor();
    notifier.initPipeline(context);
    notifier.initClientList();
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      notifier.initKalmanFilter();
    });
    Timer.periodic(const Duration(minutes: 5), (timer) {
      notifier.initVesselCoor();
      notifier.resetKalmanFilter();
      notifier.initLatLangCoor();
      notifier.initPipeline(context);
      notifier.initClientList();
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

  // void _showCursorTooltip(BuildContext context) {
  //   final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
  //   final overlay = OverlayEntry(
  //     builder: (context) {
  //       final screenSize = MediaQuery.of(context).size;
  //       final position = renderBox.localToGlobal(Offset.zero);
  //       final cursorY = position.dy - 40.0; // Sesuaikan posisi tooltip di atas cursor
  //       final cursorX = position.dx - 20.0; // Sesuaikan posisi tooltip di atas cursor
  //
  //       return Positioned(
  //         left: cursorX,
  //         top: cursorY,
  //         child: CursorTooltip(text: 'Tooltip Text'),
  //       );
  //     },
  //   );
  //
  //   Overlay.of(context)!.insert(overlay);
  // }

  // void _hideCursorTooltip() {
  //   _overlayEntry?.remove();
  //   _overlayEntry = null;
  // }

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

        Future<void> searchVessel(String callSign) async {
          value.clickVessel(callSign, context);
          Future.delayed(const Duration(seconds: 1), () {
            print(value.searchKapal!.kapal!.callSign);
            value.initLatLangCoor(call_sign: callSign);
            _animatedMapMove(
                LatLng(
                  value.searchKapal!.coor!.coorGga!.latitude!.toDouble(),
                  value.searchKapal!.coor!.coorGga!.longitude!.toDouble(),
                ),
                13);
          });
        }

        return Scaffold(
          appBar: AppBar(
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
                        VesselPage.vesselList(context,value,_pageSize);
                      case "pipelineList":
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              var width = MediaQuery.of(context).size.width;
                              return Dialog(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: SizedBox(
                                      width: width / 1.5,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              color: Colors.black12,
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    " Pipeline List",
                                                    style: GoogleFonts.openSans(
                                                        fontSize: 20,fontWeight: FontWeight.bold),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon:
                                                        const Icon(Icons.close),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      "Page ${value.currentPage} of ${(value.totalPipeline / 10).ceil()}"),
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 40,
                                                        width: 40,
                                                        child: IconButton(
                                                          style: ButtonStyle(
                                                              shape: MaterialStateProperty.all(
                                                                  RoundedRectangleBorder(
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                          5))),
                                                              backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                  .blueAccent)),
                                                          onPressed: (){
                                                            value.initPipeline(context);
                                                          }, icon: Icon(Icons.refresh,color: Colors.white,),),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      SizedBox(
                                                        height: 40,
                                                        child: ElevatedButton(
                                                            style: ButtonStyle(
                                                                shape: MaterialStateProperty.all(
                                                                    RoundedRectangleBorder(
                                                                        borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                            5))),
                                                                backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                    .blueAccent)),
                                                            onPressed: () {
                                                              addPipeline(
                                                                context,
                                                                value,
                                                              );
                                                            },
                                                            child: Text(
                                                              "Add Pipeline",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                              ),
                                                            )),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 380,
                                              width: double.infinity,
                                              child: SingleChildScrollView(
                                                child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: value.isLoading
                                                        ? const Center(
                                                            child:
                                                                CircularProgressIndicator())
                                                        : SizedBox(
                                                            width: 900,
                                                            child: DataTable(
                                                                headingRowColor:
                                                                MaterialStateProperty
                                                                    .all(Color(
                                                                    0xffd3d3d3)),
                                                                columns: [
                                                                  const DataColumn(
                                                                      label: Text(
                                                                          "Name")),
                                                                  const DataColumn(
                                                                      label: Text(
                                                                          "File")),
                                                                  const DataColumn(
                                                                      label: Text(
                                                                          "Switch")),
                                                                  const DataColumn(
                                                                      label: Text(
                                                                          "Action")),
                                                                ],
                                                                rows: value
                                                                    .getPipelineResult
                                                                    .map(
                                                                        (data) {
                                                                  return DataRow(
                                                                    cells: [
                                                                      DataCell(
                                                                          Text(data
                                                                              .name!)),
                                                                      DataCell(
                                                                          Text(data
                                                                              .file!)),
                                                                      DataCell(Text(data
                                                                              .onOff!
                                                                          ? "ON"
                                                                          : "OFF")),
                                                                      DataCell(
                                                                          Row(
                                                                        children: [
                                                                          IconButton(
                                                                            icon:
                                                                                const Icon(
                                                                              Icons.edit,
                                                                              color: Colors.blue,
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              editPipeline(data, context, value);
                                                                            },
                                                                          ),
                                                                          IconButton(
                                                                            icon:
                                                                                const Icon(
                                                                              Icons.delete,
                                                                              color: Colors.red,
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              Alerts.showAlertYesNo(
                                                                                  title: "Are you sure you want to delete this data?",
                                                                                  onPressYes: () {
                                                                                    value.deletePipeline(data.idMapping, context);
                                                                                  },
                                                                                  onPressNo: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  context: context);
                                                                            },
                                                                          ),
                                                                        ],
                                                                      )),
                                                                    ],
                                                                  );
                                                                }).toList()),
                                                          )),
                                              ),
                                            ),
                                            Pagination(
                                              numOfPages:
                                                  (value.totalPipeline / 10)
                                                      .ceil(),
                                              selectedPage: value.currentPage,
                                              pagesVisible: 7,
                                              onPageChanged: (page) {
                                                value.incrementPage(page);
                                                value.initPipeline(context);
                                              },
                                              nextIcon: const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.blue,
                                                size: 14,
                                              ),
                                              previousIcon: const Icon(
                                                Icons.arrow_back_ios,
                                                color: Colors.blue,
                                                size: 14,
                                              ),
                                              activeTextStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              activeBtnStyle: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.blue),
                                                shape:
                                                    MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            38),
                                                  ),
                                                ),
                                              ),
                                              inactiveBtnStyle: ButtonStyle(
                                                shape:
                                                    MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(38),
                                                )),
                                              ),
                                              inactiveTextStyle:
                                                  const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ])));
                            });
                      case "clientList":
                        ClientPage.clientList(context,value);
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
                  searchVessel(SearchVessel.text);
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
                          currentZoom = (position.zoom! - 8) * 9;
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
                      if (value.onClickVessel != "")
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 600,
                            ),
                            child: SnappingSheet(
                              controller: snappingSheetController,
                              // child: Background(),
                              lockOverflowDrag: true,
                              snappingPositions: [
                                SnappingPosition.factor(
                                  snappingCurve: Curves.elasticOut,
                                  snappingDuration:
                                      const Duration(milliseconds: 1750),
                                  positionFactor: (301.74 /
                                      MediaQuery.of(context).size.height),
                                ),
                                const SnappingPosition.factor(
                                  positionFactor: 0.0,
                                  snappingCurve: Curves.easeOutExpo,
                                  snappingDuration: Duration(seconds: 1),
                                  grabbingContentOffset:
                                      GrabbingContentOffset.top,
                                ),
                                SnappingPosition.factor(
                                  snappingCurve: Curves.elasticOut,
                                  snappingDuration:
                                      const Duration(milliseconds: 1750),
                                  positionFactor: (500 /
                                      MediaQuery.of(context).size.height),
                                ),
                                // SnappingPosition.factor(
                                //   grabbingContentOffset:
                                //       GrabbingContentOffset.bottom,
                                //   snappingCurve: Curves.easeInExpo,
                                //   snappingDuration: Duration(seconds: 1),
                                //   positionFactor: 0.9,
                                // ),
                              ],
                              grabbing: GrabbingWidget(),
                              grabbingHeight: 75,
                              sheetAbove: null,
                              sheetBelow: SnappingSheetContent(
                                draggable: true,
                                // childScrollController: listViewController,
                                child: SingleChildScrollView(
                                  // physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            snappingSheetController
                                                .snapToPosition(
                                              const SnappingPosition.factor(
                                                  positionFactor: -0.5),
                                            );
                                            Timer(
                                                const Duration(
                                                    milliseconds: 300), () {
                                              value.removeClickedVessel();
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              width: 45,
                                              height: 45,
                                              decoration: const BoxDecoration(
                                                  color: Colors.black12),
                                              padding: const EdgeInsets.all(4),
                                              child: const Center(
                                                child: Text(
                                                  "X",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${value.searchKapal!.kapal!.callSign}",
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "${value.searchKapal!.kapal!.flag}",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              ),
                                              Image.asset(
                                                "assets/model_kapal.jpg",
                                                width: 100,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Position Information"
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Latitude',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      61,
                                                                      61,
                                                                      61),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${predictLatLong(value.searchKapal!.coor!.coorGga!.latitude!.toDouble(), value.searchKapal!.coor!.coorGga!.longitude!.toDouble(), 100, value.searchKapal!.coor!.coorHdt!.headingDegree ?? value.searchKapal!.coor!.defaultHeading!, value.predictMovementVessel).latitude.toStringAsFixed(5)}}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      61,
                                                                      61,
                                                                      61),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Longitude',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      61,
                                                                      61,
                                                                      61),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${predictLatLong(value.searchKapal!.coor!.coorGga!.latitude!.toDouble(), value.searchKapal!.coor!.coorGga!.longitude!.toDouble(), 100, value.searchKapal!.coor!.coorHdt!.headingDegree ?? value.searchKapal!.coor!.defaultHeading!, value.predictMovementVessel).latitude.toStringAsFixed(5)}}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      61,
                                                                      61,
                                                                      61),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Text(
                                          "Vessel",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        VesselDrawer(
                                            link: value
                                                .searchKapal!.kapal!.xmlFile!
                                                .toString()),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
                      if (value.kmlOverlayPolygons.isNotEmpty)
                        for (final kmlOverlayPolygon
                            in value.kmlOverlayPolygons)
                          PolylineLayer(
                            polylines: kmlOverlayPolygon.map((kmlPolygon) {
                              return Polyline(
                                strokeWidth: 3,
                                points: kmlPolygon.points,
                                color: Color(
                                    int.parse(kmlPolygon.color, radix: 16)),
                              );
                            }).toList(),
                          ),

                      PolylineLayer(
                        polylines: [
                          Polyline(
                            strokeWidth: 5,
                            points: [
                              for (var x in value.latLangResult.reversed)
                                if (x.callSign == value.onClickVessel)
                                  LatLng(x.latitude!, x.longitude!),
                              // for (var i in value.vesselCoorResult)
                              if (value.searchKapal != null)
                                if (value.searchKapal!.kapal!.callSign ==
                                    value.onClickVessel)
                                  LatLng(
                                      predictLatLong(
                                              value.searchKapal!.coor!.coorGga!.latitude!
                                                  .toDouble(),
                                              value.searchKapal!.coor!.coorGga!
                                                  .longitude!
                                                  .toDouble(),
                                              100,
                                              value.searchKapal!.coor!.coorHdt!
                                                      .headingDegree ??
                                                  value.searchKapal!.coor!
                                                      .defaultHeading!
                                                      .toDouble(),
                                              value.predictMovementVessel)
                                          .latitude,
                                      predictLatLong(
                                              value.searchKapal!.coor!.coorGga!
                                                  .latitude!
                                                  .toDouble(),
                                              value.searchKapal!.coor!.coorGga!
                                                  .longitude!
                                                  .toDouble(),
                                              100,
                                              value.searchKapal!.coor!.coorHdt!
                                                      .headingDegree ??
                                                  value.searchKapal!.coor!
                                                      .defaultHeading!
                                                      .toDouble(),
                                              value.predictMovementVessel)
                                          .longitude
                                      // i.coorGga!.latitude!.toDouble() + (predictMovementVessel * (9.72222 / 111111.1)),
                                      //   i.coorGga!.longitude!.toDouble()
                                      ),
                            ],
                            color: Colors.blue,
                          ),
                        ],
                      ),
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
                              "assets/compass2.png",
                              width: 250,
                              height: 250,
                            ),
                          ),
                      ]),
                      MarkerLayer(
                        markers: value.vesselCoorResult
                            .map(
                              (i) => Marker(
                                width:
                                    // mapController.zoom * 1,
                                    // (mapController.zoom - 10) / 2,
                                    // vesselSizes(i.kapal!.size!.toString()) + currentZoom,
                                    // 10 + currentZoom,
                                    // currentZoom.toDouble(),
                                    // value.currentZoom.toDouble(),
                                    vesselSizes(i.kapal!.size!.toString()) +
                                        currentZoom.toDouble(),
                                height:
                                    // mapController.zoom * 1,
                                    // (mapController.zoom - 10) / 2,
                                    // vesselSizes(i.kapal!.size!.toString()) + currentZoom,
                                    // 10 + currentZoom,
                                    // currentZoom.toDouble() ,
                                    // value.currentZoom.toDouble(),
                                    vesselSizes(i.kapal!.size!.toString()) +
                                        currentZoom.toDouble(),
                                point: LatLng(
                                    predictLatLong(
                                            i.coor!.coorGga!.latitude!
                                                .toDouble(),
                                            i.coor!.coorGga!.longitude!
                                                .toDouble(),
                                            100,
                                            i.coor!.coorHdt!.headingDegree ??
                                                i.coor!.defaultHeading!
                                                    .toDouble(),
                                            value.predictMovementVessel)
                                        .latitude,
                                    predictLatLong(
                                            i.coor!.coorGga!.latitude!
                                                .toDouble(),
                                            i.coor!.coorGga!.longitude!
                                                .toDouble(),
                                            100,
                                            i.coor!.coorHdt!.headingDegree ??
                                                i.coor!.defaultHeading!
                                                    .toDouble(),
                                            value.predictMovementVessel)
                                        .longitude

                                    // i.coorGga!.latitude!.toDouble() + (predictMovementVessel * (9.72222 / 111111.1)),
                                    //   i.coorGga!.longitude!.toDouble()
                                    ),
                                rotateOrigin: const Offset(10, -10),
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      searchVessel(i.kapal!.callSign!);
                                    },
                                    child: Transform.rotate(
                                      angle: degreesToRadians(i
                                              .coor!.coorHdt!.headingDegree ??
                                          i.coor!.defaultHeading!.toDouble()),
                                      child: Tooltip(
                                        message: i.kapal!.callSign!.toString(),
                                        child: Image.asset(
                                          "assets/ship.png",
                                          height: vesselSizes(
                                                  i.kapal!.size!.toString()) +
                                              currentZoom.toDouble(),
                                          width: vesselSizes(
                                                  i.kapal!.size!.toString()) +
                                              currentZoom.toDouble(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
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

  /// function CRUD PIPELINE
  void addPipeline(BuildContext context, Notifier value) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          var width = MediaQuery.of(context).size.width;
          return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: SizedBox(
              width: width / 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black12,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          " Add Pipeline",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            nameController.clear();
                            isSwitched = false;
                            value.clearFile();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 485,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            VesselTextField(
                              controller: nameController,
                              hint: 'Name',
                              type: TextInputType.text,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                value.selectFile("KMZ");
                              },
                              child: Card(
                                color: Colors.black12,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Upload your file",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.white),
                                      ),
                                      const Text("KMZ / KML",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/xml_icon2.png",
                                                height: 55,
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 70),
                                                child: Text(
                                                  value.nameFile!,
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                  value: isSwitched,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isSwitched = value;
                                    });
                                  },
                                  activeTrackColor: Colors.lightGreen,
                                  activeColor: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // InkWell(
                                //   onTap: () {
                                //     ///
                                //     nameController.clear();
                                //     isSwitched = false;
                                //     value.clearFile();
                                //     Navigator.pop(context);
                                //
                                //   },
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(10),
                                //       color: const Color(0xFFFF0000),
                                //     ),
                                //     padding: const EdgeInsets.all(5),
                                //     alignment: Alignment.center,
                                //     height: 30,
                                //     child: const Text("Batal"),
                                //   ),
                                // ),
                                // const SizedBox(
                                //   width: 5,
                                // ),
                                // InkWell(
                                //   onTap: () {
                                //     if (nameController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Name Sign Masih Kosong...");
                                //       return;
                                //     }
                                //     if (value.file == null) {
                                //       EasyLoading.showError(
                                //           "Kolom File Masih Kosong...");
                                //       return;
                                //     }
                                //     value.submitPipeline(nameController.text, isSwitched, context, value.file);
                                //     nameController.clear();
                                //     isSwitched = false;
                                //     value.clearFile();
                                //
                                //   },
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(10),
                                //       color: const Color(0xFF399D44),
                                //     ),
                                //     padding: const EdgeInsets.all(5),
                                //     alignment: Alignment.center,
                                //     height: 30,
                                //     child: const Text("Simpan"),
                                //   ),
                                // )
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueAccent),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (nameController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Name Sign Masih Kosong...");
                                      return;
                                    }
                                    if (value.file == null) {
                                      EasyLoading.showError(
                                          "Kolom File Masih Kosong...");
                                      return;
                                    }
                                    value.submitPipeline(nameController.text,
                                        isSwitched, context, value.file);
                                    nameController.clear();
                                    isSwitched = false;
                                    value.clearFile();
                                  },
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              side: BorderSide(
                                                  color: Colors.blueAccent)))),
                                  onPressed: () {
                                    nameController.clear();
                                    isSwitched = false;
                                    value.clearFile();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void editPipeline(
      PipelineResponse.Data data, BuildContext context, Notifier value) {
    isSwitched = data.onOff!;
    nameController.text = data.name!;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          var width = MediaQuery.of(context).size.width;
          return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: SizedBox(
              width: width / 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black12,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          " Edit Pipeline",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            nameController.clear();
                            isSwitched = false;
                            value.clearFile();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 485,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            VesselTextField(
                              controller: nameController,
                              hint: 'Name',
                              type: TextInputType.text,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                value.selectFile("KMZ");
                              },
                              child: Card(
                                color: Colors.black12,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Upload your file",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.white),
                                      ),
                                      const Text("KMZ / KML",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/xml_icon2.png",
                                                height: 55,
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 70),
                                                child: Text(
                                                  value.nameFile != ""
                                                      ? value.nameFile!
                                                      : data.file != null
                                                          ? data.file!
                                                          : "",
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                  value: isSwitched,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isSwitched = value;
                                    });
                                  },
                                  activeTrackColor: Colors.lightGreen,
                                  activeColor: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // InkWell(
                                //   onTap: () {
                                //     ///
                                //     nameController.clear();
                                //     isSwitched = false;
                                //     value.clearFile();
                                //     Navigator.pop(context);
                                //   },
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(10),
                                //       color: const Color(0xFFFF0000),
                                //     ),
                                //     padding: const EdgeInsets.all(5),
                                //     alignment: Alignment.center,
                                //     height: 30,
                                //     child: const Text("Batal"),
                                //   ),
                                // ),
                                // const SizedBox(
                                //   width: 5,
                                // ),
                                // InkWell(
                                //   onTap: () {
                                //     if (nameController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Name Masih Kosong...");
                                //       return;
                                //     }
                                //     value.editPipeline(data.idMapping, nameController.text, isSwitched, context, value.file);
                                //     nameController.clear();
                                //     isSwitched = false;
                                //     value.clearFile();
                                //   },
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(10),
                                //       color: const Color(0xFF399D44),
                                //     ),
                                //     padding: const EdgeInsets.all(5),
                                //     alignment: Alignment.center,
                                //     height: 30,
                                //     child: const Text("Simpan"),
                                //   ),
                                // )
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueAccent),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (nameController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Name Masih Kosong...");
                                      return;
                                    }
                                    value.editPipeline(
                                        data.idMapping,
                                        nameController.text,
                                        isSwitched,
                                        context,
                                        value.file);
                                    nameController.clear();
                                    isSwitched = false;
                                    value.clearFile();
                                  },
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              side: BorderSide(
                                                  color: Colors.blueAccent)))),
                                  onPressed: () {
                                    nameController.clear();
                                    isSwitched = false;
                                    value.clearFile();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
