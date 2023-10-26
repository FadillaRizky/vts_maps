import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/api/GetKapalAndCoor.dart' as GetVesselCoor;
import 'package:vts_maps/api/api.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class MarkerVessel extends StatefulWidget {
  const MarkerVessel({super.key, required this.mapController, this.id_client = ""});
  final MapController mapController;
  final String id_client;

  @override
  State<MarkerVessel> createState() => _MarkerVesselState();
}

class _MarkerVesselState extends State<MarkerVessel> with TickerProviderStateMixin {
  int predictMovementVessel = 1;

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

  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = widget.mapController.camera;
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

      hasTriggeredMove |= widget.mapController.move(
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

  Future<void> searchVessel(String callSign) async {
    var readNotifier = context.read<Notifier>();

    readNotifier.vesselClicked(callSign, context);
    Future.delayed(const Duration(seconds: 1), () {
      print(readNotifier.searchKapal!.kapal!.callSign);
      readNotifier.initLatLangCoor(call_sign: callSign);
      _animatedMapMove(
          LatLng(
            readNotifier.searchKapal!.coor!.coorGga!.latitude!.toDouble() - .005,
            readNotifier.searchKapal!.coor!.coorGga!.longitude!.toDouble(),
          ),
          15);
    });
  }

  // Stream<GetVesselCoor.GetKapalAndCoor> vesselStream(
  //     {int page = 1, int perpage = 100}) async* {
  //   GetVesselCoor.GetKapalAndCoor data =
  //       await Api.getKapalAndCoor(page: page, perpage: perpage);
  //   yield data;
  // }
  
  final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('wss://api.binav-avts.id:6001/socket-kapalCoor?appKey=123456&User-Agent=BinavAvts/1.0&Accept=application/json'));
  Timer? timer;

  void fetchData(){
    // First request Data
    channel.sink.add(json.encode({
      // Give an parameter to fetch the data
      "payload":"test",
      "id_client":widget.id_client
    }));
    timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      channel.sink.add(json.encode({
        // Give an parameter to fetch the data
        "payload":"test",
        "id_client":widget.id_client
      }));
    });
  }

  void stopFetchingData(){
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  void initState() {
    fetchData();
    
    super.initState();
  }
  @override
  void dispose() {
    channel.sink.close();
    stopFetchingData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: channel.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != "on Opened") {
          final message = GetVesselCoor.GetKapalAndCoor.fromJson(jsonDecode(snapshot.data));
          List<GetVesselCoor.Data> vesselData = message.data!;

          // print(vesselData);
          // return Container();
          return Consumer<Notifier>(builder: (context, value, child) {
            return MarkerLayer(
              markers: [
                for (var i in vesselData)
                  Marker(
                    width: vesselSizes(i.kapal!.size!.toString()) +
                        value.currentZoom!.toDouble(),
                    height: vesselSizes(i.kapal!.size!.toString()) +
                        value.currentZoom!.toDouble(),
                    point: LatLng(
                        predictLatLong(
                                i.coor!.coorGga!.latitude!.toDouble(),
                                i.coor!.coorGga!.longitude!.toDouble(),
                                100,
                                i.coor!.coorHdt!.headingDegree ??
                                    i.coor!.defaultHeading!.toDouble(),
                                predictMovementVessel)
                            .latitude,
                        predictLatLong(
                                i.coor!.coorGga!.latitude!.toDouble(),
                                i.coor!.coorGga!.longitude!.toDouble(),
                                100,
                                i.coor!.coorHdt!.headingDegree ??
                                    i.coor!.defaultHeading!.toDouble(),
                                predictMovementVessel)
                            .longitude),
                    // rotateOrigin: const Offset(10, -10),
                    child: GestureDetector(
                        onTap: () {
                          searchVessel(i.kapal!.callSign!);
                          // value.vesselClicked(i.kapal!.callSign!,context);
                        },
                        child: Transform.rotate(
                          angle: degreesToRadians(
                              i.coor!.coorHdt!.headingDegree ??
                                  i.coor!.defaultHeading!.toDouble()),
                          child: Tooltip(
                            message: i.kapal!.callSign!.toString(),
                            child: Image.asset(
                              "assets/ship.png",
                              height: vesselSizes(i.kapal!.size!.toString()) +
                                  value.currentZoom!.toDouble(),
                              width: vesselSizes(i.kapal!.size!.toString()) +
                                  value.currentZoom!.toDouble(),
                            ),
                          ),
                        ),
                      ),
                  ),
              ],
            );
          });
        } else {
          return Container();
        }
      },
    );
  }
}
