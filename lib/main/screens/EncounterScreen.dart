import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/doctor/screens/AddEncounterScreen.dart';
import 'package:kivicare_flutter/doctor/screens/EncounterDashboardScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/PatientEncounterListModel.dart';
import 'package:kivicare_flutter/main/model/PatientListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class EncounterScreen extends StatefulWidget {
  final PatientData? patientData;
  final String? image;

  EncounterScreen({this.image, this.patientData});

  @override
  _EncounterScreenState createState() => _EncounterScreenState();
}

class _EncounterScreenState extends State<EncounterScreen> {
  bool isLoading = false;

  int page = 1;

  bool isList = false;
  bool isLastPage = false;
  bool isReady = false;

  List<PatientEncounterData> patientEncounterList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : scaffoldBgColor);
  }

  Widget body() {
    return NotificationListener(
      onNotification: (dynamic n) {
        if (!isLastPage && isReady) {
          if (n is ScrollEndNotification) {
            page++;
            isReady = false;

            setState(() {});
          }
        }
        return !isLastPage;
      },
      child: FutureBuilder<PatientEncounterListModel>(
        future: getPatientEncounterList(widget.patientData!.iD, page: page),
        builder: (_, snap) {
          if (snap.hasData) {
            if (page == 1) patientEncounterList.clear();

            patientEncounterList.addAll(snap.data!.patientEncounterData!);
            isReady = true;

            isLastPage = snap.data!.total.validate().toInt() <= patientEncounterList.length;

            if (patientEncounterList.isNotEmpty) {
              int cancelled = patientEncounterList.where((element) => element.status == '0').toList().length;
              List booked = patientEncounterList.where((element) => element.status == '1').toList();
              List completed = patientEncounterList.where((element) => element.status == '3').toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      color: appPrimaryColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              widget.patientData!.profile_image == null
                                  ? Image.asset(widget.image!, height: 70, width: 70)
                                  : cachedImage(
                                      widget.patientData!.profile_image,
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ).cornerRadiusWithClipRRect(defaultRadius),
                              Container(
                                padding: EdgeInsets.all(4),
                                margin: EdgeInsets.only(left: 2, right: 5),
                                child: Column(
                                  children: [
                                    Text(
                                      snap.data!.total.validate(),
                                      style: boldTextStyle(size: 18, letterSpacing: 1, color: textPrimaryWhiteColor),
                                    ).onTap(() async {}),
                                    4.height,
                                    Text(languageTranslate('lblVisited'), style: primaryTextStyle(size: 14, color: textPrimaryWhiteColor)),
                                  ],
                                ),
                              ).expand(),
                              Container(height: 40, width: 1, color: textPrimaryWhiteColor.withOpacity(0.2)),
                              Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(left: 5, right: 5),
                                child: Column(
                                  children: [
                                    Text(
                                      booked.length.validate().toString(),
                                      style: boldTextStyle(size: 18, letterSpacing: 1, color: textPrimaryWhiteColor),
                                    ).onTap(() async {}).visible(true),
                                    4.height,
                                    FittedBox(child: Text(languageTranslate('lblBooked'), style: primaryTextStyle(size: 14, color: textPrimaryWhiteColor))),
                                  ],
                                ),
                              ).expand(),
                              Container(height: 40, width: 1, color: textPrimaryWhiteColor.withOpacity(0.2)),
                              Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(left: 5, right: 5),
                                child: Column(
                                  children: [
                                    Text(
                                      completed.length.validate().toString(),
                                      style: boldTextStyle(size: 18, letterSpacing: 1, color: textPrimaryWhiteColor),
                                    ).onTap(() async {}).visible(true),
                                    4.height,
                                    FittedBox(child: Text(languageTranslate('lblCompleted'), style: primaryTextStyle(size: 14, color: textPrimaryWhiteColor))),
                                  ],
                                ),
                              ).expand(),
                              Container(height: 40, width: 1, color: textPrimaryWhiteColor.withOpacity(0.2)),
                              Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(left: 5),
                                child: Column(
                                  children: [
                                    Text(
                                      cancelled.validate().toString(),
                                      style: boldTextStyle(size: 18, letterSpacing: 1, color: textPrimaryWhiteColor),
                                    ).onTap(() async {}).visible(true),
                                    4.height,
                                    FittedBox(child: Text(languageTranslate('lblCancelled'), style: primaryTextStyle(size: 14, color: textPrimaryWhiteColor))),
                                  ],
                                ),
                              ).expand(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    16.height,
                    Text(languageTranslate('lblSwipeMassage'), style: secondaryTextStyle(size: 12)).paddingOnly(left: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: patientEncounterList.length,
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        var data = patientEncounterList[index];
                        DateTime tempDate = DateFormat(CONVERT_DATE).parse(data.encounter_date.validate());
                        return Slidable(
                          key: ValueKey(patientEncounterList[index]),
                          child: Container(
                            decoration: boxDecorationWithShadow(
                              blurRadius: 0,
                              spreadRadius: 0,
                              borderRadius: BorderRadius.circular(defaultRadius),
                              backgroundColor: Theme.of(context).cardColor,
                            ),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 60,
                                  child: Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(text: tempDate.day.toString(), style: boldTextStyle(size: 22)),
                                            WidgetSpan(
                                              child: Transform.translate(
                                                offset: const Offset(2, -10),
                                                child: Text(
                                                  getDayOfMonthSuffix(tempDate.day.validate()).toString(),
                                                  textScaleFactor: 0.7,
                                                  style: boldTextStyle(size: 14),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Text(
                                        tempDate.month.getMonthName().toString(),
                                        textAlign: TextAlign.center,
                                        style: secondaryTextStyle(color: secondaryTxtColor),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 60,
                                  child: VerticalDivider(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 25,
                                    thickness: 1,
                                    indent: 4,
                                    endIndent: 1,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(data.clinic_name.validate(), style: boldTextStyle(size: 18)),
                                        FaIcon(
                                          FontAwesomeIcons.tachometerAlt,
                                          size: 20,
                                          color: appSecondaryColor,
                                        ).paddingAll(8).onTap(
                                          () {
                                            EncounterDashboardScreen(id: data.id, name: data.patient_name).launch(context);
                                          },
                                        )
                                        // menuOption(data: data),
                                      ],
                                    ),
                                    12.height,
                                    Row(
                                      children: [
                                        Text(languageTranslate('lblDoctor') + ': ', style: secondaryTextStyle(color: secondaryTxtColor, size: 16)),
                                        4.width,
                                        Text(data.doctor_name.validate(), style: boldTextStyle(size: 16)),
                                      ],
                                    ),
                                    8.height,
                                    Row(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(languageTranslate('lblDescription') + ': ', style: secondaryTextStyle(size: 16, color: secondaryTxtColor)),
                                            4.width,
                                            Text(
                                              data.description.validate().trim(),
                                              style: boldTextStyle(size: 16),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ).expand(),
                                          ],
                                        ).expand(),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: boxDecorationWithRoundedCorners(
                                            backgroundColor: getEncounterStatusColor(data.status).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(defaultRadius),
                                          ),
                                          child: Text(
                                            "${getEncounterStatus(data.status)}".toUpperCase(),
                                            style: boldTextStyle(size: 10, color: getEncounterStatusColor(data.status)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ).expand(),
                              ],
                            ),
                          ).paddingOnly(right: 4),
                          //Add New Code
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (BuildContext context) async {
                                  bool? res = await AddEncounterScreen(
                                    patientEncounterData: data,
                                    patientId: widget.patientData!.iD,
                                  ).launch(context);
                                  if (res ?? false) {
                                    setState(() {});
                                  }
                                },
                                flex: 1,
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(defaultRadius),
                                  bottomLeft: Radius.circular(defaultRadius),
                                ),
                                icon: Icons.edit,
                                label: languageTranslate('lblEdit'),
                              ),
                              SlidableAction(
                                // An action can be bigger than the others.
                                flex: 1,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(defaultRadius),
                                  bottomRight: Radius.circular(defaultRadius),
                                ),
                                onPressed: (BuildContext context) async {
                                  bool res = await (showConfirmDialog(context, "${languageTranslate("lblDeleteRecordConfirmation")} ${data.clinic_name.validate()}?", buttonColor: primaryColor));
                                  if (res) {
                                    isLoading = true;
                                    setState(() {});
                                    Map request = {
                                      "encounter_id": data.id,
                                    };

                                    deleteEncounterData(request).then((value) {
                                      successToast(" ${languageTranslate("lblAllRecordsFor")} ${data.patient_name.validate()} ${languageTranslate("lblAreDeleted")}");
                                    }).catchError((e) {
                                      errorToast(e.toString());
                                    }).whenComplete(() {
                                      isLoading = false;
                                      setState(() {});
                                    });
                                  }
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: languageTranslate('lblDelete'),
                              ),
                            ],
                          ),
                        ).paddingSymmetric(vertical: 8);
                      },
                    ),
                  ],
                ),
              );
            } else {
              return NoDataFoundWidget(text: languageTranslate("lblNoEncounterFound"), iconSize: 130).center();
            }
          }
          return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: '${widget.patientData!.display_name.capitalizeFirstLetter()} ' + languageTranslate('lblEncounters'), elevation: 0),
        body: body(),
        floatingActionButton: AddFloatingButton(
          onTap: () async {
            bool? res = await AddEncounterScreen(patientId: widget.patientData!.iD).launch(context);
            if (res ?? false) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
