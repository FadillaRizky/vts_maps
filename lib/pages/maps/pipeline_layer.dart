import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/api/GetPipelineResponse.dart' as Pipeline;
import 'package:vts_maps/api/api.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:vts_maps/maps_view.dart';
import 'package:vts_maps/utils/constants.dart';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xml/xml.dart' as xml;

class PipelineLayer extends StatefulWidget {
  const PipelineLayer({super.key, this.id_client = ""});
  final String id_client;

  @override
  State<PipelineLayer> createState() => _PipelineLayerState();
}

class _PipelineLayerState extends State<PipelineLayer> {
  Map<String, List<KmlPolygon>> kmlOverlayPolygons = {};

  Future<void> loadKMZData(
      BuildContext context, List<Pipeline.Data> files) async {
    for (var data in files) {
      String file = data.file!;
      if (!kmlOverlayPolygons.containsKey(file.toString())) {
        // print(file);
        if (data.onOff == true) {
          // final response = await http.get(Uri.parse(data.file!),headers: {'Accept': 'application/xml'});
          final response = await http.get(Uri.parse(file));
          if (file.endsWith(".kmz")) {
            if (response.statusCode == 200) {
              final kmlData =
                  Constants.extractKMLDataFromKMZ(response.bodyBytes);
              if (kmlData != null) {
                kmlOverlayPolygons[file.toString()] =
                    parseKmlForOverlay(kmzData: kmlData);
              }
            } else {
              throw Exception(
                  'Failed to load KMZ data: ${response.statusCode}');
            }
          } else if (file.endsWith(".kml")) {
            kmlOverlayPolygons[file.toString()] =
                parseKmlForOverlay(kmlData: response.body);
          }
        }
      }
    }
    // print(kmlOverlayPolygons.length);
  }

  List<KmlPolygon> parseKmlForOverlay({List<int>? kmzData, String? kmlData}) {
    final List<KmlPolygon> polygons = [];
    xml.XmlDocument? doc;

    if (kmzData != null) {
      doc = xml.XmlDocument.parse(utf8.decode(kmzData));
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
      final subClass = simpleDataElement
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

  final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('wss://api.binav-avts.id:6001/socket-mapping?appKey=123456'));
  Timer? timer;

  void fetchData() {
    channel.sink.add(json.encode({
      // Give an parameter to fetch the data
      "page": 1,
      "perpage": 100,
      "id_client":widget.id_client
    }));
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      channel.sink.add(json.encode({
        // Give an parameter to fetch the data
        "page": 1,
        "perpage": 100,
        "id_client":widget.id_client
      }));
      // load = false;
    });
  }

  void stopFetchingData() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  void initState() {
    fetchData();
    channel.stream.listen((event) {
      // kmlOverlayPolygons.clear();
      if (event != "on Opened") {
        final data = Pipeline.GetPipelineResponse.fromJson(jsonDecode(event));
        List<Pipeline.Data> pipeData = data.data!;
        loadKMZData(context, pipeData);
      }
    });
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
    return Stack(
      children: kmlOverlayPolygons.entries
          .map((x) => PolylineLayer(
                polylines: x.value
                    .map(
                      (y) => Polyline(
                        strokeWidth: 3,
                        points: y.points,
                        color: Color(
                          int.parse(
                            y.color,
                            radix: 16,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ))
          .toList(),
    );
  }
}
