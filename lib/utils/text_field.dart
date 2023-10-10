import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.type,
    this.initValue,
  });

  final TextEditingController controller;
  final String hint;
  final String? initValue;
  final TextInputType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(" $hint",style: GoogleFonts.roboto(color: Colors.black, fontSize: 15,fontWeight: FontWeight.w500),),
        SizedBox(
          width: double.infinity,
          height: 35,
          child: TextFormField(
            style: TextStyle(fontSize: 14),
            controller: controller,
            initialValue: initValue,
            keyboardType: type,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(8, 3, 1, 3),
              // hintText: hint,
              // labelText: hint,
              // floatingLabelBehavior: FloatingLabelBehavior.always ,
              // hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
              // labelStyle: TextStyle(color: Colors.black54, fontSize: 15),
              // border: OutlineInputBorder(
              //   // borderSide: BorderSide(width: 0.5,color: Colors.red),
              // ),
                labelText: hint,
                labelStyle: Constants.labelstyle,
                floatingLabelBehavior:
                FloatingLabelBehavior.always,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1,color: Colors.blueAccent),),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1,color: Colors.black38)
                ),
              // enabledBorder: OutlineInputBorder(
              //   borderSide: BorderSide(width: 1,color: Colors.black12),
              // ),
              filled: true,
              fillColor: Colors.white
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
