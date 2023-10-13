import 'package:flutter/material.dart';

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  List<TextEditingController> controllers1 = [];
  List<TextEditingController> controllers2 = [];
  List<TextEditingController> controllers3 = [];
  List<TextEditingController> controllers4 = [];
  int numberOfFields = 1; // Dimulai dengan satu text field

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan satu controller awal
    controllers1.add(TextEditingController());
    controllers2.add(TextEditingController());
    controllers3.add(TextEditingController());
    controllers4.add(TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambahkan Text Field Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Column(
              children: List.generate(numberOfFields, (index) {
                return Column(
                  children: [
                    TextField(
                      controller: controllers1[index],
                      decoration: InputDecoration(labelText: 'Callsign'),
                    ),
                    TextField(
                      controller: controllers2[index],
                      decoration: InputDecoration(labelText: 'Type'),
                    ),
                    TextField(
                      controller: controllers3[index],
                      decoration: InputDecoration(labelText: 'IP'),
                    ),
                    TextField(
                      controller: controllers4[index],
                      decoration: InputDecoration(labelText: 'Port'),
                    ),
                    SizedBox(height: 20),
                  ],
                );
              }),
            ),
            ElevatedButton(
              onPressed: () {
                // Tambahkan controller baru dan tingkatkan jumlah kolom
                for (int i = 0; i < 4; i++) {
                  controllers1.add(TextEditingController());
                  controllers2.add(TextEditingController());
                  controllers3.add(TextEditingController());
                  controllers4.add(TextEditingController());
                }
                setState(() {
                  numberOfFields += 1;
                });
              },
              child: Text('Tambahkan Fields'),
            ),
            ElevatedButton(
              onPressed: () {

              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

//   @override
//   void dispose() {
//     // Buang controller text field untuk mencegah memory leak
//     for (var controller in controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
}