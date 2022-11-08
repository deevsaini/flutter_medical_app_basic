import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/ClinicListModel.dart';
import 'package:kivicare_flutter/main/model/LoginResponseModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class ClinicListWidget extends StatefulWidget {
  @override
  _ClinicListWidgetState createState() => _ClinicListWidgetState();
}

class _ClinicListWidgetState extends State<ClinicListWidget> {
  int selectedClinic = -1;
  int page = 1;

  bool isLastPage = false;
  bool isReady = false;

  List<Clinic> clinicList = [];

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
      child: FutureBuilder<ClinicListModel>(
        future: getClinicList(page: page),
        builder: (_, snap) {
          if (snap.hasData) {
            if (page == 1) clinicList.clear();

            clinicList.addAll(snap.data!.clinicData!);
            isReady = true;

            isLastPage = snap.data!.total.validate() <= clinicList.length;
            if (clinicList.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: 80),
                itemCount: clinicList.length,
                itemBuilder: (BuildContext context, int index) {
                  Clinic data = clinicList[index];
                  return GestureDetector(
                    onTap: () {
                      if (selectedClinic == index) {
                        selectedClinic = -1;
                        appointmentAppStore.setSelectedClinic(null);
                      } else {
                        selectedClinic = index;
                        appointmentAppStore.setSelectedClinic(data);
                      }
                      setState(() {});
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          decoration: boxDecorationWithShadow(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            spreadRadius: 0,
                            blurRadius: 0,
                            backgroundColor: selectedClinic == index ? selectedColor : context.cardColor,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              data.profile_image == null
                                  ? Image.network(
                                      "https://images.unsplash.com/photo-1589279003513-467d320f47eb?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8Y2xpbmljfGVufDB8fDB8&ixlib=rb-1.2.1&w=1000&q=80",
                                      height: 100,
                                      width: 95,
                                      fit: BoxFit.cover,
                                    )
                                  : cachedImage(data.profile_image, height: 100, width: 95, radius: defaultRadius, fit: BoxFit.cover).cornerRadiusWithClipRRect(
                                      defaultRadius,
                                    ),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  8.height,
                                  Text("${data.clinic_name.validate()}", style: boldTextStyle(size: titleTextSize)),
                                  16.height,
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Email:', style: secondaryTextStyle(color: secondaryTxtColor)).paddingOnly(top: 2),
                                      8.width,
                                      Text('${data.clinic_email}', style: boldTextStyle(size: 16)).flexible(),
                                    ],
                                  ),
                                ],
                              ).expand(),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: appSecondaryColor,
                              borderRadius: BorderRadius.only(topRight: Radius.circular(defaultRadius)),
                            ),
                            child: Text(getClinicStatus(data.status).toString(), style: primaryTextStyle(size: 12, color: white)),
                          ),
                        )
                      ],
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
