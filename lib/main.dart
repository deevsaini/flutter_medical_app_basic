import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kivicare_flutter/main/model/LanguageModel.dart';
import 'package:kivicare_flutter/main/screens/SplashScreen.dart';
import 'package:kivicare_flutter/main/services/AuthService.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLocalizations.dart';
import 'package:kivicare_flutter/main/utils/AppTheme.dart';
import 'package:kivicare_flutter/network/DefaultFirebaseConfig.dart';
import 'package:kivicare_flutter/store/AppStore.dart';
import 'package:kivicare_flutter/store/AppointmentAppStore.dart';
import 'package:kivicare_flutter/store/EditProfileAppStore.dart';
import 'package:kivicare_flutter/store/ListAppStore.dart';
import 'package:kivicare_flutter/store/MultiSelectStore.dart';
import 'package:nb_utils/nb_utils.dart';

late PackageInfoData packageInfo;

AppStore appStore = AppStore();
ListAppStore listAppStore = ListAppStore();
AppointmentAppStore appointmentAppStore = AppointmentAppStore();
EditProfileAppStore editProfileAppStore = EditProfileAppStore();
MultiSelectStore multiSelectStore = MultiSelectStore();

AuthService authService = AuthService();
AppLocalizations? appLocalization;

PickedFile? image;

late Language language;
List<Language> languages = Language.getLanguages();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions).then((value) {
    setupRemoteConfig();
  }).catchError((e) {
    log(e);
  });

  Function? originalOnError = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    originalOnError!(errorDetails);
  };

  defaultBlurRadius = 4;
  defaultSpreadRadius = 0.5;
  defaultAppBarElevation = 2;
  textPrimaryColorGlobal = textPrimaryBlackColor;
  textSecondaryColorGlobal = secondaryTxtColor;
  textBoldSizeGlobal = 14;
  textPrimarySizeGlobal = 16;
  textSecondarySizeGlobal = 14;
  appButtonBackgroundColorGlobal = primaryColor;
  defaultAppButtonTextColorGlobal = Colors.white;
  defaultAppButtonElevation = 0.0;
  defaultRadius = 5.0;
  defaultLoaderAccentColorGlobal = primaryColor;

  await initialize();

  packageInfo = await getPackageInfo();

  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));
  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(true);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
        supportedLocales: Language.languagesLocale(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguage),
        title: appName,
        navigatorKey: navigatorKey,
        home: SplashScreen(),
        builder: scrollBehaviour(),
      ),
    );
  }
}
