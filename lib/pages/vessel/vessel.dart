import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/api/api.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:vts_maps/pages/vessel/ip_kapal.dart';
import 'package:vts_maps/utils/alerts.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:vts_maps/utils/text_field.dart';
import 'package:vts_maps/api/GetKapalAndCoor.dart' as VesselCoor;
import 'package:vts_maps/api/GetAllVessel.dart' as Vessel;
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VesselPage extends StatefulWidget {
  const VesselPage({super.key, this.id_client =""});
  final String id_client;

  @override
  State<VesselPage> createState() => _VesselPageState();
}

class _VesselPageState extends State<VesselPage> {
  SingleValueDropDownController clientController =
      SingleValueDropDownController();
  String? idClientValue;
  TextEditingController callsignController = TextEditingController();
  TextEditingController flagController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController builderController = TextEditingController();
  TextEditingController yearbuiltController = TextEditingController();
  String? vesselSize;
  bool isSwitched = false;

  bool load = false;
  int page = 1;
  int perpage = 10;

  Notifier? readNotifier;

  incrementPage(int pageIndex) {
    page = pageIndex;
    load = true;
  }

  // Stream<Vessel.GetAllVessel> vesselStream(
  //     {int page = 1, int perpage = 10}) async* {
  //   Vessel.GetAllVessel someProduct =
  //       await Api.getAllVessel(page: page, perpage: perpage);
  //   yield someProduct;
  //   load = false;
  // }

  final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('wss://api.binav-avts.id:6001/socket-kapal?appKey=123456'));
  Timer? timer;

  void fetchData() {
    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      channel.sink.add(json.encode({
        // Give an parameter to fetch the data
        "page": page,
        "perpage": perpage,
        "id_client":widget.id_client
      }));
      load = false;
    });
  }

  void stopFetchingData() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  void initState() {
    fetchData();
    readNotifier = context.read<Notifier>();
    super.initState();
  }

  @override
  void dispose() {
    channel.sink.close();
    stopFetchingData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
        width: width / 1.5,
        child: StreamBuilder(
            stream: channel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data != "on Opened") {
                final data =
                    Vessel.GetAllVessel.fromJson(jsonDecode(snapshot.data));
                List<Vessel.Data> vesselData = data.data!;
                return Consumer<Notifier>(builder: (context, value, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.black12,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              " Vessel List",
                              style: GoogleFonts.openSans(
                                  fontSize: 20, fontWeight: FontWeight.bold),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "Page ${page} of ${(data!.total! / perpage).ceil()}"),

                            ///
                            Row(
                              children: [
                                // SizedBox(
                                //   height: 40,
                                //   width: 40,
                                //   child: IconButton(
                                //     style: ButtonStyle(
                                //         shape: MaterialStateProperty.all(
                                //             RoundedRectangleBorder(
                                //                 borderRadius:
                                //                     BorderRadius.circular(5))),
                                //         backgroundColor:
                                //             MaterialStateProperty.all(
                                //                 Colors.blueAccent)),
                                //     onPressed: () {
                                //       value.initVessel();
                                //     },
                                //     icon: Icon(
                                //       Icons.refresh,
                                //       color: Colors.white,
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5))),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.blueAccent)),
                                      onPressed: () {
                                        addVesselAndCoor(context, value);
                                        value.initClientList();
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
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: load
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : DataTable(
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                              Color(0xffd3d3d3)),
                                      columns: [
                                        const DataColumn(
                                            label: Text("CallSign")),
                                        const DataColumn(label: Text("Flag")),
                                        const DataColumn(label: Text("Class")),
                                        const DataColumn(
                                            label: Text("Builder")),
                                        const DataColumn(
                                            label: Text("Year Built")),
                                        const DataColumn(label: Text("Size")),
                                        const DataColumn(
                                            label: Text("File XML")),
                                        const DataColumn(
                                            label: Text("Upload IP ")),
                                        const DataColumn(label: Text("Action")),
                                      ],
                                      rows: vesselData.map((data) {
                                        return DataRow(cells: [
                                          DataCell(Text(data.callSign!)),
                                          DataCell(Text(data.flag!)),
                                          DataCell(Text(data.kelas!)),
                                          DataCell(Text(data.builder!)),
                                          DataCell(Text(data.yearBuilt!)),
                                          DataCell(Text(data.size!)),
                                          DataCell(SizedBox(
                                            width: 150,
                                            child: Text(
                                              data.xmlFile!.replaceAll(
                                                  "https://client-project.enricko.site/storage/xml/",
                                                  ""),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          )),
                                          DataCell(IconButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      var width =
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width;

                                                      return Dialog(
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                        child: IpKapalPage(
                                                            callSign:
                                                                data.callSign!),
                                                      );
                                                    });
                                              },
                                              icon: Icon(Icons
                                                  .edit_location_alt_outlined))),
                                          DataCell(Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.visibility,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  showDetailVessel(
                                                      data, context, value);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  editVesselAndCoor(
                                                      data, context, value);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  Alerts.showAlertYesNo(
                                                      title:
                                                          "Are you sure you want to delete this data?",
                                                      onPressYes: () {
                                                        value.deleteVessel(
                                                            data.callSign,
                                                            context);
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
                      Container(
                        height: 50,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Pagination(
                          numOfPages: (data.total! / perpage).ceil(),
                          selectedPage: page,
                          pagesVisible: 7,
                          onPageChanged: (page) {
                            incrementPage(page);
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
                                MaterialStateProperty.all(Colors.blue),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(38),
                              ),
                            ),
                          ),
                          inactiveBtnStyle: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38),
                            )),
                          ),
                          inactiveTextStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                });
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  void addVesselAndCoor(BuildContext context, Notifier value) {
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
                            clientController.clearDropDown();
                            callsignController.clear();
                            flagController.clear();
                            classController.clear();
                            builderController.clear();
                            yearbuiltController.clear();
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
                            SizedBox(
                              height: 35,
                              width: double.infinity,
                              child: DropDownTextField(
                                controller: clientController,
                                dropDownList: [
                                  for (var x in value.getClientResult)
                                    DropDownValueModel(
                                        name: '${x.clientName} - ${x.idClient}',
                                        value: "${x.idClient}"),
                                ],
                                clearOption: false,
                                enableSearch: true,
                                textStyle: TextStyle(color: Colors.black),
                                searchDecoration: const InputDecoration(
                                    hintText:
                                        "enter your custom hint text here"),
                                validator: (value) {
                                  if (value == null) {
                                    return "Required field";
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  idClientValue = clientController
                                      .dropDownValue!.value
                                      .toString();
                                  // SingleValueDropDownController(data: DropDownValueModel(value: "${data['role']}", name: "${data['role']}"))
                                },
                                textFieldDecoration: InputDecoration(
                                  labelText: "Pilih Client",
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
                            ),
                            SizedBox(
                              height: 10,
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
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                  value: isSwitched,
                                  onChanged: (bool value) {
                                    isSwitched = value;
                                  },
                                  activeTrackColor: Colors.lightGreen,
                                  activeColor: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),

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
                                    if (idClientValue!.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Client Masih Kosong...");
                                      return;
                                    }
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
                                      idClientValue!,
                                      callsignController.text,
                                      flagController.text,
                                      classController.text,
                                      builderController.text,
                                      yearbuiltController.text,
                                      vesselSize!,
                                    ];
                                    value.submitVessel(
                                        data, context, isSwitched, value.file);
                                    idClientValue = null;
                                    clientController.clearDropDown();
                                    callsignController.clear();
                                    flagController.clear();
                                    classController.clear();
                                    builderController.clear();
                                    yearbuiltController.clear();
                                    isSwitched = false;
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
                                    vesselSize = null;
                                    value.clearFile();
                                    isSwitched = false;
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

  void editVesselAndCoor(
      Vessel.Data data, BuildContext context, Notifier value) {
    callsignController.text = data.callSign!;
    flagController.text = data.flag!;
    classController.text = data.kelas!;
    builderController.text = data.builder!;
    yearbuiltController.text = data.yearBuilt!;
    vesselSize = data.size!;
    isSwitched = data.status!;

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
                            SizedBox(
                              height: 35,
                              width: double.infinity,
                              child: DropdownSearch<String>(
                                selectedItem: data.size ?? "",
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
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                  value: isSwitched,
                                  onChanged: (bool value) {
                                    isSwitched = value;
                                    print(value);
                                  },
                                  activeTrackColor: Colors.lightGreen,
                                  activeColor: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
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
                                                      : data.xmlFile != null
                                                          ? data.xmlFile!
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
                                    if (vesselSize == null) {
                                      EasyLoading.showError(
                                          "Kolom Ukuran Kapal Masih Kosong...");
                                      return;
                                    }
                                    List<String> dataEdit = [
                                      data.callSign!,
                                      callsignController.text,
                                      flagController.text,
                                      classController.text,
                                      builderController.text,
                                      yearbuiltController.text,
                                      vesselSize!,
                                    ];
                                    value.editVessel(dataEdit, context,
                                        isSwitched, value.file);
                                    callsignController.clear();
                                    flagController.clear();
                                    classController.clear();
                                    builderController.clear();
                                    yearbuiltController.clear();
                                    vesselSize = null;
                                    isSwitched = false;
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
                                    vesselSize = null;
                                    isSwitched = false;
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

  void showDetailVessel(
      Vessel.Data data, BuildContext context, Notifier value) {
    callsignController.text = data.callSign!;
    flagController.text = data.flag!;
    classController.text = data.kelas!;
    builderController.text = data.builder!;
    yearbuiltController.text = data.yearBuilt!;
    vesselSize = data.size!;
    isSwitched = data.status!;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          var width = MediaQuery.of(context).size.width;
          return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: SizedBox(
              width: width / 2,
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
                          " Detail Vessel",
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
                              enable: false,
                            ),
                            CustomTextField(
                              controller: flagController,
                              hint: 'Bendera',
                              type: TextInputType.text,
                              enable: false,
                            ),
                            CustomTextField(
                              controller: classController,
                              hint: 'Kelas',
                              type: TextInputType.text,
                              enable: false,
                            ),
                            CustomTextField(
                              controller: builderController,
                              hint: 'Builder',
                              type: TextInputType.text,
                              enable: false,
                            ),
                            CustomTextField(
                              controller: yearbuiltController,
                              hint: 'Tahun Pembuatan',
                              type: TextInputType.number,
                              enable: false,
                            ),
                            SizedBox(
                              height: 35,
                              width: double.infinity,
                              child: DropdownSearch<String>(
                                selectedItem: data.size ?? "",
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
                                      enabled: false),
                                ),
                                // items: [
                                //   "Small",
                                //   "Medium",
                                //   "Large",
                                // ],
                                // onChanged: (value) {
                                //   vesselSize = value;
                                // },
                              ),
                            ),
                            Text(
                              " List IP",
                              style: GoogleFonts.openSans(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            SizedBox(
                              height: 200,
                              child: SingleChildScrollView(
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: value.isLoadingIp
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : DataTable(
                                            headingRowColor:
                                                MaterialStateProperty.all(
                                                    Color(0xffd3d3d3)),
                                            columns: [
                                              const DataColumn(
                                                  label: SizedBox(
                                                      width: 200,
                                                      child: Text("IP"))),
                                              const DataColumn(
                                                  label: Text("Port")),
                                              const DataColumn(
                                                  label: Text("Type")),
                                              const DataColumn(
                                                  label: Text("Delete")),
                                            ],
                                            rows:
                                                value.ipPortResult.map((data) {
                                              return DataRow(cells: [
                                                DataCell(Text(data.ip!)),
                                                DataCell(Text(data.port!)),
                                                DataCell(Text(data.typeIp!)),
                                                DataCell(IconButton(
                                                  onPressed: () {
                                                    Alerts.showAlertYesNo(
                                                        title:
                                                            "Are you sure you want to delete this data?",
                                                        onPressYes: () {
                                                          value.deleteIP(
                                                              data.idIpKapal!,
                                                              data.callSign!,
                                                              context);
                                                        },
                                                        onPressNo: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        context: context);
                                                  },
                                                  icon: Icon(Icons.delete),
                                                )),
                                              ]);
                                            }).toList())),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                  value: isSwitched,
                                  onChanged: null,
                                  activeTrackColor: Colors.lightGreen,
                                  activeColor: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Card(
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
                                            fontSize: 10, color: Colors.white)),
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
                                              constraints:
                                                  BoxConstraints(maxWidth: 70),
                                              child: Text(
                                                // nameFileEdit != ""
                                                // ? nameFileEdit!
                                                //     : data.kapal!.xmlFile != null
                                                // ? data.kapal!.xmlFile!
                                                //     : ""
                                                value.nameFile != ""
                                                    ? value.nameFile!
                                                    : data.xmlFile != null
                                                        ? data.xmlFile!
                                                        : "",
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
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
                                    if (vesselSize == null) {
                                      EasyLoading.showError(
                                          "Kolom Ukuran Kapal Masih Kosong...");
                                      return;
                                    }
                                    List<String> dataEdit = [
                                      data.callSign!,
                                      callsignController.text,
                                      flagController.text,
                                      classController.text,
                                      builderController.text,
                                      yearbuiltController.text,
                                      vesselSize!,
                                    ];
                                    value.editVessel(dataEdit, context,
                                        isSwitched, value.file);
                                    callsignController.clear();
                                    flagController.clear();
                                    classController.clear();
                                    builderController.clear();
                                    yearbuiltController.clear();
                                    vesselSize = null;
                                    isSwitched = false;
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
                                    vesselSize = null;
                                    isSwitched = false;
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
