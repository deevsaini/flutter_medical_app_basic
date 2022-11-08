import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/AddServiceScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/ServiceModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceListScreen extends StatefulWidget {
  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  TextEditingController searchCont = TextEditingController();

  List<ServiceData> serviceList = [];

  String doctorName = '';

  int selected = -1;
  int? doctorId;
  int page = 1;

  bool isLastPage = false;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    getDoctor();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setDynamicStatusBarColor(color: scaffoldBgColor);
    searchCont.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ServiceListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<ServiceListModel>(
          future: getServiceResponse(id: doctorId != null ? getIntAsync(USER_ID) : doctorId, page: page),
          builder: (_, snap) {
            if (snap.hasData) {
              if (page == 1) serviceList.clear();

              serviceList.addAll(snap.data!.serviceData.validate());
              isReady = true;

              isLastPage = snap.data!.total.validate() <= serviceList.length;
              if (serviceList.isNotEmpty) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(languageTranslate('lblServices') + ' (${snap.data!.total.validate()})', style: boldTextStyle(size: titleTextSize)),
                          8.height,
                          Wrap(
                            runAlignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 16,
                            children: serviceList.map((e) {
                              return Container(
                                margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                width: context.width() / 2 - 24,
                                decoration: boxDecorationWithShadow(
                                  blurRadius: 0,
                                  spreadRadius: 0,
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  backgroundColor: Theme.of(context).cardColor,
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          getStringAsync(CURRENCY) + ' ${e.charges.validate()}',
                                          style: boldTextStyle(size: 24, color: primaryColor),
                                        ),
                                        8.height,
                                        Text(e.name.validate().capitalizeFirstLetter(), style: secondaryTextStyle()),
                                        4.height,
                                        Text(
                                          '${listAppStore.doctorList.firstWhereOrNull((element) => element!.iD == e.doctor_id.toInt())?.display_name.validate()}',
                                          style: boldTextStyle(),
                                        ).visible(isReceptionist() && listAppStore.doctorList.isNotEmpty),
                                      ],
                                    ).paddingLeft(20).paddingTop(8).paddingBottom(8).paddingRight(8),
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 6,
                                        decoration: boxDecorationWithRoundedCorners(
                                          backgroundColor: getServiceStatusColor(e.status.validate().toInt())!.withOpacity(0.5),
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
                                  bool? res = await AddServiceScreen(serviceData: e).launch(context);
                                  if (res ?? false) {
                                    setState(() {});
                                  }
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              );
                            }).toList(),
                          ).visible(serviceList.isNotEmpty, defaultWidget: NoDataFoundWidget(text: languageTranslate('lblNoServicesFound'))).center(),
                          70.height,
                        ],
                      ),
                    ),
                    setLoader().visible(isSnapshotLoading(snap)).center(),
                  ],
                );
              } else {
                return NoDataFoundWidget(text: languageTranslate('lblNoDataFound'), iconSize: 140).center();
              }
            }
            return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage));
          },
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblServices')),
        body: body(),
        floatingActionButton: AddFloatingButton(
          onTap: () async {
            bool? res = await AddServiceScreen().launch(context);
            if (res ?? false) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
