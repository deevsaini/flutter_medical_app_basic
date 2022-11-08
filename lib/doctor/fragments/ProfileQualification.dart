import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/fragments/AddQualificationScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class ProfileQualification extends StatefulWidget {
  final GetDoctorDetailModel? getDoctorDetail;

  ProfileQualification({this.getDoctorDetail});

  @override
  _ProfileQualificationState createState() => _ProfileQualificationState();
}

class _ProfileQualificationState extends State<ProfileQualification> {
  GetDoctorDetailModel? getDoctorDetail;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    getDoctorDetail = widget.getDoctorDetail;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didUpdateWidget(covariant ProfileQualification oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  saveDetails() async {
    Map<String, dynamic> request = {
      "qualifications": jsonEncode(getDoctorDetail!.qualifications),
    };
    editProfileAppStore.addData(request);
    toast(languageTranslate('lblDataSaved'));
    await Future.delayed(Duration(milliseconds: 500));
    isLoading = true;
    setState(() {});
    await updateProfile(editProfileAppStore.editProfile, file: image != null ? File(image!.path) : null).then((value) {
      finish(context);
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
    setDynamicStatusBarColor();
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: TextButton(
              onPressed: () async {
                bool? res = await AddQualificationScreen(
                  data: getDoctorDetail,
                  qualificationList: getDoctorDetail!.qualifications == null ? getDoctorDetail!.qualifications = [] : getDoctorDetail!.qualifications,
                ).launch(context);
                if (res ?? false) {
                  setState(() {});
                }
              },
              child: Text(languageTranslate('lblAddNewQualification'), style: boldTextStyle(color: primaryColor, size: 16)),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 70),
            itemCount: (getDoctorDetail!.qualifications == null || getDoctorDetail!.qualifications!.isEmpty) ? 0 : getDoctorDetail!.qualifications!.length,
            itemBuilder: (BuildContext context, int index) {
              Qualification data = getDoctorDetail!.qualifications![index];
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
                            AddQualificationScreen(qualification: data, data: getDoctorDetail, qualificationList: getDoctorDetail!.qualifications).launch(context);
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
                              4.height,
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
      ).paddingAll(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
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
            saveDetails();
          },
        ),
      ),
    );
  }
}
