/// message : "Data berhasil masuk database"
/// status : 200

class EditClientResponse {
  EditClientResponse({
      String? message, 
      num? status,}){
    _message = message;
    _status = status;
}

  EditClientResponse.fromJson(dynamic json) {
    _message = json['message'];
    _status = json['status'];
  }
  String? _message;
  num? _status;
EditClientResponse copyWith({  String? message,
  num? status,
}) => EditClientResponse(  message: message ?? _message,
  status: status ?? _status,
);
  String? get message => _message;
  num? get status => _status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['status'] = _status;
    return map;
  }

}