/// message : "Data berhasil di hapus database"

class DeleteClientResponse {
  DeleteClientResponse({
      String? message,}){
    _message = message;
}

  DeleteClientResponse.fromJson(dynamic json) {
    _message = json['message'];
  }
  String? _message;
DeleteClientResponse copyWith({  String? message,
}) => DeleteClientResponse(  message: message ?? _message,
);
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    return map;
  }

}