import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/doctor/screens/AddPatientScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/PatientListModel.dart';
import 'package:kivicare_flutter/main/screens/EncounterScreen.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientFragment extends StatefulWidget {
  @override
  _PatientFragmentState createState() => _PatientFragmentState();
}

class _PatientFragmentState extends State<PatientFragment> {
  TextEditingController searchCont = TextEditingController();
  bool isLoading = false;

  List<PatientData> patientDataList = [];
  List<PatientData> patientList = [];

  int page = 1;

  bool isList = false;
  bool isLastPage = false;
  bool isReady = false;

  @override
  void initState() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PatientFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    searchCont.dispose();
    super.dispose();
  }

  Widget body() {
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
      child: FutureBuilder<PatientListModel>(
        future: getPatientList(page: page),
        builder: (_, snap) {
          if (snap.hasData) {
            if (page == 1) patientList.clear();
            patientList.addAll(snap.data!.patientData.validate());
            isReady = true;
            isLastPage = snap.data!.total.validate() <= patientList.length;
            if (patientList.isNotEmpty) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    AppTextField(
                      textStyle: primaryTextStyle(color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor),
                      controller: searchCont,
                      textAlign: TextAlign.start,
                      textFieldType: TextFieldType.NAME,
                      decoration: speechInputWidget(context),
                    ).paddingAll(16).visible(false),
                    Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languageTranslate('lblPatients') + ' (${snap.data!.total.toString().validate()})',
                              style: boldTextStyle(size: titleTextSize),
                            ),
                            8.height,
                            Text(languageTranslate('lblSwipeMassage'), style: secondaryTextStyle(size: 12)),
                          ],
                        ),
                        ListView.builder(
                          padding: EdgeInsets.only(bottom: 60, top: 24),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: patientList.length,
                          itemBuilder: (BuildContext context, int index) {
                            PatientData data = patientList[index];
                            String maleImage = "images/patientAvatars/patient3.png";
                            String femaleImage = "images/patientAvatars/patient6.png";
                            String image = data.gender.validate().toLowerCase() == "male" ? maleImage : femaleImage;
                            return Slidable(
                              key: ValueKey(patientList[index]),
                              child: Container(
                                //  margin: EdgeInsets.symmetric(vertical: 12),
                                padding: EdgeInsets.only(left: 8, top: 10, bottom: 10, right: 8),
                                decoration: boxDecorationWithShadow(
                                  blurRadius: 0,
                                  spreadRadius: 0,
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  backgroundColor: Theme.of(context).cardColor,
                                ),
                                child: Row(
                                  children: [
                                    data.profile_image == null
                                        ? Image.asset(image, height: 65)
                                        : cachedImage(
                                            data.profile_image.validate(),
                                            height: 100,
                                            width: 90,
                                            fit: BoxFit.cover,
                                          ).cornerRadiusWithClipRRect(defaultRadius).paddingAll(8),
                                    8.width,
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(data.display_name.validate(), style: boldTextStyle(size: 16)).flexible(),

                                            FaIcon(
                                              FontAwesomeIcons.tachometerAlt,
                                              size: 20,
                                              color: appSecondaryColor,
                                            ).paddingAll(8).onTap(
                                              () {
                                                EncounterScreen(patientData: data, image: image).launch(context);
                                              },
                                            )

                                            // menuOption(patientData: data, image: image),
                                          ],
                                        ),
                                        8.height,
                                        Row(
                                          children: [
                                            Image.asset(
                                              "images/icons/phone.png",
                                              height: 16,
                                              width: 16,
                                              color: appStore.isDarkModeOn ? Colors.white : appPrimaryColor,
                                            ),
                                            10.width,
                                            Text(data.mobile_number.validate(), style: primaryTextStyle(color: secondaryTxtColor)),
                                          ],
                                        ).onTap(() {
                                          launch("tel:// ${data.mobile_number.validate()}");
                                        }),
                                        14.height,
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset("images/icons/user.png", height: 17, width: 17, color: appStore.isDarkModeOn ? Colors.white : appPrimaryColor),
                                                10.width,
                                                Text(
                                                  data.gender.validate().isNotEmpty ? '${data.gender.validate().capitalizeFirstLetter()}' : 'NA',
                                                  style: primaryTextStyle(color: secondaryTxtColor),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ).paddingAll(4).expand()
                                  ],
                                ),
                              ).paddingOnly(right: 4),
                              endActionPane: ActionPane(
                                motion: ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (BuildContext context) async {
                                      bool? res = await AddPatientScreen(userId: data.iD).launch(context);
                                      if (res ?? false) setState(() {});
                                    },
                                    flex: 2,
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(defaultRadius),
                                      bottomLeft: Radius.circular(defaultRadius),
                                    ),
                                    icon: Icons.edit,
                                    label: languageTranslate('lblEdit'),
                                  ),
                                  SlidableAction(
                                    // An action can be bigger than the others.
                                    flex: 2,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(defaultRadius),
                                      bottomRight: Radius.circular(defaultRadius),
                                    ),
                                    onPressed: (BuildContext context) async {
                                      bool res = await (showConfirmDialog(context, languageTranslate('lblDeleteRecordConfirmation') + " ${data.display_name}?", buttonColor: primaryColor));
                                      if (res) {
                                        isLoading = true;
                                        setState(() {});
                                        Map request = {"patient_id": data.iD};
                                        deletePatientData(request).then((value) {
                                          isLoading = false;
                                          setState(() {});
                                          successToast(languageTranslate('lblAllRecordsFor') + " ${data.display_name} " + languageTranslate('lblAreDeleted'));
                                        }).catchError((e) {
                                          isLoading = false;
                                          setState(() {});
                                          errorToast(e.toString());
                                        });
                                      }
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: languageTranslate('lblDelete'),
                                  ),
                                ],
                              ),
                            ).paddingSymmetric(vertical: 8);
                          },
                        ).paddingTop(32),
                        setLoader().visible(isSnapshotLoading(snap)).center(),
                      ],
                    ).paddingAll(16),
                  ],
                ),
              );
            } else {
              // return noDataWidget(text: translate('lblNoPatientFound'));
              return NoDataFoundWidget(text: languageTranslate('lblNoPatientFound')).center();
            }
          }
          return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            bool? res = await AddPatientScreen().launch(context);
            if (res ?? false) setState(() {});
          },
        ),
        body: body(),
      ),
    );
  }
}
