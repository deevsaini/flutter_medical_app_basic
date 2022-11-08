import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/ClinicListWidget.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/screens/appointment/AddAppointmentScreenStep1.dart';
import 'package:kivicare_flutter/patient/screens/appointment/AddAppointmentScreenStep2.dart';
import 'package:nb_utils/nb_utils.dart';

class AddAppointmentScreenStep3 extends StatefulWidget {
  @override
  _AddAppointmentScreenStep3State createState() => _AddAppointmentScreenStep3State();
}

class _AddAppointmentScreenStep3State extends State<AddAppointmentScreenStep3> {
  TextEditingController searchCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    searchCont.dispose();
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return SingleChildScrollView(
        child: Column(
          children: [
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languageTranslate("lblStep1Of3"), style: primaryTextStyle(size: 14, color: patientTxtColor)),
                    8.height,
                    Text(languageTranslate('lblChooseYourClinic'), style: boldTextStyle(size: titleTextSize)),
                  ],
                ),
                stepProgressIndicator(stepTxt: "1/3", percentage: 0.33),
              ],
            ),
            16.height,
            ClinicListWidget(),
          ],
        ).paddingAll(16),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate("lblAddNewAppointment")),
        body: body(),
        floatingActionButton: AddFloatingButton(
          icon: Icons.arrow_forward_outlined,
          onTap: () {
            if (appointmentAppStore.mClinicSelected == null)
              errorToast(languageTranslate("lblSelectOneClinic"));
            else {
              if (appStore.isBookedFromDashboard) {
                AddAppointmentScreenStep2().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
              } else {
                AddAppointmentScreenStep1().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
              }
            }
          },
        ),
      ),
    );
  }
}
