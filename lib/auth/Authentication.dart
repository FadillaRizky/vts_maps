import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vts_maps/api/LoginResponse.dart';

import '../utils/shared_pref.dart';
import 'auth_check_response.dart';

// const BASE_URL = "https://client-project.enricko.site/api";
const BASE_URL = "https://api.binav-avts.id/api";
// const BASE_URL = "http://127.0.0.1:8000/api";

class Auth {
  static Future<LoginResponse> Login(Map<String, String> data) async {
    try {
      var url = "$BASE_URL/login";
      var response = await http.post(
        Uri.parse(url),
        body: data,
      );
      if (response.statusCode == 200) {
        return LoginResponse.fromJson(jsonDecode(response.body));
      }

      return LoginResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("error nya $e");
      rethrow;
    }
  }

  static Future<LoginResponse> AuthCheck() async {
    try {
      var url = "$BASE_URL/user";
      var dataPref = await LoginPref.getPref();
      print(dataPref.token);
      var response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${dataPref.token}"
        },
      );
      if (response.statusCode == 200) {
        return LoginResponse.fromJson(jsonDecode(response.body));
      }
      return LoginResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      print("error nya $e");
      rethrow;
    }
  }
}
