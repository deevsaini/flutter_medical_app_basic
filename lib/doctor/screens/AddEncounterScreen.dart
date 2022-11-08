import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/ClinicDropDown.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/LoginResponseModel.dart';
import 'package:kivicare_flutter/main/model/PatientEncounterListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/receiptionist/components/DoctorDropDown.dart';
import 'package:nb_utils/nb_utils.dart';

class AddEncounterScreen extends StatefulWidget {
  final PatientEncounterData? patientEncounterData;
  final int? patientId;

  AddEncounterScreen({this.patientEncounterData, this.patientId});

  @override
  _AddEncounterScreenState createState() => _AddEncounterScreenState();
}

class _AddEncounterScreenState extends State<AddEncounterScreen> {
  var formKey = GlobalKey<FormState>();

  PatientEncounterData? patientEncounterData;
  late Clinic selectedClinic;
  late DoctorList selectedDoctor;

  TextEditingController encounterDate = TextEditingController();
  TextEditingController encounterDescription = TextEditingController();
  DateTime current = DateTime.now();

  int? clinicId;

  bool isLoading = false;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isUpdate = widget.patientEncounterData != null;
    if (isUpdate) {
      patientEncounterData = widget.patientEncounterData;
      encounterDate.text = patientEncounterData!.encounter_date!.getFormattedDate('dd-MMM-yyyy');
      current = DateTime.parse(patientEncounterData!.encounter_date!);
      encounterDescription.text = patientEncounterData!.description.validate();
      clinicId = patientEncounterData!.clinic_id.toInt();
    }
    await getConfiguration().catchError(log);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  saveEncounter() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});
      Map request = {
        "date": encounterDate.text,
        "patient_id": widget.patientId,
        "doctor_id": getIntAsync(USER_ID),
        "description": encounterDescription.text,
        "status": "1",
      };

      if (isDoctor()) {
        if (isProEnabled()) {
          request.putIfAbsent("clinic_id", () => selectedClinic.clinic_id);
        } else {
          request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
        }
      } else if (isReceptionist()) {
        request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
        request.putIfAbsent("doctor_id", () => selectedDoctor.iD);
      }

      addEncounterData(request).then((value) {
        isLoading = false;
        setState(() {});
        toast(languageTranslate("lblAddedNewEncounter"));
        finish(context, true);
      }).catchError((e) {
        isLoading = false;
        setState(() {});
        toast(e, bgColor: errorBackGroundColor, textColor: errorTextColor);
      });
    }
  }

  updateEncounter() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});
      Map request = {
        "id": patientEncounterData!.id,
        "date": encounterDate.text,
        "patient_id": widget.patientId,
        "description": encounterDescription.text,
        "status": "1",
      };
      if (isDoctor()) {
        if (isProEnabled()) {
          request.putIfAbsent("clinic_id", () => selectedClinic.clinic_id.validate());
        } else {
          request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
        }
      }
      if (isReceptionist()) {
        request.putIfAbsent("clinic_id", () => getIntAsync(USER_CLINIC));
        request.putIfAbsent("doctor_id", () => selectedDoctor.iD);
      }

      addEncounterData(request).then((value) {
        isLoading = false;
        setState(() {});
        successToast(languageTranslate('lblEncounterUpdated'));
        finish(context, true);
      }).catchError((e) {
        isLoading = false;
        setState(() {});
        errorToast(e.toString());
      });
    }
  }

  Widget body() {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isProEnabled()
                ? isDoctor()
                    ? ClinicDropDown(
                        clinicId: clinicId,
                        isValidate: true,
                        onSelected: (Clinic? value) {
                          selectedClinic = value!;
                        },
                      )
                    : Offstage()
                : Offstage(),
            !isDoctor() ? 16.height : 0.height,
            !isDoctor()
                ? DoctorDropDown(
                    isValidate: true,
                    onSelected: (DoctorList? e) {
                      selectedDoctor = e!;
                      setState(() {});
                    },
                  )
                : Offstage(),
            16.height,
            AppTextField(
              onTap: () async {
                DateTime? dateTime = await showDatePicker(
                  context: context,
                  initialDate: current,
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
                  locale: Locale(appStore.selectedLanguage),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (dateTime != null) {
                  encounterDate.text = dateTime.getFormattedDate('dd-MMM-yyyy');
                  current = dateTime;
                }
              },
              controller: encounterDate,
              readOnly: true,
              textFieldType: TextFieldType.OTHER,
              suffix: Icon(Icons.date_range),
              decoration: textInputStyle(context: context, label: 'lblDate'),
            ),
            16.height,
            AppTextField(
              controller: encounterDescription,
              textFieldType: TextFieldType.ADDRESS,
              maxLines: 14,
              textAlign: TextAlign.start,
              minLines: 5,
              decoration: textInputStyle(context: context, label: 'lblDescription'),
            ),
          ],
        ).paddingAll(16),
      ),
    );
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : primaryColor, statusBarIconBrightness: Brightness.light);
    encounterDate.dispose();
    encounterDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(
          context,
          name: !isUpdate ? languageTranslate('lblAddNewEncounter') : languageTranslate('lblEditEncounterDetail'),
        ),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            isUpdate ? updateEncounter() : saveEncounter();
          },
          child: Icon(Icons.done, color: Colors.white),
        ).visible(!isLoading),
      ),
    );
  }
}
