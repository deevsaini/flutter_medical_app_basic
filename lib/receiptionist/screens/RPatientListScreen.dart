import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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

class RPatientList extends StatefulWidget {
  @override
  _RPatientListState createState() => _RPatientListState();
}

class _RPatientListState extends State<RPatientList> {
  TextEditingController searchCont = TextEditingController();

  int page = 1;

  bool isList = false;
  bool isLastPage = false;
  bool isReady = false;
  bool isLoading = false;

  List<PatientData> patientList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: AddFloatingButton(
          navigate: AddPatientScreen(),
        ),
        body: NotificationListener(
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<PatientListModel>(
                  future: getPatientList(page: page),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      if (page == 1) patientList.clear();

                      patientList.addAll(snap.data!.patientData.validate());
                      isReady = true;

                      isLastPage = snap.data!.total.validate() <= patientList.length;

                      if (snap.data!.patientData.validate().isEmpty) return NoDataFoundWidget(text: languageTranslate('lblNoDataFound'));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          16.height,
                          Text('$TOTAL_PATIENT (${snap.data!.total})', style: boldTextStyle(size: 18)).paddingOnly(right: 8, left: 8).paddingRight(8),
                          8.height,
                          Text(languageTranslate('lblSwipeMassage'), style: secondaryTextStyle(size: 12)).paddingOnly(left: 8),
                          10.height,
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: patientList.length,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              PatientData data = patientList[index];
                              String maleImage = "images/patientAvatars/patient3.png";
                              String femaleImage = "images/patientAvatars/patient6.png";
                              String image = data.gender.validate().toLowerCase() == "male" ? maleImage : femaleImage;
                              //  String image = getPatientImages()[index % getPatientImages().length];
                              return Slidable(
                                key: ValueKey(patientList[index]),
                                child: Container(
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

                                              FaIcon(FontAwesomeIcons.gaugeHigh, size: 20, color: appSecondaryColor).paddingAll(8).onTap(
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
                                                  Image.asset(
                                                    "images/icons/user.png",
                                                    height: 17,
                                                    width: 17,
                                                    color: appStore.isDarkModeOn ? Colors.white : appPrimaryColor,
                                                  ),
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
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(defaultRadius), bottomRight: Radius.circular(defaultRadius)),
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
                          ),
                          setLoader().visible(isSnapshotLoading(snap)).center(),
                        ],
                      );
                    }

                    return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
                  },
                ).center(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
