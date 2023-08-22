import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/auth/Authentication.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:vts_maps/dashboard.dart';
import 'package:vts_maps/maps_view.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:vts_maps/utils/shared_pref.dart';

import 'api/LoginResponse.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool invisible = true;

  login() async {
    var email = emailController.text;
    var password = passwordController.text;
    // var email = "1@gmail.com";
    // var password = "111";
    //validasi
    if (email.isEmpty) {
      EasyLoading.showError('Masukan Email Anda..');
      return;
    }
    if (password.isEmpty) {
      EasyLoading.showError('Masukan Password Anda..');
      return;
    }
    var data = {
      "email": email,
      "password": password,
    };
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Login ..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
    try {
      Auth.Login(data).then((value) {
        LoginPref.saveToSharedPref(value.token!);
        if (value.message == "Login Success") {
          final notifier = Provider.of<Notifier>(context, listen: false);
          notifier.setAuth(value.token!);
          EasyLoading.showSuccess("Login Berhasil");
          Navigator.pop(context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (ctx) => HomePage()));
        } else if (value.message != "Login Success") {
          EasyLoading.showError("Login Gagal..");
          Navigator.pop(context);
        }
      });
    } on TimeoutException catch (_) {
      EasyLoading.showError("Sinyal Buruk..");
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Notifier>(
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "AVTS - Automated Vessel Tracking System",
              style: GoogleFonts.montserrat(fontSize: 15, color: Colors.white),
            ),
            backgroundColor: Color(0xFF0E286C),
            iconTheme: IconThemeData(
              color: Colors.white, // Change this color to the desired color
            ),
          ),
          body: Row(
            children: [
              Expanded(
                child: Stack(children: [
                  Image.asset(
                    "assets/background-login.jpg",
                    fit: BoxFit.cover,
                    height: double.infinity,
                  ),
                ]),
              ),
              Container(
                color: Color(0xFF2B3B9A),
                width: 500,
                height: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Text("Login", style: Constants.title1),
                      Spacer(),
                      Container(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                            hintText: "Email",
                            prefixIcon: Icon(Icons.email_outlined),
                            // hintStyle: Constants.hintStyle,
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 0, style: BorderStyle.none),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: TextFormField(
                          obscureText: invisible,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          controller: passwordController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(3, 3, 3, 3),
                            hintText: "Password",
                            // prefixIconConstraints: BoxConstraints.loose(Size.square(30)),
                            prefixIcon: Icon(Icons.lock),
                            // hintStyle: Constants.hintStyle,
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 0, style: BorderStyle.none),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon((invisible == true)
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  invisible = !invisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color.fromARGB(225, 0, 111, 186),
                            Color.fromARGB(225, 58, 171, 249)
                          ]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            login();
                          },
                          child: Text(
                            "Login",
                            style: Constants.button1,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 80,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            height: 50,
            color: Color(0xFF0E286C),
          ),
        );
      },
    );
  }
}
