import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
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
import 'intro_screen.dart';

class Login extends StatefulWidget {
  final String? idClient;
  final String? vesselClicked;

  const Login(
      {Key? key, this.idClient, this.vesselClicked, })
      : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool invisible = true;
  bool? _isVisible = true;

  final PageController _pageController = PageController();
  int currentIndex = 0;

  authClient(){
    if (widget.idClient != null) {
      _isVisible = false;
    }
  }

  loginAdmin() async {
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
        if (value.message == "Login Success") {
          final notifier = Provider.of<Notifier>(context, listen: false);
          notifier.setAuth(value.token!);
          EasyLoading.showSuccess("Login Berhasil");
          Navigator.pop(context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (ctx) => VtsMaps()));
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

  loginClient() async {
    var email = widget.idClient!;
    var password = passwordController.text;
    // var email = "1@gmail.com";
    // var password = "111";
    //validasi
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
      Auth.Login(data!).then((value) {
        if (value.message == "Login Success") {
          final notifier = Provider.of<Notifier>(context, listen: false);
          notifier.setAuth(value.token!);
          EasyLoading.showSuccess("Login Berhasil");
          Navigator.pop(context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (ctx) => VtsMaps()));
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

  final List<Widget> introPages = [
    IntroScreen(
        title: "Identifikasi Kapal",
        description:
            "Kemudahan dalam mengakses informasi terkait Identitas Kapal seperti lokasi, arah, dan status Kapal.",
        assets: "assets/kapal.png"),
    IntroScreen(
        title: "Pelacakan Real Time",
        description: "Efisiensi dalam mengetahui lokasi kapal secara Real Time pada peta.",
        assets: "assets/kapal.png"),
  ];

  @override
  void initState() {
    super.initState();
    authClient();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
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
          body: Container(
            child: Row(
              children: [
                Container(
                  // color: Color(0xFF2B3B9A),
                  width: width / 2,
                  height: double.infinity,
                  // MediaQuery.of(context).size.width <= 500 ? MediaQuery.of(context).size.width : double.infinity,
                  child: Column(
                    children: [
                      // Expanded(
                      //   child: PageView(
                      //
                      //     controller: _pageController,
                      //     onPageChanged: (int index) {
                      //       setState(() {
                      //         currentIndex = index;
                      //       });
                      //     },
                      //     children: introPages,
                      //   ),
                      // ),
                      Expanded(
                        child: CarouselSlider(
                            options: CarouselOptions(
                              height: double.infinity,
                              autoPlay: true,
                              viewportFraction: 1.0,
                              // viewportFraction: 0.8,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                });
                              },
                            ),
                            items: introPages),
                      ),
                      DotsIndicator(
                        dotsCount: introPages.length,
                        position: currentIndex,
                        decorator: DotsDecorator(
                          color: Colors.grey,
                          activeColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  // CarouselSlider(
                  //     options: CarouselOptions(
                  //       height: double.infinity,
                  //       autoPlay: true,
                  //     ),
                  //     items: introScreen),
                  // Padding(
                  //   padding: EdgeInsets.all(10),
                  //   child: Column(
                  //     children: [
                  //       SizedBox(
                  //         height: 50,
                  //       ),
                  //       Text("Login", style: Constants.title1),
                  //       Spacer(),
                  //       Container(
                  //         child: TextFormField(
                  //           keyboardType: TextInputType.text,
                  //           controller: emailController,
                  //           textInputAction: TextInputAction.next,
                  //           decoration: InputDecoration(
                  //             contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                  //             hintText: "Email",
                  //             prefixIcon: Icon(Icons.email_outlined),
                  //             // hintStyle: Constants.hintStyle,
                  //             border: OutlineInputBorder(
                  //               borderSide:
                  //                   BorderSide(width: 0, style: BorderStyle.none),
                  //               borderRadius: BorderRadius.circular(20),
                  //             ),
                  //             filled: true,
                  //             fillColor: Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         height: 15,
                  //       ),
                  //       Container(
                  //         child: TextFormField(
                  //           obscureText: invisible,
                  //           keyboardType: TextInputType.text,
                  //           textInputAction: TextInputAction.next,
                  //           controller: passwordController,
                  //           decoration: InputDecoration(
                  //             contentPadding: EdgeInsets.fromLTRB(3, 3, 3, 3),
                  //             hintText: "Password",
                  //             // prefixIconConstraints: BoxConstraints.loose(Size.square(30)),
                  //             prefixIcon: Icon(Icons.lock),
                  //             // hintStyle: Constants.hintStyle,
                  //             border: OutlineInputBorder(
                  //               borderSide:
                  //                   BorderSide(width: 0, style: BorderStyle.none),
                  //               borderRadius: BorderRadius.circular(20),
                  //             ),
                  //             filled: true,
                  //             fillColor: Colors.white,
                  //             suffixIcon: IconButton(
                  //               icon: Icon((invisible == true)
                  //                   ? Icons.visibility_outlined
                  //                   : Icons.visibility_off),
                  //               onPressed: () {
                  //                 setState(() {
                  //                   invisible = !invisible;
                  //                 });
                  //               },
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         height: 15,
                  //       ),
                  //       Container(
                  //         width: double.infinity,
                  //         height: 50,
                  //         decoration: BoxDecoration(
                  //           gradient: LinearGradient(colors: [
                  //             Color.fromARGB(225, 0, 111, 186),
                  //             Color.fromARGB(225, 58, 171, 249)
                  //           ]),
                  //           borderRadius: BorderRadius.circular(20),
                  //         ),
                  //         child: ElevatedButton(
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: Colors.transparent,
                  //             shadowColor: Colors.transparent,
                  //           ),
                  //           onPressed: () {
                  //             login();
                  //           },
                  //           child: Text(
                  //             "Login",
                  //             style: Constants.button1,
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         height: 80,
                  //       )
                  //     ],
                  //   ),
                  // ),
                ),
                Container(
                  width: width / 2,
                  padding: EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        height: 40,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Log in to your Account",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 150,
                      ),

                      Visibility(
                        visible: _isVisible!,
                        child: Container(
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: emailController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                              hintText: "Email",
                              prefixIcon: Icon(Icons.email_outlined),
                              // hintStyle: Constants.hintStyle,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.blueAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.black38)),
                              filled: true,
                              fillColor:  Color(0xF2F2F2F),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: passwordController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(5),
                            hintText: "Password",
                            prefixIcon: Icon(Icons.key),
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
                            // hintStyle: Constants.hintStyle,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1, color: Colors.blueAccent),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.black38)),
                            filled: true,
                            fillColor: Color(0xF2F2F2F),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xFF133BAD)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          onPressed: (){
                            _isVisible == true ? loginAdmin() : loginClient();
                          },
                          child: Text(
                            "Log in",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // bottomNavigationBar: Container(
          //   height: 50,
          //   color: Color(0xFF0E286C),
          // ),
        );
      },
    );
  }
}
