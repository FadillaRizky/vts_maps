/// message : "Data berhasil di ubah database"
/// status : 200

class EditPipelineResponse {
  EditPipelineResponse({
      String? message, 
      num? status,}){
    _message = message;
    _status = status;
}

  EditPipelineResponse.fromJson(dynamic json) {
    _message = json['message'];
    _status = json['status'];
  }
  String? _message;
  num? _status;
EditPipelineResponse copyWith({  String? message,
  num? status,
}) => EditPipelineResponse(  message: message ?? _message,
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