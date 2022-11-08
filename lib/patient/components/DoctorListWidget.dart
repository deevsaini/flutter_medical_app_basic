import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/components/DoctorDetailsScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorListWidget extends StatefulWidget {
  @override
  _DoctorListWidgetState createState() => _DoctorListWidgetState();
}

class _DoctorListWidgetState extends State<DoctorListWidget> {
  int selectedDoctor = -1;
  int page = 1;

  bool isLastPage = false;
  bool isReady = false;

  List<DoctorList> doctorList = [];

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
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (dynamic n) {
        if (!isLastPage && isReady) {
          if (n is ScrollEndNotification) {
            page++;
            isReady = false;

            setState(() {});
          }
        }
        return !isLastPage;
      },
      child: FutureBuilder<DoctorListModel>(
        future: getDoctorList(page: page, clinicId: isProEnabled() ? appointmentAppStore.mClinicSelected!.clinic_id.toInt() : null),
        builder: (_, snap) {
          if (snap.hasData) {
            if (page == 1) doctorList.clear();

            doctorList.addAll(snap.data!.doctorList.validate());
            isReady = true;

            isLastPage = snap.data!.total.validate() <= doctorList.length;
            if (doctorList.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: doctorList.length,
                padding: EdgeInsets.only(bottom: 70),
                itemBuilder: (BuildContext context, int index) {
                  DoctorList data = doctorList[index];
                  return GestureDetector(
                    onTap: () {
                      if (selectedDoctor == index) {
                        selectedDoctor = -1;
                        appointmentAppStore.setSelectedDoctor(null);
                      } else {
                        selectedDoctor = index;
                        appointmentAppStore.setSelectedDoctor(data);
                      }
                      setState(() {});
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 8, bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        backgroundColor: selectedDoctor == index ? selectedColor : context.cardColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          data.profile_image == null
                              ? Image.asset(
                                  data.profileImage,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ).cornerRadiusWithClipRRect(defaultRadius)
                              : cachedImage(
                                  data.profile_image,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ).cornerRadiusWithClipRRect(defaultRadius),
                          24.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              8.height,
                              Text("Dr. ${data.display_name.validate()}", style: boldTextStyle(size: 18)),
                              6.height,
                              Text(
                                data.specialties.validate().isNotEmpty ? data.specialties.validate() : 'NA',
                                style: secondaryTextStyle(color: secondaryTxtColor),
                              ),
                              8.height,
                              AppButton(
                                padding: EdgeInsets.symmetric(horizontal: 42),
                                text: languageTranslate('lblViewDetails'),
                                shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
                                textStyle: primaryTextStyle(color: white),
                                color: context.primaryColor,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                    ),
                                    builder: (context) {
                                      return DoctorDetailScreen(data: data);
                                    },
                                  );
                                },
                              )
                            ],
                          ).expand(),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return NoDataFoundWidget(text: languageTranslate('lblNoDataFound'), iconSize: 130).center();
            }
          }
          return snapWidgetHelper(snap);
        },
      ),
    );
  }
}
