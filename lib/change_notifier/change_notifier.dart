import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:latlong2/latlong.dart';

import 'package:vts_maps/api/GetAllVesselCoor.dart' as LatestVesselCoor;
import 'package:vts_maps/api/GetAllLatLangCoor.dart' as LatLangCoor;
import 'package:vts_maps/api/GetAllVessel.dart' as Vessel;
import 'package:vts_maps/api/GetKapalAndCoor.dart' as VesselCoor;
import 'package:vts_maps/api/api.dart';
import 'package:vts_maps/model/kml_model.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:vts_maps/utils/shared_pref.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml.dart' as xml;

class Notifier extends ChangeNotifier {

  // === AUTH ===
  String _token = "";
  String get token => _token;

  void setAuth(String token){
    LoginPref.saveToSharedPref(token);
    _token = token;
    notifyListeners();
  }

  // === API ===

  List<VesselCoor.Data> _vesselCoorResult = [];
  List<VesselCoor.Data> get vesselCoorResult => _vesselCoorResult;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  
  int _pageSize = 1;
  int get pageSize => _pageSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _totalVessel = 0;
  int get totalVessel => _totalVessel;

  void incrementPage(pageIndex){
    _currentPage = pageIndex;
    notifyListeners();
  }
  void initVesselCoor() {
    _isLoading = true;
    Api.getKapalAndCoor().then((value){
      _vesselCoorResult.clear();
      if (value.total! == 0) {
        _isLoading = false;
        _vesselCoorResult = [];
        _totalVessel = value.total!;
      }
      if (value.total! > 0) {
        _vesselCoorResult.addAll(value.data!);
        _isLoading = false;
        _totalVessel = value.total!;
      }
      print(value.data!.first.kapal!.callSign);
    });
    notifyListeners();
  }


  // List<Vessel.Data> _vesselResult = [];
  // List<Vessel.Data> get vesselResult => _vesselResult;

  // bool _loading = false;
  // bool get loading => _loading;
  
  // void initVessel() {
  //   Api.getAllVessel().then((value) {
  //   _vesselResult.clear();
  //     if (value.total! == 0) {
  //       _vesselResult = [];
  //     }
  //     if (value.total! > 0) {
  //       _vesselResult.addAll(value.data!);
  //       // vesselTotal = value.total!;
  //     }
  //     print(value.data!.first.callSign);
  //   });
  //   notifyListeners();
  // }

  void submitVessel(data,context){
     Api.createVessel(data).then((value) {
      if (value.message != "Data berhasil masuk database") {
        EasyLoading.showError("Gagal Menambahkan Kapal");
      }
      if (value.message == "Data berhasil masuk database") {
        EasyLoading.showSuccess("Berhasil Menambahkan Kapal");
        initVesselCoor();
        Navigator.pop(context);
      }
      if (value.message == "Validator Fails") {
        EasyLoading.showError("Call Sign sudah terdaftar");
        Navigator.pop(context);
      }
      return;
    });
     notifyListeners();
  }

  void deleteVessel(callSign,context,pageSize){
    Api.deleteVessel(callSign).then((value) {
          if (value.status == 200) {
            EasyLoading.showSuccess("Kapal Terhapus..");
            initVesselCoor();
            Navigator.pop(context);
          } else {
            EasyLoading.showError(
                "Gagal Menghapus Kapal..");
          }
        });
    notifyListeners();
  }

  void editVessel(data,pageSize,context){
    Api.editVessel(data).then((value) {
      if (value.message != "Data berhasil di ubah database") {
        EasyLoading.showError("Gagal Edit Kapal");
      }
      if (value.message == "Data berhasil di ubah database") {
        EasyLoading.showSuccess("Berhasil Edit Kapal");
        initVesselCoor();
        Navigator.pop(context);
      }
      if (value.message == "Validator Fails") {
        EasyLoading.showError("Call Sign tidak ditemukan");
        Navigator.pop(context);
      }
      return;
    });
    notifyListeners();
  }

  // List<LatestVesselCoor.Data> _coorResult = [];
  // List<LatestVesselCoor.Data> get coorResult => _coorResult;

  // void initCoorVessel() {
  //   Api.getAllVesselLatestCoor().then((value) {
  //     _coorResult.clear();
  //     if (value.total! == 0) {
  //       _coorResult = [];
  //     }
  //     if (value.total! > 0) {
  //       _coorResult.addAll(value.data!);
  //     }
  //   });
  //   notifyListeners();
  // }

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
  String _onClickVessel = "";
  String get onClickVessel => _onClickVessel;

  VesselCoor.Data? _searchKapal; 
  VesselCoor.Data? get searchKapal => _searchKapal; 

  void clickVessel(String call_sign){
      try {
    Api.getKapalAndCoor(call_sign: call_sign).then((value){
        _searchKapal = null;
        // print(value.data!.first.kapal!.callSign);
        if (value.total! == 0) {
          _searchKapal = null;
        }
        if (value.total! > 0) {
          _searchKapal = value.data!.first as VesselCoor.Data;
          // vesselTotal = value.total!;
        }
    _onClickVessel = call_sign;
    });
      } catch (e) {
        print(e); 
      }
    notifyListeners();
  }

  void removeClickedVessel(){
    _onClickVessel = "";
    _searchKapal = null;
    notifyListeners();
  }

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

  Future<void> loadKMZData(BuildContext context) async {
    List files = [
      "assets/kml/Pipa.kmz",
      "assets/kml/format_pipa.kml",
    ];
    for (var file in files) {
      if (file.endsWith(".kmz")) {
        final ByteData data = await rootBundle.load(file);
        final List<int> bytes = data.buffer.asUint8List();
        final kmlData = Constants.extractKMLDataFromKMZ(bytes);
        if (kmlData != null) {
          _kmlOverlayPolygons.add(parseKmlForOverlay(kmzData: kmlData));
        }
      } else if (file.endsWith(".kml")) {
        final String kmlData = await loadKmlFromFile(file,context);
        _kmlOverlayPolygons.add(parseKmlForOverlay(kmlData: kmlData));
      }
    }
    notifyListeners();
  }

  Future<String> loadKmlFromFile(String filePath,BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString(filePath);
  }

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

}