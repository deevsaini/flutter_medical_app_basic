import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/doctor/screens/telemed/component/MeetDetails.dart';
import 'package:kivicare_flutter/doctor/screens/telemed/component/ZoomDetails.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/UserConfiguration.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

bool isZoomOn = false;
bool isMeetOn = false;

class TelemedScreen extends StatefulWidget {
  @override
  _TelemedScreenState createState() => _TelemedScreenState();
}

class _TelemedScreenState extends State<TelemedScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isZoomOn = appStore.telemedType == 'zoom';
    isMeetOn = appStore.telemedType == 'meet';

    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setDynamicStatusBarColor(color: scaffoldBgColor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblTelemed')),
        body: FutureBuilder<UserConfiguration>(
            future: getConfiguration(),
            builder: (context, snap) {
              if (snap.hasData) {
                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (snap.data!.isTeleMedActive.validate()) ZoomDetails(),
                            16.height,
                            if (snap.data!.isKiviCareGooglemeetActive.validate()) MeetDetails(),
                          ],
                        ),
                      ),
                    ),
                    Observer(
                      builder: (context) => Loader().visible(appStore.isLoading),
                    )
                  ],
                );
              } else {
                return snapWidgetHelper(snap);
              }
            }),
      ),
    );
  }
}
/*Future<bool> telemedType({required bool status}) async {
  //if both telemed is off
  if (appStore.telemedType == "") {
    //
  }

  return true;
}*/

Future<bool> setTelemedType({required String type}) async {
  Map<String, dynamic> req = {"user_id": appStore.userId, "telemed_type": type.validate()};

  appStore.setLoading(true);

  return await changeTelemedType(request: req).then((value) {
    appStore.setTelemedType(type.validate(), initiliaze: true);

    appStore.setLoading(false);

    return true;
  }).catchError((e) {
    log(e.toString());
    appStore.setLoading(false);
    return false;
  });
}
