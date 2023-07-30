/// message : "Data Coor Kapal Ditemukan"
/// status : 200
/// perpage : 10
/// page : 1
/// total : 1
/// data : [{"id_coor":21,"call_sign":"YDBU2","series_id":1,"coor_hdt":{"id_coor_hdt":25,"heading_degree":123.456,"checksum":"T*00"},"coor_gga":{"id_coor_gga":24,"utc_position":172814,"latitude":37.391098,"direction_latitude":"N","longitude":-122.037826,"direction_longitude":"W","gps_quality_indicator":"Differential GPS fix (DGNSS), SBAS, OmniSTAR VBS, Beacon, RTX in GVBS mode","number_sv":6,"hdop":1.2,"orthometric_height":18.893,"unit_measure":"M","geoid_seperation":-25.669,"geoid_measure":"M"},"created_at":"2023-07-30T00:14:33.000000Z","updated_at":"2023-07-30T00:14:33.000000Z"}]

class GetAllVesselCoor {
  GetAllVesselCoor({
      String? message, 
      num? status, 
      num? perpage, 
      num? page, 
      num? total, 
      List<Data>? data,}){
    _message = message;
    _status = status;
    _perpage = perpage;
    _page = page;
    _total = total;
    _data = data;
}

  GetAllVesselCoor.fromJson(dynamic json) {
    _message = json['message'];
    _status = json['status'];
    _perpage = json['perpage'];
    _page = json['page'];
    _total = json['total'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  String? _message;
  num? _status;
  num? _perpage;
  num? _page;
  num? _total;
  List<Data>? _data;
GetAllVesselCoor copyWith({  String? message,
  num? status,
  num? perpage,
  num? page,
  num? total,
  List<Data>? data,
}) => GetAllVesselCoor(  message: message ?? _message,
  status: status ?? _status,
  perpage: perpage ?? _perpage,
  page: page ?? _page,
  total: total ?? _total,
  data: data ?? _data,
);
  String? get message => _message;
  num? get status => _status;
  num? get perpage => _perpage;
  num? get page => _page;
  num? get total => _total;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['status'] = _status;
    map['perpage'] = _perpage;
    map['page'] = _page;
    map['total'] = _total;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id_coor : 21
/// call_sign : "YDBU2"
/// series_id : 1
/// coor_hdt : {"id_coor_hdt":25,"heading_degree":123.456,"checksum":"T*00"}
/// coor_gga : {"id_coor_gga":24,"utc_position":172814,"latitude":37.391098,"direction_latitude":"N","longitude":-122.037826,"direction_longitude":"W","gps_quality_indicator":"Differential GPS fix (DGNSS), SBAS, OmniSTAR VBS, Beacon, RTX in GVBS mode","number_sv":6,"hdop":1.2,"orthometric_height":18.893,"unit_measure":"M","geoid_seperation":-25.669,"geoid_measure":"M"}
/// created_at : "2023-07-30T00:14:33.000000Z"
/// updated_at : "2023-07-30T00:14:33.000000Z"

class Data {
  Data({
      num? idCoor, 
      String? callSign, 
      num? seriesId, 
      CoorHdt? coorHdt, 
      CoorGga? coorGga, 
      String? createdAt, 
      String? updatedAt,}){
    _idCoor = idCoor;
    _callSign = callSign;
    _seriesId = seriesId;
    _coorHdt = coorHdt;
    _coorGga = coorGga;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Data.fromJson(dynamic json) {
    _idCoor = json['id_coor'];
    _callSign = json['call_sign'];
    _seriesId = json['series_id'];
    _coorHdt = json['coor_hdt'] != null ? CoorHdt.fromJson(json['coor_hdt']) : null;
    _coorGga = json['coor_gga'] != null ? CoorGga.fromJson(json['coor_gga']) : null;
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _idCoor;
  String? _callSign;
  num? _seriesId;
  CoorHdt? _coorHdt;
  CoorGga? _coorGga;
  String? _createdAt;
  String? _updatedAt;
Data copyWith({  num? idCoor,
  String? callSign,
  num? seriesId,
  CoorHdt? coorHdt,
  CoorGga? coorGga,
  String? createdAt,
  String? updatedAt,
}) => Data(  idCoor: idCoor ?? _idCoor,
  callSign: callSign ?? _callSign,
  seriesId: seriesId ?? _seriesId,
  coorHdt: coorHdt ?? _coorHdt,
  coorGga: coorGga ?? _coorGga,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get idCoor => _idCoor;
  String? get callSign => _callSign;
  num? get seriesId => _seriesId;
  CoorHdt? get coorHdt => _coorHdt;
  CoorGga? get coorGga => _coorGga;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id_coor'] = _idCoor;
    map['call_sign'] = _callSign;
    map['series_id'] = _seriesId;
    if (_coorHdt != null) {
      map['coor_hdt'] = _coorHdt?.toJson();
    }
    if (_coorGga != null) {
      map['coor_gga'] = _coorGga?.toJson();
    }
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}

/// id_coor_gga : 24
/// utc_position : 172814
/// latitude : 37.391098
/// direction_latitude : "N"
/// longitude : -122.037826
/// direction_longitude : "W"
/// gps_quality_indicator : "Differential GPS fix (DGNSS), SBAS, OmniSTAR VBS, Beacon, RTX in GVBS mode"
/// number_sv : 6
/// hdop : 1.2
/// orthometric_height : 18.893
/// unit_measure : "M"
/// geoid_seperation : -25.669
/// geoid_measure : "M"

class CoorGga {
  CoorGga({
      num? idCoorGga, 
      num? utcPosition, 
      num? latitude, 
      String? directionLatitude, 
      num? longitude, 
      String? directionLongitude, 
      String? gpsQualityIndicator, 
      num? numberSv, 
      num? hdop, 
      num? orthometricHeight, 
      String? unitMeasure, 
      num? geoidSeperation, 
      String? geoidMeasure,}){
    _idCoorGga = idCoorGga;
    _utcPosition = utcPosition;
    _latitude = latitude;
    _directionLatitude = directionLatitude;
    _longitude = longitude;
    _directionLongitude = directionLongitude;
    _gpsQualityIndicator = gpsQualityIndicator;
    _numberSv = numberSv;
    _hdop = hdop;
    _orthometricHeight = orthometricHeight;
    _unitMeasure = unitMeasure;
    _geoidSeperation = geoidSeperation;
    _geoidMeasure = geoidMeasure;
}

  CoorGga.fromJson(dynamic json) {
    _idCoorGga = json['id_coor_gga'];
    _utcPosition = json['utc_position'];
    _latitude = json['latitude'];
    _directionLatitude = json['direction_latitude'];
    _longitude = json['longitude'];
    _directionLongitude = json['direction_longitude'];
    _gpsQualityIndicator = json['gps_quality_indicator'];
    _numberSv = json['number_sv'];
    _hdop = json['hdop'];
    _orthometricHeight = json['orthometric_height'];
    _unitMeasure = json['unit_measure'];
    _geoidSeperation = json['geoid_seperation'];
    _geoidMeasure = json['geoid_measure'];
  }
  num? _idCoorGga;
  num? _utcPosition;
  num? _latitude;
  String? _directionLatitude;
  num? _longitude;
  String? _directionLongitude;
  String? _gpsQualityIndicator;
  num? _numberSv;
  num? _hdop;
  num? _orthometricHeight;
  String? _unitMeasure;
  num? _geoidSeperation;
  String? _geoidMeasure;
CoorGga copyWith({  num? idCoorGga,
  num? utcPosition,
  num? latitude,
  String? directionLatitude,
  num? longitude,
  String? directionLongitude,
  String? gpsQualityIndicator,
  num? numberSv,
  num? hdop,
  num? orthometricHeight,
  String? unitMeasure,
  num? geoidSeperation,
  String? geoidMeasure,
}) => CoorGga(  idCoorGga: idCoorGga ?? _idCoorGga,
  utcPosition: utcPosition ?? _utcPosition,
  latitude: latitude ?? _latitude,
  directionLatitude: directionLatitude ?? _directionLatitude,
  longitude: longitude ?? _longitude,
  directionLongitude: directionLongitude ?? _directionLongitude,
  gpsQualityIndicator: gpsQualityIndicator ?? _gpsQualityIndicator,
  numberSv: numberSv ?? _numberSv,
  hdop: hdop ?? _hdop,
  orthometricHeight: orthometricHeight ?? _orthometricHeight,
  unitMeasure: unitMeasure ?? _unitMeasure,
  geoidSeperation: geoidSeperation ?? _geoidSeperation,
  geoidMeasure: geoidMeasure ?? _geoidMeasure,
);
  num? get idCoorGga => _idCoorGga;
  num? get utcPosition => _utcPosition;
  num? get latitude => _latitude;
  String? get directionLatitude => _directionLatitude;
  num? get longitude => _longitude;
  String? get directionLongitude => _directionLongitude;
  String? get gpsQualityIndicator => _gpsQualityIndicator;
  num? get numberSv => _numberSv;
  num? get hdop => _hdop;
  num? get orthometricHeight => _orthometricHeight;
  String? get unitMeasure => _unitMeasure;
  num? get geoidSeperation => _geoidSeperation;
  String? get geoidMeasure => _geoidMeasure;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id_coor_gga'] = _idCoorGga;
    map['utc_position'] = _utcPosition;
    map['latitude'] = _latitude;
    map['direction_latitude'] = _directionLatitude;
    map['longitude'] = _longitude;
    map['direction_longitude'] = _directionLongitude;
    map['gps_quality_indicator'] = _gpsQualityIndicator;
    map['number_sv'] = _numberSv;
    map['hdop'] = _hdop;
    map['orthometric_height'] = _orthometricHeight;
    map['unit_measure'] = _unitMeasure;
    map['geoid_seperation'] = _geoidSeperation;
    map['geoid_measure'] = _geoidMeasure;
    return map;
  }

}

/// id_coor_hdt : 25
/// heading_degree : 123.456
/// checksum : "T*00"

class CoorHdt {
  CoorHdt({
      num? idCoorHdt, 
      num? headingDegree, 
      String? checksum,}){
    _idCoorHdt = idCoorHdt;
    _headingDegree = headingDegree;
    _checksum = checksum;
}

  CoorHdt.fromJson(dynamic json) {
    _idCoorHdt = json['id_coor_hdt'];
    _headingDegree = json['heading_degree'];
    _checksum = json['checksum'];
  }
  num? _idCoorHdt;
  num? _headingDegree;
  String? _checksum;
CoorHdt copyWith({  num? idCoorHdt,
  num? headingDegree,
  String? checksum,
}) => CoorHdt(  idCoorHdt: idCoorHdt ?? _idCoorHdt,
  headingDegree: headingDegree ?? _headingDegree,
  checksum: checksum ?? _checksum,
);
  num? get idCoorHdt => _idCoorHdt;
  num? get headingDegree => _headingDegree;
  String? get checksum => _checksum;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id_coor_hdt'] = _idCoorHdt;
    map['heading_degree'] = _headingDegree;
    map['checksum'] = _checksum;
    return map;
  }

}