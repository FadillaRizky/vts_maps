/// message : "Data Mapping Ditemukan"
/// status : 200
/// perpage : 10
/// page : 1
/// total : 1
/// data : [{"id_mapping":"1","name":"123","file":"https://api.binav-avts.id/storage/mapping/2023_09_30_10_51_32_123_Pipa.kmz","on_off":false}]

class GetPipelineResponse {
  GetPipelineResponse({
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

  GetPipelineResponse.fromJson(dynamic json) {
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
GetPipelineResponse copyWith({  String? message,
  num? status,
  num? perpage,
  num? page,
  num? total,
  List<Data>? data,
}) => GetPipelineResponse(  message: message ?? _message,
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

/// id_mapping : "1"
/// name : "123"
/// file : "https://api.binav-avts.id/storage/mapping/2023_09_30_10_51_32_123_Pipa.kmz"
/// on_off : false

class Data {
  Data({
      String? idMapping, 
      String? name, 
      String? file, 
      bool? onOff,}){
    _idMapping = idMapping;
    _name = name;
    _file = file;
    _onOff = onOff;
}

  Data.fromJson(dynamic json) {
    _idMapping = json['id_mapping'];
    _name = json['name'];
    _file = json['file'];
    _onOff = json['on_off'];
  }
  String? _idMapping;
  String? _name;
  String? _file;
  bool? _onOff;
Data copyWith({  String? idMapping,
  String? name,
  String? file,
  bool? onOff,
}) => Data(  idMapping: idMapping ?? _idMapping,
  name: name ?? _name,
  file: file ?? _file,
  onOff: onOff ?? _onOff,
);
  String? get idMapping => _idMapping;
  String? get name => _name;
  String? get file => _file;
  bool? get onOff => _onOff;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id_mapping'] = _idMapping;
    map['name'] = _name;
    map['file'] = _file;
    map['on_off'] = _onOff;
    return map;
  }

}