/// message : "Success"
/// data : {"email":"fadillarizky294@gmail.com","id_client":"lHzJTM7oz1FhePXCfTEh"}

class SendEmailResponse {
  SendEmailResponse({
      String? message, 
      Data? data,}){
    _message = message;
    _data = data;
}

  SendEmailResponse.fromJson(dynamic json) {
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? _message;
  Data? _data;
SendEmailResponse copyWith({  String? message,
  Data? data,
}) => SendEmailResponse(  message: message ?? _message,
  data: data ?? _data,
);
  String? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// email : "fadillarizky294@gmail.com"
/// id_client : "lHzJTM7oz1FhePXCfTEh"

class Data {
  Data({
      String? email, 
      String? idClient,}){
    _email = email;
    _idClient = idClient;
}

  Data.fromJson(dynamic json) {
    _email = json['email'];
    _idClient = json['id_client'];
  }
  String? _email;
  String? _idClient;
Data copyWith({  String? email,
  String? idClient,
}) => Data(  email: email ?? _email,
  idClient: idClient ?? _idClient,
);
  String? get email => _email;
  String? get idClient => _idClient;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['email'] = _email;
    map['id_client'] = _idClient;
    return map;
  }

}