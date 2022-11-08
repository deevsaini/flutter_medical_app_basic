import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/AddHolidayScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/HolidayModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class HolidayScreen extends StatefulWidget {
  @override
  _HolidayScreenState createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  TextEditingController searchCont = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    await getDoctor();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  deleteHoliday(int id) async {
    isLoading = true;
    setState(() {});
    Map request = {"id": id};
    await deleteHolidayData(request).then((value) {
      successToast(languageTranslate('lblHolidayDeleted'));
    }).catchError((e) {
      errorToast(e.toString());
    });
    isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor(color: scaffoldBgColor);
  }

  @override
  void didUpdateWidget(covariant HolidayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget body() {
    return FutureBuilder<HolidayModel>(
      future: getHolidayResponse(),
      builder: (_, snap) {
        if (snap.hasData) {
          // if (snap.data!.holidayData!.isEmpty) return noDataWidget(text: translate('lblNoDataFound'));
          if (snap.data!.holidayData!.isEmpty) return NoDataFoundWidget().center();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Text(languageTranslate('lblHolidays') + ' (${snap.data!.holidayData!.length.validate()})', style: boldTextStyle(size: titleTextSize)),
                8.height,
                Wrap(
                  spacing: 16,
                  children: List.generate(
                    snap.data!.holidayData!.length,
                    (index) {
                      HolidayData data = snap.data!.holidayData![index];
                      int totalDays = (DateTime.parse(data.end_date!).difference(DateTime.parse(data.start_date!))).inDays;
                      int pendingDays = DateTime.parse(data.end_date!).difference(DateTime.now()).inDays;
                      bool isPending = (DateTime.parse(data.end_date!).isAfter(DateTime.now()));
                      return Container(
                        margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        width: context.width() / 2 - 24,
                        decoration: boxDecorationWithShadow(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          blurRadius: 0,
                          spreadRadius: 0,
                          border: Border.all(color: context.dividerColor),
                          backgroundColor: Theme.of(context).cardColor,
                        ),
                        child: Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (data.module_type == 'doctor')
                                      if (listAppStore.doctorList.firstWhereOrNull((element) => element!.iD == data.module_id.toInt()) != null)
                                        Text(
                                          '${listAppStore.doctorList.firstWhereOrNull((element) => element!.iD == data.module_id.toInt())!.display_name}',
                                          style: boldTextStyle(size: 16),
                                        ),
                                    if (data.module_type != 'doctor') Text(languageTranslate('lblClinic'), style: boldTextStyle(size: 18)),
                                    if (listAppStore.doctorList.firstWhereOrNull((element) => element!.iD == data.module_id.toInt()) != null) 10.height,
                                    Text(
                                      '${data.start_date.validate().getFormattedDate('dd-MMM-yyyy').validate()}',
                                      style: primaryTextStyle(size: 14, color: secondaryTxtColor),
                                    ),
                                    4.height,
                                    Container(height: 1, width: 3, color: Colors.black),
                                    4.height,
                                    Text(
                                      '${data.end_date.validate().getFormattedDate('dd-MMM-yyyy').validate()}',
                                      style: primaryTextStyle(size: 14, color: secondaryTxtColor),
                                    ),
                                    10.height,
                                    Text(languageTranslate('lblAfter') + ' ${pendingDays == 0 ? '1' : pendingDays} ' + languageTranslate('lblDays'), style: boldTextStyle(size: 16)).visible(isPending),
                                    Text(languageTranslate('lblWasOffFor') + ' ${totalDays == 0 ? '1' : totalDays} ' + languageTranslate('lblDays'), style: boldTextStyle(size: 16)).visible(!isPending),
                                  ],
                                ).expand(),
                              ],
                            ).paddingAll(16),
                            Positioned(
                              top: 0,
                              left: 0,
                              bottom: 0,
                              child: Container(
                                width: 6,
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: boxDecorationWithRoundedCorners(
                                  backgroundColor: getHolidayStatusColor(isPending).withOpacity(0.5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(defaultRadius),
                                    bottomLeft: Radius.circular(defaultRadius),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).onTap(
                        () async {
                          bool? res = await AddHolidayScreen(holidayData: data).launch(context);
                          if (res ?? false) {
                            setState(() {});
                          }
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblYourHolidays')),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: AddFloatingButton(
          onTap: () async {
            bool? res = await AddHolidayScreen().launch(context);
            if (res ?? false) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
