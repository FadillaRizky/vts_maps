
class GetIpListResponse {
  String? message;
  int? status;
  int? total;
  Kapal? kapal;
  List<Data>? data;

  GetIpListResponse({this.message, this.status, this.total, this.kapal, this.data});

  GetIpListResponse.fromJson(Map<String, dynamic> json) {
    if(json["message"] is String) {
      message = json["message"];
    }
    if(json["status"] is int) {
      status = json["status"];
    }
    if(json["total"] is int) {
      total = json["total"];
    }
    if(json["kapal"] is Map) {
      kapal = json["kapal"] == null ? null : Kapal.fromJson(json["kapal"]);
    }
    if(json["data"] is List) {
      data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["message"] = message;
    _data["status"] = status;
    _data["total"] = total;
    if(kapal != null) {
      _data["kapal"] = kapal?.toJson();
    }
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Data {
  String? idIpKapal;
  String? callSign;
  String? typeIp;
  String? ip;
  String? port;
  String? createdAt;
  String? updatedAt;

  Data({this.idIpKapal, this.callSign, this.typeIp, this.ip, this.port, this.createdAt, this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    if(json["id_ip_kapal"] is String) {
      idIpKapal = json["id_ip_kapal"];
    }
    if(json["call_sign"] is String) {
      callSign = json["call_sign"];
    }
    if(json["type_ip"] is String) {
      typeIp = json["type_ip"];
    }
    if(json["ip"] is String) {
      ip = json["ip"];
    }
    if(json["port"] is String) {
      port = json["port"];
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
    _data["id_ip_kapal"] = idIpKapal;
    _data["call_sign"] = callSign;
    _data["type_ip"] = typeIp;
    _data["ip"] = ip;
    _data["port"] = port;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}

class Kapal {
  String? callSign;
  String? idClient;
  String? status;
  String? flag;
  String? kelas;
  String? builder;
  String? yearBuilt;
  String? size;
  String? xmlFile;
  String? createdAt;
  String? updatedAt;

  Kapal({this.callSign, this.idClient, this.status, this.flag, this.kelas, this.builder, this.yearBuilt, this.size, this.xmlFile, this.createdAt, this.updatedAt});

  Kapal.fromJson(Map<String, dynamic> json) {
    if(json["call_sign"] is String) {
      callSign = json["call_sign"];
    }
    if(json["id_client"] is String) {
      idClient = json["id_client"];
    }
    if(json["status"] is String) {
      status = json["status"];
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
    if(json["year_built"] is String) {
      yearBuilt = json["year_built"];
    }
    if(json["size"] is String) {
      size = json["size"];
    }
    if(json["xml_file"] is String) {
      xmlFile = json["xml_file"];
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
    _data["id_client"] = idClient;
    _data["status"] = status;
    _data["flag"] = flag;
    _data["kelas"] = kelas;
    _data["builder"] = builder;
    _data["year_built"] = yearBuilt;
    _data["size"] = size;
    _data["xml_file"] = xmlFile;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}