import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:searchfield/searchfield.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:vts_maps/system/scale_bar.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:vts_maps/utils/snipping_sheet.dart';
import 'package:vts_maps/vessel_list.dart';
import 'package:vts_maps/vessel_models.dart';
import 'package:xml/xml.dart' as xml;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

import 'api/GetAllVesselCoor.dart' as LatestVesselCoor;
import 'api/GetAllLatLangCoor.dart' as LatLangCoor;
import 'api/GetAllVessel.dart' as Vessel;
import 'api/api.dart';
import 'system/zoom_button.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';

// import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import 'package:archive/archive.dart';

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
  // Controller
  final SnappingSheetController snappingSheetController =
      new SnappingSheetController();
  TextEditingController SearchVessel = TextEditingController();
  late final MapController mapController;

  final DataTableSource _dummydata = MyData();

  // List API
  List<LatestVesselCoor.Data> result = [];
  List<Vessel.Data> vesselResult = [];
  List<LatLangCoor.Data> latLangResult = [];

  // Random Variable
  int predictMovementVessel = 0;
  String onClickVessel = "";
  final pointSize = 75.0;
  final pointY = 75.0;

  LatLng? latLng;

  int _currentPage = 1;
  int _pageSize = 10;
  List<DataModel> _data = [];
  bool _isLoading = false;

  // Animated Map Variable
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  int? vesselIndex;

  List<List<KmlPolygon>> kmlOverlayPolygons = [];

  // Map<String, Color> HEX_MAP = {
  //   '#yellowLine': Color(0xFFFFFF00),
  //   '#purpleLine': Color(0xFF800080),
  //   '#brownLine': Color(0xFFA52A2A),
  //   '#pinkLine': Color(0xFFFFC0CB),
  //   '#orangeLine': Color(0xFFFFA500),
  //   '#greenLine': Color(0xFF00FF00),
  //   '#redLine': Color(0xFFFF0000),
  //   '#blueLine': Color(0xFF0000FF),
  // };

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
      setState(() {
        predictMovementVessel = 0;
      });
      Api.getAllVesselLatestCoor().then((value) {
        result.clear();
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

  void updatePoint(MapEvent? event, BuildContext context) {
    final pointX = Constants.getPointX(context);
    setState(() {
      latLng = mapController.camera.pointToLatLng(Point(pointX, pointY));
    });
  }

  Vessel.Data vesselDescription(String vessel) {
    var dataVessel = vesselResult.where((e) => e.callSign == vessel).first;
    return dataVessel;
  }

  LatestVesselCoor.Data vesselLatestCoor(String vessel) {
    LatestVesselCoor.Data latestCoor =
        result.where((e) => e.callSign == vessel).first;
    return latestCoor;
  }

  searchVessel(String callSign) {
    var vessel = vesselLatestCoor(callSign);
    setState(() {
      onClickVessel = vessel.callSign!;
    });
    _animatedMapMove(
        LatLng(
          vessel.coorGga!.latitude!.toDouble(),
          vessel.coorGga!.longitude!.toDouble(),
        ),
        13);
  }

  // void loadKmlData() async {
  //   final String kmlData = await loadKmlFromFile('assets/kml/format_pipa.kml');
  //   setState(() {
  //     kmlOverlayPolygons = parseKmlForOverlay(kmlData);
  //   });
  // }

  Future<String> loadKmlFromFile(String filePath) async {
    return await DefaultAssetBundle.of(context).loadString(filePath);
  }

  Future<void> loadKMZData() async {
    // final file = "assets/kml/Pipa.kmz";
    // final file = "assets/kml/format_pipa.kml";
    List files = [
      "assets/kml/Pipa.kmz",
      "assets/kml/format_pipa.kml",
    ];
    for (var file in files) {
      if (file.endsWith(".kmz")) {
        final ByteData data = await rootBundle.load(file);
        final List<int> bytes = data.buffer.asUint8List();
        final kmlData = Constants.extractKMLDataFromKMZ(bytes);
        if (kmlData != null) {
          kmlOverlayPolygons.add(parseKmlForOverlay(kmzData: kmlData));
          setState(() {});
        }
      } else if (file.endsWith(".kml")) {
        final String kmlData = await loadKmlFromFile(file);
        kmlOverlayPolygons.add(parseKmlForOverlay(kmlData: kmlData));
        setState(() {});
      }
    }
  }

  List<KmlPolygon> parseKmlForOverlay({List<int>? kmzData, String? kmlData}) {
    final List<KmlPolygon> polygons = [];
    XmlDocument? doc;

    if (kmzData != null) {
      doc = XmlDocument.parse(utf8.decode(kmzData));
    } else if (kmlData != null) {
      doc = xml.XmlDocument.parse(kmlData);
    }

    final Iterable<xml.XmlElement> placemarks =
        doc!.findAllElements('Placemark');
    for (final placemark in placemarks) {
      final xml.XmlElement? extendedDataElement =
          placemark.getElement("ExtendedData");
      final xml.XmlElement? schemaDataElement =
          extendedDataElement!.getElement("SchemaData");
      final Iterable<xml.XmlElement> simpleDataElement =
          schemaDataElement!.findAllElements("SimpleData");
      final subClass = simpleDataElement!
          .where((element) => element.getAttribute("name") == "SubClasses")
          .first
          .innerText;
      if (subClass == "AcDbEntity:AcDb2dPolyline" ||
          subClass == "AcDbEntity:AcDbPolyline") {
        final styleElement = placemark.findAllElements('Style').first;
        final lineStyleElement = styleElement.findElements('LineStyle').first;
        final colorLine =
            lineStyleElement.findElements('color').first.innerText;

        final xml.XmlElement? polygonElement =
            placemark.getElement('LineString');
        if (polygonElement != null) {
          final List<LatLng> polygonPoints = [];

          final xml.XmlElement? coordinatesElement =
              polygonElement.getElement('coordinates');
          if (coordinatesElement != null) {
            final String coordinatesText = coordinatesElement.text;
            final List<String> coordinateList = coordinatesText.split(' ');

            for (final coordinate in coordinateList) {
              final List<String> latLng = coordinate.split(',');
              if (latLng.length >= 2) {
                double? latitude = double.tryParse(latLng[1]);
                double? longitude = double.tryParse(latLng[0]);
                if (latitude != null && longitude != null) {
                  polygonPoints.add(LatLng(latitude, longitude));
                }
              }
            }
          }

          // print(placemark.getElement('styleUrl')!.text);
          if (polygonPoints.isNotEmpty) {
            polygons.add(KmlPolygon(points: polygonPoints, color: colorLine));
          }
        }
      }
    }

    return polygons;
  }
  Future<void> fetchDataVessel() async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(Uri.parse(
        "https://client-project.enricko.site/api/kapal?page=$_currentPage&perpage=$_pageSize"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      inspect(jsonData);
      final dataList = jsonData['data'] as List<dynamic>;

      final List<DataModel> newData =
      dataList.map((item) => DataModel.fromJson(item)).toList();

      setState(() {
        _data.addAll(newData);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to fetch data');
    }
  }


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

  @override
  void initState() {
    super.initState();
    // loadKmlData();
    fetchDataVessel();
    initVessel();
    initCoorVessel();
    initLatLangCoor();
    initKalmanFilter();
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
                                        width: width / 2,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              color: Colors.black12,
                                              padding: EdgeInsets.all(5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Vessel List",style: GoogleFonts.openSans(
                                                    fontSize: 20
                                                  ),),
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
                                                    .end,
                                                children: [
                                                  InkWell(
                                                    onTap: () {},
                                                    child: Container(
                                                      decoration:
                                                      BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            10),
                                                        color: Color(
                                                            0xFF399D44),
                                                      ),
                                                      padding:
                                                      EdgeInsets
                                                          .all(5),
                                                      alignment:
                                                      Alignment
                                                          .center,
                                                      height: 40,
                                                      child: Icon(
                                                          Icons.add),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 300,
                                              child: ListView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  children: [
                                                    _isLoading
                                                    ? CircularProgressIndicator()
                                                    : PaginatedDataTable(
                                                      columns: [
                                                        DataColumn(
                                                            label: Text(
                                                                'Call Sign')),
                                                        DataColumn(
                                                            label: Text(
                                                                'Flag')),
                                                        DataColumn(
                                                            label: Text(
                                                                'Kelas')),
                                                        DataColumn(
                                                            label: Text(
                                                                'Builder')),
                                                        DataColumn(
                                                            label: Text(
                                                                'Year Built')),
                                                      ],
                                                      arrowHeadColor:
                                                          Colors.black,
                                                      columnSpacing: 100,
                                                      horizontalMargin: 10,
                                                      rowsPerPage: 10,
                                                      showCheckboxColumn: false,
                                                      source: _DataSource(data: _data),
                                                    ),
                                                  ]),
                                            )
                                          ],
                                        )));
                              });
                      }
                    },
                  ),
              Container(),
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
                    child: SearchField<Vessel.Data>(
                      controller: SearchVessel,
                      suggestions: vesselResult
                          .map(
                            (e) => SearchFieldListItem<Vessel.Data>(
                              e.callSign!,
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
                                    Text(e.callSign!),
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
                              color: const Color.fromARGB(255, 230, 230, 230)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 3,
                              color: const Color.fromARGB(255, 230, 230, 230)),
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
                  if (onClickVessel != "")
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
                              snappingDuration: Duration(milliseconds: 1750),
                              positionFactor:
                                  (301.74 / MediaQuery.of(context).size.height),
                            ),
                            SnappingPosition.factor(
                              positionFactor: 0.0,
                              snappingCurve: Curves.easeOutExpo,
                              snappingDuration: Duration(seconds: 1),
                              grabbingContentOffset: GrabbingContentOffset.top,
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
                                        snappingSheetController.snapToPosition(
                                          SnappingPosition.factor(
                                              positionFactor: -0.5),
                                        );
                                        Timer(Duration(milliseconds: 300), () {
                                          setState(() {
                                            onClickVessel = "";
                                          });
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
                                              style: TextStyle(fontSize: 20),
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
                                                  "${onClickVessel}",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "${vesselDescription(onClickVessel).flag!}",
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
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey,
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
                                                              255, 61, 61, 61),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${predictLat(vesselLatestCoor(onClickVessel).coorGga!.latitude!.toDouble(), 100, vesselLatestCoor(onClickVessel).coorHdt!.headingDegree!.toDouble(), predictMovementVessel).toStringAsFixed(5)}",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color
                                                                  .fromARGB(
                                                              255, 61, 61, 61),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey,
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
                                                              255, 61, 61, 61),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${predictLong(vesselLatestCoor(onClickVessel).coorGga!.latitude!.toDouble(), vesselLatestCoor(onClickVessel).coorGga!.longitude!.toDouble(), 100, vesselLatestCoor(onClickVessel).coorHdt!.headingDegree!.toDouble(), predictMovementVessel).toStringAsFixed(5)}",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color
                                                                  .fromARGB(
                                                              255, 61, 61, 61),
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
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  if (kmlOverlayPolygons.isNotEmpty)
                    for (final kmlOverlayPolygon in kmlOverlayPolygons)
                      PolylineLayer(
                        polylines: kmlOverlayPolygon.map((kmlPolygon) {
                          return Polyline(
                            strokeWidth: 3,
                            points: kmlPolygon.points,
                            color:
                                Color(int.parse(kmlPolygon.color, radix: 16)),
                          );
                        }).toList(),
                      ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        strokeWidth: 5,
                        points: [
                          for (var x in latLangResult.reversed)
                            if (x.callSign == onClickVessel)
                              LatLng(x.latitude!, x.longitude!),
                          for (var i in result)
                            if (i.callSign == onClickVessel)
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
                      for (var i in result)
                        Marker(
                          width: 50,
                          height: 50,
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
                                searchVessel(i.callSign!);
                              },
                              child: Transform.rotate(
                                angle: degreesToRadians(
                                    i.coorHdt!.headingDegree!.toDouble()),
                                child: Image.asset("assets/ship.png"),
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

class _DataSource extends DataTableSource {
  final List<DataModel> data;

  _DataSource({required this.data});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final item = data[index];

    return DataRow(cells: [
      DataCell(Text(item.call_sign)),
      DataCell(Text(item.flag)),
      DataCell(Text(item.kelas)),
      DataCell(Text(item.builder)),
      DataCell(Text(item.year_built)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

