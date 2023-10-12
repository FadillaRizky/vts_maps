import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:vts_maps/utils/alerts.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:vts_maps/utils/text_field.dart';
import 'package:vts_maps/api/GetKapalAndCoor.dart' as VesselCoor;

class VesselPage{
  static TextEditingController callsignController = TextEditingController();
  static TextEditingController flagController = TextEditingController();
  static TextEditingController classController = TextEditingController();
  static TextEditingController builderController = TextEditingController();
  static TextEditingController yearbuiltController = TextEditingController();
  ////-----------------------------------------------------/////
  static TextEditingController ipController = TextEditingController();
  static TextEditingController portController = TextEditingController();
  static String? vesselSize;
  static String? type;

  static vesselList(BuildContext context,Notifier value,){
    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      var width = MediaQuery.of(context).size.width;

      return Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(5))),
          child: SizedBox(
              width: width / 1.5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black12,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          " Vessel List",
                          style: GoogleFonts.openSans(
                              fontSize: 20,fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                            "Page ${value.currentPage} of ${(value.totalVessel / 10).ceil()}"),

                        ///
                        Row(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                                5))),
                                    backgroundColor:
                                    MaterialStateProperty
                                        .all(Colors
                                        .blueAccent)),
                                onPressed: (){
                                value.initVesselCoor();
                              }, icon: Icon(Icons.refresh,color: Colors.white,),),
                            ),
                            SizedBox(width: 5,),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          5))),
                                      backgroundColor:
                                          MaterialStateProperty
                                              .all(Colors
                                                  .blueAccent)),
                                  onPressed: () {
                                    addVesselAndCoor(
                                        context, value);
                                  },
                                  child: Text(
                                    "Add Vessel",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                          ],
                        )

                        ///
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 380,
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                          scrollDirection:
                              Axis.horizontal,
                          child: value.isLoading
                              ? const Center(
                                  child:
                                      CircularProgressIndicator())
                              : DataTable(
                                  headingRowColor:
                                      MaterialStateProperty
                                          .all(Color(
                                          0xffd3d3d3)),
                                  columns: [
                                    const DataColumn(
                                        label: Text(
                                            "CallSign")),
                                    const DataColumn(
                                        label: Text(
                                            "Flag")),
                                    const DataColumn(
                                        label: Text(
                                            "Class")),
                                    const DataColumn(
                                        label: Text(
                                            "Builder")),
                                    const DataColumn(
                                        label: Text(
                                            "Year Built")),
                                    const DataColumn(
                                        label: Text(
                                            "Size")),
                                    const DataColumn(
                                        label: Text(
                                            "File XML")),
                                    const DataColumn(
                                        label: Text(
                                            "Upload IP ")),
                                    const DataColumn(
                                        label: Text(
                                            "Action")),
                                  ],
                                  rows: value
                                      .vesselCoorResult
                                      .map((data) {
                                    return DataRow(
                                        cells: [
                                          DataCell(Text(data
                                              .kapal!
                                              .callSign!)),
                                          DataCell(Text(data
                                              .kapal!
                                              .flag!)),
                                          DataCell(Text(data
                                              .kapal!
                                              .kelas!)),
                                          DataCell(Text(data
                                              .kapal!
                                              .builder!)),
                                          DataCell(Text(data
                                              .kapal!
                                              .yearBuilt!)),
                                          DataCell(Text(data
                                              .kapal!
                                              .size!)),
                                          DataCell(
                                              SizedBox(
                                                width: 100,
                                                child: Text(data
                                                .kapal!
                                                .xmlFile!,overflow: TextOverflow.ellipsis,maxLines: 2,),
                                              )),
                                          DataCell(
                                              IconButton(onPressed: (){
                                                value.initIpList(data.kapal!.callSign!);
                                            uploadIpAndPort(context, value,data.kapal!.callSign!);
                                          }, icon:Icon(Icons.edit_location_alt_outlined) )),
                                          DataCell(Row(
                                            children: [
                                              IconButton(
                                                icon:
                                                    const Icon(
                                                  Icons
                                                      .edit,
                                                  color:
                                                      Colors.blue,
                                                ),
                                                onPressed:
                                                    () {
                                                  editVesselAndCoor(
                                                      data,
                                                      context,
                                                      value);
                                                },
                                              ),
                                              IconButton(
                                                icon:
                                                    const Icon(
                                                  Icons
                                                      .delete,
                                                  color:
                                                      Colors.red,
                                                ),
                                                onPressed:
                                                    () {
                                                  Alerts.showAlertYesNo(
                                                      title: "Are you sure you want to delete this data?",
                                                      onPressYes: () {
                                                        value.deleteVessel(data.kapal!.callSign, context);
                                                      },
                                                      onPressNo: () {
                                                        Navigator.pop(context);
                                                      },
                                                      context: context);
                                                },
                                              ),
                                            ],
                                          )),
                                        ]);
                                  }).toList())),
                    ),
                  ),
                  Pagination(
                    numOfPages:
                        (value.totalVessel / 10).ceil(),
                    selectedPage: value.currentPage,
                    pagesVisible: 7,
                    onPageChanged: (page) {
                      value.incrementPage(page);
                      value.initVesselCoor();
                    },
                    nextIcon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue,
                      size: 14,
                    ),
                    previousIcon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.blue,
                      size: 14,
                    ),
                    activeTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    activeBtnStyle: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(
                              Colors.blue),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(38),
                        ),
                      ),
                    ),
                    inactiveBtnStyle: ButtonStyle(
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(38),
                      )),
                    ),
                    inactiveTextStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )));
    });
  }
  static addVesselAndCoor(BuildContext context, Notifier value) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          var width = MediaQuery.of(context).size.width;

          return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Container(
              color: Colors.white,
              width: width / 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black12,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          " Add Vessel",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            callsignController.clear();
                            flagController.clear();
                            classController.clear();
                            builderController.clear();
                            yearbuiltController.clear();
                            // ipController.clear();
                            // portController.clear();
                            vesselSize = null;
                            value.clearFile();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 480,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            CustomTextField(
                              controller: callsignController,
                              hint: 'Call Sign',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: flagController,
                              hint: 'Bendera',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: classController,
                              hint: 'Kelas',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: builderController,
                              hint: 'Builder',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: yearbuiltController,
                              hint: 'Tahun Pembuatan',
                              type: TextInputType.number,
                            ),
                            // CustomTextField(
                            //   controller: ipController,
                            //   hint: 'IP',
                            //   type: TextInputType.text,
                            // ),
                            // CustomTextField(
                            //   controller: portController,
                            //   hint: 'Port',
                            //   type: TextInputType.number,
                            // ),
                            SizedBox(
                              height: 35,
                              width: double.infinity,
                              child: DropdownSearch<String>(
                                dropdownBuilder: (context, selectedItem) =>
                                    Text(
                                  selectedItem ?? "",
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black54),
                                ),
                                popupProps: PopupPropsMultiSelection.dialog(
                                  fit: FlexFit.loose,
                                  itemBuilder: (context, item, isSelected) =>
                                      ListTile(
                                    title: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  ///
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Ukuran Kapal",
                                    labelStyle: Constants.labelstyle,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.black38)),
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(8, 3, 1, 3),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),

                                  ///
                                ),
                                items: [
                                  "small",
                                  "medium",
                                  "large",
                                ],
                                onChanged: (value) {
                                  vesselSize = value;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(" Upload File",style: GoogleFonts.openSans(fontSize: 17,fontWeight: FontWeight.bold),),
                            Divider(),

                            ///file xml
                            GestureDetector(
                              onTap: () {
                                value.selectFile("XML");
                              },
                              child: Card(
                                color: Colors.black12,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Upload your file",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.white),
                                      ),
                                      const Text("XML",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/xml_icon2.png",
                                                height: 55,
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 70),
                                                child: Text(
                                                  value.nameFile!,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // InkWell(
                                //   onTap: () {
                                //     callsignController.clear();
                                //     flagController.clear();
                                //     classController.clear();
                                //     builderController.clear();
                                //     yearbuiltController.clear();
                                //     ipController.clear();
                                //     portController.clear();
                                //     vesselSize = null;
                                //     value.clearFile();
                                //     Navigator.pop(context);
                                //   },
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(10),
                                //       color: const Color(0xFFFF0000),
                                //     ),
                                //     padding: const EdgeInsets.all(5),
                                //     alignment: Alignment.center,
                                //     height: 30,
                                //     child: const Text("Batal"),
                                //   ),
                                // ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueAccent),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (callsignController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Call Sign Masih Kosong...");
                                      return;
                                    }
                                    if (flagController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Bendera Masih Kosong...");
                                      return;
                                    }
                                    if (classController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Kelas Masih Kosong...");
                                      return;
                                    }
                                    if (builderController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Builder Masih Kosong...");
                                      return;
                                    }
                                    if (yearbuiltController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Tahun Pembuatan Masih Kosong...");
                                      return;
                                    }
                                    // if (ipController.text.isEmpty) {
                                    //   EasyLoading.showError(
                                    //       "Kolom IP Pembuatan Masih Kosong...");
                                    //   return;
                                    // }
                                    // if (portController.text.isEmpty) {
                                    //   EasyLoading.showError(
                                    //       "Kolom Port Masih Kosong...");
                                    //   return;
                                    // }
                                    if (vesselSize == null) {
                                      EasyLoading.showError(
                                          "Kolom Ukuran Kapal Masih Kosong...");
                                      return;
                                    }
                                    if (value.file == null) {
                                      EasyLoading.showError(
                                          "Kolom File Masih Kosong...");
                                      return;
                                    }
                                    List<String> data = [
                                      callsignController.text,
                                      flagController.text,
                                      classController.text,
                                      builderController.text,
                                      yearbuiltController.text,
                                      vesselSize!,
                                      // ipController.text,
                                      // portController.text,

                                    ];
                                    value.submitVessel(
                                        data, context, value.file);
                                    callsignController.clear();
                                    flagController.clear();
                                    classController.clear();
                                    builderController.clear();
                                    yearbuiltController.clear();
                                    // ipController.clear();
                                    // portController.clear();
                                    vesselSize = null;
                                    value.clearFile();
                                  },
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              side: BorderSide(
                                                  color: Colors.blueAccent)))),
                                  onPressed: () {
                                    callsignController.clear();
                                    flagController.clear();
                                    classController.clear();
                                    builderController.clear();
                                    yearbuiltController.clear();
                                    // ipController.clear();
                                    // portController.clear();
                                    vesselSize = null;
                                    value.clearFile();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),

                                // InkWell(
                                //   onTap: () {
                                //     if (callsignController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Call Sign Masih Kosong...");
                                //       return;
                                //     }
                                //     if (flagController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Bendera Masih Kosong...");
                                //       return;
                                //     }
                                //     if (classController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Kelas Masih Kosong...");
                                //       return;
                                //     }
                                //     if (builderController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Builder Masih Kosong...");
                                //       return;
                                //     }
                                //     if (yearbuiltController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Tahun Pembuatan Masih Kosong...");
                                //       return;
                                //     }
                                //     if (ipController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom IP Pembuatan Masih Kosong...");
                                //       return;
                                //     }
                                //     if (portController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Port Masih Kosong...");
                                //       return;
                                //     }
                                //     if (vesselSize == null) {
                                //       EasyLoading.showError(
                                //           "Kolom Ukuran Kapal Masih Kosong...");
                                //       return;
                                //     }
                                //     if (value.file == null) {
                                //       EasyLoading.showError(
                                //           "Kolom File Masih Kosong...");
                                //       return;
                                //     }
                                //     List<String> data = [
                                //       callsignController.text,
                                //       flagController.text,
                                //       classController.text,
                                //       builderController.text,
                                //       yearbuiltController.text,
                                //       ipController.text,
                                //       portController.text,
                                //       vesselSize!,
                                //     ];
                                //     value.submitVessel(
                                //         data, context, value.file);
                                //     callsignController.clear();
                                //     flagController.clear();
                                //     classController.clear();
                                //     builderController.clear();
                                //     yearbuiltController.clear();
                                //     ipController.clear();
                                //     portController.clear();
                                //     vesselSize = null;
                                //     value.clearFile();
                                //   },
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(10),
                                //       color: const Color(0xFF24A438),
                                //     ),
                                //     padding: const EdgeInsets.all(5),
                                //     alignment: Alignment.center,
                                //     height: 30,
                                //     child: const Text("Submit"),
                                //   ),
                                // )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  static uploadIpAndPort(BuildContext context, Notifier value,String callSign) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          var width = MediaQuery.of(context).size.width;

          return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Container(
              color: Colors.white,
              width: width / 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black12,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          " Upload Ip & Port",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            ipController.clear();
                            portController.clear();
                            type = null;
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 480,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            CustomTextField(
                              controller: ipController,
                              hint: 'IP',
                              type: TextInputType.text,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 35,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 14),
                                      controller: portController,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(8, 3, 1, 3),
                                          labelText: "Port",
                                          labelStyle: Constants.labelstyle,
                                          floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(width: 1,color: Colors.blueAccent),),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 1,color: Colors.black38)
                                          ),
                                          filled: true,
                                          fillColor: Colors.white
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                SizedBox(
                                  height: 35,
                                  width: 150,
                                  child: DropdownSearch<String>(
                                    dropdownBuilder: (context, selectedItem) =>
                                        Text(
                                          selectedItem ?? "",
                                          style: const TextStyle(
                                              fontSize: 15, color: Colors.black54),
                                        ),
                                    popupProps: PopupPropsMultiSelection.dialog(
                                      fit: FlexFit.loose,
                                      itemBuilder: (context, item, isSelected) =>
                                          ListTile(
                                            title: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                    ),
                                    dropdownDecoratorProps: DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Type",
                                        labelStyle: Constants.labelstyle,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.blueAccent),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.black38)),
                                        contentPadding:
                                        const EdgeInsets.fromLTRB(8, 3, 1, 3),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                    items: [
                                      "all",
                                      "gga",
                                      "hdt",
                                      "vtg",
                                    ],
                                    onChanged: (value) {
                                      type = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueAccent),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (ipController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom IP Masih Kosong...");
                                      return;
                                    }
                                    if (portController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Port Masih Kosong...");
                                      return;
                                    }
                                    if (type == null) {
                                      EasyLoading.showError(
                                          "Kolom Type Masih Kosong...");
                                      return;
                                    }
                                    Map<String,String> data = {
                                      "call_sign" : callSign,
                                     "ip" : ipController.text,
                                     "port" : portController.text,
                                      "type_ip" : type!,
                                  };
                                     value.uploadIP(data, context,callSign);
                                    ipController.clear();
                                    portController.clear();
                                    type = null;
                                  },
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5,),
                            SizedBox(
                              height: 380,
                              child: SingleChildScrollView(
                                child: SingleChildScrollView(
                                    scrollDirection:
                                    Axis.horizontal,
                                    child: value.isLoadingIp
                                        ? const Center(
                                        child:
                                        CircularProgressIndicator())
                                        : DataTable(
                                        headingRowColor:
                                        MaterialStateProperty
                                            .all(Color(
                                            0xffd3d3d3)),
                                        columns: [
                                          const DataColumn(
                                              label: Text(
                                                  "No")),
                                          const DataColumn(
                                              label: Text(
                                                  "IP")),
                                          const DataColumn(
                                              label: Text(
                                                  "Port")),
                                          const DataColumn(
                                              label: Text(
                                                  "Type")),
                                          const DataColumn(
                                              label: Text(
                                                  "Delete")),
                                        ],
                                        rows: value
                                            .ipPortResult
                                            .map((data) {
                                          return DataRow(
                                              cells: [
                                                DataCell(SizedBox(
                                                    width: 10,
                                                    child: Text(""))),
                                                DataCell(Text(data.ip!)),
                                                DataCell(Text(data.port!)),
                                                DataCell(Text(data.typeIp!)),
                                                DataCell(IconButton(onPressed: (){
                                                  Alerts.showAlertYesNo(
                                                      title: "Are you sure you want to delete this data?",
                                                      onPressYes: () {
                                                        value.deleteIP(data.idIpKapal!,data.callSign!, context);
                                                      },
                                                      onPressNo: () {
                                                        Navigator.pop(context);
                                                      },
                                                      context: context);
                                                },icon: Icon(Icons.delete),)),
                                              ]);
                                        }).toList())),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  static editVesselAndCoor(VesselCoor.Data data, BuildContext context, Notifier value) {
    callsignController.text = data.kapal!.callSign!;
    flagController.text = data.kapal!.flag!;
    classController.text = data.kapal!.kelas!;
    builderController.text = data.kapal!.builder!;
    yearbuiltController.text = data.kapal!.yearBuilt!;
    vesselSize = data.kapal!.size!;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          var width = MediaQuery.of(context).size.width;
          return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: SizedBox(
              width: width / 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black12,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          " Edit Vessel",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            callsignController.clear();
                            flagController.clear();
                            classController.clear();
                            builderController.clear();
                            yearbuiltController.clear();
                            ipController.clear();
                            portController.clear();
                            vesselSize = null;
                            value.clearFile();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 485,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            CustomTextField(
                              controller: callsignController,
                              hint: 'Call Sign',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: flagController,
                              hint: 'Bendera',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: classController,
                              hint: 'Kelas',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: builderController,
                              hint: 'Builder',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: yearbuiltController,
                              hint: 'Tahun Pembuatan',
                              type: TextInputType.number,
                            ),
                            CustomTextField(
                              controller: ipController,
                              hint: 'IP',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: portController,
                              hint: 'Port',
                              type: TextInputType.number,
                            ),
                            SizedBox(
                              height: 35,
                              width: double.infinity,
                              child: DropdownSearch<String>(
                                selectedItem: data.kapal!.size ?? "",
                                dropdownBuilder: (context, selectedItem) =>
                                    Text(
                                  selectedItem ?? "",
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black54),
                                ),
                                popupProps: PopupPropsMultiSelection.dialog(
                                  fit: FlexFit.loose,
                                  itemBuilder: (context, item, isSelected) =>
                                      ListTile(
                                    title: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Ukuran Kapal",
                                    labelStyle: Constants.labelstyle,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.black38)),
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(8, 3, 1, 3),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                items: [
                                  "Small",
                                  "Medium",
                                  "Large",
                                ],
                                onChanged: (value) {
                                  vesselSize = value;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(" Upload File",style: GoogleFonts.openSans(fontSize: 17,fontWeight: FontWeight.bold),),
                            Divider(),
                            GestureDetector(
                              onTap: () {
                                value.selectFile("XML");
                              },
                              child: Card(
                                color: Colors.black12,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Upload your file",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.white),
                                      ),
                                      const Text("XML",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white)),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/xml_icon2.png",
                                                height: 55,
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 70),
                                                child: Text(
                                                  // nameFileEdit != ""
                                                  // ? nameFileEdit!
                                                  //     : data.kapal!.xmlFile != null
                                                  // ? data.kapal!.xmlFile!
                                                  //     : ""
                                                  value.nameFile != ""
                                                      ? value.nameFile!
                                                      : data.kapal!.xmlFile !=
                                                              null
                                                          ? data.kapal!.xmlFile!
                                                          : "",
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // InkWell(
                                //   onTap: () {
                                //     callsignController.clear();
                                //     flagController.clear();
                                //     classController.clear();
                                //     builderController.clear();
                                //     yearbuiltController.clear();
                                //     ipController.clear();
                                //     portController.clear();
                                //     vesselSize = null;
                                //     readNotifier.clearFile();
                                //     Navigator.pop(context);
                                //   },
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(10),
                                //       color: const Color(0xFFFF0000),
                                //     ),
                                //     padding: const EdgeInsets.all(5),
                                //     alignment: Alignment.center,
                                //     height: 30,
                                //     child: const Text("Batal"),
                                //   ),
                                // ),
                                // const SizedBox(
                                //   width: 5,
                                // ),
                                // InkWell(
                                //   onTap: () {
                                //     if (callsignController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Call Sign Masih Kosong...");
                                //       return;
                                //     }
                                //     if (flagController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Bendera Masih Kosong...");
                                //       return;
                                //     }
                                //     if (classController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Kelas Masih Kosong...");
                                //       return;
                                //     }
                                //     if (builderController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Builder Masih Kosong...");
                                //       return;
                                //     }
                                //     if (yearbuiltController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Tahun Pembuatan Masih Kosong...");
                                //       return;
                                //     }
                                //     if (ipController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom IP Pembuatan Masih Kosong...");
                                //       return;
                                //     }
                                //     if (portController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Port Masih Kosong...");
                                //       return;
                                //     }
                                //     if (vesselSize == null) {
                                //       EasyLoading.showError(
                                //           "Kolom Ukuran Kapal Masih Kosong...");
                                //       return;
                                //     }
                                //     List<String> dataEdit = [
                                //       data.kapal!.callSign!,
                                //       callsignController.text,
                                //       flagController.text,
                                //       classController.text,
                                //       builderController.text,
                                //       yearbuiltController.text,
                                //       ipController.text,
                                //       portController.text,
                                //       vesselSize!,
                                //     ];
                                //     readNotifier.editVessel(dataEdit, _pageSize,
                                //         context, readNotifier.file);
                                //     callsignController.clear();
                                //     flagController.clear();
                                //     classController.clear();
                                //     builderController.clear();
                                //     yearbuiltController.clear();
                                //     ipController.clear();
                                //     portController.clear();
                                //     vesselSize = null;
                                //     readNotifier.clearFile();
                                //   },
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(10),
                                //       color: const Color(0xFF399D44),
                                //     ),
                                //     padding: const EdgeInsets.all(5),
                                //     alignment: Alignment.center,
                                //     height: 30,
                                //     child: const Text("Simpan"),
                                //   ),
                                // ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueAccent),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (callsignController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Call Sign Masih Kosong...");
                                      return;
                                    }
                                    if (flagController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Bendera Masih Kosong...");
                                      return;
                                    }
                                    if (classController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Kelas Masih Kosong...");
                                      return;
                                    }
                                    if (builderController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Builder Masih Kosong...");
                                      return;
                                    }
                                    if (yearbuiltController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Tahun Pembuatan Masih Kosong...");
                                      return;
                                    }
                                    if (ipController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom IP Pembuatan Masih Kosong...");
                                      return;
                                    }
                                    if (portController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Port Masih Kosong...");
                                      return;
                                    }
                                    if (vesselSize == null) {
                                      EasyLoading.showError(
                                          "Kolom Ukuran Kapal Masih Kosong...");
                                      return;
                                    }
                                    List<String> dataEdit = [
                                      data.kapal!.callSign!,
                                      callsignController.text,
                                      flagController.text,
                                      classController.text,
                                      builderController.text,
                                      yearbuiltController.text,
                                      ipController.text,
                                      portController.text,
                                      vesselSize!,
                                    ];
                                    value.editVessel(dataEdit,
                                        context, value.file);
                                    callsignController.clear();
                                    flagController.clear();
                                    classController.clear();
                                    builderController.clear();
                                    yearbuiltController.clear();
                                    ipController.clear();
                                    portController.clear();
                                    vesselSize = null;
                                    value.clearFile();
                                  },
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              side: BorderSide(
                                                  color: Colors.blueAccent)))),
                                  onPressed: () {
                                    callsignController.clear();
                                    flagController.clear();
                                    classController.clear();
                                    builderController.clear();
                                    yearbuiltController.clear();
                                    ipController.clear();
                                    portController.clear();
                                    vesselSize = null;
                                    value.clearFile();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}