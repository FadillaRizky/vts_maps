import "dart:async";
import "dart:convert";

import "package:dropdown_search/dropdown_search.dart";
import "package:flutter/material.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import "package:vts_maps/change_notifier/change_notifier.dart";
import "package:vts_maps/utils/alerts.dart";
import "package:vts_maps/utils/constants.dart";
import "package:vts_maps/utils/text_field.dart";
import "package:web_socket_channel/web_socket_channel.dart";

import 'package:vts_maps/api/GetIpListResponse.dart' as IpKapal;

class IpKapalPage extends StatefulWidget {
  const IpKapalPage({super.key, required this.callSign});
  final String callSign;

  @override
  State<IpKapalPage> createState() => _IpKapalPageState();
}

class _IpKapalPageState extends State<IpKapalPage> {
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  String? type;
  bool load = false;

  final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('wss://api.binav-avts.id:6001/socket-ipKapal?appKey=123456'));
  Timer? timer;

  void fetchData() {
    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      channel.sink.add(json.encode({
        // Give an parameter to fetch the data
        "call_sign": widget.callSign
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
    return StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != "on Opened") {
            final data =
                IpKapal.GetIpListResponse.fromJson(jsonDecode(snapshot.data));
            IpKapal.Kapal vesselData = data.kapal!;
            List<IpKapal.Data> ipData = data.data!;
            return Consumer<Notifier>(builder: (context, readNotifier, child) {
              return Container(
                color: Colors.white,
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
                            " Upload Ip & Port",
                            style: GoogleFonts.openSans(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              ipController.clear();
                              portController.clear();
                              readNotifier.clearType();
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
                                            contentPadding:
                                                EdgeInsets.fromLTRB(8, 3, 1, 3),
                                            labelText: "Port",
                                            labelStyle: Constants.labelstyle,
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.blueAccent),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.black38)),
                                            filled: true,
                                            fillColor: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  SizedBox(
                                    height: 35,
                                    width: 150,
                                    child: DropdownSearch<String>(
                                      dropdownBuilder:
                                          (context, selectedItem) => Text(
                                        selectedItem ?? "",
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54),
                                      ),
                                      popupProps:
                                          PopupPropsMultiSelection.dialog(
                                        fit: FlexFit.loose,
                                        itemBuilder:
                                            (context, item, isSelected) =>
                                                ListTile(
                                          title: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "Type",
                                          labelStyle: Constants.labelstyle,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.blueAccent),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black38)),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  8, 3, 1, 3),
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
                                        readNotifier.selectingType(value!);
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
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.blueAccent),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                      if (readNotifier.type == "") {
                                        EasyLoading.showError(
                                            "Kolom Type Masih Kosong...");
                                        return;
                                      }
                                      Map<String, String> data = {
                                        "call_sign": widget.callSign,
                                        "ip": ipController.text,
                                        "port": portController.text,
                                        "type_ip": readNotifier.type!,
                                      };
                                      readNotifier.uploadIP(
                                          data, context, widget.callSign);
                                      ipController.clear();
                                      portController.clear();
                                      load = true;
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
                              SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                height: 300,
                                child: load
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : SingleChildScrollView(
                                        child: DataTable(
                                            headingRowColor:
                                                MaterialStateProperty.all(
                                                    Color(0xffd3d3d3)),
                                            columns: [
                                              const DataColumn(
                                                  label: SizedBox(
                                                      width: 210,
                                                      child: Text("IP"))),
                                              const DataColumn(
                                                  label: Text("Port")),
                                              const DataColumn(
                                                  label: Text("Type")),
                                              const DataColumn(
                                                  label: Text("Delete")),
                                            ],
                                            rows: ipData.map((data) {
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
                                                          readNotifier.deleteIP(
                                                              data.idIpKapal!,
                                                              data.callSign!,
                                                              context);
                                                          load = true;
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
                                            }).toList()),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
