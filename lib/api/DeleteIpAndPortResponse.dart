/// message : "Data berhasil di hapus database"

class DeleteIpAndPortResponse {
  DeleteIpAndPortResponse({
      String? message,}){
    _message = message;
}

  DeleteIpAndPortResponse.fromJson(dynamic json) {
    _message = json['message'];
  }
  String? _message;
DeleteIpAndPortResponse copyWith({  String? message,
}) => DeleteIpAndPortResponse(  message: message ?? _message,
);
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    return map;
  }

}