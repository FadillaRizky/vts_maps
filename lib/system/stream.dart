import 'package:flutter/material.dart';

import 'package:vts_maps/api/GetKapalAndCoor.dart' as GetVesselCoor;
import 'package:vts_maps/api/api.dart';
class StreamSystem{

  static Stream<GetVesselCoor.GetKapalAndCoor> vesselCoorStream(
      {int page = 1, int perpage = 100}) async* {
    GetVesselCoor.GetKapalAndCoor data =
        await Api.getKapalAndCoor(page: page, perpage: perpage);
    yield data;
  }
  
}