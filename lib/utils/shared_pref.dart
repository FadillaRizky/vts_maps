import 'package:shared_preferences/shared_preferences.dart';

import 'data_user.dart';

class LoginPref {
  static Future<bool> saveToSharedPref(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey("token")) {
      pref.remove("token");
    }
    pref.setString("token", token);

    return true;
  }

  static Future<bool> checkPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool status = pref.containsKey("token");

    return status;
  }

  static Future <DataUser> getPref() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    DataUser dataUser = DataUser();
    dataUser.token = pref.getString("token");
    return dataUser;
  }

  static Future<bool> removePref() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove("token");
    return true;
  }

}
