import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  final String title;
  final String description;
  final String assets;
  const IntroScreen({Key? key, required this.description, required this.assets, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      // width: 1000,
      color: Colors.blueAccent,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Center(child: Image.asset(assets,fit: BoxFit.cover,height: 200,)),

          Text(title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          Text(description,style: TextStyle(fontSize: 20),)
        ],
      ),
    );
  }
}
