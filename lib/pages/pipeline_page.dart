import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:vts_maps/utils/alerts.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:vts_maps/utils/text_field.dart';
import 'package:vts_maps/api/GetPipelineResponse.dart' as PipelineResponse;

class PipelinePage{
  static TextEditingController nameController = TextEditingController();

  static PipelineList(BuildContext context,Notifier value){
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
                                " Pipeline List",
                                style: GoogleFonts.openSans(
                                    fontSize: 20,fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon:
                                const Icon(Icons.close),
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
                                  "Page ${value.currentPage} of ${(value.totalPipeline / 10).ceil()}"),
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
                                        value.initPipeline(context);
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
                                          addPipeline(context, value);
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
                        SizedBox(
                          height: 380,
                          width: double.infinity,
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                                scrollDirection:
                                Axis.horizontal,
                                child: value.isLoading
                                    ? const Center(
                                    child:
                                    CircularProgressIndicator())
                                    : SizedBox(
                                  width: 900,
                                  child: DataTable(
                                      headingRowColor:
                                      MaterialStateProperty
                                          .all(Color(
                                          0xffd3d3d3)),
                                      columns: [
                                        const DataColumn(
                                            label: Text(
                                                "Name")),
                                        const DataColumn(
                                            label: Text(
                                                "File")),
                                        const DataColumn(
                                            label: Text(
                                                "Switch")),
                                        const DataColumn(
                                            label: Text(
                                                "Action")),
                                      ],
                                      rows: value
                                          .getPipelineResult
                                          .map(
                                              (data) {
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                    Text(data
                                                        .name!)),
                                                DataCell(
                                                    Text(data
                                                        .file!)),
                                                DataCell(Text(data
                                                    .onOff!
                                                    ? "ON"
                                                    : "OFF")),
                                                DataCell(
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon:
                                                          const Icon(
                                                            Icons.edit,
                                                            color: Colors.blue,
                                                          ),
                                                          onPressed:
                                                              () {
                                                            editPipeline(data, context, value);
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon:
                                                          const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed:
                                                              () {
                                                            Alerts.showAlertYesNo(
                                                                title: "Are you sure you want to delete this data?",
                                                                onPressYes: () {
                                                                  value.deletePipeline(data.idMapping.toString(), context);
                                                                },
                                                                onPressNo: () {
                                                                  Navigator.pop(context);
                                                                },
                                                                context: context);
                                                          },
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            );
                                          }).toList()),
                                )),
                          ),
                        ),
                        Pagination(
                          numOfPages:
                          (value.totalPipeline / 10)
                              .ceil(),
                          selectedPage: value.currentPage,
                          pagesVisible: 7,
                          onPageChanged: (page) {
                            value.incrementPage(page);
                            value.initPipeline(context);
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
                            shape:
                            MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    38),
                              ),
                            ),
                          ),
                          inactiveBtnStyle: ButtonStyle(
                            shape:
                            MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(38),
                                )),
                          ),
                          inactiveTextStyle:
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ])));
        });
  }
  static addPipeline(BuildContext context, Notifier readNotifier) {
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
                          " Add Pipeline",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            nameController.clear();
                            readNotifier.switchControl(false);
                            readNotifier.clearFile();
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
                                readNotifier.selectFile("KMZ");
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
                                                  readNotifier.nameFile!,
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
                                  value: readNotifier.isSwitched,
                                  onChanged: (bool value) {
                                    readNotifier.switchControl(value);
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
                                          "Kolom Name Sign Masih Kosong...");
                                      return;
                                    }
                                    if (readNotifier.file == null) {
                                      EasyLoading.showError(
                                          "Kolom File Masih Kosong...");
                                      return;
                                    }
                                    readNotifier.submitPipeline(nameController.text,
                                        readNotifier.isSwitched, context, readNotifier.file);
                                    nameController.clear();
                                    readNotifier.switchControl(false);
                                    readNotifier.clearFile();
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
                                    readNotifier.switchControl(false);
                                    readNotifier.clearFile();
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

  static editPipeline(
      PipelineResponse.Data data, BuildContext context, Notifier readNotifier) {
    readNotifier.switchControl(data.onOff!);
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
                            readNotifier.switchControl(false);
                            readNotifier.clearFile();
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
                                readNotifier.selectFile("KMZ");
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
                                                  readNotifier.nameFile != ""
                                                      ? readNotifier.nameFile!
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
                                  value: readNotifier.isSwitched,
                                  onChanged: (bool value) {
                                    readNotifier.switchControl(value);
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
                                    readNotifier.editPipeline(
                                        data.idMapping.toString(),
                                        nameController.text,
                                        readNotifier.isSwitched,
                                        context,
                                        readNotifier.file);
                                    nameController.clear();
                                    readNotifier.switchControl(false);
                                    readNotifier.clearFile();
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
                                    readNotifier.switchControl(false);
                                    readNotifier.clearFile();
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
