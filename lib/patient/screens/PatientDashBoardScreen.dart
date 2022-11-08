import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/SettingFragment.dart';
import 'package:kivicare_flutter/main/components/TopNameWidget.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/patient/fragment/FeedListFragment.dart';
import 'package:kivicare_flutter/patient/fragment/PDashBoardFragment.dart';
import 'package:kivicare_flutter/patient/fragment/PatientAppointmentFragment.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientDashBoardScreen extends StatefulWidget {
  @override
  _PatientDashBoardScreenState createState() => _PatientDashBoardScreenState();
}

class _PatientDashBoardScreenState extends State<PatientDashBoardScreen> {
  Color disableIconColor = appStore.isDarkModeOn ? Colors.white : secondaryTxtColor;

  int currentIndex = 0;

  double iconSize = 24;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);

    getDoctor();
    getPatient();
    getSpecialization();

    window.onPlatformBrightnessChanged = () {
      if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
        appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.light);
      }
    };
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              TopNameWidget().visible(currentIndex != 3),
              Container(
                margin: EdgeInsets.only(top: currentIndex != 3 ? 70 : 0),
                child: [
                  PDashBoardFragment(),
                  PatientAppointmentFragment(),
                  FeedListFragment(),
                  SettingFragment(),
                ][currentIndex],
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (i) {
              currentIndex = i;
              setState(() {});
            },
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Theme.of(context).iconTheme.color,
            backgroundColor: Theme.of(context).cardColor,
            mouseCursor: MouseCursor.uncontrolled,
            elevation: 12,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset('images/icons/dashboard.png', height: iconSize, width: iconSize, color: disableIconColor),
                activeIcon: Image.asset('images/icons/dashboardFill.png', height: iconSize, width: iconSize),
                label: languageTranslate('lblPatientDashboard'),
              ),
              BottomNavigationBarItem(
                icon: Image.asset('images/icons/calendar.png', height: iconSize, width: iconSize, color: disableIconColor),
                activeIcon: Image.asset('images/icons/calendarFill.png', height: iconSize, width: iconSize),
                label: languageTranslate('lblAppointments'),
              ),
              BottomNavigationBarItem(
                icon: Image.asset('images/icons/document.png', height: iconSize, width: iconSize, color: disableIconColor),
                activeIcon: Image.asset("images/icons/document_fill.png", height: iconSize, width: iconSize),
                label: languageTranslate('lblFeedsAndArticles'),
              ),
              BottomNavigationBarItem(
                icon: Image.asset('images/icons/user.png', height: iconSize, width: iconSize, color: disableIconColor),
                activeIcon: Image.asset('images/icons/profile_fill.png', height: iconSize, width: iconSize, color: primaryColor),
                label: languageTranslate('lblSettings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
