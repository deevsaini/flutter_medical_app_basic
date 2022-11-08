import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GenderModel.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/model/StaticDataModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class EditPatientProfileScreen extends StatefulWidget {
  @override
  _EditPatientProfileScreenState createState() => _EditPatientProfileScreenState();
}

class _EditPatientProfileScreenState extends State<EditPatientProfileScreen> {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer<GetDoctorDetailModel> _memorizer = AsyncMemoizer();

  List<GenderModel> genderList = [];
  List<int> selectedItems = [];

  var picked = DateTime.now();

  int selectedGender = -1;
  final List<DropdownMenuItem> items = [];

  TextEditingController emailCont = TextEditingController();
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController dOBCont = TextEditingController();
  String? genderValue;
  TextEditingController addressCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController stateCont = TextEditingController();
  TextEditingController countryCont = TextEditingController();
  TextEditingController postalCodeCont = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode dOBFocus = FocusNode();
  FocusNode genderFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode postalCodeFocus = FocusNode();

  StaticData? staticData;

  bool isSelected = false;
  bool isLoading = false;
  bool isFirst = true;

  String displayName = "";

  PickedFile? selectedImage;

  @override
  void initState() {
    super.initState();
    init();
  }

  addEditedData() async {
    isLoading = true;
    setState(() {});
    Map<String, dynamic> qualificationRequest = {
      "ID": "${getIntAsync(USER_ID)}",
      "user_email": "${emailCont.text}",
      "first_name": "${firstNameCont.text}",
      "last_name": "${lastNameCont.text}",
      "gender": "$genderValue",
      "dob": "${picked.toString().getFormattedDate(CONVERT_DATE)}",
      "address": "${addressCont.text}",
      "city": "${cityCont.text}",
      "country": "${countryCont.text}",
      "state": "${countryCont.text}",
      "postal_code": "${postalCodeCont.text}",
      "mobile_number": "${contactNumberCont.text}",
      "profile_image": "",
    };

    updatePatientProfile(qualificationRequest, file: selectedImage != null ? File(selectedImage!.path) : null).then((value) {
      finish(context);
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);

    genderList.add(GenderModel(name: languageTranslate('lblMale'), icon: FontAwesomeIcons.male, value: "male"));
    genderList.add(GenderModel(name: languageTranslate('lblFemale'), icon: FontAwesomeIcons.female, value: "female"));
    genderList.add(GenderModel(name: languageTranslate('lblOther'), icon: FontAwesomeIcons.female, value: "other"));
    // getDoctorDetails();
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);

    emailCont.dispose();
    firstNameCont.dispose();
    lastNameCont.dispose();
    contactNumberCont.dispose();
    dOBCont.dispose();
    addressCont.dispose();
    cityCont.dispose();
    stateCont.dispose();
    countryCont.dispose();
    postalCodeCont.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    emailFocus.dispose();
    contactNumberFocus.dispose();
    dOBFocus.dispose();
    genderFocus.dispose();
    addressFocus.dispose();
    cityFocus.dispose();
    stateFocus.dispose();
    countryFocus.dispose();
    postalCodeFocus.dispose();
    super.dispose();
  }

  void getReceiptionistDetails(GetDoctorDetailModel getDoctorDetail) {
    firstNameCont.text = getDoctorDetail.first_name.validate();
    lastNameCont.text = getDoctorDetail.last_name.validate();
    emailCont.text = getDoctorDetail.user_email.validate();
    contactNumberCont.text = getDoctorDetail.mobile_number.validate();
    if (getDoctorDetail.dob.validate().isNotEmpty) {
      dOBCont.text = getDoctorDetail.dob!.getFormattedDate(BIRTH_DATE_FORMAT).validate();
      picked = DateTime.parse(getDoctorDetail.dob!);
    }
    selectedGender = getDoctorDetail.gender == 'male' ? 0 : 1;
    genderValue = getDoctorDetail.gender;
    addressCont.text = getDoctorDetail.address.validate();
    cityCont.text = getDoctorDetail.city.validate();
    stateCont.text = getDoctorDetail.state.validate();
    countryCont.text = getDoctorDetail.country.validate();
    postalCodeCont.text = getDoctorDetail.postal_code.validate();
  }

  saveDetails() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      addEditedData();
    }
  }

  Future<void> dateBottomSheet(context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext e) {
        return Container(
          height: 245,
          color: appStore.isDarkModeOn ? Colors.black : Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(languageTranslate('lblCancel'), style: boldTextStyle()).onTap(() {
                    finish(context);
                    setState(() {});
                  }),
                  Text(languageTranslate('lblDone'), style: boldTextStyle()).onTap(() {
                    if (DateTime.now().year - picked.year < 18) {
                      toast(
                        languageTranslate('lblMinimumAgeRequired') + languageTranslate('lblCurrentAgeIs') + ' ${DateTime.now().year - picked.year}',
                        bgColor: errorBackGroundColor,
                        textColor: errorTextColor,
                      );
                    } else {
                      finish(context);
                      dOBCont.text = picked.getFormattedDate(BIRTH_DATE_FORMAT).toString();
                    }
                  })
                ],
              ).paddingOnly(top: 8, left: 8, right: 8, bottom: 8),
              Container(
                height: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: primaryTextStyle(size: 20))),
                  child: CupertinoDatePicker(
                    minimumDate: DateTime(1900, 1, 1),
                    minuteInterval: 1,
                    initialDateTime: picked,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime dateTime) {
                      picked = dateTime;
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future getImage() async {
    selectedImage = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 100);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    height: 100,
                    width: 100,
                    margin: EdgeInsets.all(12),
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: appStore.isDarkModeOn ? cardDarkColor : profileBgColor, boxShape: BoxShape.circle),
                    child: selectedImage != null
                        ? Image.file(File(selectedImage!.path), height: 90, width: 90, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(180)
                        : appStore.profileImage.validate().isNotEmpty
                            ? cachedImage(appStore.profileImage, height: 90, width: 90, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(180)
                            : Icon(Icons.person_outline_rounded).paddingAll(16),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: appPrimaryColor,
                        boxShape: BoxShape.circle,
                        border: Border.all(color: white, width: 3),
                      ),
                      child: Image.asset("images/icons/camera.png", height: 14, width: 14, color: Colors.white),
                    ).onTap(() {
                      getImage();
                    }),
                  )
                ],
              ).paddingOnly(top: 16, bottom: 16),
              16.height,
              Row(
                children: [
                  AppTextField(
                    controller: firstNameCont,
                    focus: firstNameFocus,
                    nextFocus: lastNameFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: textInputStyle(context: context, label: 'lblFirstName'),
                    scrollPadding: EdgeInsets.all(0),
                  ).expand(),
                  10.width,
                  AppTextField(
                    controller: lastNameCont,
                    focus: lastNameFocus,
                    nextFocus: emailFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: textInputStyle(context: context, label: 'lblLastName'),
                  ).expand(),
                ],
              ),
              16.height,
              (getStringAsync(USER_EMAIL) == receptionistEmail || getStringAsync(USER_EMAIL) == doctorEmail || getStringAsync(USER_EMAIL) == patientEmail)
                  ? AppTextField(
                      controller: emailCont,
                      focus: emailFocus,
                      nextFocus: contactNumberFocus,
                      textFieldType: TextFieldType.EMAIL,
                      readOnly: true,
                      onTap: () {
                        errorToast(languageTranslate('lblDemoEmailCannotBeChanged'));
                      },
                      decoration: textInputStyle(context: context, label: 'lblEmail'),
                    )
                  : AppTextField(
                      controller: emailCont,
                      focus: emailFocus,
                      nextFocus: contactNumberFocus,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: textInputStyle(context: context, label: 'lblEmail'),
                    ),
              16.height,
              AppTextField(
                controller: contactNumberCont,
                focus: contactNumberFocus,
                nextFocus: dOBFocus,
                textFieldType: TextFieldType.PHONE,
                decoration: textInputStyle(context: context, label: 'lblContactNumber'),
              ),
              16.height,
              AppTextField(
                controller: dOBCont,
                focus: dOBFocus,
                nextFocus: addressFocus,
                readOnly: true,
                validator: (s) {
                  if (s!.trim().isEmpty) return languageTranslate('lblContactNumberIsRequired');
                  return null;
                },
                decoration: textInputStyle(context: context, label: 'lblDOB', isMandatory: true),
                onTap: () {
                  dateBottomSheet(context);
                  if (dOBCont.text.isNotEmpty) {
                    FocusScope.of(context).requestFocus(addressFocus);
                  }
                },
                textFieldType: TextFieldType.OTHER,
              ),
              16.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languageTranslate('lblGender1'), style: primaryTextStyle(size: 12, color: secondaryTxtColor)),
                  6.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      genderList.length,
                      (index) {
                        return Container(
                          width: 90,
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: radius(defaultRadius),
                            backgroundColor: context.cardColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: selectedGender == index ? EdgeInsets.all(2) : EdgeInsets.all(1),
                                decoration: boxDecorationWithRoundedCorners(
                                  boxShape: BoxShape.circle,
                                  border: Border.all(color: selectedGender == index ? primaryColor : secondaryTxtColor.withOpacity(0.5)),
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Container(
                                  height: selectedGender == index ? 10 : 10,
                                  width: selectedGender == index ? 10 : 10,
                                  decoration: boxDecorationWithRoundedCorners(
                                    boxShape: BoxShape.circle,
                                    backgroundColor: selectedGender == index ? primaryColor : white,
                                  ),
                                ),
                              ),
                              8.width,
                              Text(genderList[index].name!, style: primaryTextStyle(size: 12, color: secondaryTxtColor)).flexible()
                            ],
                          ).center(),
                        ).onTap(() {
                          if (selectedGender == index) {
                            selectedGender = -1;
                          } else {
                            genderValue = genderList[index].value;
                            selectedGender = index;
                          }
                          setState(() {});
                        }, borderRadius: BorderRadius.circular(defaultRadius)).paddingRight(16);
                      },
                    ),
                  ),
                ],
              ),
              16.height,
              AppTextField(
                controller: addressCont,
                focus: addressFocus,
                nextFocus: cityFocus,
                textFieldType: TextFieldType.ADDRESS,
                decoration: textInputStyle(context: context, label: 'lblAddress').copyWith(alignLabelWithHint: true),
                minLines: 4,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
              ),
              16.height,
              AppTextField(
                controller: cityCont,
                focus: cityFocus,
                nextFocus: stateFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(context: context, label: 'lblCity'),
              ),
              16.height,
              AppTextField(
                controller: stateCont,
                focus: stateFocus,
                nextFocus: countryFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(context: context, label: 'lblState'),
              ),
              16.height,
              AppTextField(
                controller: countryCont,
                focus: countryFocus,
                nextFocus: postalCodeFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(context: context, label: 'lblCountry'),
              ),
              16.height,
              AppTextField(
                controller: postalCodeCont,
                focus: postalCodeFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(context: context, label: 'lblPostalCode'),
              ),
            ],
          ),
        ),
      );
    }

    Widget body1() {
      return FutureBuilder<GetDoctorDetailModel>(
        future: _memorizer.runOnce(() => getUserProfile(getIntAsync(USER_ID))),
        builder: (_, snap) {
          if (snap.hasData) {
            if (isFirst) {
              getReceiptionistDetails(snap.data!);
              isFirst = false;
            }
            return body();
          }
          return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblEditProfile')),
        body: body1().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.done, color: textPrimaryWhiteColor),
          onPressed: () {
            saveDetails();
          },
        ),
      ),
    );
  }
}
