import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:vts_maps/api/GetAllVesselCoor.dart' as LatestVesselCoor;
import 'package:vts_maps/api/GetAllLatLangCoor.dart' as LatLangCoor;
import 'package:vts_maps/api/GetAllVessel.dart' as Vessel;
import 'package:vts_maps/api/GetKapalAndCoor.dart' as VesselCoor;
import 'package:vts_maps/api/GetIpListResponse.dart' as IpList;
import 'package:vts_maps/api/GetPipelineResponse.dart' as Pipeline;
import 'package:vts_maps/api/GetClientListResponse.dart' as ClientResponse;
import 'package:vts_maps/api/LoginResponse.dart' as LoginResponse;
import 'package:vts_maps/api/api.dart';
import 'package:vts_maps/auth/Authentication.dart';
import 'package:vts_maps/auth/auth_check_response.dart';
import 'package:vts_maps/model/kml_model.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:vts_maps/utils/shared_pref.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:html' as html;

import 'package:http/http.dart' as http;

class Notifier extends ChangeNotifier {
  // === AUTH ===
  String _token = "";
  String get token => _token;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  LoginResponse.LoginResponse? _userAuth;
  LoginResponse.LoginResponse? get userAuth => _userAuth;

  void setAuth(String token, LoginResponse.LoginResponse dataLogin) {
    LoginPref.saveToSharedPref(
        token,
        dataLogin.user!.idUser.toString(),
        dataLogin.client!.idClient.toString(),
        dataLogin.user!.name.toString(),
        dataLogin.user!.email.toString(),
        dataLogin.user!.level.toString());
    _token = token;
    _userAuth = dataLogin;
    notifyListeners();
  }

  void authCheck(BuildContext context) async {
    await Auth.AuthCheck().then((value) async {
      final userPref = await LoginPref.getPref();
      if (value.message!.contains("Unauthenticated")) {
        if (userPref.level == "client") {
          context.go("/login-client/${userPref.idClient}");
        } else {
          context.go("/login");
        }
        _loggedIn = false;
        LoginPref.removePref();
        EasyLoading.showError("Renew your login session", dismissOnTap: true);
        _userAuth = null;
      } else {
        if (userPref.level == "client") {
          context.go("/client-map-view/${userPref.idClient}");
        } else {
          context.go("/");
        }
        _userAuth = value;
        _loggedIn = true;
        EasyLoading.showSuccess("Selamat Datang Kembali ${value.user!.name}");
      }
    });
    notifyListeners();
  }

  /// CRUD VESSEL
  List<VesselCoor.Data> _vesselCoorResult = [];
  List<VesselCoor.Data> get vesselCoorResult => _vesselCoorResult;

  int _totalIp = 0;
  int get totalIp => _totalIp;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _pageSize = 1;
  int get pageSize => _pageSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _totalVessel = 0;
  int get totalVessel => _totalVessel;

  void incrementPage(pageIndex) {
    _currentPage = pageIndex;
    notifyListeners();
  }

  void initVesselCoor() async {
    _isLoading = true;
    await Api.getKapalAndCoor().then((value) {
      _vesselCoorResult.clear();
      if (value.total! == 0) {
        _isLoading = false;
        _vesselCoorResult = [];
        _totalVessel = value.total!.toInt();
      }
      if (value.total! > 0) {
        _vesselCoorResult.addAll(value.data!);
        _isLoading = false;
        _totalVessel = value.total!.toInt();
      }
      print(value.data!.first.kapal!.callSign);
    });
    notifyListeners();
  }

  List<Vessel.Data> _vesselResult = [];
  List<Vessel.Data> get vesselResult => _vesselResult;

  void initVessel() async {
    _isLoading = true;
    await Api.getAllVessel(page: _currentPage).then((value) {
      _vesselResult.clear();
      if (value.total! == 0) {
        _isLoading = false;
        _vesselResult = [];
        _totalVessel = value.total!.toInt();
      }
      if (value.total! > 0) {
        _vesselResult.addAll(value.data!);
        _isLoading = false;
        _totalVessel = value.total!.toInt();
      }
      // print(value.data!.first.kapal!.callSign);
    });
    notifyListeners();
  }

  void submitVessel(data, context, onOff, file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "loading ..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
    await Api.submitCreateVessel(data, onOff, file).then((value) {
      if (value.message == "Validator Fails") {
        Navigator.pop(context);
        EasyLoading.showError("Call Sign sudah Terdaftar");
        return;
      }
      if (value.message == "Data berhasil masuk database") {
        Navigator.pop(context);
        EasyLoading.showSuccess("Berhasil Menambahkan Data");
        Navigator.pop(context);
        initVessel();
        initVesselCoor();
        return;
      }
      if (value.message != "Data berhasil masuk database") {
        Navigator.pop(context);
        EasyLoading.showError(
            "Gagal Menambahkan Kapal Karena : ${value.message}. Coba Lagi...");
        return;
      }
      return;
    });
    notifyListeners();
  }

  void editVessel(data, context, onOff, file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "loading ..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
    await Api.editVessel(data, onOff, file).then((value) {
      print(value.message);
      if (value.message != "Data berhasil di ubah database") {
        Navigator.pop(context);
        EasyLoading.showError("Gagal Edit Kapal");
      }
      if (value.message == "Data berhasil di ubah database") {
        Navigator.pop(context);
        EasyLoading.showSuccess("Berhasil Edit Kapal");
        Navigator.pop(context);
      }
      if (value.message == "Validator Fails") {
        Navigator.pop(context);
        EasyLoading.showError("Call Sign sudah digunakan");
        Navigator.pop(context);
      }
      return;
    });
    notifyListeners();
  }

  void deleteVessel(callSign, context) {
    Api.deleteVessel(callSign).then((value) {
      if (value.status == 200) {
        EasyLoading.showSuccess("Kapal Terhapus..");
        Navigator.pop(context);
        initVessel();
        initVesselCoor();
      } else {
        EasyLoading.showError("Gagal Menghapus Kapal..");
      }
    });
    notifyListeners();
  }

  /// CRUD IP
  List<IpList.Data> _ipPortResult = [];
  List<IpList.Data> get ipPortResult => _ipPortResult;

  void uploadIP(
      Map<String, String> data, BuildContext context, String callSign) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "loading ..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
    await Api.uploadIP(data).then((value) {
      if (value.message == "Data berhasil masuk database") {
        EasyLoading.showSuccess("Berhasil Menambahkan Data");
        Navigator.pop(context);
        return;
      }
      if (value.message != "Data berhasil masuk database") {
        EasyLoading.showError("Gagal Menambahkan Data, Coba Lagi...");
        return;
      }
      return;
    });
    notifyListeners();
  }

  bool _isLoadingIp = false;
  bool get isLoadingIp => _isLoadingIp;

  String? _type;
  String? get type => _type;

  void clearType() async {
    _type = null;
    notifyListeners();
  }

  void selectingType(String value) async {
    _type = value;
    notifyListeners();
  }

  void deleteIP(String id, callSign, context) {
    Api.deleteIP(id).then((value) {
      if (value.message == "Data berhasil di hapus database") {
        EasyLoading.showSuccess("Data Terhapus..");
        Navigator.pop(context);
      } else {
        EasyLoading.showError("Gagal Menghapus Data..");
      }
    });
    notifyListeners();
  }

  /// CRUD PIPELINE
  List<Pipeline.Data> _getPipelineResult = [];
  List<Pipeline.Data> get getPipelineResult => _getPipelineResult;

  int _totalPipeline = 0;
  int get totalPipeline => _totalPipeline;

  void initPipeline(BuildContext context) async {
    _isLoading = true;
    await Api.getPipeline().then((value) {
      _getPipelineResult.clear();
      if (value.total! == 0) {
        _isLoading = false;
        _getPipelineResult = [];
        _totalPipeline = value.total!.toInt();
      }
      if (value.total! > 0) {
        _getPipelineResult.addAll(value.data!);
        _isLoading = false;
        _totalPipeline = value.total!.toInt();
      }
    });
    loadKMZData(context, _getPipelineResult);
    notifyListeners();
  }

  void submitPipeline(
      String idClientValue, String name, bool onOff, context, file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "loading ..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
    await Api.submitPipeline(idClientValue, name, onOff, file).then((value) {
      print(value.message);
      // if (value.message == "Validator Fails") {
      //   Navigator.pop(context);
      //   EasyLoading.showError("Call Sign sudah Terdaftar");
      //   return;
      // }
      if (value.message == "Data berhasil masuk database") {
        Navigator.pop(context);
        EasyLoading.showSuccess("Berhasil Menambahkan Data");
        Navigator.pop(context);
        initPipeline(context);
        return;
      }
      if (value.message != "Data berhasil masuk database") {
        Navigator.pop(context);
        EasyLoading.showError("Gagal Menambahkan Data, Coba Lagi...");
        return;
      }
      return;
    });
    notifyListeners();
  }

  void deletePipeline(id, context) {
    Api.deletePipeline(id).then((value) {
      if (value.status == 200) {
        EasyLoading.showSuccess("Data Terhapus..");
        Navigator.pop(context);
        initPipeline(context);
      } else {
        EasyLoading.showError("Gagal Menghapus Data..");
      }
    });
    notifyListeners();
  }

  /// CRUD CLIENT
  List<ClientResponse.Data> _getClientResult = [];
  List<ClientResponse.Data> get getClientResult => _getClientResult;

  int _totalClient = 0;
  int get totalClient => _totalClient;

  bool _isSwitched = false;
  bool get isSwitched => _isSwitched;

  void switchControl(bool value){
    _isSwitched = value;
    notifyListeners();
  }

  void initClientList() async {
    _isLoading = true;
    await Api.getClientList().then((value) {
      _getClientResult.clear();
      if (value.total! == 0) {
        _isLoading = false;
        _getClientResult = [];
        _totalClient = value.total!.toInt();
      }
      if (value.total! > 0) {
        _getClientResult.addAll(value.data!);
        _isLoading = false;
        _totalClient = value.total!.toInt();
      }
    });
    notifyListeners();
  }

  void deleteClient(id, context) {
    Api.deleteClient(id).then((value) {
      if (value.message == "Data berhasil di hapus database") {
        EasyLoading.showSuccess("Data Terhapus..");
        Navigator.pop(context);
        initClientList();
        // if (value.status == 200) {
        //   EasyLoading.showSuccess("Data Terhapus..");
        //   Navigator.pop(context);
        //   initClientList();
      } else {
        EasyLoading.showError("Gagal Menghapus Data..");
      }
    });
    notifyListeners();
  }
  
  void sendEmailClient(idClient,context)async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "loading ..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
    Api.sendEmail(idClient).then((value) {
    if (value.message == "Success") {
      EasyLoading.showSuccess("Email Terkirim...");
      Navigator.pop(context);
    }else{
      EasyLoading.showError(
          "Gagal Mengirim Email..");
      Navigator.pop(context);
    }
    });
    
  }


/////////-----------------------------------------------------------------/////////////////
  List<LatLangCoor.Data> _latLangResult = [];
  List<LatLangCoor.Data> get latLangResult => _latLangResult;

  void initLatLangCoor({String? call_sign}) {
    Api.getAllLatLangCoor(call_sign: call_sign).then((value) {
      _latLangResult.clear();
      if (value.total! == 0) {
        _latLangResult = [];
      }
      if (value.total! > 0) {
        _latLangResult.addAll(value.data!);
      }
    });
    notifyListeners();
  }

  // === Vessel Function ===
  // String _onClickVessel = "";
  // String get onClickVessel => _onClickVessel;

  // VesselCoor.Data? _searchKapal;
  // VesselCoor.Data? get searchKapal => _searchKapal;

  // void clickVessel(String call_sign,context){
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CircularProgressIndicator(
  //               color: Colors.white,
  //             ),
  //             SizedBox(
  //               height: 20,
  //             ),
  //             Text(
  //               "loading ..",
  //               style: TextStyle(color: Colors.white, fontSize: 20),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //     try {
  //   Api.getKapalAndCoor(call_sign: call_sign).then((value){
  //       _searchKapal = null;
  //       // print(value.data!.first.kapal!.callSign);
  //       if (value.total! == 0) {
  //         _searchKapal = null;
  //         // Navigator.pop(context);
  //       }
  //       if (value.total! > 0) {
  //         _searchKapal = value.data!.first as VesselCoor.Data;
  //         // Navigator.pop(context);
  //         // vesselTotal = value.total!;
  //       }
  //   _onClickVessel = call_sign;
  //       Navigator.pop(context);
  //   });
  //     } catch (e) {
  //       print(e);
  //     }
  //   notifyListeners();
  // }

  // void removeClickedVessel(){
  //   _onClickVessel = "";
  //   _searchKapal = null;
  //   notifyListeners();
  // }

  int _predictMovementVessel = 0;
  int get predictMovementVessel => _predictMovementVessel;
  void initKalmanFilter() {
    _predictMovementVessel++;
    notifyListeners();
  }

  void resetKalmanFilter() {
    _predictMovementVessel = 0;
    notifyListeners();
  }

  // === Overlay Function ===

  List<List<KmlPolygon>> _kmlOverlayPolygons = [];
  List<List<KmlPolygon>> get kmlOverlayPolygons => _kmlOverlayPolygons;

  Future<void> loadKMZData(
      BuildContext context, List<Pipeline.Data> files) async {
    for (var data in files) {
      String file = data.file!;
      if (data.onOff == true) {
        // final response = await http.get(Uri.parse(data.file!),headers: {'Accept': 'application/xml'});
        final response = await http.get(Uri.parse(file));
        if (file.endsWith(".kmz")) {
          if (response.statusCode == 200) {
            final kmlData = Constants.extractKMLDataFromKMZ(response.bodyBytes);
            if (kmlData != null) {
              _kmlOverlayPolygons.add(parseKmlForOverlay(kmzData: kmlData));
            }
          } else {
            throw Exception('Failed to load KMZ data: ${response.statusCode}');
          }
        } else if (file.endsWith(".kml")) {
          _kmlOverlayPolygons.add(parseKmlForOverlay(kmlData: response.body));
        }
      }
    }
    notifyListeners();
  }

  // Future<String> loadKmlFromFile(String filePath,BuildContext context) async {
  //   return await DefaultAssetBundle.of(context).loadString(filePath);
  // }

  List<KmlPolygon> parseKmlForOverlay({List<int>? kmzData, String? kmlData}) {
    final List<KmlPolygon> polygons = [];
    XmlDocument? doc;

    if (kmzData != null) {
      doc = XmlDocument.parse(utf8.decode(kmzData));
    } else if (kmlData != null) {
      doc = XmlDocument.parse(kmlData);
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

  /// UTILS
  html.File? _file;
  html.File? get file => _file;

  String? _nameFile = "";
  String? get nameFile => _nameFile;

  void selectFile(String Type) async {
    final input = html.FileUploadInputElement()
      ..accept = (Type == "XML")
          ? 'application/xml, text/xml'
          : (Type == "KMZ")
              ? '.kml,.kmz'
              : '*/*';
    input.click();
    input.onChange.listen((e) {
      final file = input.files?.first;
      if (file != null) {
        _file = file;
        _nameFile = file.name;
      }
    });
    notifyListeners();
  }

  void clearFile() {
    _file = null;
    _nameFile = "";
    notifyListeners();
  }

  num? _currentZoom = 15;
  num? get currentZoom => _currentZoom;

  void changeZoom(num zoom) {
    _currentZoom = zoom;
    // print(zoom);
    notifyListeners();
  }

  String? _vesselClick = "";
  String? get vesselClick => _vesselClick;

  VesselCoor.Data? _searchKapal;
  VesselCoor.Data? get searchKapal => _searchKapal;

  void vesselClicked(String call_sign, context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "loading ..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
    try {
      Api.getKapalAndCoor(call_sign: call_sign).then((value) {
        _searchKapal = null;
        if (value.total! == 0) {
          _searchKapal = null;
        }
        if (value.total! > 0) {
          _searchKapal = value.data!.first as VesselCoor.Data;
        }
        _vesselClick = call_sign;
        Navigator.pop(context);
      });
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  void removeVesselClicked() {
    _vesselClick = "";
    notifyListeners();
  }
}
