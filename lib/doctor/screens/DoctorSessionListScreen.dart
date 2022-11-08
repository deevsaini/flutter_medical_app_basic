import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/AddSessionScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/components/cached_image_widget.dart';
import 'package:kivicare_flutter/main/model/DoctorScheduleModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorSessionListScreen extends StatefulWidget {
  @override
  _DoctorSessionListScreenState createState() => _DoctorSessionListScreenState();
}

class _DoctorSessionListScreenState extends State<DoctorSessionListScreen> {
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
    setDynamicStatusBarColor(color: scaffoldBgColor);
  }

  Widget body() {
    return Container(
      child: FutureBuilder<DoctorSessionModel>(
        future: getDoctorSessionData(clinicData: isProEnabled() ? getIntAsync(USER_CLINIC) : getIntAsync(USER_CLINIC)),
        builder: (_, snap) {
          if (snap.hasData) {
            // if (snap.data!.sessionData!.isEmpty) return noDataWidget(text: translate('lblNoDataFound'));
            if (snap.data!.sessionData!.isEmpty) return NoDataFoundWidget(text: languageTranslate('lblNoDataFound')).center();

            return SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text(languageTranslate('lblDoctorSessions') + ' (${snap.data!.sessionData!.length.validate()})', style: boldTextStyle(size: titleTextSize)),
                  16.height,
                  ListView.builder(
                    itemCount: snap.data!.sessionData!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      SessionData data = snap.data!.sessionData![index];
                      String morningStart = '-';
                      String morningEnd = '-';
                      String eveningStart = '-';
                      String eveningEnd = '-';

                      if (data.s_one_start_time!.hH!.isNotEmpty) {
                        morningStart = '${data.s_one_start_time!.hH.validate(value: '00')}:${data.s_one_start_time!.mm.validate(value: '00')}';
                      }
                      if (data.s_one_start_time!.hH!.isNotEmpty) {
                        morningEnd = '${data.s_one_end_time!.hH.validate(value: '00')}:${data.s_one_end_time!.mm.validate(value: '00')}';
                      }
                      if (data.s_two_start_time!.hH!.isNotEmpty) {
                        eveningStart = '${data.s_two_start_time!.hH.validate(value: '00')}:${data.s_two_start_time!.mm.validate(value: '00')}';
                      }
                      if (data.s_two_start_time!.hH!.isNotEmpty) {
                        eveningEnd = '${data.s_two_end_time!.hH.validate(value: '00')}:${data.s_two_end_time!.mm.validate(value: '00')}';
                      }

                      return GestureDetector(
                        onTap: () async {
                          bool? res = await AddSessionsScreen(sessionData: data).launch(context);
                          if (res ?? false) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          decoration: boxDecorationWithShadow(
                            blurRadius: 0,
                            spreadRadius: 0,
                            borderRadius: BorderRadius.circular(defaultRadius),
                            backgroundColor: Theme.of(context).cardColor,
                          ),
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CachedImageWidget(
                                    // url: data.attchments.validate().isNotEmpty ? data.attchments!.first.validate() : '',
                                    url: '',
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                    radius: 120,
                                  ),
                                  16.width,
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${data.clinic_name.validate()}', style: boldTextStyle(size: 16)),
                                      16.height,
                                      if (appStore.userRole!.toLowerCase() == UserRoleReceptionist)
                                        Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Doctor: ", style: secondaryTextStyle(size: 16)),
                                                Text('${data.doctors.validate()}', style: boldTextStyle()).flexible(),
                                              ],
                                            ),
                                            8.height,
                                          ],
                                        ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(languageTranslate('lblSpeciality'), style: secondaryTextStyle(size: 16)),
                                          Text('${data.specialties.validate()}', style: boldTextStyle()).flexible(),
                                        ],
                                      ),
                                      8.height,
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(languageTranslate('lblOpen'), style: secondaryTextStyle(size: 16)),
                                          Text(
                                            '${data.days!.map((e) => e.validate()).join(" - ")}',
                                            style: boldTextStyle(),
                                          ).paddingOnly(top: 1).flexible(),
                                        ],
                                      ),
                                    ],
                                  ).expand(),
                                ],
                              ),
                              24.height,
                              Container(
                                decoration: boxDecorationWithRoundedCorners(
                                  backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
                                ),
                                padding: EdgeInsets.all(22),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset("images/icons/morning.png", height: 22, width: 22),
                                        8.width,
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(languageTranslate('lblMorning'), style: secondaryTextStyle(color: secondaryTxtColor)),
                                            8.height,
                                            Text("$morningStart to $morningEnd", style: boldTextStyle(size: 14)),
                                          ],
                                        ).expand(),
                                      ],
                                    ).expand(),
                                    16.width,
                                    Row(
                                      children: [
                                        Image.asset("images/icons/evening.png", height: 22, width: 22),
                                        8.width,
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(languageTranslate('lblEvening'), style: secondaryTextStyle(color: secondaryTxtColor)),
                                            8.height,
                                            eveningStart == "-"
                                                ? Text('--', style: boldTextStyle())
                                                : Text(
                                                    "$eveningStart to $eveningEnd ",
                                                    style: boldTextStyle(size: 14),
                                                  ),
                                          ],
                                        ).expand(),
                                      ],
                                    ).expand(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            );
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
        appBar: appAppBar(context, name: languageTranslate('lblDoctorSessions')),
        body: body(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            bool? res = await AddSessionsScreen().launch(context);
            if (res ?? false) {
              setState(() {});
            }
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
