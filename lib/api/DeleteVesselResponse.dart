/// message : "Data berhasil di hapus database"
/// status : 200

class DeleteVesselResponse {
  DeleteVesselResponse({
      String? message, 
      num? status,}){
    _message = message;
    _status = status;
}

  DeleteVesselResponse.fromJson(dynamic json) {
    _message = json['message'];
    _status = json['status'];
  }
  String? _message;
  num? _status;
DeleteVesselResponse copyWith({  String? message,
  num? status,
}) => DeleteVesselResponse(  message: message ?? _message,
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