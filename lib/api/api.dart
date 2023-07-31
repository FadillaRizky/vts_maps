
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vts_maps/api/GetAllLatLangCoor.dart';
import 'package:vts_maps/api/GetAllVessel.dart';

import 'GetAllVesselCoor.dart';

const BASE_URL = "https://client-project.enricko.site/api/";
class Api{

  static Future<GetAllVessel> getAllVessel() async {
    var url = BASE_URL + "kapal";
    var response = await http.get(
      Uri.parse(url),
    );
    print("${response.statusCode} kapal");
    if (response.statusCode == 200) {
      return GetAllVessel.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request all vessel:\n${response.body}";
  
  }
  static Future<GetAllLatLangCoor> getAllLatLangCoor() async {
    var url = BASE_URL + "get_all_latlang_coor?page=1";
    var response = await http.get(
      Uri.parse(url),
    );
    print("${response.statusCode} latlang coor");
    if (response.statusCode == 200) {
      return GetAllLatLangCoor.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request all vessel:\n${response.body}";

  }
  static Future<GetAllVesselCoor> getAllVesselLatestCoor() async {
    var url = BASE_URL + "get_all_latest_coor?page=1";
    var response = await http.get(
      Uri.parse(url),
    );
    print("${response.statusCode} coor");
    if (response.statusCode == 200) {
      return GetAllVesselCoor.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request all vessel:\n${response.body}";

  }

}