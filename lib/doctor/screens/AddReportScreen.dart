import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class AddReportScreen extends StatefulWidget {
  final int? patientId;

  AddReportScreen({this.patientId});

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController nameCont = TextEditingController();
  TextEditingController dateCont = TextEditingController();
  TextEditingController fileCont = TextEditingController();

  int pages = 0;
  int currentPage = 0;

  bool isReady = false;
  bool isLoading = false;

  String errorMessage = '';

  DateTime current = DateTime.now();

  FilePickerResult? result;
  File? file;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  void PickSingleFile() async {
    result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = File(result!.files.single.path!);

      fileCont.text = file!.path.substring(file!.path.lastIndexOf("/") + 1);
      setState(() {});
    } else {
      toast(languageTranslate('lblNoReportWasSelected'));
    }
  }

  void saveData() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});

      Map<String, dynamic> res = {
        "name": "${nameCont.text}",
        "patient_id": "${widget.patientId}",
        "date": "${current.getFormattedDate('yyyy-MM-dd')}",
      };
      addReportData(res, file: file != null ? File(file!.path) : null).then((value) {
        isLoading = false;
        setState(() {});
        finish(context, true);
      }).catchError((e) {
        toast(e.toString());
      });
    }
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            AppTextField(controller: nameCont, textFieldType: TextFieldType.NAME, decoration: textInputStyle(context: context, text: "Name")),
            16.height,
            AppTextField(
              onTap: () async {
                DateTime? dateTime = await showDatePicker(
                  context: context,
                  initialDate: current,
                  firstDate: DateTime(1900),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: appStore.isDarkModeOn
                          ? ThemeData.dark()
                          : ThemeData.light().copyWith(
                              primaryColor: Color(0xFF4974dc),
                              accentColor: const Color(0xFF4974dc),
                              colorScheme: ColorScheme.light(primary: const Color(0xFF4974dc)),
                            ),
                      child: child!,
                    );
                  },
                  lastDate: DateTime.now(),
                );
                if (dateTime != null) {
                  dateCont.text = dateTime.getFormattedDate('dd-MMM-yyyy');
                  current = dateTime;
                }
              },
              controller: dateCont,
              readOnly: true,
              textFieldType: TextFieldType.OTHER,
              validator: (s) {
                if (s!.trim().isEmpty) return languageTranslate('lblDatecantBeNull');
                return null;
              },
              decoration: textInputStyle(context: context, text: 'Date').copyWith(
                suffixIcon: Icon(Icons.date_range),
              ),
            ),
            16.height,
            AppTextField(
              controller: fileCont,
              textFieldType: TextFieldType.NAME,
              decoration: textInputStyle(context: context, text: languageTranslate('lblUploadReport')).copyWith(
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.upload_file),
                      onPressed: () {
                        PickSingleFile();
                      },
                    ),
                    file == null
                        ? Offstage()
                        : IconButton(
                            icon: Icon(Icons.remove_red_eye_outlined),
                            onPressed: () {
                              //
                            },
                          ),
                  ],
                ),
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblAddReportScreen')),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            saveData();
          },
          child: Icon(Icons.check, color: Colors.white),
        ),
      ),
    );
  }
}
