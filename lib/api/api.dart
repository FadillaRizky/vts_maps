
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vts_maps/api/EditVesselResponse.dart';
import 'package:vts_maps/api/GetAllLatLangCoor.dart';
import 'package:vts_maps/api/GetAllVessel.dart';
import 'package:vts_maps/api/SubmitVesselResponse.dart';

import '../utils/shared_pref.dart';
import 'DeleteVesselResponse.dart';
import 'GetAllVesselCoor.dart';

const BASE_URL = "https://client-project.enricko.site/api";
// const BASE_URL = "http://127.0.0.1:8000/api";
class Api{

  static Future<GetAllVessel> getAllVessel({int page = 1,int perpage = 10}) async {
    var url = "$BASE_URL/kapal?page=$page&perpage=$perpage";
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
  static Future<GetAllLatLangCoor> getAllLatLangCoor({String? call_sign}) async {
    var url = "$BASE_URL/get_all_latlang_coor?call_sign=$call_sign&page=1&perpage=100";
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
    var url = "$BASE_URL/get_all_latest_coor?page=1&perpage=100";
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
  static Future<SubmitVesselResponse>createVessel(Map<String,String> data) async {
    try{
      var url = "$BASE_URL/insert_kapal";
      var datatoken = await LoginPref.getPref();
      var token = datatoken.token!;
      var response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          // 'Content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return SubmitVesselResponse.fromJson(jsonDecode(response.body));
      }
      if (response.statusCode == 400) {
        return SubmitVesselResponse.fromJson(jsonDecode(response.body));
      }
      else {
        throw "Gagal create vessel:\n${response.body}";
      }
    }catch(e){
      print("error nya $e");
      rethrow;
    }
  }
  static Future<EditVesselResponse>editVessel(Map<String,String> data) async {
    try{
      var url = "$BASE_URL/update_kapal";
      var datatoken = await LoginPref.getPref();
      var token = datatoken.token!;
      var response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          // 'Content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return EditVesselResponse.fromJson(jsonDecode(response.body));
      }
      if (response.statusCode == 400) {
        return EditVesselResponse.fromJson(jsonDecode(response.body));
      }
      else {
        throw "Gagal edit vessel:\n${response.body}";
      }
    }catch(e){
      print("error nya $e");
      rethrow;
    }
  }

  static Future<DeleteVesselResponse> deleteVessel(String callSign) async {
    var url = "$BASE_URL/delete_kapal/$callSign";
    var response = await http.delete(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return DeleteVesselResponse.fromJson(jsonDecode(response.body));
    }
    throw "Gagal delete vessel:\n${response.body}";

  }
}