import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/doctor/components/DashBoardCountWidget.dart';
import 'package:kivicare_flutter/doctor/components/WeeklyChartComponent.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/AppointmentListWidget.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  List<DashBoardCountWidget> dashboardCount = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);
  }

  @override
  void didUpdateWidget(covariant DashboardFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
      body: FutureBuilder<DoctorDashboardModel>(
        future: getDoctorDashBoard(),
        builder: (_, snap) {
          if (snap.hasData) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  8.height,
                  Text(languageTranslate('lblYourNumber'), style: boldTextStyle(size: titleTextSize)).paddingOnly(top: 16, left: 16),
                  ListView(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 60),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      32.height,
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        children: [
                          DashBoardCountWidget(
                            title: languageTranslate('lblTodayAppointments'),
                            color1: appSecondaryColor,
                            // color2: Color(0x8C58CDB2),
                            subTitle: languageTranslate('lblTotalTodayAppointments'),
                            count: snap.data!.upcoming_appointment_total.validate(),
                            icon: FontAwesomeIcons.calendarCheck,
                          ),
                          DashBoardCountWidget(
                            title: languageTranslate('lblTotalAppointment'),
                            color1: appPrimaryColor,
                            //color2: Color(0x8C58CDB2),
                            subTitle: languageTranslate('lblTotalVisitedAppointment'),
                            count: snap.data!.total_appointment.validate(),
                            icon: FontAwesomeIcons.calendarCheck,
                          ),
                          DashBoardCountWidget(
                            title: languageTranslate('lblTotalPatient'),
                            color1: appSecondaryColor,
                            //  color2: Color(0x8CE2A17C),
                            subTitle: languageTranslate('lblTotalVisitedPatients'),
                            count: snap.data!.total_patient.validate(),
                            icon: FontAwesomeIcons.userInjured,
                          ),
                        ],
                      ),
                      42.height,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(languageTranslate('lblWeeklyAppointments'), style: boldTextStyle(size: titleTextSize)).paddingOnly(left: 10),
                          10.height,
                          snap.data!.weekly_appointment.validate().isNotEmpty
                              ? Container(
                                  height: 220,
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 24),
                                  decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.all(radiusCircular(defaultRadius)),
                                    backgroundColor: context.cardColor,
                                  ),
                                  child: WeeklyChartComponent(weeklyAppointment: snap.data!.weekly_appointment).withWidth(
                                    context.width(),
                                  ),
                                )
                              : Container(
                                  height: 220,
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 24),
                                  decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.all(radiusCircular(defaultRadius)),
                                    backgroundColor: context.scaffoldBackgroundColor,
                                  ),
                                  child: WeeklyChartComponent(weeklyAppointment: emptyGraphList).withWidth(context.width()),
                                ),
                        ],
                      ),
                      28.height,
                      Text(languageTranslate('lblTodaySAppointments'), style: boldTextStyle(size: titleTextSize)).paddingAll(8),
                      Text(languageTranslate('lblSwipeMassage'), style: secondaryTextStyle(size: 12)).paddingOnly(left: 8),
                      16.height,
                      AppointmentListWidget(
                        upcomingAppointment: snap.data!.upcoming_appointment.validate(),
                      ).paddingSymmetric(horizontal: 8),
                      NoDataFoundWidget(
                        text: languageTranslate('lblNoAppointmentForToday'),
                      ).visible(snap.data!.upcoming_appointment.validate().isEmpty),
                    ],
                  ),
                ],
              ),
            );
          }
          return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
        },
      ),
    );
  }
}
