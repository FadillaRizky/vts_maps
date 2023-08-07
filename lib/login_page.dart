import 'package:flutter/material.dart';
import 'package:vts_maps/dashboard.dart';
import 'package:vts_maps/maps_view.dart';
import 'package:vts_maps/utils/constants.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool invisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0E286C),
        iconTheme: IconThemeData(
          color: Colors.white, // Change this color to the desired color
        ),
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(
                "Menu",
                style: Constants.title1,
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Text("Show Map"),
                trailing: Image.asset("assets/maps-icon.png",width: 30,),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
              ListTile(leading: Text("menu2")),
              ListTile(leading: Text("menu3")),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: Image.asset(
              "assets/background-login.jpg",
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          Container(
            color: Colors.white,
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
                      controller: usernameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                        hintText: "Username",
                        // hintStyle: Constants.hintStyle,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0, style: BorderStyle.none),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.black12,
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
                      controller: passwordController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                        hintText: "Password",
                        // hintStyle: Constants.hintStyle,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0, style: BorderStyle.none),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.black12,
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
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => Dashboard(),
                          ),
                        );
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
      // Stack(
      //   children: [
      //     Image.asset(
      //       "assets/background-login.jpg",
      //       fit: BoxFit.cover,
      //       width: double.infinity,
      //     ),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: [
      //         Padding(
      //           padding: EdgeInsets.fromLTRB(0, 50, 50, 50),
      //           child: SizedBox(
      //             width: 500,
      //             child: Card(
      //               color: Colors.transparent,
      //               child: Padding(
      //                 padding: EdgeInsets.all(10),
      //                 child: Column(
      //                   children: [
      //                     Text(
      //                       "Login",
      //                       style: TextStyle(
      //                           fontSize: 25,
      //                           fontWeight: FontWeight.bold,
      //                           color: Colors.white),
      //                     ),
      //                     Container(
      //                       child: TextFormField(
      //                         obscureText: invisible,
      //                         keyboardType: TextInputType.text,
      //                         controller: passwordController,
      //                         decoration: InputDecoration(
      //                           contentPadding:
      //                               EdgeInsets.fromLTRB(20, 3, 1, 3),
      //                           hintText: "Password",
      //                           // hintStyle: Constants.hintStyle,
      //                           border: OutlineInputBorder(
      //                             borderSide: BorderSide(
      //                                 width: 0, style: BorderStyle.none),
      //                             borderRadius: BorderRadius.circular(10),
      //                           ),
      //                           filled: true,
      //                           fillColor: Colors.white,
      //                           suffixIcon: IconButton(
      //                             icon: Icon((invisible == true)
      //                                 ? Icons.visibility_outlined
      //                                 : Icons.visibility_off),
      //                             onPressed: () {},
      //                           ),
      //                         ),
      //                       ),
      //                     )
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       ],
      //     )
      //   ],
      // ),
    );
  }
}
