import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/ClinicDropDown.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/DoctorScheduleModel.dart';
import 'package:kivicare_flutter/main/model/LoginResponseModel.dart';
import 'package:kivicare_flutter/main/model/WeekDaysModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/receiptionist/components/DoctorDropDown.dart';
import 'package:nb_utils/nb_utils.dart';

class AddSessionsScreen extends StatefulWidget {
  final SessionData? sessionData;

  AddSessionsScreen({this.sessionData});

  @override
  _AddSessionsScreenState createState() => _AddSessionsScreenState();
}

class _AddSessionsScreenState extends State<AddSessionsScreen> {
  SessionData? sessionData;

  var formKey = GlobalKey<FormState>();

  bool isUpdate = false;
  bool isLoading = false;

  late DoctorList doctorCont;
  late Clinic selectedClinic;

  List<WeekDaysModel> weekDays = [];
  List<int> timeSlots = [];
  List<Clinic> clinicList = [];

  int? timeSlotCont;

  TextEditingController morningStartTimeCont = TextEditingController();
  TextEditingController morningEndTimeCont = TextEditingController();
  TextEditingController eveningStartTimeCont = TextEditingController();
  TextEditingController eveningEndTimeCont = TextEditingController();

  FocusNode morningStartTimeFocus = FocusNode();
  FocusNode morningEndTimeFocus = FocusNode();
  FocusNode eveningStartTimeFocus = FocusNode();
  FocusNode eveningEndTimeFocus = FocusNode();

  DateTime? morningStartDateTime = DateTime.now();
  DateTime? morningEndDateTime = DateTime.now();
  DateTime? eveningStartDateTime = DateTime.now();
  DateTime? eveningEndDateTime = DateTime.now();

  addDetails() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      List<String> temp = [];
      weekDays.forEach((element) {
        if (element.isSelected == true) {
          temp.add(element.name!.toLowerCase());
        }
      });

      if (temp.isEmpty) {
        toast(languageTranslate('lblSelectWeekdays'));
      } else {
        isLoading = true;
        setState(() {});
        Map<String, dynamic> request = {
          "time_slot": timeSlotCont.validate(),
          "day": temp,
        };

        if (morningStartTimeCont.text.isNotEmpty) {
          request.putIfAbsent("s_one_start_time", () => {"HH": "${morningStartDateTime!.hour}", "mm": "${morningStartDateTime!.minute}"});
        }
        if (morningEndTimeCont.text.isNotEmpty) {
          request.putIfAbsent("s_one_end_time", () => {"HH": "${morningEndDateTime!.hour}", "mm": "${morningEndDateTime!.minute}"});
        }
        if (eveningStartTimeCont.text.isNotEmpty) {
          request.putIfAbsent("s_two_start_time", () => {"HH": "${eveningStartDateTime!.hour}", "mm": "${eveningStartDateTime!.minute}"});
        }
        if (eveningEndTimeCont.text.isNotEmpty) {
          request.putIfAbsent("s_two_end_time", () => {"HH": "${eveningEndDateTime!.hour}", "mm": "${eveningEndDateTime!.minute}"});
        }
        if (isDoctor()) {
          if (isProEnabled()) {
            request.putIfAbsent("clinic_id", () => selectedClinic.clinic_id);
            request.putIfAbsent("doctor_id", () => getIntAsync(USER_ID));
          } else {
            request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
            request.putIfAbsent("doctor_id", () => getIntAsync(USER_ID));
          }
        }
        if (isReceptionist()) {
          request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
          request.putIfAbsent("doctor_id", () => doctorCont.iD);
        }

        addDoctorSessionData(request).then((value) {
          successToast(languageTranslate('lblSessionAddedSuccessfully'));
          finish(context, true);
        }).catchError((e) {
          errorToast(e.toString());
        }).whenComplete(() {
          isLoading = false;
          setState(() {});
        });
      }
    }
  }

  updateDetails() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      List<String> temp = [];
      weekDays.forEach((element) {
        if (element.isSelected == true) {
          temp.add(element.name!.toLowerCase());
        }
      });
      isLoading = true;
      setState(() {});
      Map request = {
        "id": sessionData!.id,
        "clinic_id": getIntAsync(USER_CLINIC),
        "doctor_id": getStringAsync(USER_ROLE) == UserRoleDoctor ? getIntAsync(USER_ID) : doctorCont.iD,
        "time_slot": timeSlotCont.validate(),
        "day": temp,
      };

      if (morningStartTimeCont.text.isNotEmpty) {
        request.putIfAbsent("s_one_start_time", () => {"HH": "${morningStartDateTime!.hour}", "mm": "${morningStartDateTime!.minute}"});
      }
      if (morningEndTimeCont.text.isNotEmpty) {
        request.putIfAbsent("s_one_end_time", () => {"HH": "${morningEndDateTime!.hour}", "mm": "${morningEndDateTime!.minute}"});
      }
      if (eveningStartTimeCont.text.isNotEmpty) {
        request.putIfAbsent("s_two_start_time", () => {"HH": "${eveningStartDateTime!.hour}", "mm": "${eveningStartDateTime!.minute}"});
      }
      if (eveningEndTimeCont.text.isNotEmpty) {
        request.putIfAbsent("s_two_end_time", () => {"HH": "${eveningEndDateTime!.hour}", "mm": "${eveningEndDateTime!.minute}"});
      }
      if (isDoctor()) {
        if (isProEnabled()) {
          request.putIfAbsent("clinic_id", () => selectedClinic.clinic_id);
          request.putIfAbsent("doctor_id", () => getIntAsync(USER_ID));
        } else {
          request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
          request.putIfAbsent("doctor_id", () => getIntAsync(USER_ID));
        }
      }
      if (isReceptionist()) {
        request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
        request.putIfAbsent("doctor_id", () => doctorCont.iD);
      }

      addDoctorSessionData(request).then((value) {
        successToast(languageTranslate('lblSessionUpdatedSuccessfully'));
        finish(context, true);
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }

  deleteSession() {
    isLoading = true;
    setState(() {});

    Map request = {"id": "${sessionData!.id}"};
    deleteDoctorSessionData(request).then((value) {
      successToast(languageTranslate('lblSessionDeleted'));
      finish(context, true);
    }).catchError((s) {
      errorToast(languageTranslate('lblSessionDeleted'));
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

  Future<void> init() async {
    await getConfiguration().catchError(log);
    for (int i = 1; i <= 60; i++) {
      if (i % 5 == 0) {
        timeSlots.add(i);
      }
    }

    for (int i = 1; i <= 7; i++) {
      weekDays.add(WeekDaysModel(name: i.getWeekDays(), value: i.getWeekDays().toLowerCase(), isSelected: false));
      setState(() {});
    }

    isUpdate = widget.sessionData != null;
    if (isUpdate) {
      sessionData = widget.sessionData;

      String morningStart = '00:00';
      String morningEnd = '00:00';
      String eveningStart = '00:00';
      String eveningEnd = '00:00';

      if (sessionData!.s_one_start_time!.hH!.isNotEmpty) {
        morningStart = '${sessionData!.s_one_start_time!.hH.validate(value: '00')}:${sessionData!.s_one_start_time!.mm.validate(value: '00')}';
      }
      if (sessionData!.s_one_start_time!.hH!.isNotEmpty) {
        morningEnd = '${sessionData!.s_one_end_time!.hH.validate(value: '00')}:${sessionData!.s_one_end_time!.mm.validate(value: '00')}';
      }
      if (sessionData!.s_two_start_time!.hH!.isNotEmpty) {
        eveningStart = '${sessionData!.s_two_start_time!.hH.validate(value: '00')}:${sessionData!.s_two_start_time!.mm.validate(value: '00')}';
      }
      if (sessionData!.s_two_start_time!.hH!.isNotEmpty) {
        eveningEnd = '${sessionData!.s_two_end_time!.hH.validate(value: '00')}:${sessionData!.s_two_end_time!.mm.validate(value: '00')}';
      }

      morningStartDateTime = DateFormat('HH:mm').parse('$morningStart');
      morningEndDateTime = DateFormat('HH:mm').parse('$morningEnd');
      eveningStartDateTime = DateFormat('HH:mm').parse('$eveningStart');
      eveningEndDateTime = DateFormat('HH:mm').parse('$eveningEnd');

      timeSlotCont = sessionData!.time_slot.toInt();
      morningStartTimeCont.text = morningStartDateTime!.getFormattedDate('HH:mm');
      morningEndTimeCont.text = morningEndDateTime!.getFormattedDate('HH:mm');
      eveningStartTimeCont.text = eveningStartDateTime!.getFormattedDate('HH:mm');
      eveningEndTimeCont.text = eveningEndDateTime!.getFormattedDate('HH:mm');

      setState(() {});
      weekDays.forEach((weekDays) {
        sessionData!.days!.forEach((element) {
          if (element == weekDays.name!.toLowerCase()) {
            weekDays.isSelected = true;
          }
        });
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<DateTime?> timeBottomSheet(context, {DateTime? initial, bool? aIsMorning, bool? aIsEvening}) async {
    DateTime? picked = initial;
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext e) {
        return Container(
          height: 250,
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(languageTranslate('lblCancel'), style: primaryTextStyle(size: 18)).onTap(() {
                      finish(context);
                      toast(languageTranslate('lblPleaseSelectTime'));
                    }),
                    Text(languageTranslate('lblDone'), style: primaryTextStyle(size: 18)).onTap(() {
                      if ((picked!.minute % 5) == 0) {
                        if (aIsMorning ?? false) {
                          if (picked!.getFormattedDate('HH:mm') == morningStartDateTime!.getFormattedDate('HH:mm')) {
                            toast(languageTranslate('lblStartAndEndTimeNotSame'));
                          } else {
                            bool check = morningStartDateTime!.isBefore(picked!);
                            if (check) {
                              finish(context, picked);
                            } else {
                              toast(languageTranslate('lblTimeNotBeforeMorningStartTime'));
                            }
                          }
                        } else if (aIsEvening ?? false) {
                          if (picked!.getFormattedDate('HH:mm') == eveningStartDateTime!.getFormattedDate('HH:mm')) {
                            toast(languageTranslate('lblStartAndEndTimeNotSame'));
                          } else {
                            bool check = eveningStartDateTime!.isBefore(picked!);
                            if (check) {
                              finish(context, picked);
                            } else {
                              toast(languageTranslate('lblTimeNotBeforeEveningStartTime'));
                            }
                          }
                        } else {
                          finish(context, picked);
                        }
                      } else {
                        toast(languageTranslate('lblTimeShouldBeInMultiplyOf5'));
                      }
                    })
                  ],
                ).paddingAll(8.0),
              ),
              Container(
                height: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: primaryTextStyle(size: 20),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    backgroundColor: Theme.of(context).cardColor,
                    minuteInterval: 1,
                    initialDateTime: picked,
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime dateTime) {
                      picked = dateTime;
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    return picked;
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (isDoctor() && isProEnabled())
                ? ClinicDropDown(
                    clinicId: sessionData?.clinic_id?.toInt(),
                    isValidate: true,
                    onSelected: (Clinic? clinic) {
                      selectedClinic = clinic!;
                    },
                  )
                : 0.height,
            DoctorDropDown(
              clinicId: getIntAsync(USER_CLINIC),
              doctorId: sessionData?.doctor_id?.toInt(),
              isValidate: true,
              onSelected: (value) {
                doctorCont = value!;
                setState(() {});
              },
            ).visible(isReceptionist()),
            16.height,
            DropdownButtonFormField(
              value: timeSlotCont,
              icon: SizedBox.shrink(),
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              decoration: textInputStyle(
                context: context,
                label: 'lblTimeSlotInMinute',
                suffixIcon: commonImage(
                  imageUrl: "images/icons/arrowDown.png",
                  size: 10,
                ),
              ),
              validator: (dynamic v) {
                if (v == null) return languageTranslate('lblTimeSlotRequired');
                return null;
              },
              items: List.generate(
                timeSlots.length,
                (index) {
                  return DropdownMenuItem(
                    child: Text("${timeSlots[index]}", style: primaryTextStyle()),
                    value: timeSlots[index],
                  );
                },
              ),
              onChanged: (dynamic e) {
                timeSlotCont = e;
                setState(() {});
              },
            ),
            16.height,
            Text(languageTranslate('lblWeekDays'), style: boldTextStyle()),
            8.height,
            Wrap(
                spacing: 8,
                children: List.generate(weekDays.length, (index) {
                  WeekDaysModel data = weekDays[index];
                  return FilterChip(
                    backgroundColor: Theme.of(context).cardColor,
                    label: Text(data.name.validate()),
                    labelStyle: primaryTextStyle(size: 14),
                    selected: data.isSelected!,
                    onSelected: (bool selected) {
                      data.isSelected = !data.isSelected!;
                      setState(() {});
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                      //side: BorderSide(color: viewLineColor),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    selectedColor: Theme.of(context).accentColor,
                    checkmarkColor: Colors.white,
                  );
                })),
            16.height,
            Text(languageTranslate('lblMorningSession'), style: boldTextStyle()),
            16.height,
            Row(
              children: [
                AppTextField(
                  controller: morningStartTimeCont,
                  textFieldType: TextFieldType.OTHER,
                  decoration: textInputStyle(
                    context: context,
                    label: 'lblStartTime',
                    suffixIcon: commonImage(
                      imageUrl: "images/icons/timer.png",
                      size: 10,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? result = await timeBottomSheet(context, initial: morningStartDateTime);
                    morningStartDateTime = result;
                    setState(() {});
                    morningStartTimeCont.text = morningStartDateTime!.getFormattedDate('HH:mm');
                  },
                ).expand(),
                8.width,
                AppTextField(
                  controller: morningEndTimeCont,
                  textFieldType: TextFieldType.OTHER,
                  decoration: textInputStyle(
                    context: context,
                    label: 'lblEndTime',
                    suffixIcon: commonImage(
                      imageUrl: "images/icons/timer.png",
                      size: 10,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    if (morningStartTimeCont.text.isNotEmpty) {
                      DateTime? result = await timeBottomSheet(context, initial: morningEndDateTime, aIsMorning: true);

                      morningEndDateTime = result;
                      setState(() {});
                      morningEndTimeCont.text = morningEndDateTime!.getFormattedDate('HH:mm');
                    } else {
                      toast(languageTranslate('lblSelectStartTimeFirst'));
                    }
                  },
                ).expand()
              ],
            ),
            16.height,
            Text(languageTranslate('lblEveningSession'), style: boldTextStyle()),
            16.height,
            Row(
              children: [
                AppTextField(
                  controller: eveningStartTimeCont,
                  textFieldType: TextFieldType.OTHER,
                  decoration: textInputStyle(
                    context: context,
                    label: 'lblStartTime',
                    suffixIcon: commonImage(
                      imageUrl: "images/icons/timer.png",
                      size: 10,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? result = await timeBottomSheet(context, initial: eveningStartDateTime);
                    eveningStartDateTime = result;
                    setState(() {});
                    eveningStartTimeCont.text = eveningStartDateTime!.getFormattedDate('HH:mm');
                  },
                ).expand(),
                8.width,
                AppTextField(
                  controller: eveningEndTimeCont,
                  textFieldType: TextFieldType.OTHER,
                  decoration: textInputStyle(
                    context: context,
                    label: 'lblEndTime',
                    suffixIcon: commonImage(
                      imageUrl: "images/icons/timer.png",
                      size: 10,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    if (eveningStartTimeCont.text.isNotEmpty) {
                      DateTime? result = await timeBottomSheet(context, initial: eveningEndDateTime, aIsEvening: true);
                      eveningEndDateTime = result;
                      setState(() {});
                      eveningEndTimeCont.text = eveningEndDateTime!.getFormattedDate('HH:mm');
                    } else {
                      toast(languageTranslate('lblSelectStartTimeFirst'));
                    }
                  },
                ).expand()
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(
          context,
          name: !isUpdate ? languageTranslate('lblAddSession') : languageTranslate('lblEditSession'),
          actions: !isUpdate
              ? []
              : [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool? res = await showConfirmDialog(context, languageTranslate('lblAreYouSureToDelete'), buttonColor: primaryColor);
                      if (res ?? false) {
                        deleteSession();
                      }
                    },
                  ),
                ],
        ),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            isUpdate ? updateDetails() : addDetails();
          },
          child: Icon(Icons.done, color: Colors.white),
        ),
      ),
    );
  }
}
