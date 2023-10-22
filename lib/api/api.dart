
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:vts_maps/api/EditClientResponse.dart';
import 'package:vts_maps/api/EditVesselResponse.dart';
import 'package:vts_maps/api/GetAllLatLangCoor.dart';
import 'package:vts_maps/api/GetAllVessel.dart';
import 'package:vts_maps/api/GetClientListResponse.dart';
import 'package:vts_maps/api/GetKapalAndCoor.dart';
import 'package:vts_maps/api/SubmitClientResponse.dart';
import 'package:vts_maps/api/SubmitPipelineResponse.dart';
import 'package:vts_maps/api/SubmitVesselResponse.dart';

import '../utils/shared_pref.dart';
import 'DeleteClientResponse.dart';
import 'DeleteIpAndPortResponse.dart';
import 'DeletePipelineResponse.dart';
import 'DeleteVesselResponse.dart';
import 'EditPipelineResponse.dart';
import 'GetAllVesselCoor.dart';
import 'GetIpListResponse.dart';
import 'GetPipelineResponse.dart';
import 'UploadIpAndPortResponse.dart';

// const BASE_URL = "https://client-project.enricko.site/api";
const BASE_URL = "https://api.binav-avts.id/api";
// const BASE_URL = "http://127.0.0.1:8000/api";

class Api{

  static Future<GetAllVessel> getAllVessel({int page = 1,int perpage = 10,String call_sign = "",String id_client = ""}) async {
    var url = "$BASE_URL/kapal?page=$page&perpage=$perpage&call_sign=${call_sign}&id_client=${id_client}";
    var response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return GetAllVessel.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request all vessel:\n${response.body}";
  
  }
  static Future<GetAllVessel> getVessel({required String call_sign}) async {
    var url = "$BASE_URL/get_kapal?call_sign=$call_sign";
    var response = await http.get(
      Uri.parse(url),
    );
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
    if (response.statusCode == 200) {
      return GetAllLatLangCoor.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request all vessel:\n${response.body}";

  }
  static Future<GetAllVesselCoor> getAllVesselLatestCoor({int page = 1,int perpage = 100}) async {
    var url = "$BASE_URL/get_all_latest_coor?page=$page&perpage=$perpage";
    var response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return GetAllVesselCoor.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request all vessel:\n${response.body}";

  }
  static Future<SubmitVesselResponse>createVessel(Map<String,dynamic> data) async {
    // try{
    //   // var datatoken = await LoginPref.getPref();
    //   // var token = datatoken.token!;
    //   // request.headers["Content-type"] = 'application/xml';
    //   // request.headers["Authorization"] = 'Bearer $token';
    //   var url = "$BASE_URL/insert_kapal";
    //   var request = await http.MultipartRequest('post', Uri.parse(url));
    //   request.fields["call_sign"] = "ssodfk00";
    //   request.fields["flag"] = data[1];
    //   request.fields["class"] = data[2];
    //   request.fields["builder"] = data[3];
    //   request.fields["year_built"] = data[4];
    //   request.fields["ip"] = data[5];
    //   request.fields["port"] = data[6];
    //   request.fields["size"] = data[7];
    //   request.files
    //       .add(await http.MultipartFile.fromBytes(
    //       'xml_file',
    //       file.bytes!));
    //   var response = await request.send();
    //   // print(response.stream);
    //   var responseJson = await http.Response.fromStream(response);
    //   // print(response.statusCode);
    //
    //   if (response.statusCode == 200) {
    //     return SubmitVesselResponse.fromJson(jsonDecode(responseJson.body));
    //   }
    //   if (response.statusCode == 400) {
    //     return SubmitVesselResponse.fromJson(jsonDecode(responseJson.body));
    //   }
    //   else {
    //     throw "Gagal create vessel";
    //   }
    // }catch(e){
    //   print("error nya $e");
    //   rethrow;
    // }
    try{
      var url = "$BASE_URL/insert_kapal";
      // var datatoken = await LoginPref.getPref();
      // var token = datatoken.token!;
      var response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          // 'Content-type': 'application/json',
          // 'Authorization': 'Bearer $token',
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


  /// CRUD VESSEL
  static Future<SubmitVesselResponse> submitCreateVessel(List<String> data,bool onOff,html.File file) async {
    try{
      ///jangan di hapus
      // var datatoken = await LoginPref.getPref();
      // var token = datatoken.token!;
      // var url = "$BASE_URL/insert_kapal";
      // var request = await http.MultipartRequest('post', Uri.parse(url));
      final url = Uri.parse('$BASE_URL/insert_kapal');

      final formData = html.FormData();
      formData.appendBlob('xml_file', file);
      formData.append("id_client", data[0]);
      formData.append("call_sign", data[1]);
      formData.append("flag", data[2]);
      formData.append("class", data[3]);
      formData.append("builder", data[4]);
      formData.append("year_built", data[5]);
      formData.append("size", data[6]);
      formData.append("status", onOff ? "1" : "0");
      // formData.append("ip", data[5]);
      // formData.append("port", data[6]);


      final request = html.HttpRequest();
      request.open('POST', url.toString());
      request.send(formData);

      await request.onLoadEnd.first;
      if (request.status == 200) {
        print('statuscode 200,');
        return SubmitVesselResponse.fromJson(jsonDecode(request.responseText!));
      }
      if (request.status == 400) {
        print('statuscode 400,');
        return SubmitVesselResponse.fromJson(jsonDecode(request.responseText!));
      }
      else {
        throw "Gagal create vessel";
      }
    }catch(e){
      print("error nya $e");
      rethrow;
    }
  }

  static Future<GetKapalAndCoor> getKapalAndCoor({String call_sign = "",int page = 1,int perpage = 10})async{
    var url = "$BASE_URL/get_kapal_and_latest_coor?call_sign=$call_sign&page=$page&perpage=$perpage";
    var response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return GetKapalAndCoor.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request all vessel:\n${response.body}";
  }

  static Future<EditVesselResponse>editVessel(List<String> data,bool onOff,html.File? file) async {
    try{
      ///jangan di hapus
      // var datatoken = await LoginPref.getPref();
      // var token = datatoken.token!;
      // var url = "$BASE_URL/insert_kapal";
      // var request = await http.MultipartRequest('post', Uri.parse(url));
      final url = Uri.parse('$BASE_URL/update_kapal');

      final formData = html.FormData();
      if (file != null) {
        formData.appendBlob('xml_file', file);
      }
      formData.append("old_call_sign", data[0]);
      formData.append("call_sign", data[1]);
      formData.append("flag", data[2]);
      formData.append("class", data[3]);
      formData.append("builder", data[4]);
      formData.append("year_built", data[5]);
      formData.append("size", data[6]);
      formData.append("status", onOff ? "1" : "0");

      final request = html.HttpRequest();
      request.open('POST', url.toString());
      request.send(formData);

      await request.onLoadEnd.first;
      if (request.status == 200) {
        print('statuscode 200,');
        return EditVesselResponse.fromJson(jsonDecode(request.responseText!));
      }
      if (request.status == 400) {
        print('statuscode 400,');
        return EditVesselResponse.fromJson(jsonDecode(request.responseText!));
      }
      else {
        throw "Gagal create vessel";
      }
    }catch(e){
      print("error nya $e");
      rethrow;
    }
  }

  static Future<DeleteVesselResponse> deleteVessel(String callSign) async {
    var url = "$BASE_URL/delete_kapal/$callSign";
    var response = await http.post(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return DeleteVesselResponse.fromJson(jsonDecode(response.body));
    }
    throw "Gagal delete vessel:\n${response.body}";

  }

  /// CRUD IP AND PORT

  static Future<UploadIpAndPortResponse> uploadIP(Map <String,String> data) async {
    var url = "$BASE_URL/insert_kapal_ip";
    var response = await http.post(
      Uri.parse(url),
      body : data
    );
    if (response.statusCode == 200) {
      return UploadIpAndPortResponse.fromJson(jsonDecode(response.body));
    }
    throw "Gagal upload ip and port:\n${response.body}";

  }

  static Future<GetIpListResponse> getIpList(String callSign)async{
    var url = "$BASE_URL/get_kapal_ip?call_sign=$callSign";
    var response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return GetIpListResponse.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request ip list:\n${response.body}";
  }

  static Future<DeleteIpAndPortResponse> deleteIP(String id) async {
    var url = "$BASE_URL/delete_kapal_ip/$id";
    var response = await http.post(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return DeleteIpAndPortResponse.fromJson(jsonDecode(response.body));
    }
    throw "Gagal delete IP:\n${response.body}";

  }


  /// CRUD PIPELINE

  static Future<SubmitPipelineResponse> submitPipeline(String idClientValue,String name,bool onOff,html.File file) async {
    try{
      ///jangan di hapus
      // var datatoken = await LoginPref.getPref();
      // var token = datatoken.token!;
      // var url = "$BASE_URL/insert_kapal";
      // var request = await http.MultipartRequest('post', Uri.parse(url));
      final url = Uri.parse('$BASE_URL/insert_mapping');

      final formData = html.FormData();
      formData.appendBlob('file', file);
      formData.append("id_client", idClientValue);
      formData.append("name", name);
      formData.append("switch", onOff ? "1" : "0");

      final request = html.HttpRequest();
      request.open('POST', url.toString());
      request.send(formData);

      await request.onLoadEnd.first;
      if (request.status == 200) {
        print('statuscode 200,');
        return SubmitPipelineResponse.fromJson(jsonDecode(request.responseText!));
      }
      if (request.status == 400) {
        print('statuscode 400,');
        return SubmitPipelineResponse.fromJson(jsonDecode(request.responseText!));
      }
      else {
        throw "Gagal create pipeline";
      }
    }catch(e){
      print("error nya $e");
      rethrow;
    }
  }

  static Future<GetPipelineResponse> getPipeline({int page = 1,int perpage = 10})async{
    var url = "$BASE_URL/get_mapping?page=$page&perpage=$perpage";
    var response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return GetPipelineResponse.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request data pipeline:\n${response.body}";
  }

  static Future<EditPipelineResponse> editPipeline(String id,String name,bool onOff,html.File? file) async {
    try{
      ///jangan di hapus
      // var datatoken = await LoginPref.getPref();
      // var token = datatoken.token!;
      // var url = "$BASE_URL/insert_kapal";
      // var request = await http.MultipartRequest('post', Uri.parse(url));
      final url = Uri.parse('$BASE_URL/update_mapping');

      final formData = html.FormData();
      if (file != null) {
        formData.appendBlob('file', file);
      }
      formData.append("id_mapping", id);
      formData.append("name", name);
      formData.append("switch", onOff ? "1" : "0");

      final request = html.HttpRequest();
      request.open('POST', url.toString());
      request.send(formData);

      await request.onLoadEnd.first;
      if (request.status == 200) {
        print('statuscode 200,');
        return EditPipelineResponse.fromJson(jsonDecode(request.responseText!));
      }
      if (request.status == 400) {
        print('statuscode 400,');
        return EditPipelineResponse.fromJson(jsonDecode(request.responseText!));
      }
      else {
        throw "Gagal create vessel";
      }
    }catch(e){
      print("error nya $e");
      rethrow;
    }
  }

  static Future<DeletePipelineResponse> deletePipeline(String idMapping) async {
    var url = "$BASE_URL/delete_mapping/$idMapping";
    var response = await http.post(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return DeletePipelineResponse.fromJson(jsonDecode(response.body));
    }
    throw "Gagal delete pipeline:\n${response.body}";

  }

  /// CRUD CLIENT LIST
  static Future<GetClientResponse> getClientList({int page = 1,int perpage = 10})async{
    var url = "$BASE_URL/get_client?page=$page&perpage=$perpage";
    var response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return GetClientResponse.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request client list:\n${response.body}";
  }

  static Future<SubmitClientResponse>createClient(Map<String,String> data) async {
    try{
      var url = "$BASE_URL/insert_client";
      // var datatoken = await LoginPref.getPref();
      // var token = datatoken.token!;
      var response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          // 'Content-type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return SubmitClientResponse.fromJson(jsonDecode(response.body));
      }
      if (response.statusCode == 400) {
        return SubmitClientResponse.fromJson(jsonDecode(response.body));
      }
      else {
        throw "Gagal create Client:\n${response.body}";
      }
    }catch(e){
      print("error nya $e");
      rethrow;
    }
  }

  static Future<DeleteClientResponse> deleteClient(String id) async {
    var url = "$BASE_URL/delete_client/$id";
    var response = await http.post(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return DeleteClientResponse.fromJson(jsonDecode(response.body));
    }
    throw "Gagal delete vessel:\n${response.body}";

  }

  static Future<EditClientResponse> updateClient(Map <String,String> data ) async {
    var url = "$BASE_URL/update_client";
    var response = await http.post(
      Uri.parse(url),
      body: data
    );
    if (response.statusCode == 200) {
      return EditClientResponse.fromJson(jsonDecode(response.body));
    }
    throw "Gagal Update Data:\n${response.body}";

  }





}