import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/fragments/AddQualificationScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class RProfileQualification extends StatefulWidget {
  final GetDoctorDetailModel? getDoctorDetail;

  RProfileQualification({this.getDoctorDetail});

  @override
  _RProfileQualificationState createState() => _RProfileQualificationState();
}

class _RProfileQualificationState extends State<RProfileQualification> {
  List<Qualification>? qualificationList = [];

  bool isLoading = false;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isUpdate = widget.getDoctorDetail != null;
    if (isUpdate) {
      qualificationList = widget.getDoctorDetail!.qualifications;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didUpdateWidget(covariant RProfileQualification oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  saveDetails() async {
    isLoading = true;
    setState(() {});

    Map<String, dynamic> request = {
      "qualifications": jsonEncode(qualificationList),
    };
    editProfileAppStore.addData(request);

    addDoctor(editProfileAppStore.editProfile).then((value) {
      finish(context, true);
      successToast(languageTranslate('lblDoctorAddedSuccessfully'));
      setDynamicStatusBarColor();
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  updateDetails() async {
    isLoading = true;
    setState(() {});

    Map<String, dynamic> request = {
      "qualifications": jsonEncode(qualificationList),
    };
    editProfileAppStore.addData(request);

    updateReceptionistDoctor(editProfileAppStore.editProfile).then((value) {
      finish(context, true);
      setDynamicStatusBarColor();
      successToast(languageTranslate('lblDoctorUpdatedSuccessfully'));
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor(color: appPrimaryColor);
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return Column(
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Container(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Text(languageTranslate('lblAddNewQualification'), style: boldTextStyle(color: primaryColor)).onTap(
                () async {
                  bool? res = await AddQualificationScreen(qualificationList: qualificationList).launch(context);
                  if (res ?? false) {
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          16.height,
          ListView.builder(
            shrinkWrap: true,
            itemCount: qualificationList == null ? 0 : qualificationList!.length,
            itemBuilder: (BuildContext context, int index) {
              Qualification data = qualificationList![index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  color: context.cardColor,
                ),
                padding: EdgeInsets.only(left: 16, top: 10, right: 8, bottom: 16),
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Image.asset("images/icons/graduationCap.png", width: 24, height: 24, color: appSecondaryColor),
                        16.width,
                        Text(data.degree!.toUpperCase().validate(), style: boldTextStyle(size: 16)).expand(),
                        IconButton(
                          onPressed: () {
                            AddQualificationScreen(qualification: data, data: widget.getDoctorDetail, qualificationList: qualificationList).launch(context);
                          },
                          padding: EdgeInsets.zero,
                          icon: Image.asset(
                            "images/icons/edit.png",
                            fit: BoxFit.cover,
                            width: 18,
                            height: 18,
                            color: appStore.isDarkModeOn ? Colors.white : secondaryTxtColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.university.validate().isNotEmpty)
                          Column(
                            children: [
                              16.height,
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    margin: EdgeInsets.only(left: 8),
                                    decoration: boxDecorationWithRoundedCorners(
                                      boxShape: BoxShape.circle,
                                      backgroundColor: secondaryTxtColor,
                                    ),
                                  ),
                                  8.width,
                                  Text(data.university.validate(), style: secondaryTextStyle()),
                                ],
                              ),
                            ],
                          ),
                        if (data.year.toString().validate().isNotEmpty)
                          Column(
                            children: [
                              16.height,
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    margin: EdgeInsets.only(left: 8),
                                    decoration: boxDecorationWithRoundedCorners(
                                      boxShape: BoxShape.circle,
                                      backgroundColor: secondaryTxtColor,
                                    ),
                                  ),
                                  8.width,
                                  Text(data.year.toString().validate(), style: secondaryTextStyle()),
                                ],
                              ),
                            ],
                          )
                      ],
                    ).paddingOnly(left: 42),
                  ],
                ),
              );
            },
          ),
        ],
      ).paddingAll(16);
    }

    return SafeArea(
      child: Scaffold(
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: appSecondaryColor,
          elevation: 0.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text(
            languageTranslate('lblSaveAndContinue'),
            style: boldTextStyle(color: Colors.white),
          ).paddingSymmetric(horizontal: 24),
          onPressed: () async {
            isUpdate ? updateDetails() : saveDetails();
          },
        ),
      ),
    );
  }
}
