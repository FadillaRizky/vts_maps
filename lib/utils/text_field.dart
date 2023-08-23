import 'package:flutter/material.dart';

class VesselTextField extends StatelessWidget {
  const VesselTextField({
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
      children: [
        Container(
          width: double.infinity,
          height: 30,
          child: TextFormField(
            controller: controller,
            initialValue: initValue,
            keyboardType: type,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
              hintText: hint,
              labelText: hint,
              hintStyle: TextStyle(color: Colors.black, fontSize: 15),
              labelStyle: TextStyle(color: Colors.black, fontSize: 15),
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 0, style: BorderStyle.none),
                borderRadius: BorderRadius.circular(20),
              ),
              filled: true,
              fillColor: Colors.black12,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}
