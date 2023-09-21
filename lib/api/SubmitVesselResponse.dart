/// message : "Validator Fails"
/// error : {"call_sign":["The call sign has already been taken."],"xml_file":["The xml file field is required."]}

class SubmitVesselResponse {
  SubmitVesselResponse({
      String? message, 
      Error? error,}){
    _message = message;
    _error = error;
}

  SubmitVesselResponse.fromJson(dynamic json) {
    _message = json['message'];
    _error = json['error'] != null ? Error.fromJson(json['error']) : null;
  }
  String? _message;
  Error? _error;
SubmitVesselResponse copyWith({  String? message,
  Error? error,
}) => SubmitVesselResponse(  message: message ?? _message,
  error: error ?? _error,
);
  String? get message => _message;
  Error? get error => _error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    if (_error != null) {
      map['error'] = _error?.toJson();
    }
    return map;
  }

}

/// call_sign : ["The call sign has already been taken."]
/// xml_file : ["The xml file field is required."]

class Error {
  Error({
      List<String>? callSign, 
      List<String>? xmlFile,}){
    _callSign = callSign;
    _xmlFile = xmlFile;
}

  Error.fromJson(dynamic json) {
    _callSign = json['call_sign'] != null ? json['call_sign'].cast<String>() : [];
    _xmlFile = json['xml_file'] != null ? json['xml_file'].cast<String>() : [];
  }
  List<String>? _callSign;
  List<String>? _xmlFile;
Error copyWith({  List<String>? callSign,
  List<String>? xmlFile,
}) => Error(  callSign: callSign ?? _callSign,
  xmlFile: xmlFile ?? _xmlFile,
);
  List<String>? get callSign => _callSign;
  List<String>? get xmlFile => _xmlFile;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['call_sign'] = _callSign;
    map['xml_file'] = _xmlFile;
    return map;
  }

}