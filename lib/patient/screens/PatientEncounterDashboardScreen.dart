import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/BillDetailsScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/components/PrecriptionWidget.dart';
import 'package:kivicare_flutter/patient/components/ProblemListWidget.dart';
import 'package:kivicare_flutter/patient/model/PatientEncounterDashboardModel.dart';
import 'package:kivicare_flutter/patient/screens/PatientReportScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientEncounterDashboardScreen extends StatefulWidget {
  final int? id;

  PatientEncounterDashboardScreen({this.id});

  @override
  _PatientEncounterDashboardScreenState createState() => _PatientEncounterDashboardScreenState();
}

class _PatientEncounterDashboardScreenState extends State<PatientEncounterDashboardScreen> {
  int? encounterId;
  List<Widget> dataWidgets = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget profileDetailFragment(PatientEncounterDashboardModel data) {
    return Container(
      child: Column(
        children: [
          if (data.payment_status == 'paid')
            Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: boxDecorationWithShadow(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(defaultRadius),
                  backgroundColor: Theme.of(context).cardColor,
                ),
                padding: EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.book, color: primaryColor, size: 20),
                    4.width,
                    Text(languageTranslate('lblBillDetails'), style: primaryTextStyle(color: primaryColor)),
                    4.width,
                  ],
                ),
              ).onTap(() {
                BillDetailsScreen(encounterId: data.id.toInt()).launch(context); //
              }),
            ),
          8.height,
          //Divider(color: viewLineColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languageTranslate('lblName') + ':', style: secondaryTextStyle(color: secondaryTxtColor, size: 16)),
                  8.height,
                  Text(languageTranslate('lblEmail') + ':', style: secondaryTextStyle(color: secondaryTxtColor, size: 16)),
                  8.height,
                  Text(languageTranslate('lblEncounterDate') + ':', style: secondaryTextStyle(color: secondaryTxtColor, size: 16)),
                  8.height,
                  Text(languageTranslate('lblClinicName') + ':', style: secondaryTextStyle(color: secondaryTxtColor, size: 16)),
                  8.height,
                  Text(languageTranslate('lblDoctorName') + ':', style: secondaryTextStyle(color: secondaryTxtColor, size: 16)),
                  8.height,
                  if (data.description.validate().isNotEmpty)
                    Text(
                      languageTranslate('lblDesc') + ':',
                      style: secondaryTextStyle(color: secondaryTxtColor, size: 16),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${data.patient_name.validate()}', style: boldTextStyle(size: 16)),
                  8.height,
                  Text('${data.patient_email.validate()}', style: boldTextStyle(size: 16)),
                  8.height,
                  Text('${data.encounter_date.validate()}'.capitalizeFirstLetter(), style: boldTextStyle(size: 16)),
                  8.height,
                  Text('${data.clinic_name.validate()}', style: boldTextStyle(size: 16)),
                  8.height,
                  Text('${data.doctor_name.validate()}', style: boldTextStyle(size: 16)),
                  8.height,
                  if (data.description.validate().isNotEmpty)
                    Text(
                      '${data.description.validate()}'.capitalizeFirstLetter(),
                      style: boldTextStyle(size: 16),
                    ),
                ],
              )
            ],
          ),
          4.height,
          Divider(color: viewLineColor),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 120,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: getEncounterStatusColor(data.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text(
                "${getEncounterStatus(data.status.validate())}".toUpperCase(),
                style: boldTextStyle(size: 12, color: getEncounterStatusColor(data.status)),
              ).center(),
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
        appBar: appAppBar(context, name: languageTranslate('lblEncounterDashboard')),
        body: FutureBuilder<PatientEncounterDashboardModel>(
          future: getPatientEncounterDetailsDashBoard(widget.id!.toInt()),
          builder: (_, snap) {
            if (snap.hasData) {
              encounterId = snap.data!.id.validate().toInt();
              if (dataWidgets.isEmpty) {
                if (getBoolAsync(USER_PRO_ENABLED)) {
                  snap.data!.enocunter_modules.validate().forEach((element) {
                    if (element.status.toInt() == 1) {
                      if (element.name == "problem") {
                        dataWidgets.add(ProblemListWidget(medicalHistory: snap.data!.problem, encounterType: PROBLEM));
                        dataWidgets.add(Divider(color: viewLineColor));
                      } else if (element.name == "observation") {
                        dataWidgets.add(ProblemListWidget(medicalHistory: snap.data!.observation, encounterType: OBSERVATION));
                        dataWidgets.add(Divider(color: viewLineColor));
                      } else if (element.name == "note") {
                        dataWidgets.add(ProblemListWidget(medicalHistory: snap.data!.note, encounterType: NOTE));
                        dataWidgets.add(Divider(color: viewLineColor));
                      }
                    }
                  });

                  snap.data!.prescription_module.validate().forEach((element) {
                    if (element.status.toInt() == 1) {
                      if (element.name == "prescription") {
                        dataWidgets.add(PrescriptionWidget(prescription: snap.data!.prescription));
                      }
                    }
                  });
                } else {
                  dataWidgets.add(ProblemListWidget(medicalHistory: snap.data!.problem, encounterType: PROBLEM));
                  dataWidgets.add(Divider(color: viewLineColor));

                  dataWidgets.add(ProblemListWidget(medicalHistory: snap.data!.observation, encounterType: OBSERVATION));
                  dataWidgets.add(Divider(color: viewLineColor));

                  dataWidgets.add(ProblemListWidget(medicalHistory: snap.data!.note, encounterType: NOTE));
                  dataWidgets.add(Divider(color: viewLineColor));

                  dataWidgets.add(PrescriptionWidget(prescription: snap.data!.prescription));
                }
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    profileDetailFragment(snap.data!),
                    16.height,
                    isProEnabled()
                        ? Container(
                            decoration: boxDecorationWithShadow(
                              blurRadius: 0,
                              spreadRadius: 0,
                              backgroundColor: context.scaffoldBackgroundColor,
                              border: Border.all(color: context.dividerColor),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(languageTranslate('lblViewAllReports'), style: boldTextStyle()).center().onTap(() {
                              PatientReportScreen(patientId: snap.data!.patient_id.toInt()).launch(context);
                            }),
                          )
                        : Offstage(),
                    16.height,
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: dataWidgets,
                    ),
                  ],
                ),
              );
            } else {
              return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
            }
          },
        ),
      ),
    );
  }
}
