import 'package:flutter/material.dart';

import 'package:vts_maps/api/GetAllVesselCoor.dart' as LatestVesselCoor;
import 'package:vts_maps/api/GetAllLatLangCoor.dart' as LatLangCoor;
import 'package:vts_maps/api/GetAllVessel.dart' as Vessel;
import 'package:vts_maps/api/api.dart';

class Notifier extends ChangeNotifier {

  List<Vessel.Data> _vesselResult = [];
  List<Vessel.Data> get vesselResult => _vesselResult;
  
  void initVessel() {
    Api.getAllVessel().then((value) {
    _vesselResult.clear();
      if (value.total! == 0) {
        _vesselResult = [];
      }
      if (value.total! > 0) {
        _vesselResult.addAll(value.data!);
        // vesselTotal = value.total!;
      }
    });
    notifyListeners();
  }
  List<LatestVesselCoor.Data> _coorResult = [];
  List<LatestVesselCoor.Data> get coorResult => _coorResult;

  void initCoorVessel() {
    Api.getAllVesselLatestCoor().then((value) {
      _coorResult.clear();
      if (value.total! == 0) {
        _coorResult = [];
      }
      if (value.total! > 0) {
        _coorResult.addAll(value.data!);
      }
    });
    notifyListeners();
  }

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
        print(_latLangResult.where((e) => e.callSign == call_sign).length);
      }
    });
    notifyListeners();
  }
  
  String _onClickVessel = "";
  String get onClickVessel => _onClickVessel;

  void clickVessel(String call_sign){
    _onClickVessel = call_sign;
    notifyListeners();
  }
  int _predictMovementVessel = 0;
  int get predictMovementVessel => _predictMovementVessel;
  void initKalmanFilter() {
    _predictMovementVessel++;
  }
  void resetKalmanFilter() {
    _predictMovementVessel = 0;
  }

}