import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/SettingFragment.dart';
import 'package:kivicare_flutter/main/components/TopNameWidget.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/receiptionist/components/RAppointmentFragment.dart';
import 'package:kivicare_flutter/receiptionist/screens/RDoctorListingScreen.dart';
import 'package:kivicare_flutter/receiptionist/screens/RPatientListScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class RDashBoardScreen extends StatefulWidget {
  @override
  _RDashBoardScreenState createState() => _RDashBoardScreenState();
}

class _RDashBoardScreenState extends State<RDashBoardScreen> {
  int currentIndex = 0;

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
                margin: EdgeInsets.only(top: currentIndex != 3 ? 70 : 0),
                child: [
                  RAppointmentFragment(),
                  RDoctorListingScreen(),
                  RPatientList(),
                  SettingFragment(),
                ][currentIndex],
              )
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
                icon: Container(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Image.asset(
                    'images/icons/calendar.png',
                    height: 25,
                    width: 25,
                    color: appStore.isDarkModeOn ? Colors.white : secondaryTxtColor,
                  ),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Image.asset('images/icons/calendarFill.png', height: 25, width: 25),
                ).cornerRadiusWithClipRRect(10),
                label: languageTranslate('lblAppointments'),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Image.asset(
                    'images/icons/doctorIcon.png',
                    height: 25,
                    width: 25,
                    color: appStore.isDarkModeOn ? Colors.white : secondaryTxtColor,
                  ),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Image.asset('images/icons/fill_doctor.png', height: 25, width: 25),
                ).cornerRadiusWithClipRRect(10),
                label: languageTranslate('lblDoctor'),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  child: Image.asset(
                    'images/icons/patient.png',
                    height: 25,
                    width: 25,
                    color: appStore.isDarkModeOn ? Colors.white : secondaryTxtColor,
                  ),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  child: Image.asset('images/icons/patientFill.png', height: 25, width: 25, color: primaryColor),
                ).cornerRadiusWithClipRRect(10),
                label: languageTranslate('lblPatients'),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  child: Image.asset(
                    'images/icons/more_item.png',
                    height: 25,
                    width: 25,
                    color: appStore.isDarkModeOn ? Colors.white : secondaryTxtColor,
                  ),
                ),
                activeIcon: Container(
                  padding: EdgeInsets.all(6),
                  child: Image.asset('images/icons/more_item_fill.png', height: 25, width: 25, color: primaryColor),
                ).cornerRadiusWithClipRRect(10),
                label: languageTranslate('lblMoreItems'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
