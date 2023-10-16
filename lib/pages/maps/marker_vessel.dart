import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/api/GetKapalAndCoor.dart' as GetVesselCoor;
import 'package:vts_maps/api/api.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';

class MarkerVessel extends StatefulWidget {
  const MarkerVessel({super.key});

  @override
  State<MarkerVessel> createState() => _MarkerVesselState();
}

class _MarkerVesselState extends State<MarkerVessel> {
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

  Stream<GetVesselCoor.GetKapalAndCoor> vesselStream(
      {int page = 1, int perpage = 100}) async* {
    GetVesselCoor.GetKapalAndCoor data =
        await Api.getKapalAndCoor(page: page, perpage: perpage);
    yield data;
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GetVesselCoor.GetKapalAndCoor>(
      stream: vesselStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<GetVesselCoor.Data> clientData = snapshot.data!.data!;

          return Consumer<Notifier>(builder: (context, value, child) {
            return MarkerLayer(
              markers: [
                for (var i in clientData)
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
                    rotateOrigin: const Offset(10, -10),
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          // searchVessel(i.kapal!.callSign!);
                          value.vesselClicked(i.kapal!.callSign!);
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
                      );
                    },
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
