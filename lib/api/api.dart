
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vts_maps/api/GetAllVessel.dart';

const BASE_URL = "client-project.enricko.site";
class Api{

  static Future<GetAllVessel> getAllVessel() async {
    var url = "http://client-project.enricko.site/api/kapal";
    var response = await http.get(
      Uri.parse(url),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return GetAllVessel.fromJson(jsonDecode(response.body));
    }
    //jika tidak,muncul pesan error
    throw "Gagal request all vessel:\n${response.body}";

  }

}