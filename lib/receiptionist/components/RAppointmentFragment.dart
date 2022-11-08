import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/AppointmentListWidget.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/AppoinmentModel.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/receiptionist/screens/appointment/RAppointmentScreen1.dart';
import 'package:nb_utils/nb_utils.dart';

class RAppointmentFragment extends StatefulWidget {
  @override
  _RAppointmentFragmentState createState() => _RAppointmentFragmentState();
}

class _RAppointmentFragmentState extends State<RAppointmentFragment> {
  bool isCheckIn = false;

  String? todayDate;

  List<UpcomingAppointment> mainList = [];
  List<String> pStatus = [];

  int selectIndex = -1;
  int page = 1;

  bool isLastPage = false;
  bool isReady = false;
  bool isPast = false;

  String status = "1";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);

    pStatus.add(languageTranslate("lblAll"));
    pStatus.add(languageTranslate("lblUpcomingAppointments"));
    pStatus.add(languageTranslate("lblPast"));
    selectIndex = 1;
    todayDate = DateTime.now().getFormattedDate(CONVERT_DATE);
    LiveStream().on(UPDATE, (isUpdate) {
      if (isUpdate as bool) {
        setState(() {});
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);
    LiveStream().dispose(UPDATE);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: body(),
        floatingActionButton: AddFloatingButton(
          navigate: RAppointmentScreen1(),
        ),
      ),
    );
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
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16, bottom: 82),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languageTranslate("lblClinicAppointments"), style: boldTextStyle(size: titleTextSize, letterSpacing: 1)).paddingOnly(left: 16),
            16.height,
            HorizontalList(
                spacing: 16,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: pStatus.length,
                itemBuilder: (_, index) {
                  return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 20),
                    margin: EdgeInsets.only(left: 0, right: 8, top: 4, bottom: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                      color: selectIndex == index
                          ? appStore.isDarkModeOn
                              ? cardDarkColor
                              : black
                          : appStore.isDarkModeOn
                              ? scaffoldDarkColors
                              : scaffoldBgColor,
                    ),
                    child: FittedBox(
                      child: Text(
                        pStatus[index],
                        style: primaryTextStyle(size: 14, color: selectIndex == index ? white : Theme.of(context).iconTheme.color),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ).onTap(
                    () {
                      selectIndex = index;
                      if (index == 0) {
                        status = "all";
                        isPast = false;
                      } else if (index == 1) {
                        status = "1";
                        isPast = false;
                      } else if (index == 2) {
                        status = "past";
                        isPast = true;
                      }
                      setState(() {});
                    },
                  );
                }),
            16.height,
            FutureBuilder<AppointmentModel>(
              future: getAppointmentData(isPast: isPast, todayDate: todayDate, page: page, status: status),
              builder: (_, snap) {
                if (snap.hasData) {
                  if (page == 1) mainList.clear();

                  mainList.addAll(snap.data!.appointmentData!);
                  isReady = true;
                  isLastPage = snap.data!.total.validate() <= mainList.length;

                  if (mainList.isNotEmpty) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$TOTAL_APPOINTMENT (${snap.data!.total.validate()})', style: boldTextStyle(size: 18)),
                            8.height,
                            Text(languageTranslate('lblSwipeMassage'), style: secondaryTextStyle(size: 12)),
                            16.height,
                            AppointmentListWidget(upcomingAppointment: mainList),
                          ],
                        ).paddingSymmetric(horizontal: 16).visible(
                              snap.connectionState != ConnectionState.waiting,
                              defaultWidget: setLoader().center(),
                            ),

                        //setLoader().visible(isSnapshotLoading(snap)).center(),
                      ],
                    );
                  } else {
                    return NoDataFoundWidget(text: languageTranslate('lblNoDataFound'), iconSize: 140).center();
                  }
                }
                return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
              },
            ),
          ],
        ),
      ),
    );
  }
}
