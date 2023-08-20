
class AuthCheckResponse {
  String? message;
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? level;
  String? createdAt;
  String? updatedAt;

  AuthCheckResponse({this.message,this.id, this.name, this.email, this.emailVerifiedAt, this.level, this.createdAt, this.updatedAt});

  AuthCheckResponse.fromJson(Map<String, dynamic> json) {
    if(json["message"] is String) {
      message = json["message"];
    }
    if(json["id"] is int) {
      id = json["id"];
    }
    if(json["name"] is String) {
      name = json["name"];
    }
    if(json["email"] is String) {
      email = json["email"];
    }
    emailVerifiedAt = json["email_verified_at"];
    if(json["level"] is String) {
      level = json["level"];
    }
    if(json["created_at"] is String) {
      createdAt = json["created_at"];
    }
    if(json["updated_at"] is String) {
      updatedAt = json["updated_at"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["message"] = message;
    _data["id"] = id;
    _data["name"] = name;
    _data["email"] = email;
    _data["email_verified_at"] = emailVerifiedAt;
    _data["level"] = level;
    _data["created_at"] = createdAt;
    _data["updated_at"] = updatedAt;
    return _data;
  }
}