/// message : "Selamat datang rizky"
/// token : "3|zoQIxjQ5MYjNIQLKmBni4TASgEIsTGkuiR5GthuO"
/// user : {"id":2,"name":"rizky","email":"rizky@gmail.com","email_verified_at":null,"created_at":"2023-08-08T12:55:06.000000Z","updated_at":"2023-08-08T12:55:06.000000Z"}

class LoginResponse {
  LoginResponse({
      String? message, 
      String? token, 
      User? user,}){
    _message = message;
    _token = token;
    _user = user;
}

  LoginResponse.fromJson(dynamic json) {
    _message = json['message'];
    _token = json['token'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  String? _message;
  String? _token;
  User? _user;
LoginResponse copyWith({  String? message,
  String? token,
  User? user,
}) => LoginResponse(  message: message ?? _message,
  token: token ?? _token,
  user: user ?? _user,
);
  String? get message => _message;
  String? get token => _token;
  User? get user => _user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['token'] = _token;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    return map;
  }

}

/// id : 2
/// name : "rizky"
/// email : "rizky@gmail.com"
/// email_verified_at : null
/// created_at : "2023-08-08T12:55:06.000000Z"
/// updated_at : "2023-08-08T12:55:06.000000Z"

class User {
  User({
      num? id, 
      String? name, 
      String? email, 
      dynamic emailVerifiedAt, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _name = name;
    _email = email;
    _emailVerifiedAt = emailVerifiedAt;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  User.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _email = json['email'];
    _emailVerifiedAt = json['email_verified_at'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _name;
  String? _email;
  dynamic _emailVerifiedAt;
  String? _createdAt;
  String? _updatedAt;
User copyWith({  num? id,
  String? name,
  String? email,
  dynamic emailVerifiedAt,
  String? createdAt,
  String? updatedAt,
}) => User(  id: id ?? _id,
  name: name ?? _name,
  email: email ?? _email,
  emailVerifiedAt: emailVerifiedAt ?? _emailVerifiedAt,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get id => _id;
  String? get name => _name;
  String? get email => _email;
  dynamic get emailVerifiedAt => _emailVerifiedAt;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['email_verified_at'] = _emailVerifiedAt;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}