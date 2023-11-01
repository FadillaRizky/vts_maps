import 'package:shared_preferences/shared_preferences.dart';

import 'data_user.dart';

class LoginPref {
  static Future<bool> saveToSharedPref(String token,String idUser,String idClient,String name,String email,String level) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey("token")) {
      pref.remove("token");
    }
    if (pref.containsKey("idUser")) {
      pref.remove("idUser");
    }
    if (pref.containsKey("idClient")) {
      pref.remove("idClient");
    }
    if (pref.containsKey("name")) {
      pref.remove("name");
    }
    if (pref.containsKey("email")) {
      pref.remove("email");
    }
    if (pref.containsKey("level")) {
      pref.remove("level");
    }
    pref.setString("token", token);
    pref.setString("idUser", idUser);
    pref.setString("idClient", idClient);
    pref.setString("name", name);
    pref.setString("email", email);
    pref.setString("level", level);

    return true;
  }

  static Future<bool> checkPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool status = pref.containsKey("token");

    return status;
  }

  static Future<DataUser> getPref() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    DataUser dataUser = DataUser();
    dataUser.token = pref.getString("token");
    dataUser.idUser = pref.getString("idUser");
    dataUser.idClient = pref.getString("idClient");
    dataUser.name = pref.getString("name");
    dataUser.email = pref.getString("email");
    dataUser.level = pref.getString("level");
    return dataUser;
  }

  static Future<bool> removePref() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove("token");
    await pref.remove("idUser");
    await pref.remove("idClient");
    await pref.remove("name");
    await pref.remove("email");
    await pref.remove("level");
    return true;
  }

}
