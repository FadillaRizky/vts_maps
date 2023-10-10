/// message : "Data Client Ditemukan"
/// status : 200
/// perpage : 10
/// page : 1
/// total : 2
/// data : [{"id_client":"2WIxyHGRNQVmcsH1rutH","client_name":"Ilham","email":"ilham123@gmail.com","status":"1","created_at":"2023-10-07T13:02:01.000000Z","updated_at":"2023-10-07T13:02:01.000000Z"},{"id_client":"lHzJTM7oz1FhePXCfTEh","client_name":"Ilham","email":"ilham@gmail.com","status":"1","created_at":"2023-10-01T13:10:24.000000Z","updated_at":"2023-10-01T13:10:24.000000Z"}]

class GetClientResponse {
  GetClientResponse({
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

  GetClientResponse.fromJson(dynamic json) {
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
GetClientResponse copyWith({  String? message,
  num? status,
  num? perpage,
  num? page,
  num? total,
  List<Data>? data,
}) => GetClientResponse(  message: message ?? _message,
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

/// id_client : "2WIxyHGRNQVmcsH1rutH"
/// client_name : "Ilham"
/// email : "ilham123@gmail.com"
/// status : "1"
/// created_at : "2023-10-07T13:02:01.000000Z"
/// updated_at : "2023-10-07T13:02:01.000000Z"

class Data {
  Data({
      String? idClient, 
      String? clientName, 
      String? email, 
      String? status, 
      String? createdAt, 
      String? updatedAt,}){
    _idClient = idClient;
    _clientName = clientName;
    _email = email;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Data.fromJson(dynamic json) {
    _idClient = json['id_client'];
    _clientName = json['client_name'];
    _email = json['email'];
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  String? _idClient;
  String? _clientName;
  String? _email;
  String? _status;
  String? _createdAt;
  String? _updatedAt;
Data copyWith({  String? idClient,
  String? clientName,
  String? email,
  String? status,
  String? createdAt,
  String? updatedAt,
}) => Data(  idClient: idClient ?? _idClient,
  clientName: clientName ?? _clientName,
  email: email ?? _email,
  status: status ?? _status,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get idClient => _idClient;
  String? get clientName => _clientName;
  String? get email => _email;
  String? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id_client'] = _idClient;
    map['client_name'] = _clientName;
    map['email'] = _email;
    map['status'] = _status;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}