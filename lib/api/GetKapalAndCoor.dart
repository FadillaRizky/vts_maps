class GetKapalAndCoor {
  String? message;
  int? status;
  int? perpage;
  int? page;
  int? total;
  List<Data>? data;

  GetKapalAndCoor({this.message, this.status, this.perpage, this.page, this.total, this.data});

  GetKapalAndCoor.fromJson(Map<String, dynamic> json) {
    if(json["message"] is String) {
      message = json["message"];
    }
    if(json["status"] is int) {
      status = json["status"];
    }
    if(json["perpage"] is int) {
      perpage = json["perpage"];
    }
    if(json["page"] is int) {
      page = json["page"];
    }
    if(json["total"] is int) {
      total = json["total"];
    }
    if(json["data"] is List) {
      data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["message"] = message;
    _data["status"] = status;
    _data["perpage"] = perpage;
    _data["page"] = page;
    _data["total"] = total;
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Data {
  Kapal? kapal;
  Coor? coor;

  Data({this.kapal, this.coor});

  Data.fromJson(Map<String, dynamic> json) {
    if(json["kapal"] is Map) {
      kapal = json["kapal"] == null ? null : Kapal.fromJson(json["kapal"]);
    }
    if(json["coor"] is Map) {
      coor = json["coor"] == null ? null : Coor.fromJson(json["coor"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(kapal != null) {
      _data["kapal"] = kapal?.toJson();
    }
    if(coor != null) {
      _data["coor"] = coor?.toJson();
    }
    return _data;
  }
}

class Coor {
  int? idCoor;
  String? callSign;
  int? seriesId;
  double? defaultHeading;
  CoorHdt? coorHdt;
  CoorGga? coorGga;
  String? createdAt;
  dynamic updatedAt;

  Coor({this.idCoor, this.callSign, this.seriesId, this.defaultHeading, this.coorHdt, this.coorGga, this.createdAt, this.updatedAt});

  Coor.fromJson(Map<String, dynamic> json) {
    if(json["id_coor"] is int) {
      idCoor = json["id_coor"];
    }
    if(json["call_sign"] is String) {
      callSign = json["call_sign"];
    }
    if(json["series_id"] is int) {
      seriesId = json["series_id"];
    }
    if(json["default_heading"] is double) {
      defaultHeading = json["default_heading"];
    }
    if(json["coor_hdt"] is Map) {
      coorHdt = json["coor_hdt"] == null ? null : CoorHdt.fromJson(json["coor_hdt"]);
    }
    if(json["coor_gga"] is Map) {
      coorGga = json["coor_gga"] == null ? null : CoorGga.fromJson(json["coor_gga"]);
    }
    if(json["created_at"] is String) {
      createdAt = json["created_at"];
    }
    updatedAt = json["updated_at"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id_coor"] = idCoor;
    _data["call_sign"] = callSign;
    _data["series_id"] = seriesId;
    _data["default_heading"] = defaultHeading;
    if(coorHdt != null) {
      _data["coor_hdt"] = coorHdt?.toJson();
    }
    if(coorGga != null) {
      _data["coor_gga"] = coorGga?.toJson();
    }
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}

class CoorGga {
  int? idCoorGga;
  double? utcPosition;
  double? latitude;
  String? directionLatitude;
  double? longitude;
  String? directionLongitude;
  String? gpsQualityIndicator;
  int? numberSv;
  double? hdop;
  double? orthometricHeight;
  String? unitMeasure;
  double? geoidSeperation;
  String? geoidMeasure;

  CoorGga({this.idCoorGga, this.utcPosition, this.latitude, this.directionLatitude, this.longitude, this.directionLongitude, this.gpsQualityIndicator, this.numberSv, this.hdop, this.orthometricHeight, this.unitMeasure, this.geoidSeperation, this.geoidMeasure});

  CoorGga.fromJson(Map<String, dynamic> json) {
    if(json["id_coor_gga"] is int) {
      idCoorGga = json["id_coor_gga"];
    }
    if(json["utc_position"] is double) {
      utcPosition = json["utc_position"];
    }
    if(json["latitude"] is double) {
      latitude = json["latitude"];
    }
    if(json["direction_latitude"] is String) {
      directionLatitude = json["direction_latitude"];
    }
    if(json["longitude"] is double) {
      longitude = json["longitude"];
    }
    if(json["direction_longitude"] is String) {
      directionLongitude = json["direction_longitude"];
    }
    if(json["gps_quality_indicator"] is String) {
      gpsQualityIndicator = json["gps_quality_indicator"];
    }
    if(json["number_sv"] is int) {
      numberSv = json["number_sv"];
    }
    if(json["hdop"] is double) {
      hdop = json["hdop"];
    }
    if(json["orthometric_height"] is double) {
      orthometricHeight = json["orthometric_height"];
    }
    if(json["unit_measure"] is String) {
      unitMeasure = json["unit_measure"];
    }
    if(json["geoid_seperation"] is double) {
      geoidSeperation = json["geoid_seperation"];
    }
    if(json["geoid_measure"] is String) {
      geoidMeasure = json["geoid_measure"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id_coor_gga"] = idCoorGga;
    _data["utc_position"] = utcPosition;
    _data["latitude"] = latitude;
    _data["direction_latitude"] = directionLatitude;
    _data["longitude"] = longitude;
    _data["direction_longitude"] = directionLongitude;
    _data["gps_quality_indicator"] = gpsQualityIndicator;
    _data["number_sv"] = numberSv;
    _data["hdop"] = hdop;
    _data["orthometric_height"] = orthometricHeight;
    _data["unit_measure"] = unitMeasure;
    _data["geoid_seperation"] = geoidSeperation;
    _data["geoid_measure"] = geoidMeasure;
    return _data;
  }
}

class CoorHdt {
  int? idCoorHdt;
  double? headingDegree;
  String? checksum;

  CoorHdt({this.idCoorHdt, this.headingDegree, this.checksum});

  CoorHdt.fromJson(Map<String, dynamic> json) {
    if(json["id_coor_hdt"] is int) {
      idCoorHdt = json["id_coor_hdt"];
    }
    if(json["heading_degree"] is double) {
      headingDegree = json["heading_degree"];
    }
    if(json["checksum"] is String) {
      checksum = json["checksum"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id_coor_hdt"] = idCoorHdt;
    _data["heading_degree"] = headingDegree;
    _data["checksum"] = checksum;
    return _data;
  }
}

class Kapal {
  String? callSign;
  String? flag;
  String? kelas;
  String? builder;
  String? size;
  String? ip;
  String? port;
  String? xmlFile;
  String? yearBuilt;
  String? createdAt;
  String? updatedAt;

  Kapal({this.callSign, this.flag, this.kelas, this.builder, this.size, this.ip, this.port, this.xmlFile, this.yearBuilt, this.createdAt, this.updatedAt});

  Kapal.fromJson(Map<String, dynamic> json) {
    if(json["call_sign"] is String) {
      callSign = json["call_sign"];
    }
    if(json["flag"] is String) {
      flag = json["flag"];
    }
    if(json["kelas"] is String) {
      kelas = json["kelas"];
    }
    if(json["builder"] is String) {
      builder = json["builder"];
    }
    if(json["size"] is String) {
      size = json["size"];
    }
    if(json["ip"] is String) {
      ip = json["ip"];
    }
    if(json["port"] is String) {
      port = json["port"];
    }
    if(json["xml_file"] is String) {
      xmlFile = json["xml_file"];
    }
    if(json["year_built"] is String) {
      yearBuilt = json["year_built"];
    }
    if(json["created_at"] is String) {
      createdAt = json["created_at"];
    }
    if(json["updated_at"] is String) {
      updatedAt = json["updated_at"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["call_sign"] = callSign;
    _data["flag"] = flag;
    _data["kelas"] = kelas;
    _data["builder"] = builder;
    _data["size"] = size;
    _data["ip"] = ip;
    _data["port"] = port;
    _data["xml_file"] = xmlFile;
    _data["year_built"] = yearBuilt;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}