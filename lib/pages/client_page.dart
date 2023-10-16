import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:provider/provider.dart';
import 'package:vts_maps/api/api.dart';
import 'package:vts_maps/change_notifier/change_notifier.dart';
import 'package:vts_maps/utils/alerts.dart';
import 'package:vts_maps/utils/constants.dart';
import 'package:vts_maps/utils/text_field.dart';
import 'package:vts_maps/api/GetClientListResponse.dart' as ClientList;

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailControler = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  bool load = false;
  int page = 1;
  int perpage = 10;

  Notifier? readNotifier;

  incrementPage(int pageIndex) {
    page = pageIndex;
    load = true;
  }

  Stream<ClientList.GetClientResponse> clientStream(
      {int page = 1, int perpage = 10}) async* {
    ClientList.GetClientResponse someProduct =
        await Api.getClientList(page: page, perpage: perpage);
    yield someProduct;
    load = false;
  }

  @override
  void initState() {
    readNotifier = context.read<Notifier>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width / 1.5,
      child: StreamBuilder<ClientList.GetClientResponse>(
          stream: clientStream(page: page, perpage: perpage),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var data = snapshot.data;
              List<ClientList.Data> clientData = snapshot.data!.data!;
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
                            " Client List",
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
                                      ///FUNCTION ADD CLIENT
                                      addClientList(context);
                                    },
                                    child: Text(
                                      "Add Client",
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
                    Container(
                      height: 380,
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
                                        const DataColumn(
                                            label: Text("Email")),
                                        const DataColumn(
                                            label: Text("Status")),
                                        const DataColumn(
                                            label: Text(
                                                "View Client Only Data")),
                                        const DataColumn(
                                            label: Text("Action")),
                                      ],
                                      rows: clientData.map((data) {
                                        return DataRow(cells: [
                                          DataCell(Text(data.clientName!)),
                                          DataCell(Text(data.email!)),
                                          DataCell(Text((data.status! == "1")
                                              ? "ACTIVE"
                                              : "INACTIVE")),
                                          DataCell(
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
                                                    ///FUNCTION VIEW CLIENT ONLY DATA
                                                     // addClientList(context);
                                                  },
                                                  child: Text(
                                                    "View Client",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          DataCell(Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  /// FUNCTION EDIT CLIENT
                                                  editClientList(
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
                                                          "Are you sure you want to delete this user?",
                                                      onPressYes: () {
                                                        /// FUNCTION DELETE CLIENT
                                                        value.deleteClient(
                                                            data.idClient,
                                                            context);
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
                                        ]);
                                      }).toList())),
                            ),
                    ),
                    Pagination(
                      numOfPages: (data!.total! / perpage).ceil(),
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
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(38),
                          ),
                        ),
                      ),
                      inactiveBtnStyle: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38),
                        )),
                      ),
                      inactiveTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  void addClientList(BuildContext context) {
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
                          " Add Client",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            nameController.clear();
                            emailControler.clear();
                            passwordController.clear();
                            confirmpasswordController.clear();
                            readNotifier!.switchControl(false);
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
                              controller: nameController,
                              hint: 'Name',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: emailControler,
                              hint: 'Email',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: passwordController,
                              hint: 'Password',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: confirmpasswordController,
                              hint: 'Confirm Password',
                              type: TextInputType.text,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                  value: readNotifier!.isSwitched,
                                  onChanged: (bool value) {
                                    readNotifier!.switchControl(value);
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
                                    if (emailControler.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Email Masih Kosong...");
                                      return;
                                    }
                                    if (passwordController.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Password Masih Kosong...");
                                      return;
                                    }
                                    if (confirmpasswordController
                                        .text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Confirm Password Masih Kosong...");
                                      return;
                                    }
                                    if (passwordController.text !=
                                        confirmpasswordController.text) {
                                      EasyLoading.showError(
                                          "The Password Confirmation does not match...");
                                      return;
                                    }
                                    var data = {
                                      "client_name": nameController.text,
                                      "email": emailControler.text,
                                      "password": passwordController.text,
                                      "password_confirmation":
                                          confirmpasswordController.text,
                                      "status":
                                          readNotifier!.isSwitched ? "1" : "0"
                                    };
                                    submitClient(context, data);
                                    nameController.clear();
                                    emailControler.clear();
                                    passwordController.clear();
                                    confirmpasswordController.clear();
                                    readNotifier!.switchControl(false);
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
                                    nameController.clear();
                                    emailControler.clear();
                                    passwordController.clear();
                                    confirmpasswordController.clear();
                                    readNotifier!.switchControl(false);
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
  void submitClient(BuildContext context,Map<String,String> data)async{
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
    await Api.createClient(data).then((value){
      print(value.message);
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

  void editClientList(
    ClientList.Data data,
    BuildContext context,
  ) {
    nameController.text = data.clientName!;
    emailControler.text = data.email!;
    readNotifier!.switchControl((data.status == "1") ? true : false);
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
                          " Edit Client",
                          style: GoogleFonts.openSans(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            nameController.clear();
                            emailControler.clear();
                            readNotifier!.switchControl(false);
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
                            CustomTextField(
                              controller: emailControler,
                              hint: 'Email',
                              type: TextInputType.text,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                  value: readNotifier!.isSwitched,
                                  onChanged: (bool value) {
                                    readNotifier!.switchControl(value);
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
                                    if (emailControler.text.isEmpty) {
                                      EasyLoading.showError(
                                          "Kolom Email Masih Kosong...");
                                      return;
                                    }
                                    var body = {
                                      "id_client": data.idClient!,
                                      "client_name": nameController.text,
                                      "email": emailControler.text,
                                      "status":
                                          readNotifier!.isSwitched ? "1" : "0"
                                    };
                                    editClient(body, context);
                                    nameController.clear();
                                    emailControler.clear();
                                    load = true;
                                    readNotifier!.switchControl(false);
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
                                    emailControler.clear();
                                    readNotifier!.switchControl(false);
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
  void editClient(Map <String,String> data,BuildContext context)async{
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
    await Api.updateClient(data).then((value) {
      print(value.message);
      if (value.status == 200) {
        Navigator.pop(context);
        EasyLoading.showSuccess("Berhasil Edit Data");
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
        EasyLoading.showError("Gagal Edit Data");
      }
      return;
    });
  }
}
