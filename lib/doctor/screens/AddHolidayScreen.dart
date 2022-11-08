import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/HolidayModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/receiptionist/components/DoctorDropDown.dart';
import 'package:nb_utils/nb_utils.dart';

class AddHolidayScreen extends StatefulWidget {
  final HolidayData? holidayData;

  AddHolidayScreen({this.holidayData});

  @override
  _AddHolidayScreenState createState() => _AddHolidayScreenState();
}

class _AddHolidayScreenState extends State<AddHolidayScreen> {
  DateTime selectedDate = DateTime.now();
  var formKey = GlobalKey<FormState>();

  TextEditingController toDateCont = TextEditingController();
  TextEditingController clinicId = TextEditingController();

  HolidayData? holidayData;
  DateTimeRange? picked = DateTimeRange(start: DateTime.now(), end: DateTime.now());

  bool isUpdate = false;
  bool isLoading = false;

  int? totalLeaveInDays;
  DoctorList? doctorCont;
  String? moduleCont;

  insertHolidays() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});
      Map request = {};

      if (moduleCont == "doctor" || moduleCont == null) {
        request = {
          "start_date": picked!.start.getFormattedDate(CONVERT_DATE),
          "end_date": picked!.end.getFormattedDate(CONVERT_DATE),
          "module_type": DOCTOR,
          "module_id": "${doctorCont == null ? getIntAsync(USER_ID) : doctorCont!.iD.validate()}",
          "description": "",
        };
      } else {
        request = {
          "start_date": picked!.start.getFormattedDate(CONVERT_DATE),
          "end_date": picked!.end.getFormattedDate(CONVERT_DATE),
          "module_type": CLINIC,
          "module_id": getIntAsync(USER_CLINIC),
          "description": "",
        };
      }

      addHolidayData(request).then((value) {
        successToast('${value['message']}');
        finish(context, true);
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }

  updateHolidays() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});
      Map request = {};

      if (moduleCont == "doctor" || moduleCont == null) {
        request = {
          "id": holidayData!.id,
          "start_date": picked!.start.getFormattedDate(CONVERT_DATE),
          "end_date": picked!.end.getFormattedDate(CONVERT_DATE),
          "module_type": DOCTOR,
          "module_id": "${doctorCont == null ? getIntAsync(USER_ID) : doctorCont!.iD.validate()}",
          "description": "",
        };
      } else {
        request = {
          "id": holidayData!.id,
          "start_date": picked!.start.getFormattedDate(CONVERT_DATE),
          "end_date": picked!.end.getFormattedDate(CONVERT_DATE),
          "module_type": CLINIC,
          "module_id": getIntAsync(USER_CLINIC),
          "description": "",
        };
      }

      addHolidayData(request).then((value) {
        successToast('${value['message']}');
        finish(context, true);
      }).catchError((e) {
        toast(e);
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }

  deleteHoliday() async {
    Map request = {
      "id": holidayData!.id,
    };
    isLoading = true;
    setState(() {});
    deleteHolidayData(request).then((value) {
      finish(context, true);
      successToast('${value['message']}');
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor, statusBarIconBrightness: Brightness.light);

    holidayData = widget.holidayData;
    isUpdate = widget.holidayData != null;
    if (isUpdate) {
      listAppStore.doctorList.forEach((element) {
        if (element!.iD.toString() == holidayData!.module_id) {
          doctorCont = element;
        }
      });
      if (!isDoctor()) {
        moduleCont = holidayData!.module_type;
      }
      picked = DateTimeRange(
        start: DateTime.parse(holidayData!.start_date.validate()),
        end: DateTime.parse(holidayData!.end_date.validate()),
      );
      toDateCont.text = "${holidayData!.start_date!.getFormattedDate('dd-MMM-yyyy')} - ${holidayData!.end_date!.getFormattedDate('dd-MMM-yyyy')}";
      totalLeaveInDays = DateTime.parse(holidayData!.end_date!).difference(DateTime.parse(holidayData!.start_date!)).inDays;
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    toDateCont.dispose();
    clinicId.dispose();
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  Widget body() {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          !isDoctor()
              ? DropdownButtonFormField<String>(
                  decoration: textInputStyle(
                    context: context,
                    label: 'lblHolidayOf',
                    isMandatory: true,
                    suffixIcon: commonImage(
                      imageUrl: "images/icons/arrowDown.png",
                      size: 10,
                    ),
                  ),
                  isExpanded: true,
                  icon: SizedBox.shrink(),
                  dropdownColor: Theme.of(context).cardColor,
                  value: moduleCont,
                  validator: (v) {
                    if (v == null) return languageTranslate('lblModuleIsRequired');
                    return null;
                  },
                  onChanged: (value) {
                    moduleCont = value;
                    setState(() {});
                  },
                  items: [DOCTOR, CLINIC]
                      .map(
                        (e) => DropdownMenuItem<String>(child: Text(e.capitalizeFirstLetter(), style: primaryTextStyle()), value: e),
                      )
                      .toList(),
                )
              : 0.height,
          16.height,
          moduleCont == "doctor"
              ? DoctorDropDown(
                  doctorCont: doctorCont,
                  doctorId: doctorCont?.iD.validate(),
                  isValidate: true,
                  onSelected: (value) {
                    doctorCont = value;
                    setState(() {});
                  },
                ).visible(!isDoctor())
              : 0.height,
          16.height,
          AppTextField(
            onTap: () async {
              picked = await showDateRangePicker(
                firstDate: selectedDate,
                initialDateRange: picked,
                helpText: languageTranslate('lblScheduleDate'),
                context: context,
                locale: Locale(appStore.selectedLanguage),
                lastDate: DateTime(2101),
                errorFormatText: "Test!",
                errorInvalidText: "Test3",
                errorInvalidRangeText: "Test2",
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
              ).catchError((e) {
                errorToast(languageTranslate("lblCantEditDate"));
              });
              if (picked != null) {
                toDateCont.text = "${picked!.start.getFormattedDate('dd-MMM-yyyy')} - ${picked!.end.getFormattedDate('dd-MMM-yyyy')}";
                totalLeaveInDays = (picked!.end.difference(picked!.start)).inDays;
                setState(() {});
              }
            },
            controller: toDateCont,
            validator: (v) {
              if (v!.trim().isEmpty) return languageTranslate('lblDateIsRequired');
              return null;
            },
            textFieldType: TextFieldType.OTHER,
            suffix: Icon(Icons.date_range_outlined),
            decoration: textInputStyle(context: context, label: 'lblScheduleDate'),
            readOnly: true,
          ),
          8.height,
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              languageTranslate('lblLeaveFor') + ' $totalLeaveInDays ' + languageTranslate('lblDays'),
              style: secondaryTextStyle(size: 16, color: primaryColor),
            ).visible(
              totalLeaveInDays != null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(
          context,
          name: !isUpdate ? languageTranslate('lblAddHoliday') : languageTranslate('lblEditHolidays'),
          actions: !isUpdate
              ? []
              : [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool? res = await showConfirmDialog(context, languageTranslate('lblAreYouSureToDelete'), buttonColor: primaryColor);
                      if (res ?? false) {
                        deleteHoliday();
                      }
                    },
                  ),
                ],
          backgroundColor: primaryColor,
        ),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            isUpdate ? updateHolidays() : insertHolidays();
          },
          child: Icon(Icons.done, color: Colors.white),
        ).visible(!isLoading),
      ),
    );
  }
}
