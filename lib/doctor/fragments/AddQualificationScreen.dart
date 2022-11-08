import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class AddQualificationScreen extends StatefulWidget {
  Qualification? qualification;
  List<Qualification>? qualificationList;
  GetDoctorDetailModel? data;

  AddQualificationScreen({this.qualification, this.data, this.qualificationList});

  @override
  _AddQualificationScreenState createState() => _AddQualificationScreenState();
}

class _AddQualificationScreenState extends State<AddQualificationScreen> {
  TextEditingController degreeCont = TextEditingController();
  TextEditingController universityCont = TextEditingController();
  TextEditingController yearCont = TextEditingController();

  FocusNode degreeFocus = FocusNode();
  FocusNode universityFocus = FocusNode();
  FocusNode yearFocus = FocusNode();

  DateTime selectedDate = DateTime.now();
  Qualification? qualification;
  List<Qualification> qualificationList = [];

  bool isUpdate = false;
  GetDoctorDetailModel? data;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    qualification = widget.qualification;
    data = widget.data;
    isUpdate = widget.qualification != null;
    if (isUpdate) {
      degreeCont.text = qualification!.degree!;
      universityCont.text = qualification!.university!;
      yearCont.text = qualification!.year!;
      selectedDate = DateFormat('yyyy').parse(qualification!.year!);
    }
  }

  addQualificationData() async {
    widget.qualificationList!.add(Qualification(
      university: universityCont.text,
      degree: degreeCont.text,
      year: yearCont.text,
      file: "",
    ));
    finish(context);
  }

  updateQualificationData() async {
    widget.qualificationList![widget.qualificationList!.indexOf(widget.qualification!)] = Qualification(
      university: "${universityCont.text}",
      degree: "${degreeCont.text}",
      year: "${yearCont.text}",
      file: "",
    );
    finish(context);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : primaryColor, statusBarIconBrightness: Brightness.light);

    degreeCont.dispose();
    universityCont.dispose();
    yearCont.dispose();
    degreeFocus.dispose();
    universityFocus.dispose();
    yearFocus.dispose();
    super.dispose();
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: degreeCont,
            focus: degreeFocus,
            textFieldType: TextFieldType.OTHER,
            decoration: textInputStyle(
              context: context,
              label: "lblDegree",
              suffixIcon: commonImage(imageUrl: "images/icons/degree.png", size: 10),
            ),
          ),
          20.height,
          AppTextField(
            controller: universityCont,
            focus: universityFocus,
            textFieldType: TextFieldType.OTHER,
            decoration: textInputStyle(
              context: context,
              label: "lblUniversity",
              suffixIcon: commonImage(imageUrl: "images/icons/collage.png", size: 10),
            ),
          ),
          20.height,
          AppTextField(
            controller: yearCont,
            focus: yearFocus,
            textFieldType: TextFieldType.OTHER,
            decoration: textInputStyle(
              context: context,
              label: "lblYear",
              suffixIcon: commonImage(imageUrl: "images/icons/calendar.png", size: 10),
            ),
            readOnly: true,
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return YearPicker(
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    dragStartBehavior: DragStartBehavior.start,
                    selectedDate: selectedDate,
                    onChanged: (s) {
                      finish(context);
                      yearCont.text = s.year.toString();
                      selectedDate = s;
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
          20.height,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
        appBar: appAppBar(
          context,
          name: !isUpdate ? languageTranslate('lblAddQualification') : languageTranslate('lblEditQualification'),
          actions: !isUpdate
              ? []
              : [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      //TODO
                    },
                  ),
                ],
        ),
        body: body(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.done, color: Colors.white),
          onPressed: () {
            isUpdate ? updateQualificationData() : addQualificationData();
            // isUpdate ? updateHolidays() : insertHolidays();
          },
        ),
      ),
    );
  }
}
