import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vts_maps/api/api.dart';
import 'package:vts_maps/utils/constants.dart';

class VesselScreen extends StatefulWidget {
  const VesselScreen({Key? key}) : super(key: key);

  @override
  State<VesselScreen> createState() => _VesselScreenState();
}

class _VesselScreenState extends State<VesselScreen> {
  final DataTableSource _data = MyData();

  TextEditingController callsignController = TextEditingController();
  TextEditingController flagController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController builderController = TextEditingController();
  TextEditingController yearbuiltController = TextEditingController();

  submitVessel() async {
    var data = {
      "call_sign": callsignController.text,
      "flag": flagController.text,
      "class": classController.text,
      "builder": builderController.text,
      "year_built": yearbuiltController.text,
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
                "Loading..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
   await Api.createVessel(data).then((value) {
      print(value.message);
       if (value.message != "Data berhasil masuk database") {
        EasyLoading.showError("Gagal Menambahkan Kapal");
      }
       if (value.message == "Data berhasil masuk database") {
         EasyLoading.showSuccess("Berhasil Menambahkan Kapal");
         callsignController.clear();
         flagController.clear();
         classController.clear();
         builderController.clear();
         yearbuiltController.clear();
         Navigator.pop(context);
         Navigator.pop(context);
       }
       if (value.message == "Validator Fails") {
        EasyLoading.showError("Call Sign sudah terdaftar");
        Navigator.pop(context);
      }
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Theme(
      data: Theme.of(context).copyWith(
        cardColor: Color.fromARGB(255, 54, 60, 66),
        dividerColor: Color.fromARGB(137, 34, 34, 34),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          titleSmall: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
        ),
      ),
      child: PaginatedDataTable(
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Vessel List"),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            insetPadding: EdgeInsets.all(10),
                            backgroundColor: Colors.white,
                            elevation: 1,
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Tambah Kapal",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ),),
                                    SizedBox(height: 10,),
                                    Container(
                                      width: 500,
                                      child: TextFormField(
                                        controller: callsignController,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                                          hintText: "Call Sign",
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
                                    SizedBox(height: 10,),
                                    Container(
                                      width: 500,
                                      child: TextFormField(
                                        controller: flagController,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                                          hintText: "Flag",
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
                                    SizedBox(height: 10,),
                                    Container(
                                      width: 500,
                                      child: TextFormField(
                                        controller: classController,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                                          hintText: "Class",
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
                                    SizedBox(height: 10,),
                                    Container(
                                      width: 500,
                                      child: TextFormField(
                                        controller: builderController,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                                          hintText: "Builder",
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
                                    SizedBox(height: 10,),
                                    Container(
                                      width: 500,
                                      child: TextFormField(
                                        controller: yearbuiltController,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                                          hintText: "Tahun Pembuatan",
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
                                    SizedBox(height: 10,),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            submitVessel();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Color(0xFF277DC7),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            alignment: Alignment.center,
                                            height: 40,
                                            child: Text(
                                              "Simpan",
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        InkWell(
                                          onTap: (){
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Color(0xFFE51010),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            alignment: Alignment.center,
                                            height: 40,
                                            child: Text(
                                              "Batal",
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        )

                                      ],
                                    )

                                  ],
                                )),
                          );
                        });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF399D44),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    alignment: Alignment.center,
                    height: 40,
                    child: Text(
                      "Tambah Kapal +",
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        columns: [
          DataColumn(label: Text('Nama Kapal')),
          DataColumn(label: Text('Call Sign')),
          DataColumn(label: Text('Jenis Kapal')),
          DataColumn(label: Text('Tahun Pembuatan'))
        ],
        arrowHeadColor: Colors.black,
        columnSpacing: 100,
        horizontalMargin: 10,
        rowsPerPage: 8,
        showCheckboxColumn: false,
        source: _data,
      ),
    ));
  }
}

class MyData extends DataTableSource {
  // Generate some made-up data
  final List<Map<String, dynamic>> _data = List.generate(
      2,
      (index) => {
            "id": index,
            "title": "Item $index",
            "price": Random().nextInt(10000)
          });

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_data[index]['id'].toString())),
      DataCell(Text(_data[index]["title"])),
      DataCell(Text(_data[index]["price"].toString())),
      DataCell(Text(_data[index]["price"].toString())),
    ]);
  }
}
