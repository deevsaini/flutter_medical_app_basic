import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/receiptionist/screens/RProfileBasicInformation.dart';
import 'package:kivicare_flutter/receiptionist/screens/RProfileBasicSetting.dart';
import 'package:kivicare_flutter/receiptionist/screens/RProfileQualification.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class RAddNewDoctor extends StatefulWidget {
  DoctorList? doctorList;
  bool isUpdate;

  RAddNewDoctor({this.doctorList, this.isUpdate = false});

  @override
  _RAddNewDoctorState createState() => _RAddNewDoctorState();
}

class _RAddNewDoctorState extends State<RAddNewDoctor> with SingleTickerProviderStateMixin {
  AsyncMemoizer<GetDoctorDetailModel> _memorizer = AsyncMemoizer();

  int currentIndex = 0;
  TabController? tabController;
  GetDoctorDetailModel? getDoctorDetail;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    multiSelectStore.clearStaticList();

    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);

    editProfileAppStore.removeData();
    tabController = TabController(length: 3, vsync: this);
    tabController!.addListener(() {
      setState(() {
        currentIndex = tabController!.index;
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : scaffoldBgColor);
    super.dispose();
  }

  Widget body() {
    return TabBarView(
      physics: NeverScrollableScrollPhysics(),
      controller: tabController,
      children: [
        RProfileBasicInformation(
          isNewDoctor: true,
          onSave: (bool? s) {
            if (s ?? false) {
              tabController!.animateTo(currentIndex + 1);
            }
          },
        ),
        RProfileBasicSettings(
          onSave: (bool? s) {
            if (s ?? false) {
              tabController!.animateTo(currentIndex + 1);
            }
          },
        ),
        RProfileQualification(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: appPrimaryColor,
            title: Text(languageTranslate('lblAddDoctorProfile')),
            elevation: 0,
            titleSpacing: 0.0,
          ),
          body: widget.isUpdate
              ? FutureBuilder<GetDoctorDetailModel>(
                  future: _memorizer.runOnce(() => getUserProfile(widget.doctorList!.iD)),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      return Column(
                        children: [
                          16.height,
                          TabBar(
                            physics: NeverScrollableScrollPhysics(),
                            labelColor: Colors.white,
                            unselectedLabelColor: appStore.isDarkModeOn ? gray : secondaryTxtColor,
                            onTap: (i) {
                              tabController!.index = tabController!.previousIndex;
                            },
                            indicatorSize: TabBarIndicatorSize.label,
                            isScrollable: true,
                            controller: tabController,
                            indicator: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(4),
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                              color: tabBgColor,
                            ),
                            tabs: [
                              Tab(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(defaultRadius),
                                  ),
                                  child: Text(languageTranslate('lblBasicInfo').toUpperCase()),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(defaultRadius),
                                  ),
                                  child: Text(languageTranslate('lblBasicSettings').toUpperCase()),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(defaultRadius),
                                  ),
                                  child: Text(languageTranslate('lblQualification').toUpperCase()),
                                ),
                              ),
                            ],
                          ),
                          TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            controller: tabController,
                            children: [
                              RProfileBasicInformation(
                                getDoctorDetail: snap.data,
                                doctorId: widget.doctorList!.iD,
                                onSave: (bool? s) {
                                  if (s ?? false) {
                                    tabController!.animateTo(currentIndex + 1);
                                  }
                                },
                              ),
                              RProfileBasicSettings(
                                getDoctorDetail: snap.data,
                                onSave: (bool? s) {
                                  if (s ?? false) {
                                    tabController!.animateTo(currentIndex + 1);
                                  }
                                },
                              ),
                              RProfileQualification(getDoctorDetail: snap.data),
                            ],
                          ).expand(),
                        ],
                      );
                    }
                    return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
                  },
                )
              : body(),
        ),
      ),
    );
  }
}
