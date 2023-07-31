
class GetAllLatLangCoor {
  String? message;
  int? status;
  int? perpage;
  int? page;
  int? total;
  List<Data>? data;

  GetAllLatLangCoor({this.message, this.status, this.perpage, this.page, this.total, this.data});

  GetAllLatLangCoor.fromJson(Map<String, dynamic> json) {
    if(json["message"] is String) {
      message = json["message"];
    }
    if(json["status"] is int) {
      status = json["status"];
    }
    if(json["perpage"] is int) {
      perpage = json["perpage"];
    }
    if(json["page"] is int) {
      page = json["page"];
    }
    if(json["total"] is int) {
      total = json["total"];
    }
    if(json["data"] is List) {
      data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["message"] = message;
    _data["status"] = status;
    _data["perpage"] = perpage;
    _data["page"] = page;
    _data["total"] = total;
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Data {
  String? callSign;
  int? seriesId;
  double? latitude;
  double? longitude;

  Data({this.callSign, this.seriesId, this.latitude, this.longitude});

  Data.fromJson(Map<String, dynamic> json) {
    if(json["call_sign"] is String) {
      callSign = json["call_sign"];
    }
    if(json["series_id"] is int) {
      seriesId = json["series_id"];
    }
    if(json["latitude"] is double) {
      latitude = json["latitude"];
    }
    if(json["longitude"] is double) {
      longitude = json["longitude"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["call_sign"] = callSign;
    _data["series_id"] = seriesId;
    _data["latitude"] = latitude;
    _data["longitude"] = longitude;
    return _data;
  }
}