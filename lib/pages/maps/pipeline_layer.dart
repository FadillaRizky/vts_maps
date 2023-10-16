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
import 'package:xml/xml.dart' as xml;

class PipelineLayer extends StatefulWidget {
  const PipelineLayer({super.key});

  @override
  State<PipelineLayer> createState() => _PipelineLayerState();
}

class _PipelineLayerState extends State<PipelineLayer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Notifier>(builder:(context, value, child) {
      return Stack(
        children: value.kmlOverlayPolygons
                  .map(
                    (x) => PolylineLayer(
                      polylines: x
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
                    ),
                  )
                  .toList(),
      );
    },);
    // return StreamBuilder<List<List<KmlPolygon>>>(
    //     stream: pipelineStream(context),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         return Stack(
    //           children: 
    //         );
    //       } else {
    //         return Container();
    //       }
    //     });
  }
}
