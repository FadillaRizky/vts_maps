import "dart:async";
import "dart:convert";
import 'dart:html' as html;

import "package:dropdown_textfield/dropdown_textfield.dart";
import "package:flutter/material.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";
import "package:google_fonts/google_fonts.dart";
import "package:pagination_flutter/pagination.dart";
import "package:provider/provider.dart";
import "package:vts_maps/api/api.dart";
import "package:vts_maps/change_notifier/change_notifier.dart";
import "package:vts_maps/utils/alerts.dart";

import 'package:vts_maps/api/GetPipelineResponse.dart' as PipelineResponse;
import "package:vts_maps/utils/constants.dart";
import "package:vts_maps/utils/text_field.dart";
import "package:web_socket_channel/web_socket_channel.dart";

class PipelinePage extends StatefulWidget {
  const PipelinePage({super.key, this.id_client = ""});
  final String id_client;

  @override
  State<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends State<PipelinePage> {
  SingleValueDropDownController clientController =
      SingleValueDropDownController();
  String? idClientValue;
  bool isSwitched = false;
  TextEditingController nameController = TextEditingController();
  Notifier? readNotifier;

  int noRow = 1;
  int page = 1;
  int perpage = 10;

  bool load = false;

  incrementPage(int pageIndex) {
    page = pageIndex;
    load = true;
  }

  // Stream<PipelineResponse.GetPipelineResponse> pipelineStream() async* {
  //   PipelineResponse.GetPipelineResponse someProduct =
  //       await Api.getPipeline(page: page, perpage: perpage);
  //   yield someProduct;
  //   load = false;
  // }

  final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('wss://api.binav-avts.id:6001/socket-mapping?appKey=123456'));
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
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width / 1.5,
      child: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != "on Opened") {
            // var data = snapshot.data;
            // List<PipelineResponse.Data> pipeData = snapshot.data!.data!;

            final data = PipelineResponse.GetPipelineResponse.fromJson(
                jsonDecode(snapshot.data));
            List<PipelineResponse.Data> pipeData = data.data!;

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
                            " Pipeline List",
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
                              //                 BorderRadius
                              //                     .circular(
                              //                     5))),
                              //         backgroundColor:
                              //         MaterialStateProperty
                              //             .all(Colors
                              //             .blueAccent)),
                              //     onPressed: (){
                              //       value.initPipeline(context);
                              //     }, icon: Icon(Icons.refresh,color: Colors.white,),),
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
                                                    BorderRadius.circular(5))),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blueAccent)),
                                    onPressed: () {
                                      addPipeline(context);
                                      value.initClientList();
                                    },
                                    child: Text(
                                      "Add Pipeline",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: load
                            ? Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                                Color(0xffd3d3d3)),
                                        columns: [
                                          const DataColumn(label: Text("Name")),
                                          const DataColumn(label: Text("File")),
                                          const DataColumn(
                                              label: Text("Switch")),
                                          const DataColumn(
                                              label: Text("Action")),
                                        ],
                                        rows: pipeData.map((data) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(data.name!)),
                                              DataCell(Text(data.file!.replaceAll(
                                                  "https://client-project.enricko.site/storage/mapping/",
                                                  ""))),
                                              DataCell(Text(
                                                  data.onOff! ? "ON" : "OFF")),
                                              DataCell(Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                    onPressed: () {
                                                      editPipeline(
                                                          data, context);
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
                                                            value.deletePipeline(
                                                                data.idMapping
                                                                    .toString(),
                                                                context);
                                                            load = true;
                                                          },
                                                          onPressNo: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          context: context);
                                                    },
                                                  ),
                                                ],
                                              )),
                                            ],
                                          );
                                        }).toList())),
                              ),
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
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(38),
                          )),
                        ),
                        inactiveTextStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ]);
            });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  /// function CRUD PIPELINE
  void addPipeline(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          var width = MediaQuery.of(context).size.width;
          return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: SingleChildScrollView(
              child: Container(
                width: width / 2.5,
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
                            " Add Pipeline",
                            style: GoogleFonts.openSans(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              nameController.clear();
                              isSwitched = false;
                              readNotifier!.clearFile();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
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
                                  for (var x in readNotifier!.getClientResult)
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
                              height: 5,
                            ),
                            CustomTextField(
                              controller: nameController,
                              hint: 'Name',
                              type: TextInputType.text,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                readNotifier!.selectFile("KMZ");
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
                                      const Text("KMZ / KML",
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
                                                  readNotifier!.nameFile!,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // InkWell(
                                //   onTap: () {
                                //     ///
                                //     nameController.clear();
                                //     isSwitched = false;
                                //     value.clearFile();
                                //     Navigator.pop(context);
                                //
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
                                //     if (nameController.text.isEmpty) {
                                //       EasyLoading.showError(
                                //           "Kolom Name Sign Masih Kosong...");
                                //       return;
                                //     }
                                //     if (value.file == null) {
                                //       EasyLoading.showError(
                                //           "Kolom File Masih Kosong...");
                                //       return;
                                //     }
                                //     value.submitPipeline(nameController.text, isSwitched, context, value.file);
                                //     nameController.clear();
                                //     isSwitched = false;
                                //     value.clearFile();
                                //
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
                                // )
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
                                    if (nameController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Name Sign Masih Kosong...");
                                      return;
                                    }
                                    if (readNotifier!.file == null) {
                                      EasyLoading.showError(
                                          "Kolom File Masih Kosong...");
                                      return;
                                    }
                                    submitPipeline(
                                        idClientValue!,
                                        nameController.text,
                                        isSwitched,
                                        context,
                                        readNotifier!.file);
                                    idClientValue = null;
                                    clientController.clearDropDown();
                                    nameController.clear();
                                    isSwitched = false;
                                    readNotifier!.clearFile();
                                    load = true;
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
                                    idClientValue = null;
                                    clientController.clearDropDown();
                                    nameController.clear();
                                    isSwitched = false;
                                    readNotifier!.clearFile();
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
                  ],
                ),
              ),
            ),
          );
        });
  }

  void submitPipeline(
      String idClientValue, String name, bool onOff, context, file) async {
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
                "loading ..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
    await Api.submitPipeline(idClientValue, name, onOff, file).then((value) {
      print(value.message);
      // if (value.message == "Validator Fails") {
      //   Navigator.pop(context);
      //   EasyLoading.showError("Call Sign sudah Terdaftar");
      //   return;
      // }
      if (value.message == "Data berhasil masuk database") {
        Navigator.pop(context);
        EasyLoading.showSuccess("Berhasil Menambahkan Data");
        Navigator.pop(context);
        return;
      }
      if (value.message != "Data berhasil masuk database") {
        Navigator.pop(context);
        EasyLoading.showError("Gagal Menambahkan Data, Coba Lagi...");
        return;
      }
      return;
    });
  }

  void editPipeline(PipelineResponse.Data data, BuildContext context) {
    isSwitched = data.onOff!;
    nameController.text = data.name!;

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
                          " Edit Pipeline",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            nameController.clear();
                            isSwitched = false;
                            readNotifier!.clearFile();
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
                              controller: nameController,
                              hint: 'Name',
                              type: TextInputType.text,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                readNotifier!.selectFile("KMZ");
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
                                      const Text("KMZ / KML",
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
                                                  readNotifier!.nameFile != ""
                                                      ? readNotifier!.nameFile!
                                                      : data.file != null
                                                          ? data.file!
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
                                    if (nameController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Name Masih Kosong...");
                                      return;
                                    }
                                    editPipelineApi(
                                        data.idMapping.toString(),
                                        nameController.text,
                                        isSwitched,
                                        context,
                                        readNotifier!.file);
                                    nameController.clear();
                                    load = true;
                                    isSwitched = false;
                                    readNotifier!.clearFile();
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
                                    nameController.clear();
                                    isSwitched = false;
                                    readNotifier!.clearFile();
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

  void editPipelineApi(
      String id, String name, bool onOff, BuildContext context, file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
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
                "loading ..",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        );
      },
    );
    await Api.editPipeline(id, name, onOff, file).then((value) {
      if (value.message != "Data berhasil di ubah database") {
        Navigator.pop(context);
        EasyLoading.showError("Gagal Edit Data");
        Navigator.pop(context);
      }
      if (value.message == "Data berhasil di ubah database") {
        Navigator.pop(context);
        EasyLoading.showSuccess("Berhasil Edit Data");
        Navigator.pop(context);
      }
      return;
    });
  }
}
