import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/components/AddPrescriptionScreen.dart';
import 'package:kivicare_flutter/doctor/fragments/PrescriptionFragment.dart';
import 'package:kivicare_flutter/doctor/fragments/ProfileDetailFragment.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/EncounterListWidget.dart';
import 'package:kivicare_flutter/main/model/EncounterDashboardModel.dart';
import 'package:kivicare_flutter/main/model/LoginResponseModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class EncounterDashboardScreen extends StatefulWidget {
  final String? id;
  final String? name;

  EncounterDashboardScreen({this.id, this.name});

  @override
  _EncounterDashboardScreenState createState() => _EncounterDashboardScreenState();
}

class _EncounterDashboardScreenState extends State<EncounterDashboardScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;

  EncounterDashboardModel? encounterDashboardModel;

  List<EnocunterModule>? encounterModuleList;
  List<PrescriptionModule>? prescriptionModuleList;
  List<Tab> tabData = [];
  List<Widget> tabWidgets = [];

  String? paymentStatus;

  int tabBarLength = 0;
  int currentIndex = 0;
  int? encounterId;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    getEncounterDetailsDashBoard(widget.id.toInt()).then((value) async {
      await getConfiguration().catchError((c) {
        //
      });

      if (isProEnabled()) {
        tabData.clear();
        tabWidgets.clear();
        encounterDashboardModel = value;
        paymentStatus = value.payment_status;
        setState(() {});
        tabBarLength = 1;

        tabData.add(
          Tab(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text("${languageTranslate("lblEncounterDetails")}".toUpperCase()),
            ),
          ),
        );
        tabWidgets.add(ProfileDetailFragment(encounterId: value.id.toInt(), patientEncounterDetailData: value, isStatusBack: true));

        if (value.enocunter_modules!.isNotEmpty) {
          value.enocunter_modules!.forEach((element) {
            if (element.status.toInt() == 1) {
              tabBarLength = tabBarLength + 1;

              setState(() {});
            }

            if (element.status.toInt() == 1) {
              tabData.add(
                Tab(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                    child: Text("${element.label.validate()}".toUpperCase()),
                  ),
                ),
              );

              tabWidgets.add(EncounterListWidget(id: value.id.toInt(), encounterType: element.name.validate(), paymentStatus: value.payment_status));
            }
          });
        }

        if (value.prescription_module!.isNotEmpty) {
          value.prescription_module!.forEach((element) {
            if (element.status.toInt() == 1) {
              tabBarLength = tabBarLength + 1;
            }
            if (element.status.toInt() == 1) {
              tabData.add(
                Tab(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                    child: Text("${element.label}".toUpperCase()),
                  ),
                ),
              );
              tabWidgets.add(PrescriptionFragment(id: value.id.toInt()));
            }
          });
        }
      } else {
        tabBarLength = 5;
        setState(() {});
        tabData.add(Tab(
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: Text(languageTranslate("lblEncounterDetails").toUpperCase()),
          ),
        ));
        tabWidgets.add(ProfileDetailFragment(encounterId: value.id.toInt(), patientEncounterDetailData: value, isStatusBack: true));
        tabData.add(
          Tab(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text(languageTranslate("lblProblems").toUpperCase()),
            ),
          ),
        );
        tabWidgets.add(EncounterListWidget(id: value.id.toInt(), encounterType: PROBLEM, paymentStatus: value.payment_status));
        tabData.add(
          Tab(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius)),
              child: Text(languageTranslate("lblObservation").toUpperCase()),
            ),
          ),
        );
        tabWidgets.add(EncounterListWidget(id: value.id.toInt(), encounterType: OBSERVATION, paymentStatus: value.payment_status));
        tabData.add(
          Tab(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text(languageTranslate("lblNotes").toUpperCase()),
            ),
          ),
        );
        tabWidgets.add(EncounterListWidget(id: value.id.toInt(), encounterType: NOTE, paymentStatus: value.payment_status));
        tabData.add(
          Tab(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text(languageTranslate("lblPrescription").toUpperCase()),
            ),
          ),
        );
        tabWidgets.add(PrescriptionFragment(id: value.id.toInt()));
      }

      tabController = TabController(length: tabBarLength, vsync: this);
      tabController?.addListener(() {
        currentIndex = tabController!.index.validate();
        setState(() {});
      });

      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : primaryColor, statusBarIconBrightness: Brightness.light);
    tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: tabBarLength,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: appPrimaryColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_outlined, color: textPrimaryWhiteColor),
              onPressed: () {
                finish(context);
              },
            ),
            title: Text(languageTranslate('lblEncounterDashboard'), style: boldTextStyle(color: textPrimaryWhiteColor, size: 18)),
          ),
          body: Column(
            children: [
              16.height,
              tabData.isNotEmpty
                  ? TabBar(
                      controller: tabController,
                      physics: BouncingScrollPhysics(),
                      labelColor: Colors.white,
                      overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                      isScrollable: true,
                      unselectedLabelColor: appStore.isDarkModeOn ? gray : secondaryTxtColor,
                      automaticIndicatorColorAdjustment: true,
                      onTap: (i) {
                        currentIndex = i;
                        setState(() {});
                      },
                      indicatorSize: TabBarIndicatorSize.label,
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
                      tabs: tabData,
                    )
                  : SizedBox(),
              tabWidgets.isNotEmpty
                  ? TabBarView(
                      controller: tabController,
                      children: tabWidgets,
                    ).expand()
                  : setLoader(),
            ],
          ),
          floatingActionButton: !isPatient() && paymentStatus.validate() != 'paid'
              ? FloatingActionButton(
                  backgroundColor: primaryColor,
                  onPressed: () async {
                    bool? res = await AddPrescriptionScreen(id: widget.id.toInt().validate()).launch(context);
                    if (res ?? false) {
                      setState(() {});
                    }
                  },
                  child: Icon(Icons.add, color: Colors.white),
                ).visible(currentIndex == 4)
              : 0.height,
        ),
      ),
    );
  }
}
