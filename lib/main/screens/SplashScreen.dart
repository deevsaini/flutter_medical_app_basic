import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/DoctorDashboardScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/screens/SignInScreen.dart';
import 'package:kivicare_flutter/main/screens/WalkThroughScreen.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLocalizations.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/screens/PatientDashBoardScreen.dart';
import 'package:kivicare_flutter/receiptionist/screens/RDashBoardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    checkFirstSeen();
  }

  Future<void> getDefaultDetailsOfUser() async {
    appStore.setUserId(getIntAsync(USER_ID));
    appStore.setFirstName(getStringAsync(FIRST_NAME));
    appStore.setLastName(getStringAsync(LAST_NAME));
    appStore.setUserEmail(getStringAsync(USER_EMAIL));
    appStore.setUserDisplayName(getStringAsync(USER_DISPLAY_NAME));
    appStore.setUserProfile(getStringAsync(PROFILE_IMAGE, defaultValue: ""));
    appStore.setUserGender(getStringAsync(USER_GENDER));
    appStore.setRole(getStringAsync(USER_ROLE));
    appStore.setUserMobileNumber(getStringAsync(USER_MOBILE));
    appStore.setUserProEnabled(getBoolAsync(USER_PRO_ENABLED));
    appStore.setUserTelemedOn(getBoolAsync(USER_TELEMED_ON));
    appStore.setUserEnableGoogleCal(getStringAsync(USER_ENABLE_GOOGLE_CAL));
    appStore.setUserDoctorGoogleCal(getStringAsync(DOCTOR_ENABLE_GOOGLE_CAL));
    appStore.setCurrency(getStringAsync(CURRENCY));
    appStore.setBaseUrl(getStringAsync(SAVE_BASE_URL, defaultValue: mainUrl));
    appStore.setDemoDoctor(getStringAsync(DEMO_DOCTOR));
    appStore.setDemoReceptionist(getStringAsync(DEMO_RECEPTIONIST));
    appStore.setDemoPatient(getStringAsync(DEMO_PATIENT));
    appStore.setBaseUrl(getStringAsync(SAVE_BASE_URL));
  }

  Future checkFirstSeen() async {
    setStatusBarColor(Colors.transparent, statusBarBrightness: Brightness.dark, statusBarIconBrightness: appStore.isDarkModeOn ? Brightness.light : Brightness.dark);

    afterBuildCreated(() {
      int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
      if (themeModeIndex == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
      }
    });

    await Future.delayed(Duration(seconds: 2));
    appLocalization = AppLocalizations.of(context);

    appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));
    getDefaultDetailsOfUser();
    getPackageInfo().then((value) {
      setValue(VERSION, value.versionName);
      setValue(PACKAGE_NAME, value.packageName);
    });

    if (appStore.isLoggedIn) {
      if (getStringAsync(USER_ROLE) == UserRoleDoctor) {
        DoctorDashboardScreen().launch(context, isNewTask: true);
      } else if (getStringAsync(USER_ROLE) == UserRolePatient) {
        PatientDashBoardScreen().launch(context, isNewTask: true);
      } else if (isReceptionist()) {
        RDashBoardScreen().launch(context, isNewTask: true);
      } else {
        SignInScreen().launch(context, isNewTask: true);
      }
      getConfiguration().catchError((e) {
        log(e.toString());
      });
    } else {
      if (getBoolAsync(IS_WALKTHROUGH_FIRST, defaultValue: false)) {
        SignInScreen().launch(context, isNewTask: true);
      } else {
        WalkThroughScreen().launch(context, isNewTask: true);
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('images/appIcon.png', height: 150, width: 150).center(),
          25.height,
          RichTextWidget(
            list: [
              TextSpan(
                text: appFirstName,
                style: boldTextStyle(
                  size: 36,
                  letterSpacing: 1,
                  color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor,
                ),
              ),
              TextSpan(
                text: appSecondName,
                style: primaryTextStyle(
                  size: 36,
                  letterSpacing: 1,
                  color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
