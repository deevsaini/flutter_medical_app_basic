import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/AppointmentWidget.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/PatientDashboardModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/components/DoctorDashboardWidget.dart';
import 'package:kivicare_flutter/patient/components/NewsDashboardWidget.dart';
import 'package:kivicare_flutter/patient/components/NewsListWidget.dart';
import 'package:kivicare_flutter/patient/model/NewsModel.dart';
import 'package:kivicare_flutter/patient/screens/CategoryScreen.dart';
import 'package:kivicare_flutter/patient/screens/DoctorListScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import 'PatientUpcomingAppointmentFragment.dart';

class PDashBoardFragment extends StatefulWidget {
  @override
  _PDashBoardFragmentState createState() => _PDashBoardFragmentState();
}

class _PDashBoardFragmentState extends State<PDashBoardFragment> {
  TextEditingController searchCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    searchCont.dispose();
    super.dispose();
  }

  Widget patientTotalDataComponent({required List<UpcomingAppointment> upcomingAppointment}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(languageTranslate('lblUpcomingAppointments'), style: boldTextStyle(size: titleTextSize)).expand(),
            Text(languageTranslate('lblViewAll'), style: secondaryTextStyle(color: appSecondaryColor)).onTap(() {
              PatientUpcomingAppointmentFragment().launch(context);
            }).visible(upcomingAppointment.length >= 2),
          ],
        ),
        8.height,
        Text(languageTranslate('lblSwipeMassage'), style: secondaryTextStyle(size: 12)),
        24.height,
        Wrap(
          runSpacing: 16,
          children: upcomingAppointment
              .map((UpcomingAppointment data) {
                return AppointmentWidget(upcomingData: data, index: upcomingAppointment.indexOf(data));
              })
              .take(2)
              .toList(),
        ).visible(
          upcomingAppointment.isNotEmpty,
          defaultWidget: noAppointmentDataWidget(text: languageTranslate('lblNoUpcomingAppointments')),
        ),
      ],
    );
  }

  Widget patientSymptomsComponent({required List<Service> service}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(languageTranslate('lblClinicServices'), style: boldTextStyle(size: titleTextSize)),
            TextButton(
              onPressed: () {
                CategoryScreen(service: service).launch(context);
              },
              child: Text("More", style: secondaryTextStyle(color: appSecondaryColor)),
            ).visible(service.length >= 7),
          ],
        ).paddingSymmetric(horizontal: 8),
        18.height,
        Wrap(
          direction: Axis.horizontal,
          spacing: 16,
          runSpacing: 16,
          children: service.map((data) {
            String image = getServicesImages()[service.indexOf(data) % getServicesImages().length];
            return Container(
              width: context.width() / 4 - 20,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
                    child: Image.asset(image, height: 36),
                  ),
                  8.height,
                  Text(
                    '${data.name.validate()}',
                    textAlign: TextAlign.center,
                    style: secondaryTextStyle(color: secondaryTxtColor),
                    softWrap: true,
                    textWidthBasis: TextWidthBasis.longestLine,
                    textScaleFactor: 1,
                  ),
                ],
              ),
            );
          }).toList(),
        ).paddingSymmetric(horizontal: 4),
      ],
    );
  }

  Widget topDoctorComponent({required List<DoctorList> doctorList}) {
    if (doctorList.isEmpty) return Offstage();
    return Column(
      children: [
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(languageTranslate('lblTopDoctors'), style: boldTextStyle(size: titleTextSize)),
            Text(languageTranslate('lblViewAll'), style: secondaryTextStyle(color: appSecondaryColor)).onTap(() {
              DoctorListScreen().launch(context);
            }).visible(doctorList.length >= 2),
          ],
        ),
        16.height,
        Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            runSpacing: 8,
            spacing: 16,
            children: doctorList.map((e) => DoctorDashboardWidget(data: e)).take(2).toList(),
          ),
        ),
      ],
    );
  }

  Widget newsComponent({required List<NewsData> newsData}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(languageTranslate('lblExpertsHealthTipsAndAdvice'), style: boldTextStyle(size: 20)),
                1.height,
                Text(languageTranslate('lblArticlesByHighlyQualifiedDoctors'), style: secondaryTextStyle()),
              ],
            ).expand(),
            Text(languageTranslate('lblViewAll'), style: boldTextStyle()).onTap(() {
              NewsListWidget(newsData: newsData).launch(context);
            }).visible(newsData.length >= 2),
          ],
        ),
        20.height,
        Wrap(
          runSpacing: 16,
          children: newsData
              .map((e) {
                return NewsDashboardWidget(newsData: e, index: newsData.indexOf(e));
              })
              .take(3)
              .toList(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientDashboardModel>(
      future: getPatientDashBoard(),
      builder: (context, snap) {
        if (snap.hasData) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                //TODO Not implement the Functionality
                16.height.visible(false),
                AppTextField(
                  textStyle: primaryTextStyle(color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor),
                  controller: searchCont,
                  textAlign: TextAlign.start,
                  textFieldType: TextFieldType.NAME,
                  decoration: speechInputWidget(context, hintText: languageTranslate('lblSearchDoctor'), iconColor: primaryColor),
                ).paddingSymmetric(horizontal: 8).visible(false),
                8.height,
                patientTotalDataComponent(upcomingAppointment: snap.data!.upcoming_appointment!).paddingAll(8),
                32.height,
                patientSymptomsComponent(service: snap.data!.serviceList!).paddingSymmetric(vertical: 8),
                topDoctorComponent(doctorList: snap.data!.doctor.validate()).paddingAll(8),
              ],
            ),
          );
        }
        return snapWidgetHelper(snap);
      },
    );
  }
}
