import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/fragments/AppointmentFragment.dart';
import 'package:kivicare_flutter/doctor/fragments/DashboardFragment.dart';
import 'package:kivicare_flutter/doctor/fragments/PatientFragment.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/SettingFragment.dart';
import 'package:kivicare_flutter/main/components/TopNameWidget.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorDashboardScreen extends StatefulWidget {
  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int currentIndex = 0;
  double iconSize = 24;

  Color disabledIconColor = appStore.isDarkModeOn ? Colors.white : secondaryTxtColor;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
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
                margin: EdgeInsets.only(top: 66),
                child: [
                  DashboardFragment(),
                  AppointmentFragment(),
                  PatientFragment(),
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
                icon: Image.asset('images/icons/dashboard.png', height: iconSize, width: iconSize, color: disabledIconColor),
                activeIcon: Image.asset('images/icons/dashboardFill.png', height: iconSize, width: iconSize),
                label: languageTranslate('lblDashboard'),
              ),
              BottomNavigationBarItem(
                icon: Image.asset('images/icons/calendar.png', height: iconSize, width: iconSize, color: disabledIconColor),
                activeIcon: Image.asset('images/icons/calendarFill.png', height: iconSize, width: iconSize),
                label: languageTranslate('lblAppointments'),
              ),
              BottomNavigationBarItem(
                icon: Image.asset('images/icons/patient.png', height: iconSize, width: iconSize, color: disabledIconColor),
                activeIcon: Image.asset('images/icons/patientFill.png', height: iconSize, width: iconSize),
                label: languageTranslate('lblPatients'),
              ),
              BottomNavigationBarItem(
                icon: Image.asset('images/icons/user.png', height: iconSize, width: iconSize, color: disabledIconColor),
                activeIcon: Image.asset('images/icons/profile_fill.png', height: iconSize, width: iconSize),
                label: languageTranslate('lblSettings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
