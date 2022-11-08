import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/components/DoctorListWidget.dart';
import 'package:kivicare_flutter/patient/screens/appointment/AddAppointmentScreenStep2.dart';
import 'package:nb_utils/nb_utils.dart';

class AddAppointmentScreenStep1 extends StatefulWidget {
  @override
  _AddAppointmentScreenStep1State createState() => _AddAppointmentScreenStep1State();
}

class _AddAppointmentScreenStep1State extends State<AddAppointmentScreenStep1> {
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
  void dispose() async {
    super.dispose();
    setStatusBarColor(
      appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor,
      delayInMilliSeconds: 400,
      statusBarIconBrightness: Brightness.light,
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isProEnabled()
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languageTranslate('lblStep2Of3'),
                              style: primaryTextStyle(size: 14, color: patientTxtColor),
                            ),
                            8.height,
                            Text(languageTranslate('lblChooseYourDoctor'), style: boldTextStyle(size: titleTextSize)),
                          ],
                        ),
                      ],
                    )
                  : Text(
                      languageTranslate('lblStep1Of2'),
                      style: primaryTextStyle(size: 14, color: patientTxtColor),
                    ),
              stepProgressIndicator(stepTxt: "2/3", percentage: 0.66),
            ],
          ),
          16.height,
          DoctorListWidget(),
        ],
      ).paddingAll(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: appAppBar(context, name: languageTranslate('lblAddNewAppointment')),
          body: body(),
          floatingActionButton: AddFloatingButton(
            icon: Icons.arrow_forward_outlined,
            onTap: () {
              if (appointmentAppStore.mDoctorSelected == null)
                errorToast(languageTranslate('lblSelectOneDoctor'));
              else {
                AddAppointmentScreenStep2().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
              }
            },
          )),
    );
  }
}
