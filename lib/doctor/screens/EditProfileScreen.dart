import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/fragments/ProfileBasicInformation.dart';
import 'package:kivicare_flutter/doctor/fragments/ProfileQualification.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  AsyncMemoizer<GetDoctorDetailModel> _memorizer = AsyncMemoizer();

  int currentIndex = 0;

  TabController? tabController;

  TextEditingController degreeCont = TextEditingController();
  TextEditingController universityCont = TextEditingController();
  TextEditingController yearCont = TextEditingController();

  FocusNode degreeFocus = FocusNode();
  FocusNode universityFocus = FocusNode();
  FocusNode yearFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);

    tabController = TabController(length: 2, vsync: this);
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
    degreeCont.dispose();
    universityCont.dispose();
    yearCont.dispose();

    degreeFocus.dispose();
    universityFocus.dispose();
    yearFocus.dispose();
    setDynamicStatusBarColor(color: scaffoldBgColor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: appPrimaryColor,
            title: Text(languageTranslate('lblEditProfile')),
            elevation: 4.0,
            titleSpacing: 0.0,
            shadowColor: shadowColorGlobal,
          ),
          body: FutureBuilder<GetDoctorDetailModel>(
            future: _memorizer.runOnce(() => getUserProfile(getIntAsync(USER_ID))),
            builder: (_, snap) {
              if (snap.hasData) {
                return Column(
                  children: [
                    16.height,
                    TabBar(
                      physics: NeverScrollableScrollPhysics(),
                      labelColor: Colors.white,
                      overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
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
                          child: Container(padding: EdgeInsets.fromLTRB(48, 4, 48, 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius)), child: Text(languageTranslate('lblBasicInfo'))),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(48, 4, 48, 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(defaultRadius),
                            ),
                            child: Text(languageTranslate('lblQualification')),
                          ),
                        ).visible(getStringAsync(USER_ROLE) != UserRoleReceptionist),
                      ],
                    ),
                    TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: tabController,
                      children: [
                        ProfileBasicInformation(
                          getDoctorDetail: snap.data,
                          onSave: (bool? s) {
                            if (s ?? false) {
                              tabController!.animateTo(currentIndex + 1);
                            }
                          },
                        ),
                        ProfileQualification(getDoctorDetail: snap.data).visible(getStringAsync(USER_ROLE) != UserRoleReceptionist),
                      ],
                    ).expand(),
                  ],
                );
              }
              return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
            },
          ),
        ),
      ),
    );
  }
}
