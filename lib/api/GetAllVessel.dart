/// message : "Data Kapal Ditemukan"
/// status : 200
/// perpage : 10
/// page : 1
/// total : 3
/// data : [{"call_sign":"YDBU2","flag":"Indonesia","kelas":"BKI","builder":"Batam","year_built":"2016","created_at":null,"updated_at":null},{"call_sign":"YDBU3","flag":"Indonesia","kelas":"BKI","builder":"Batam","year_built":"2017","created_at":"2023-07-28T22:30:10.000000Z","updated_at":"2023-07-28T22:30:10.000000Z"},{"call_sign":"YDBU4","flag":"Indonesia","kelas":"BKI","builder":"Batam","year_built":"2017","created_at":"2023-07-28T22:30:59.000000Z","updated_at":"2023-07-28T22:30:59.000000Z"}]

class GetAllVessel {
  GetAllVessel({
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

  GetAllVessel.fromJson(dynamic json) {
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
GetAllVessel copyWith({  String? message,
  num? status,
  num? perpage,
  num? page,
  num? total,
  List<Data>? data,
}) => GetAllVessel(  message: message ?? _message,
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

/// call_sign : "YDBU2"
/// flag : "Indonesia"
/// kelas : "BKI"
/// builder : "Batam"
/// year_built : "2016"
/// created_at : null
/// updated_at : null

class Data {
  Data({
      String? callSign, 
      String? flag, 
      String? kelas, 
      String? builder, 
      String? yearBuilt, 
      dynamic createdAt, 
      dynamic updatedAt,}){
    _callSign = callSign;
    _flag = flag;
    _kelas = kelas;
    _builder = builder;
    _yearBuilt = yearBuilt;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Data.fromJson(dynamic json) {
    _callSign = json['call_sign'];
    _flag = json['flag'];
    _kelas = json['kelas'];
    _builder = json['builder'];
    _yearBuilt = json['year_built'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  String? _callSign;
  String? _flag;
  String? _kelas;
  String? _builder;
  String? _yearBuilt;
  dynamic _createdAt;
  dynamic _updatedAt;
Data copyWith({  String? callSign,
  String? flag,
  String? kelas,
  String? builder,
  String? yearBuilt,
  dynamic createdAt,
  dynamic updatedAt,
}) => Data(  callSign: callSign ?? _callSign,
  flag: flag ?? _flag,
  kelas: kelas ?? _kelas,
  builder: builder ?? _builder,
  yearBuilt: yearBuilt ?? _yearBuilt,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get callSign => _callSign;
  String? get flag => _flag;
  String? get kelas => _kelas;
  String? get builder => _builder;
  String? get yearBuilt => _yearBuilt;
  dynamic get createdAt => _createdAt;
  dynamic get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['call_sign'] = _callSign;
    map['flag'] = _flag;
    map['kelas'] = _kelas;
    map['builder'] = _builder;
    map['year_built'] = _yearBuilt;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}