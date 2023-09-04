import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

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
import 'package:vts_maps/utils/text_field.dart';

import 'package:vts_maps/system/scale_bar.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:vts_maps/utils/snipping_sheet.dart';
import 'package:vts_maps/vessel_list.dart';

import 'system/zoom_button.dart';
import 'api/GetAllVesselCoor.dart' as LatestVesselCoor;
import 'api/GetAllLatLangCoor.dart' as LatLangCoor;
import 'api/GetAllVessel.dart' as Vessel;
import 'api/GetKapalAndCoor.dart' as VesselCoor;
import 'api/api.dart';

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
      new SnappingSheetController();
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
  late final MapController mapController;

  // List API
  List<LatestVesselCoor.Data> result = [];
  List<Vessel.Data> vesselResult = [];
  List<LatLangCoor.Data> latLangResult = [];

  // Random Variable
  final pointSize = 75.0;
  final pointY = 75.0;

  LatLng? latLng;

  int vesselTotal = 0;

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
      latLng = mapController.camera.pointToLatLng(Point(pointX, pointY));
    });
  }

  double vesselSizes(String size) {
    switch (size) {
      case "small":
        return 35.0;
      case "medium":
        return 50.0;
      case "large":
        return 65.0;
      case "extra_large":
        return 70.0;
      default:
        return 35.0;
    }
  }

  // submitVessel() async {
  //   if (callsignController.text.isEmpty) {
  //     EasyLoading.showError("Kolom Call Sign Masih Kosong...");
  //     return;
  //   }
  //   if (flagController.text.isEmpty) {
  //     EasyLoading.showError("Kolom Bendera Masih Kosong...");
  //     return;
  //   }
  //   if (classController.text.isEmpty) {
  //     EasyLoading.showError("Kolom Kelas Masih Kosong...");
  //     return;
  //   }
  //   if (builderController.text.isEmpty) {
  //     EasyLoading.showError("Kolom Builder Masih Kosong...");
  //     return;
  //   }
  //   if (yearbuiltController.text.isEmpty) {
  //     EasyLoading.showError("Kolom Tahun Pembuatan Masih Kosong...");
  //     return;
  //   }
  //   if (ipController.text.isEmpty) {
  //     EasyLoading.showError("Kolom IP Pembuatan Masih Kosong...");
  //     return;
  //   }
  //   if (portController.text.isEmpty) {
  //     EasyLoading.showError("Kolom Port Masih Kosong...");
  //     return;
  //   }
  //   if (vesselSize == null) {
  //     EasyLoading.showError("Kolom Ukuran Kapal Masih Kosong...");
  //     return;
  //   }

  //   var data = {
  //     "call_sign": callsignController.text,
  //     "flag": flagController.text,
  //     "class": classController.text,
  //     "builder": builderController.text,
  //     "year_built": yearbuiltController.text,
  //     "ip": ipController.text,
  //     "port": portController.text,
  //     "size": vesselSize!,
  //   };
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CircularProgressIndicator(
  //               color: Colors.white,
  //             ),
  //             SizedBox(
  //               height: 20,
  //             ),
  //             Text(
  //               "Loading..",
  //               style: TextStyle(color: Colors.white, fontSize: 20),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //   await Api.createVessel(data).then((value) {
  //     if (value.message != "Data berhasil masuk database") {
  //       EasyLoading.showError("Gagal Menambahkan Kapal");
  //     }
  //     if (value.message == "Data berhasil masuk database") {
  //       EasyLoading.showSuccess("Berhasil Menambahkan Kapal");
  //       callsignController.clear();
  //       flagController.clear();
  //       classController.clear();
  //       builderController.clear();
  //       yearbuiltController.clear();
  //       ipController.clear();
  //       portController.clear();
  //       vesselSize == null;
  //       // _dataVesselTable.clear();
  //       final notifier = Provider.of<Notifier>(context, listen: false);
  //       notifier.fetchDataVessel(_pageSize);
  //       notifier.initVessel();

  //       Navigator.pop(context);
  //       Navigator.pop(context);
  //     }
  //     if (value.message == "Validator Fails") {
  //       EasyLoading.showError("Call Sign sudah terdaftar");
  //       Navigator.pop(context);
  //     }
  //     return;
  //   });
  // }

  // void calculateCenter() {
  //   for(var kmlOverlayPolygon in kmlOverlayPolygons){
  //     double totalLat = 0.0;
  //     double totalLng = 0.0;
  //     int total = 0;

  //     for (final coordinate in kmlOverlayPolygon) {
  //       for(final latlong in coordinate.points){
  //         totalLat += latlong.latitude;
  //         totalLng += latlong.longitude;
  //         total += coordinate.points.length;
  //       }
  //     }
  //     print(LatLng(totalLat / total, totalLng / total));
  //     // return LatLng(totalLat / coordinates.length, totalLng / coordinates.length);
  //   }
  // }
  Future<void> runNotifier() async {
    final notifier = await Provider.of<Notifier>(context, listen: false);
    notifier.initVesselCoor();
    notifier.initLatLangCoor();
    notifier.loadKMZData(context);
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      notifier.initKalmanFilter();
    });
    Timer.periodic(const Duration(minutes: 5), (timer) {
      notifier.initVesselCoor();
      notifier.resetKalmanFilter();
      notifier.initLatLangCoor();
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
          value.clickVessel(callSign);
          Future.delayed(Duration(seconds: 1),(){
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
            backgroundColor: Color(0xFF0E286C),
            iconTheme: IconThemeData(
              color: Colors.white, // Change this color to the desired color
            ),
            title: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton(
                    position: PopupMenuPosition.under,
                    icon: Icon(Icons.menu),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'btnAddVessel',
                        child: Text('Vessel List'),
                      ),
                    ],
                    onSelected: (item) {
                      switch (item) {
                        case "btnAddVessel":
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                var height = MediaQuery.of(context).size.height;
                                var width = MediaQuery.of(context).size.width;

                                return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Container(
                                        width: width / 1.5,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              color: Colors.black12,
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Vessel List",
                                                    style: GoogleFonts.openSans(
                                                        fontSize: 20),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon: Icon(Icons.close),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      "Page ${value.currentPage} of ${(value.totalVessel / 10).ceil()}"),
                                                  InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (BuildContext
                                                              context) {
                                                            var width =
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width;

                                                            return Dialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5))),
                                                              child: Container(
                                                                width:
                                                                    width / 3,
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      color: Colors
                                                                          .black12,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            "Add Vessel",
                                                                            style:
                                                                                GoogleFonts.openSans(fontSize: 15),
                                                                          ),
                                                                          IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            icon:
                                                                                Icon(Icons.close),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          VesselTextField(
                                                                            controller:
                                                                                callsignController,
                                                                            hint:
                                                                                'Call Sign',
                                                                            type:
                                                                                TextInputType.text,
                                                                          ),
                                                                          VesselTextField(
                                                                            controller:
                                                                                flagController,
                                                                            hint:
                                                                                'Bendera',
                                                                            type:
                                                                                TextInputType.text,
                                                                          ),
                                                                          VesselTextField(
                                                                            controller:
                                                                                classController,
                                                                            hint:
                                                                                'Kelas',
                                                                            type:
                                                                                TextInputType.text,
                                                                          ),
                                                                          VesselTextField(
                                                                            controller:
                                                                                builderController,
                                                                            hint:
                                                                                'Builder',
                                                                            type:
                                                                                TextInputType.text,
                                                                          ),
                                                                          VesselTextField(
                                                                            controller:
                                                                                yearbuiltController,
                                                                            hint:
                                                                                'Tahun Pembuatan',
                                                                            type:
                                                                                TextInputType.number,
                                                                          ),
                                                                          VesselTextField(
                                                                            controller:
                                                                                ipController,
                                                                            hint:
                                                                                'IP',
                                                                            type:
                                                                                TextInputType.text,
                                                                          ),
                                                                          VesselTextField(
                                                                            controller:
                                                                                portController,
                                                                            hint:
                                                                                'Port',
                                                                            type:
                                                                                TextInputType.number,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                30,
                                                                            width:
                                                                                double.infinity,
                                                                            child:
                                                                                DropdownSearch<String>(
                                                                              dropdownBuilder: (context, selectedItem) => Text(
                                                                                selectedItem ?? "Ukuran Kapal",
                                                                                style: TextStyle(fontSize: 15, color: Colors.black54),
                                                                              ),
                                                                              popupProps: PopupPropsMultiSelection.dialog(
                                                                                fit: FlexFit.loose,
                                                                                itemBuilder: (context, item, isSelected) => ListTile(
                                                                                  title: Text(
                                                                                    item,
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              dropdownDecoratorProps: DropDownDecoratorProps(
                                                                                dropdownSearchDecoration: InputDecoration(
                                                                                  border: OutlineInputBorder(
                                                                                    borderSide: BorderSide.none,
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                  contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                                                                                  filled: true,
                                                                                  fillColor: Colors.black12,
                                                                                ),
                                                                              ),
                                                                              items: [
                                                                                "small",
                                                                                "medium",
                                                                                "large",
                                                                                "extra large",
                                                                              ],
                                                                              onChanged: (value) {
                                                                                vesselSize = value;
                                                                              },
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    color: Color(0xFFFF0000),
                                                                                  ),
                                                                                  padding: EdgeInsets.all(5),
                                                                                  alignment: Alignment.center,
                                                                                  height: 30,
                                                                                  child: Text("Batal"),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  if (callsignController.text.isEmpty) {
                                                                                    EasyLoading.showError("Kolom Call Sign Masih Kosong...");
                                                                                    return;
                                                                                  }
                                                                                  if (flagController.text.isEmpty) {
                                                                                    EasyLoading.showError("Kolom Bendera Masih Kosong...");
                                                                                    return;
                                                                                  }
                                                                                  if (classController.text.isEmpty) {
                                                                                    EasyLoading.showError("Kolom Kelas Masih Kosong...");
                                                                                    return;
                                                                                  }
                                                                                  if (builderController.text.isEmpty) {
                                                                                    EasyLoading.showError("Kolom Builder Masih Kosong...");
                                                                                    return;
                                                                                  }
                                                                                  if (yearbuiltController.text.isEmpty) {
                                                                                    EasyLoading.showError("Kolom Tahun Pembuatan Masih Kosong...");
                                                                                    return;
                                                                                  }
                                                                                  if (ipController.text.isEmpty) {
                                                                                    EasyLoading.showError("Kolom IP Pembuatan Masih Kosong...");
                                                                                    return;
                                                                                  }
                                                                                  if (portController.text.isEmpty) {
                                                                                    EasyLoading.showError("Kolom Port Masih Kosong...");
                                                                                    return;
                                                                                  }
                                                                                  if (vesselSize == null) {
                                                                                    EasyLoading.showError("Kolom Ukuran Kapal Masih Kosong...");
                                                                                    return;
                                                                                  }
                                                                                  Map<String,String> data = {
                                                                                    "call_sign": callsignController.text,
                                                                                    "flag": flagController.text,
                                                                                    "class": classController.text,
                                                                                    "builder": builderController.text,
                                                                                    "year_built": yearbuiltController.text,
                                                                                    "ip": ipController.text,
                                                                                    "port": portController.text,
                                                                                    "size": vesselSize!,
                                                                                  };
                                                                                  value.submitVessel(data,context);

                                                                                  // submitVessel();
                                                                                },
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                    color: Color(0xFF399D44),
                                                                                  ),
                                                                                  padding: EdgeInsets.all(5),
                                                                                  alignment: Alignment.center,
                                                                                  height: 30,
                                                                                  child: Text("Simpan"),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color:
                                                            Color(0xFF399D44),
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      alignment:
                                                          Alignment.center,
                                                      height: 40,
                                                      child: Icon(Icons.add),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 400,
                                              child: SingleChildScrollView(
                                                child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: value.isLoading
                                                        ? Center(
                                                            child:
                                                                CircularProgressIndicator())
                                                        : DataTable(
                                                            columns: [
                                                                DataColumn(
                                                                    label: Text(
                                                                        "CallSign")),
                                                                DataColumn(
                                                                    label: Text(
                                                                        "Flag")),
                                                                DataColumn(
                                                                    label: Text(
                                                                        "Kelas")),
                                                                DataColumn(
                                                                    label: Text(
                                                                        "Builder")),
                                                                DataColumn(
                                                                    label: Text(
                                                                        "Year Built")),
                                                                DataColumn(
                                                                    label: Text(
                                                                        "IP")),
                                                                DataColumn(
                                                                    label: Text(
                                                                        "Port")),
                                                                DataColumn(
                                                                    label: Text(
                                                                        "Size")),
                                                                DataColumn(
                                                                    label: Text(
                                                                        "Action")),
                                                              ],
                                                            rows: value
                                                                .vesselCoorResult
                                                                .map((data) {
                                                              return DataRow(
                                                                  cells: [
                                                                    DataCell(
                                                                        Text(data.kapal!
                                                                            .callSign!)),
                                                                    DataCell(
                                                                        Text(data.kapal!
                                                                            .flag!)),
                                                                    DataCell(
                                                                        Text(data.kapal!
                                                                            .kelas!)),
                                                                    DataCell(
                                                                        Text(data.kapal!
                                                                            .builder!)),
                                                                    DataCell(
                                                                        Text(data.kapal!
                                                                            .yearBuilt!)),
                                                                    DataCell(
                                                                        Text(data.kapal!
                                                                            .ip!)),
                                                                    DataCell(
                                                                        Text(data.kapal!
                                                                            .port!)),
                                                                    DataCell(
                                                                        Text(data.kapal!
                                                                            .size!)),
                                                                    DataCell(
                                                                        Row(
                                                                          children: [
                                                                            IconButton(
                                                                      icon:
                                                                              Icon(
                                                                            Icons
                                                                                .edit,
                                                                            color: Colors
                                                                                .blue,
                                                                      ),
                                                                      onPressed:
                                                                              () {
                                                                        // print(data.callSign);
                                                                        callsignController.text = data.kapal!.callSign!;
                                                                         flagController.text= data.kapal!.flag!;
                                                                         classController.text = data.kapal!.kelas!;
                                                                         builderController.text = data.kapal!.builder!;
                                                                         yearbuiltController.text = data.kapal!.yearBuilt!;
                                                                         ipController.text = data.kapal!.ip! ;
                                                                         portController.text = data.kapal!.port!;
                                                                         vesselSize = data.kapal!.size!;
                                                                                showDialog(
                                                                                    context: context,
                                                                                    barrierDismissible:
                                                                                    false,
                                                                                    builder: (BuildContext
                                                                                    context) {
                                                                                      var width =
                                                                                          MediaQuery.of(
                                                                                              context)
                                                                                              .size
                                                                                              .width;

                                                                                      return Dialog(
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius:
                                                                                            BorderRadius.all(
                                                                                                Radius.circular(
                                                                                                    5))),
                                                                                        child: Container(
                                                                                          width:
                                                                                          width / 3,
                                                                                          child: Column(
                                                                                            mainAxisSize:
                                                                                            MainAxisSize
                                                                                                .min,
                                                                                            crossAxisAlignment:
                                                                                            CrossAxisAlignment
                                                                                                .start,
                                                                                            children: [
                                                                                              Container(
                                                                                                color: Colors
                                                                                                    .black12,
                                                                                                padding:
                                                                                                EdgeInsets.all(
                                                                                                    8),
                                                                                                child:
                                                                                                Row(
                                                                                                  mainAxisAlignment:
                                                                                                  MainAxisAlignment.spaceBetween,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      "Edit Vessel",
                                                                                                      style:
                                                                                                      GoogleFonts.openSans(fontSize: 15),
                                                                                                    ),
                                                                                                    IconButton(
                                                                                                      onPressed:
                                                                                                          () {
                                                                                                        Navigator.pop(context);
                                                                                                      },
                                                                                                      icon:
                                                                                                      Icon(Icons.close),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                               Padding(
                                                                                                 padding:
                                                                                                 EdgeInsets.all(
                                                                                                     8),
                                                                                                 child:
                                                                                                 // Container(
                                                                                                 //   width: double.infinity,
                                                                                                 //   height: 30,
                                                                                                 //   child: TextFormField(
                                                                                                 //     controller: callsignController,
                                                                                                 //     // initialValue: data.callSign,
                                                                                                 //     keyboardType: TextInputType.text,
                                                                                                 //     decoration: InputDecoration(
                                                                                                 //       contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                                                                                                 //       hintText: "sadas",
                                                                                                 //       labelText: "Asdas",
                                                                                                 //       hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                                                                                                 //       labelStyle: TextStyle(color: Colors.black, fontSize: 15),
                                                                                                 //       border: OutlineInputBorder(
                                                                                                 //         borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                                                                                 //         borderRadius: BorderRadius.circular(20),
                                                                                                 //       ),
                                                                                                 //       filled: true,
                                                                                                 //       fillColor: Colors.black12,
                                                                                                 //     ),
                                                                                                 //   ),
                                                                                                 // ),
                                                                                                 Column(
                                                                                                   children: [
                                                                                                     VesselTextField(
                                                                                                       controller:
                                                                                                       callsignController,
                                                                                                       hint:
                                                                                                       'Call Sign',
                                                                                                       type:
                                                                                                       TextInputType.text,
                                                                                                     ),
                                                                                                     VesselTextField(
                                                                                                       controller:
                                                                                                       flagController,
                                                                                                       hint:
                                                                                                       'Bendera',
                                                                                                       type:
                                                                                                       TextInputType.text,
                                                                                                     ),
                                                                                                     VesselTextField(
                                                                                                       controller:
                                                                                                       classController,
                                                                                                       hint:
                                                                                                       'Kelas',
                                                                                                       type:
                                                                                                       TextInputType.text,
                                                                                                     ),
                                                                                                     VesselTextField(
                                                                                                       controller:
                                                                                                       builderController,
                                                                                                       hint:
                                                                                                       'Builder',
                                                                                                       type:
                                                                                                       TextInputType.text,
                                                                                                     ),
                                                                                                     VesselTextField(
                                                                                                       controller:
                                                                                                       yearbuiltController,
                                                                                                       hint:
                                                                                                       'Tahun Pembuatan',
                                                                                                       type:
                                                                                                       TextInputType.number,
                                                                                                     ),
                                                                                                     VesselTextField(
                                                                                                       controller:
                                                                                                       ipController,
                                                                                                       hint:
                                                                                                       'IP',
                                                                                                       type:
                                                                                                       TextInputType.text,
                                                                                                     ),
                                                                                                     VesselTextField(
                                                                                                       controller:
                                                                                                       portController,
                                                                                                       hint:
                                                                                                       'Port',
                                                                                                       type:
                                                                                                       TextInputType.number,
                                                                                                     ),
                                                                                                     SizedBox(
                                                                                                       height:
                                                                                                       30,
                                                                                                       width:
                                                                                                       double.infinity,
                                                                                                       child:
                                                                                                       DropdownSearch<String>(
                                                                                                         selectedItem: data.kapal!.size ?? "",
                                                                                                         dropdownBuilder: (context, selectedItem) => Text(
                                                                                                           selectedItem ?? "Ukuran Kapal",
                                                                                                           style: TextStyle(fontSize: 15, color: Colors.black54),
                                                                                                         ),
                                                                                                         popupProps: PopupPropsMultiSelection.dialog(
                                                                                                           fit: FlexFit.loose,
                                                                                                           itemBuilder: (context, item, isSelected) => ListTile(
                                                                                                             title: Text(
                                                                                                               item,
                                                                                                               style: TextStyle(
                                                                                                                 fontSize: 15,
                                                                                                               ),
                                                                                                             ),
                                                                                                           ),
                                                                                                         ),
                                                                                                         dropdownDecoratorProps: DropDownDecoratorProps(
                                                                                                           dropdownSearchDecoration: InputDecoration(
                                                                                                             border: OutlineInputBorder(
                                                                                                               borderSide: BorderSide.none,
                                                                                                               borderRadius: BorderRadius.circular(10),
                                                                                                             ),
                                                                                                             contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                                                                                                             filled: true,
                                                                                                             fillColor: Colors.black12,
                                                                                                           ),
                                                                                                         ),
                                                                                                         items: [
                                                                                                           "small",
                                                                                                           "medium",
                                                                                                           "large",
                                                                                                         ],
                                                                                                         onChanged: (value) {
                                                                                                           vesselSize = value;
                                                                                                         },
                                                                                                       ),
                                                                                                     ),
                                                                                                     SizedBox(
                                                                                                       height:
                                                                                                       5,
                                                                                                     ),
                                                                                                     Row(
                                                                                                       mainAxisAlignment:
                                                                                                       MainAxisAlignment.end,
                                                                                                       children: [
                                                                                                         InkWell(
                                                                                                           onTap: () {
                                                                                                             Navigator.pop(context);
                                                                                                           },
                                                                                                           child: Container(
                                                                                                             decoration: BoxDecoration(
                                                                                                               borderRadius: BorderRadius.circular(10),
                                                                                                               color: Color(0xFFFF0000),
                                                                                                             ),
                                                                                                             padding: EdgeInsets.all(5),
                                                                                                             alignment: Alignment.center,
                                                                                                             height: 30,
                                                                                                             child: Text("Batal"),
                                                                                                           ),
                                                                                                         ),
                                                                                                         SizedBox(
                                                                                                           width: 5,
                                                                                                         ),
                                                                                                         InkWell(
                                                                                                           onTap: () {
                                                                                                             if (callsignController.text.isEmpty) {
                                                                                                               EasyLoading.showError("Kolom Call Sign Masih Kosong...");
                                                                                                               return;
                                                                                                             }
                                                                                                             if (flagController.text.isEmpty) {
                                                                                                               EasyLoading.showError("Kolom Bendera Masih Kosong...");
                                                                                                               return;
                                                                                                             }
                                                                                                             if (classController.text.isEmpty) {
                                                                                                               EasyLoading.showError("Kolom Kelas Masih Kosong...");
                                                                                                               return;
                                                                                                             }
                                                                                                             if (builderController.text.isEmpty) {
                                                                                                               EasyLoading.showError("Kolom Builder Masih Kosong...");
                                                                                                               return;
                                                                                                             }
                                                                                                             if (yearbuiltController.text.isEmpty) {
                                                                                                               EasyLoading.showError("Kolom Tahun Pembuatan Masih Kosong...");
                                                                                                               return;
                                                                                                             }
                                                                                                             if (ipController.text.isEmpty) {
                                                                                                               EasyLoading.showError("Kolom IP Pembuatan Masih Kosong...");
                                                                                                               return;
                                                                                                             }
                                                                                                             if (portController.text.isEmpty) {
                                                                                                               EasyLoading.showError("Kolom Port Masih Kosong...");
                                                                                                               return;
                                                                                                             }
                                                                                                             if (vesselSize == null) {
                                                                                                               EasyLoading.showError("Kolom Ukuran Kapal Masih Kosong...");
                                                                                                               return;
                                                                                                             }
                                                                                                             Map<String,String> dataEdit = {
                                                                                                               "old_call_sign": data.kapal!.callSign!,
                                                                                                               "call_sign": callsignController.text,
                                                                                                               "flag": flagController.text,
                                                                                                               "class": classController.text,
                                                                                                               "builder": builderController.text,
                                                                                                               "year_built": yearbuiltController.text,
                                                                                                               "ip": ipController.text,
                                                                                                               "port": portController.text,
                                                                                                               "size": vesselSize!,
                                                                                                             };
                                                                                                             readNotifier.editVessel(dataEdit,_pageSize,context);

                                                                                                             // submitVessel();
                                                                                                           },
                                                                                                           child: Container(
                                                                                                             decoration: BoxDecoration(
                                                                                                               borderRadius: BorderRadius.circular(10),
                                                                                                               color: Color(0xFF399D44),
                                                                                                             ),
                                                                                                             padding: EdgeInsets.all(5),
                                                                                                             alignment: Alignment.center,
                                                                                                             height: 30,
                                                                                                             child: Text("Simpan"),
                                                                                                           ),
                                                                                                         )
                                                                                                       ],
                                                                                                     )
                                                                                                   ],
                                                                                                 ),
                                                                                               ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    });
                                                                      },
                                                                    ),
                                                                            IconButton(
                                                                      icon:
                                                                              Icon(
                                                                            Icons
                                                                                .delete,
                                                                            color: Colors
                                                                                .red,
                                                                      ),
                                                                      onPressed:
                                                                              () {
                                                                            value.deleteVessel(
                                                                                data.kapal!.callSign,
                                                                                context,_pageSize);
                                                                      },
                                                                    ),
                                                                          ],
                                                                        )),
                                                                  ]);
                                                            }).toList())),
                                              ),
                                            ),
                                            Pagination(
                                              numOfPages:
                                                  (value.totalVessel / 10)
                                                      .ceil(),
                                              selectedPage: value.currentPage,
                                              pagesVisible: 7,
                                              onPageChanged: (page) {
                                                value
                                                    .incrementPage(page);
                                                value
                                                    .initVesselCoor();
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
                                          ],
                                        )));
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
                  Row(
                    children: [
                      Container(
                        width: 300,
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
                                        SizedBox(
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
                            labelText: "Pilih Call Sign Kapal",
                            hintStyle: TextStyle(color: Colors.black),
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.search),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 230, 230, 230),
                            prefixIconColor: Colors.black,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3,
                                  color:
                                      const Color.fromARGB(255, 230, 230, 230)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3,
                                  color:
                                      const Color.fromARGB(255, 230, 230, 230)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
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
                          child: Icon(Icons.search),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          // drawer: Drawer(
          //   child: Padding(
          //     padding: const EdgeInsets.all(15),
          //     child: Column(
          //       children: [
          //         Text(
          //           "Menu",
          //           style: Constants.title1,
          //         ),
          //         SizedBox(
          //           height: 10,
          //         ),
          //         ListTile(
          //           leading: Icon(Icons.menu),
          //           trailing: Text(
          //             "Vessel",
          //             style: TextStyle(
          //               fontSize: 16,
          //             ),
          //           ),
          //           onTap: () {
          //             // Navigator.push(context,
          //             //     MaterialPageRoute(builder: (context) => HomePage()));
          //           },
          //         ),
          //         ListTile(leading: Text("menu2")),
          //         ListTile(leading: Text("menu3")),
          //       ],
          //     ),
          //   ),
          // ),
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
                    ),
                    nonRotatedChildren: [
                      FlutterMapZoomButtons(
                        minZoom: 4,
                        maxZoom: 19,
                        mini: true,
                        padding: 10,
                        alignment: Alignment.bottomRight,
                      ),
                      ScaleLayerWidget(
                        options: ScaleLayerPluginOption(
                          lineColor: Colors.blue,
                          lineWidth: 2,
                          textStyle:
                              const TextStyle(color: Colors.blue, fontSize: 12),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                      if (value.onClickVessel != "")
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
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
                                      Duration(milliseconds: 1750),
                                  positionFactor: (301.74 /
                                      MediaQuery.of(context).size.height),
                                ),
                                SnappingPosition.factor(
                                  positionFactor: 0.0,
                                  snappingCurve: Curves.easeOutExpo,
                                  snappingDuration: Duration(seconds: 1),
                                  grabbingContentOffset:
                                      GrabbingContentOffset.top,
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
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            snappingSheetController
                                                .snapToPosition(
                                              SnappingPosition.factor(
                                                  positionFactor: -0.5),
                                            );
                                            Timer(Duration(milliseconds: 300),
                                                () {
                                              value.removeClickedVessel();
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                  color: Colors.black12),
                                              padding: EdgeInsets.all(4),
                                              child: Center(
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
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${value.searchKapal!.kapal!.callSign}",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      "${value.searchKapal!.kapal!.flag}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Image.asset(
                                                "assets/model_kapal.jpg",
                                                width: 100,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Position Information"
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(10),
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
                                                          Text(
                                                            'Latitude',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: const Color
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
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: const Color
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
                                                          EdgeInsets.all(10),
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
                                                          Text(
                                                            'Longitude',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: const Color
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
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: const Color
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
                              if(value.searchKapal != null)
                                if (value.searchKapal!.kapal!.callSign == value.onClickVessel)
                                  LatLng(
                                      predictLatLong(
                                              value.searchKapal!.coor!.coorGga!.latitude!.toDouble(),
                                              value.searchKapal!.coor!.coorGga!.longitude!.toDouble(),
                                              100,
                                              value.searchKapal!.coor!.coorHdt!.headingDegree ??
                                                  value.searchKapal!.coor!.defaultHeading!.toDouble(),
                                              value.predictMovementVessel)
                                          .latitude,
                                      predictLatLong(
                                              value.searchKapal!.coor!.coorGga!.latitude!.toDouble(),
                                              value.searchKapal!.coor!.coorGga!.longitude!.toDouble(),
                                              100,
                                              value.searchKapal!.coor!.coorHdt!.headingDegree ??
                                                  value.searchKapal!.coor!.defaultHeading!.toDouble(),
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
                      MarkerLayer(
                        markers: [
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
                        ]
                      ),
                      MarkerLayer(
                        markers: 
                          value.vesselCoorResult.map((i) => 
                            Marker(
                              width: vesselSizes(i.kapal!.size!.toString()),
                              height: vesselSizes(i.kapal!.size!.toString()),
                              point: LatLng(
                                  predictLatLong(
                                          i.coor!.coorGga!.latitude!.toDouble(),
                                          i.coor!.coorGga!.longitude!.toDouble(),
                                          100,
                                          i.coor!.coorHdt!.headingDegree ??
                                              i.coor!.defaultHeading!.toDouble(),
                                          value.predictMovementVessel)
                                      .latitude,
                                  predictLatLong(
                                          i.coor!.coorGga!.latitude!.toDouble(),
                                          i.coor!.coorGga!.longitude!.toDouble(),
                                          100,
                                          i.coor!.coorHdt!.headingDegree ??
                                              i.coor!.defaultHeading!.toDouble(),
                                          value.predictMovementVessel)
                                      .longitude
                                  // i.coorGga!.latitude!.toDouble() + (predictMovementVessel * (9.72222 / 111111.1)),
                                  //   i.coorGga!.longitude!.toDouble()
                                  ),
                              rotateOrigin: Offset(10, -10),
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    searchVessel(i.kapal!.callSign);
                                  },
                                  child: Transform.rotate(
                                    angle: degreesToRadians(
                                        i.coor!.coorHdt!.headingDegree ??
                                            i.coor!.defaultHeading!.toDouble()),
                                    child: Tooltip(
                                      message: i.kapal!.callSign!.toString(),
                                      child: Image.asset(
                                          "assets/ship.png"),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ).toList(),     
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
}

// class _DataSource extends DataTableSource {
//   final List<Vessel.Data> data;
//   final BuildContext ctx;
//   final int vesselTotal;

//   _DataSource(
//       {required this.data, required this.context, required this.vesselTotal});

//   @override
//   DataRow? getRow(int index) {
//     if (index >= data.length) {
//       return null;
//     }

//     final item = data[index];

//     return DataRow(cells: [
//       DataCell(Text(item.callSign!)),
//       DataCell(Text(item.flag!)),
//       DataCell(Text(item.kelas!)),
//       DataCell(Text(item.builder!)),
//       DataCell(Text(item.yearBuilt!)),
//       DataCell(Text(item.ip!)),
//       DataCell(Text(item.port!)),
//       DataCell(Text(item.size!)),
//       DataCell(
//           IconButton(
//         icon: Icon(
//           Icons.delete,
//           color: Colors.red,
//         ),
//         onPressed: () {
//           Api.deleteVessel(item.callSign!).then((value) {
//             if (value.status == 200) {
//               EasyLoading.showSuccess("Kapal Terhapus..");
//               Navigator.pop(ctx);
//             } else {
//               EasyLoading.showError("Gagal Menghapus Kapal..");
//             }
//           });
//         },
//       ))
//     ]);
//   }

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get rowCount => vesselTotal;

//   @override
//   int get selectedRowCount => 0;
// }

class CursorTooltip extends StatelessWidget {
  final String text;

  CursorTooltip({required this.text});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(8),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}