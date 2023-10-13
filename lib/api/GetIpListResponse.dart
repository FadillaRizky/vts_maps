/// message : "Data Kapal Ditemukan"
/// status : 200
/// total : 5
/// kapal : {"call_sign":"YDBU07","id_client":"lHzJTM7oz1FhePXCfTEh","status":"1","flag":"Indonesia","class":"BKI","builder":"Batam","year_built":"2017","size":"small","xml_file":"2023_10_06_10_58_42_YDBU07.xml","created_at":"2023-10-06T10:58:43.000000Z","updated_at":"2023-10-11T01:05:50.000000Z"}
/// data : [{"id_ip_kapal":"3","call_sign":"YDBU07","type_ip":"all","ip":"103.157.117.229","port":"5019","created_at":"2023-10-08T09:32:50.000000Z","updated_at":"2023-10-08T09:32:50.000000Z"},{"id_ip_kapal":"4","call_sign":"YDBU07","type_ip":"all","ip":"103.157.117.229","port":"5018","created_at":"2023-10-11T03:47:09.000000Z","updated_at":"2023-10-11T03:47:09.000000Z"},{"id_ip_kapal":"5","call_sign":"YDBU07","type_ip":"all","ip":"103.157.117.229","port":"5018","created_at":"2023-10-11T07:51:18.000000Z","updated_at":"2023-10-11T07:51:18.000000Z"},{"id_ip_kapal":"6","call_sign":"YDBU07","type_ip":"all","ip":"103.157.117.229","port":"5018","created_at":"2023-10-11T16:29:06.000000Z","updated_at":"2023-10-11T16:29:06.000000Z"},{"id_ip_kapal":"7","call_sign":"YDBU07","type_ip":"all","ip":"123.123123.132.2","port":"5018","created_at":"2023-10-11T16:45:45.000000Z","updated_at":"2023-10-11T16:45:45.000000Z"}]

class GetIpListResponse {
  GetIpListResponse({
      String? message, 
      num? status, 
      num? total, 
      Kapal? kapal, 
      List<Data>? data,}){
    _message = message;
    _status = status;
    _total = total;
    _kapal = kapal;
    _data = data;
}

  GetIpListResponse.fromJson(dynamic json) {
    _message = json['message'];
    _status = json['status'];
    _total = json['total'];
    _kapal = json['kapal'] != null ? Kapal.fromJson(json['kapal']) : null;
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  String? _message;
  num? _status;
  num? _total;
  Kapal? _kapal;
  List<Data>? _data;
GetIpListResponse copyWith({  String? message,
  num? status,
  num? total,
  Kapal? kapal,
  List<Data>? data,
}) => GetIpListResponse(  message: message ?? _message,
  status: status ?? _status,
  total: total ?? _total,
  kapal: kapal ?? _kapal,
  data: data ?? _data,
);
  String? get message => _message;
  num? get status => _status;
  num? get total => _total;
  Kapal? get kapal => _kapal;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['status'] = _status;
    map['total'] = _total;
    if (_kapal != null) {
      map['kapal'] = _kapal?.toJson();
    }
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id_ip_kapal : "3"
/// call_sign : "YDBU07"
/// type_ip : "all"
/// ip : "103.157.117.229"
/// port : "5019"
/// created_at : "2023-10-08T09:32:50.000000Z"
/// updated_at : "2023-10-08T09:32:50.000000Z"

class Data {
  Data({
      String? idIpKapal, 
      String? callSign, 
      String? typeIp, 
      String? ip, 
      String? port, 
      String? createdAt, 
      String? updatedAt,}){
    _idIpKapal = idIpKapal;
    _callSign = callSign;
    _typeIp = typeIp;
    _ip = ip;
    _port = port;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Data.fromJson(dynamic json) {
    _idIpKapal = json['id_ip_kapal'];
    _callSign = json['call_sign'];
    _typeIp = json['type_ip'];
    _ip = json['ip'];
    _port = json['port'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  String? _idIpKapal;
  String? _callSign;
  String? _typeIp;
  String? _ip;
  String? _port;
  String? _createdAt;
  String? _updatedAt;
Data copyWith({  String? idIpKapal,
  String? callSign,
  String? typeIp,
  String? ip,
  String? port,
  String? createdAt,
  String? updatedAt,
}) => Data(  idIpKapal: idIpKapal ?? _idIpKapal,
  callSign: callSign ?? _callSign,
  typeIp: typeIp ?? _typeIp,
  ip: ip ?? _ip,
  port: port ?? _port,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get idIpKapal => _idIpKapal;
  String? get callSign => _callSign;
  String? get typeIp => _typeIp;
  String? get ip => _ip;
  String? get port => _port;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id_ip_kapal'] = _idIpKapal;
    map['call_sign'] = _callSign;
    map['type_ip'] = _typeIp;
    map['ip'] = _ip;
    map['port'] = _port;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}

/// call_sign : "YDBU07"
/// id_client : "lHzJTM7oz1FhePXCfTEh"
/// status : "1"
/// flag : "Indonesia"
/// class : "BKI"
/// builder : "Batam"
/// year_built : "2017"
/// size : "small"
/// xml_file : "2023_10_06_10_58_42_YDBU07.xml"
/// created_at : "2023-10-06T10:58:43.000000Z"
/// updated_at : "2023-10-11T01:05:50.000000Z"

class Kapal {
  Kapal({
      String? callSign, 
      String? idClient, 
      String? status, 
      String? flag, 
      String? kelas,
      String? builder, 
      String? yearBuilt, 
      String? size, 
      String? xmlFile, 
      String? createdAt, 
      String? updatedAt,}){
    _callSign = callSign;
    _idClient = idClient;
    _status = status;
    _flag = flag;
    _kelas = kelas;
    _builder = builder;
    _yearBuilt = yearBuilt;
    _size = size;
    _xmlFile = xmlFile;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Kapal.fromJson(dynamic json) {
    _callSign = json['call_sign'];
    _idClient = json['id_client'];
    _status = json['status'];
    _flag = json['flag'];
    _kelas = json['kelas'];
    _builder = json['builder'];
    _yearBuilt = json['year_built'];
    _size = json['size'];
    _xmlFile = json['xml_file'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  String? _callSign;
  String? _idClient;
  String? _status;
  String? _flag;
  String? _kelas;
  String? _builder;
  String? _yearBuilt;
  String? _size;
  String? _xmlFile;
  String? _createdAt;
  String? _updatedAt;
Kapal copyWith({  String? callSign,
  String? idClient,
  String? status,
  String? flag,
  String? kelas,
  String? builder,
  String? yearBuilt,
  String? size,
  String? xmlFile,
  String? createdAt,
  String? updatedAt,
}) => Kapal(  callSign: callSign ?? _callSign,
  idClient: idClient ?? _idClient,
  status: status ?? _status,
  flag: flag ?? _flag,
  kelas: kelas ?? _kelas,
  builder: builder ?? _builder,
  yearBuilt: yearBuilt ?? _yearBuilt,
  size: size ?? _size,
  xmlFile: xmlFile ?? _xmlFile,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get callSign => _callSign;
  String? get idClient => _idClient;
  String? get status => _status;
  String? get flag => _flag;
  String? get kelas => _kelas;
  String? get builder => _builder;
  String? get yearBuilt => _yearBuilt;
  String? get size => _size;
  String? get xmlFile => _xmlFile;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['call_sign'] = _callSign;
    map['id_client'] = _idClient;
    map['status'] = _status;
    map['flag'] = _flag;
    map['kelas'] = _kelas;
    map['builder'] = _builder;
    map['year_built'] = _yearBuilt;
    map['size'] = _size;
    map['xml_file'] = _xmlFile;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}