import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

Future<void> launchUrl(String url, {bool forceWebView = false}) async {
  await launch(url, forceWebView: forceWebView, enableJavaScript: true, statusBarBrightness: Brightness.light).catchError((e) {
    log(e);
    toast('Invalid URL: $url');
  });
}

String languageTranslate(String? key) {
  return appLocalization!.translate(key);
}

void errorToast(String e) {
  toast(e, bgColor: errorBackGroundColor, textColor: errorTextColor);
}

void successToast(String? e) {
  toast(e, bgColor: successBackGroundColor, textColor: successTextColor);
}

InputDecoration textInputStyle({required BuildContext context, String? label, bool isMandatory = false, Widget? suffixIcon, Widget? prefixIcon, String? text, String prefixText = ''}) {
  return InputDecoration(
    contentPadding: EdgeInsets.all(8),
    fillColor: appStore.isDarkModeOn ? cardDarkColor : Colors.white,
    filled: true,
    labelStyle: secondaryTextStyle(color: secondaryTxtColor),
    hintStyle: secondaryTextStyle(color: secondaryTxtColor),
    hintText: '',
    prefixText: prefixText,
    suffixIcon: suffixIcon,
    suffixIconColor: context.iconColor,
    prefixStyle: primaryTextStyle(),
    alignLabelWithHint: true,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    labelText: text != null
        ? text
        : label.validate().isNotEmpty
            ? '${languageTranslate(label)}${isMandatory ? '*' : ''}'
            : '',
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 0.5),
      borderRadius: radius(),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 0.5),
      borderRadius: radius(),
    ),
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Colors.transparent),
      borderRadius: radius(),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: Colors.transparent),
      borderRadius: radius(),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 0.5),
      borderRadius: radius(),
    ),
  );
}

DateTime getDay(DateTime date) {
  return DateTime.parse(DateFormat(CONVERT_DATE).format(date));
}

InputDecoration speechInputWidget(BuildContext context, {String? hintText, Color? iconColor}) {
  return InputDecoration(
    contentPadding: EdgeInsets.all(8),
    fillColor: context.cardColor,
    filled: true,
    prefixIcon: Image.asset("images/icons/search.png", color: iconColor ?? context.iconColor, height: 10, width: 10).paddingAll(16)
    /*commonImage(
      imageUrl: "images/icons/search.png",
      size: 10,
    )*/
    ,
    suffixIcon: commonImage(imageUrl: "images/icons/speech.png", size: 16, fit: BoxFit.cover),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 1.0),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 1.0),
      borderRadius: BorderRadius.circular(8),
    ),
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1.0, color: Colors.transparent),
      borderRadius: BorderRadius.circular(8),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(width: 1.0, color: Colors.transparent),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: 1.0),
      borderRadius: BorderRadius.circular(8),
    ),
    hintText: hintText ?? "Search here...",
    hintStyle: secondaryTextStyle(size: 14, color: secondaryTxtColor),
  );
}

String? getStatus(String num) {
  String? status;
  if (num == '0') {
    return status = 'Cancelled';
  } else if (num == '1') {
    return status = 'Booked';
  } else if (num == '3') {
    return status = 'Checkout';
  } else if (num == '4') {
    return status = 'Checkin';
  }
  return status;
}

Color? getStatusColor(String num) {
  Color? colors;
  if (num == '0') {
    return colors = Color(0xFFd0150f);
  } else if (num == '1') {
    return colors = Color(0xFF1b52d6);
  } else if (num == '3') {
    return colors = Color(0xFF23a359);
  } else if (num == '4') {
    return colors = Color(0xFF23a359);
  }
  return colors;
}

String? getEncounterStatus(String? num) {
  String? status;
  if (num == '0') {
    return status = 'Complete';
  } else if (num == '1') {
    return status = 'Active';
  } else if (num == '2') {
    return status = 'InActive';
  }
  return status;
}

String? getServiceStatus(String num) {
  String? status;
  if (num == '0') {
    return status = 'Active';
  } else if (num == '1') {
    return status = 'InActive';
  }
  return status;
}

String? getClinicStatus(String? num) {
  String? status;
  if (num == '0') {
    return status = 'Closed';
  } else if (num == '1') {
    return status = 'Open';
  }
  return status;
}

Color? getServiceStatusColor(int num) {
  Color? colors;
  if (num == 0) {
    return colors = Color(0xFFd0150f);
  } else if (num == 1) {
    return colors = Color(0xFF23a359);
  }
  return colors;
}

Color getHolidayStatusColor(bool num) {
  Color colors;
  if (num) {
    colors = Color(0xFF23a359);
  } else {
    colors = Color(0xFFd0150f);
  }
  return colors;
}

Color getEncounterStatusColor(String? num) {
  Color colors = Color(0xFFd0150f);
  if (num == '0') {
    return colors = Color(0xFFd0150f);
  } else if (num == '1') {
    return colors = Color(0xFF23a359);
  } else if (num == '2') {
    return colors = Color(0xFF23a359);
  }
  return colors;
}

List<String> monthNameList = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

String getDayOfMonthSuffix(int dayNum) {
  if (!(dayNum >= 1 && dayNum <= 31)) {
    throw Exception('Invalid day of month');
  }

  if (dayNum >= 11 && dayNum <= 13) {
    return 'th';
  }

  switch (dayNum % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

extension DateExt on DateTime {
  String getFormattedDate(String format) {
    return DateFormat(format).format(this);
  }
}

extension StExt on String {
  String getFormattedDate(String format) {
    return DateFormat(format).format(DateTime.parse(this));
  }

  int? getStatus() {
    int? id;
    if (this == BookedStatus) {
      return id = 1;
    } else if (this == CheckOutStatus) {
      return id = 3;
    } else if (this == CheckInStatus) {
      return id = 4;
    } else if (this == CancelledStatus) {
      return id = 0;
    }
    return id;
  }
}

extension intExt on int? {
  String? getMonthName() {
    String? status;
    if (this == 1) {
      return status = 'Jan';
    } else if (this == 2) {
      return status = 'Feb';
    } else if (this == 3) {
      return status = 'Mar';
    } else if (this == 4) {
      return status = 'Apr';
    } else if (this == 5) {
      return status = 'May';
    } else if (this == 6) {
      return status = 'Jun';
    } else if (this == 7) {
      return status = 'Jul';
    } else if (this == 8) {
      return status = 'Aug';
    } else if (this == 9) {
      return status = 'Sept';
    } else if (this == 10) {
      return status = 'Oct';
    } else if (this == 11) {
      return status = 'Nov';
    } else if (this == 12) {
      return status = 'Dec';
    }
    return status;
  }

  String getWeekDay() {
    String weekName = 'Sun';

    if (this == 1) {
      return weekName = "Mon";
    } else if (this == 2) {
      return weekName = "Tue";
    } else if (this == 3) {
      return weekName = "Wed";
    } else if (this == 4) {
      return weekName = "Thu";
    } else if (this == 5) {
      return weekName = "Fri";
    } else if (this == 6) {
      return weekName = "Sat";
    }
    return weekName;
  }

  String getFullWeekDay() {
    String weekName = 'Sunday';

    if (this == 1) {
      return weekName = "Monday";
    } else if (this == 2) {
      return weekName = "Tuesday";
    } else if (this == 3) {
      return weekName = "Wednesday";
    } else if (this == 4) {
      return weekName = "Thursday";
    } else if (this == 5) {
      return weekName = "Friday";
    } else if (this == 6) {
      return weekName = "Saturday";
    }
    return weekName;
  }

  String getWeekDays() {
    String weekName = '';

    if (this == 1) {
      return weekName = "Mon";
    } else if (this == 2) {
      return weekName = "Tue";
    } else if (this == 3) {
      return weekName = "Wed";
    } else if (this == 4) {
      return weekName = "Thu";
    } else if (this == 5) {
      return weekName = "Fri";
    } else if (this == 6) {
      return weekName = "Sat";
    } else if (this == 7) {
      return weekName = "Sun";
    }
    return weekName;
  }

  String? getStatus() {
    String? id;
    if (this == 1) {
      return id = BookedStatus;
    } else if (this == 3) {
      return id = CheckOutStatus;
    } else if (this == 4) {
      return id = CheckInStatus;
    } else if (this == 0) {
      return id = CancelledStatus;
    }
    return id;
  }
}

bool isDoctor() => getStringAsync(USER_ROLE) == UserRoleDoctor;

bool isPatient() => getStringAsync(USER_ROLE) == UserRolePatient;

bool isReceptionist() => getStringAsync(USER_ROLE) == UserRoleReceptionist;

bool isProEnabled() => getBoolAsync(USER_PRO_ENABLED);

void setDynamicStatusBarColor({Color? color}) {
  if (color != null) {
    setStatusBarColor(appStore.isDarkModeOn ? primaryDarkColor : color);
  } else if (appStore.isDarkModeOn) {
    setStatusBarColor(primaryDarkColor);
  } else {
    setStatusBarColor(Colors.white);
  }
}

Future setupRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await FirebaseRemoteConfig.instance.fetchAndActivate();

  appStore.setDemoEmails();
}

Widget commonImage({String? imageUrl, double? size, BoxFit? fit}) {
  return Image.asset(
    imageUrl.validate(),
    width: size ?? 24,
    height: size ?? 24,
    fit: fit ?? BoxFit.cover,
    color: appStore.isDarkModeOn ? Colors.white : Color(0xFF6E7990),
  ).paddingAll(16);
}

Widget loginRegisterWidget(BuildContext context, {String? title, String? subTitle, Function()? onTap}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(title.validate(), style: secondaryTextStyle()),
      TextButton(
        onPressed: onTap,
        child: Text(subTitle.validate(), style: primaryTextStyle(color: appSecondaryColor, size: 14, decoration: TextDecoration.underline)),
      )
    ],
  );
}

Widget doctorDetailWidget({String? image, String? title, String? subTitle, Color? bgColor}) {
  return Row(
    children: [
      Container(
        decoration: boxDecorationWithRoundedCorners(
          boxShape: BoxShape.circle,
          backgroundColor: bgColor ?? iconBgColor,
        ),
        padding: EdgeInsets.all(16),
        child: Image.asset(image.validate(), width: 18, height: 18, fit: BoxFit.cover, color: appSecondaryColor),
      ),
      16.width,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.validate(), style: secondaryTextStyle(color: secondaryTxtColor)),
          8.height,
          Text(subTitle.validate(), style: boldTextStyle(size: 16)).fit(),
        ],
      ).expand(),
    ],
  );
}

Widget stepProgressIndicator({String? stepTxt, double? percentage}) {
  return CircularPercentIndicator(
    radius: 30.0,
    animation: true,
    animationDuration: 1200,
    lineWidth: 6.0,
    percent: percentage.validate(),
    center: Text(stepTxt.validate(), style: boldTextStyle()),
    circularStrokeCap: CircularStrokeCap.round,
    backgroundColor: Color(0xFF5CC16C).withOpacity(0.4),
    progressColor: Color(0xFF5CC16C),
  );
}
