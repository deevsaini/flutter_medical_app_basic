import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
import 'package:kivicare_flutter/receiptionist/components/MultiSelectSpecialization.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ProfileBasicInformation extends StatefulWidget {
  final GetDoctorDetailModel? getDoctorDetail;
  void Function(bool isChanged)? onSave;

  ProfileBasicInformation({this.getDoctorDetail, this.onSave});

  @override
  _ProfileBasicInformationState createState() => _ProfileBasicInformationState();
}

class _ProfileBasicInformationState extends State<ProfileBasicInformation> {
  var formKey = GlobalKey<FormState>();

  GetDoctorDetailModel? getDoctorDetail;
  StaticData? staticData;
  GetDoctorDetailModel? data;

  List<GenderModel> genderList = [];
  List<int> selectedItems = [];
  final List<DropdownMenuItem> items = [];
  List<Specialty> temp = [];

  bool isSelected = false;
  bool isLoading = false;

  var picked = DateTime.now();

  int selectedGender = -1;

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
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
  TextEditingController experienceCont = TextEditingController();

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
  FocusNode experienceCodeFocus = FocusNode();

  //Add New Second teb

  TextEditingController fixedPriceCont = TextEditingController();
  TextEditingController toPriceCont = TextEditingController();
  TextEditingController fromPriceCont = TextEditingController();
  TextEditingController videoPriceCont = TextEditingController();
  TextEditingController mAPIKeyCont = TextEditingController();
  TextEditingController mAPISecretCont = TextEditingController();

  FocusNode fixedPriceFocus = FocusNode();
  FocusNode toPriceFocus = FocusNode();
  FocusNode fromPriceFocus = FocusNode();
  FocusNode mAPIKeyFocus = FocusNode();
  FocusNode mAPISecretFocus = FocusNode();

  int? result = 0;
  String resultName = "range";

  bool mIsTelemedOn = false;

  @override
  void initState() {
    super.initState();
    init();
    data = widget.getDoctorDetail;
  }

  init() async {
    multiSelectStore.clearStaticList();
    genderList.add(GenderModel(name: languageTranslate('lblMale'), icon: FontAwesomeIcons.male, value: "male"));
    genderList.add(GenderModel(name: languageTranslate('lblFemale'), icon: FontAwesomeIcons.female, value: "female"));
    genderList.add(GenderModel(name: languageTranslate('lblOther'), icon: FontAwesomeIcons.female, value: "other"));
    getDoctorDetail = widget.getDoctorDetail;
    getDoctorDetails();

    // Add New Code
    getDoctorDetail = widget.getDoctorDetail;
    if (getDoctorDetail!.price_type.validate() == "range") {
      toPriceCont.text = getDoctorDetail!.price.validate().split('-')[0];
      fromPriceCont.text = getDoctorDetail!.price.validate().split('-')[1];
      result = 0;
      setState(() {});
    } else {
      resultName = 'fixed';
      fixedPriceCont.text = getDoctorDetail!.price.validate();
      result = 1;
      setState(() {});
    }
  }

  // Add New Code

  saveBasicSettingData() async {
    Map<String, dynamic> request = {
      "price_type": "$resultName",
    };

    if (resultName == 'range') {
      fixedPriceCont.clear();
      request.putIfAbsent('minPrice', () => fromPriceCont.text);
      request.putIfAbsent('maxPrice', () => toPriceCont.text);
    } else {
      fromPriceCont.clear();
      toPriceCont.clear();
      request.putIfAbsent('price', () => fixedPriceCont.text);
    }
    editProfileAppStore.addData(request);
    toast(languageTranslate('lblInformationSaved'));
    widget.onSave!.call(true);
  }

  Widget telemed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageTranslate('lblZoomConfiguration'), style: boldTextStyle(size: 18, color: primaryColor)),
        16.height,
        SwitchListTile(
          title: Text(
            languageTranslate('lblTelemed') + ' ${mIsTelemedOn ? 'On' : 'Off'}',
            style: primaryTextStyle(color: mIsTelemedOn ? successTextColor : textPrimaryBlackColor),
          ),
          value: mIsTelemedOn,
          selected: mIsTelemedOn,
          secondary: FaIcon(FontAwesomeIcons.video, size: 20),
          activeColor: successTextColor,
          onChanged: (v) {
            mIsTelemedOn = v;
            setState(() {});
          },
        ),
        Column(
          children: [
            16.height,
            AppTextField(
              controller: videoPriceCont,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(context: context, text: languageTranslate('lblVideoPrice')),
              validator: (v) {
                if (v!.trim().isEmpty) return languageTranslate('lblAPIKeyCannotBeEmpty');
                return null;
              },
            ),
            16.height,
            AppTextField(
              controller: mAPIKeyCont,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(context: context, text: languageTranslate('lblAPIKey')),
              validator: (v) {
                if (v!.trim().isEmpty) return languageTranslate('lblAPIKeyCannotBeEmpty');
                return null;
              },
            ),
            16.height,
            AppTextField(
              controller: mAPISecretCont,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(context: context, text: languageTranslate('lblAPISecret')),
              validator: (v) {
                if (v!.trim().isEmpty) return languageTranslate('lblAPISecretCannotBeEmpty');
                return null;
              },
            ),
            16.height,
            zoomConfigurationGuide(),
          ],
        ).visible(mIsTelemedOn),
      ],
    );
  }

  Widget zoomConfigurationGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageTranslate('lblZoomConfigurationGuide'), style: boldTextStyle(color: primaryColor, size: 18)),
        16.height,
        Container(
          decoration: BoxDecoration(border: Border.all(color: viewLineColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languageTranslate('lbl1'), style: boldTextStyle()),
                  6.width,
                  createRichText(
                    list: [
                      TextSpan(text: languageTranslate('lblSignUpOrSignIn'), style: primaryTextStyle()),
                      TextSpan(
                        text: languageTranslate('lblZoomMarketPlacePortal'),
                        style: boldTextStyle(color: primaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch("https://marketplace.zoom.us/");
                          },
                      ),
                    ],
                  ),
                ],
              ).paddingAll(8),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languageTranslate('lbl2'), style: boldTextStyle()),
                  6.width,
                  createRichText(list: [
                    TextSpan(text: languageTranslate('lblClickOnDevelopButton'), style: primaryTextStyle()),
                    TextSpan(
                      text: languageTranslate('lblCreateApp'),
                      style: boldTextStyle(color: primaryColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch("https://marketplace.zoom.us/develop/create");
                        },
                    ),
                  ], maxLines: 5)
                      .expand(),
                ],
              ).paddingAll(8),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languageTranslate('lb13'), style: boldTextStyle()),
                  6.width,
                  Text(languageTranslate('lblChooseAppTypeToJWT'), style: primaryTextStyle()).expand(),
                ],
              ).paddingAll(8),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languageTranslate('lbl4'), style: boldTextStyle()),
                  6.width,
                  Text(languageTranslate('lblMandatoryMessage'), style: primaryTextStyle()).expand(),
                ],
              ).paddingAll(8),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languageTranslate('lbl5'), style: boldTextStyle()),
                  6.width,
                  Text(languageTranslate('lblCopyAndPasteAPIKey'), style: primaryTextStyle()).expand(),
                ],
              ).paddingAll(8),
            ],
          ),
        ),
      ],
    );
  }

  void getDoctorDetails() {
    firstNameCont.text = getDoctorDetail!.first_name.validate();
    lastNameCont.text = getDoctorDetail!.last_name.validate();
    emailCont.text = getDoctorDetail!.user_email.validate();
    contactNumberCont.text = getDoctorDetail!.mobile_number.validate();
    dOBCont.text = getDoctorDetail!.dob.validate().getFormattedDate(BIRTH_DATE_FORMAT);
    picked = DateTime.parse(getDoctorDetail!.dob!);
    selectedGender = getDoctorDetail!.gender == 'male' ? 0 : 1;
    genderValue = getDoctorDetail!.gender;
    addressCont.text = getDoctorDetail!.address.validate();
    cityCont.text = getDoctorDetail!.city.validate();
    stateCont.text = getDoctorDetail!.state.validate();
    countryCont.text = getDoctorDetail!.country.validate();
    postalCodeCont.text = getDoctorDetail!.postal_code.validate();
    experienceCont.text = getDoctorDetail!.no_of_experience.validate();
    getDoctorDetail!.specialties!.forEach((element) {
      multiSelectStore.selectedStaticData.add(StaticData(id: element.id, label: element.label));
      temp.add(Specialty(id: element.id, label: element.label));
    });
  }

  saveDetails() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      saveBasicInformationData();
    }
  }

  saveBasicInformationData() async {
    hideKeyboard(context);
    Map<String, dynamic> request = {
      "ID": "${getIntAsync(USER_ID)}",
      "user_email": "${emailCont.text}",
      "user_login": "${data!.user_login}",
      "first_name": "${firstNameCont.text}",
      "last_name": "${lastNameCont.text}",
      "gender": "$genderValue",
      "dob": "${picked.toString().getFormattedDate(CONVERT_DATE)}",
      "address": "${addressCont.text}",
      "city": "${cityCont.text}",
      "country": "${countryCont.text}",
      "postal_code": "${postalCodeCont.text}",
      "mobile_number": "${contactNumberCont.text}",
      "state": "${stateCont.text}",
      "no_of_experience": "${experienceCont.text}",
      "profile_image": image != null ? File(image!.path) : null,
      "specialties": jsonEncode(getDoctorDetail!.specialties),
      "price_type": "$resultName",
    };

    if (resultName == 'range') {
      fixedPriceCont.clear();
      request.putIfAbsent('minPrice', () => fromPriceCont.text);
      request.putIfAbsent('maxPrice', () => toPriceCont.text);
    } else {
      fromPriceCont.clear();
      toPriceCont.clear();
      request.putIfAbsent('price', () => fixedPriceCont.text);
    }

    editProfileAppStore.addData(request);
    toast(languageTranslate('lblInformationSaved'));
    widget.onSave!.call(true);
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
              Container(
                child: Row(
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
              ),
              Container(
                height: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: primaryTextStyle(size: 20),
                    ),
                  ),
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

  Future getImage() async {
    image = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    emailCont.dispose();
    passwordCont.dispose();
    firstNameCont.dispose();
    lastNameCont.dispose();
    contactNumberCont.dispose();
    dOBCont.dispose();
    addressCont.dispose();
    cityCont.dispose();
    stateCont.dispose();
    countryCont.dispose();
    postalCodeCont.dispose();
    experienceCont.dispose();

    //Add New Code
    fixedPriceCont.dispose();
    toPriceCont.dispose();
    fromPriceCont.dispose();
    videoPriceCont.dispose();
    mAPIKeyCont.dispose();
    mAPISecretCont.dispose();

    fixedPriceFocus.dispose();
    toPriceFocus.dispose();
    fromPriceFocus.dispose();
    mAPIKeyFocus.dispose();
    mAPISecretFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    height: 100,
                    width: 100,
                    margin: EdgeInsets.all(12),
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: profileBgColor, boxShape: BoxShape.circle),
                    //  decoration: boxDecorationWithShadow(backgroundColor: context.cardColor,borderRadius: radius(defaultRadius), boxShape: BoxShape.rectangle),
                    child: image != null
                        ? Image.file(File(image!.path), height: 90, width: 90, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(180)
                        : appStore.profileImage.validate().isNotEmpty
                            ? cachedImage(appStore.profileImage, height: 90, width: 90, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(180)
                            : Icon(Icons.person_outline_rounded).paddingAll(16),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 6,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: appPrimaryColor,
                        boxShape: BoxShape.circle,
                        border: Border.all(color: white, width: 3),
                      ),
                      child: Image.asset("images/icons/camera.png", height: 20, width: 20, color: Colors.white),
                    ).onTap(() {
                      getImage();
                    }),
                  ),
                ],
              ),
              16.height,
              Row(
                children: [
                  AppTextField(
                    controller: firstNameCont,
                    focus: firstNameFocus,
                    nextFocus: lastNameFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: textInputStyle(
                      context: context,
                      label: 'lblFirstName',
                      suffixIcon: commonImage(
                        imageUrl: "images/icons/user.png",
                        size: 10,
                      ),
                    ),
                    scrollPadding: EdgeInsets.all(0),
                  ).expand(),
                  10.width,
                  AppTextField(
                    controller: lastNameCont,
                    focus: lastNameFocus,
                    nextFocus: emailFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: textInputStyle(
                      context: context,
                      label: 'lblLastName',
                      suffixIcon: commonImage(
                        imageUrl: "images/icons/user.png",
                        size: 10,
                      ),
                    ),
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
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblEmail',
                        suffixIcon: commonImage(imageUrl: "images/icons/message.png", size: 10),
                      ),
                    )
                  : AppTextField(
                      controller: emailCont,
                      focus: emailFocus,
                      nextFocus: contactNumberFocus,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblEmail',
                        suffixIcon: commonImage(imageUrl: "images/icons/message.png", size: 10),
                      ),
                    ),
              16.height,
              AppTextField(
                controller: contactNumberCont,
                focus: contactNumberFocus,
                nextFocus: dOBFocus,
                textFieldType: TextFieldType.PHONE,
                decoration: textInputStyle(
                  context: context,
                  label: 'lblContactNumber',
                  suffixIcon: commonImage(imageUrl: "images/icons/phone.png", size: 10),
                ),
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
                decoration: textInputStyle(
                  context: context,
                  label: 'lblDOB',
                  isMandatory: true,
                  suffixIcon: commonImage(imageUrl: "images/icons/calendar.png", size: 10),
                ),
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
                  Text(languageTranslate('lblGender1'), style: primaryTextStyle(size: 12)),
                  6.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      genderList.length,
                      (index) {
                        return Container(
                          width: 90,
                          padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: radius(defaultRadius),
                            backgroundColor: context.cardColor,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: selectedGender == index ? EdgeInsets.all(2) : EdgeInsets.all(1),
                                decoration: boxDecorationWithRoundedCorners(
                                  boxShape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedGender == index ? primaryColor : secondaryTxtColor.withOpacity(0.5),
                                  ),
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
              Container(
                padding: EdgeInsets.fromLTRB(8, 8, 16, 8),
                width: context.width(),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: viewLineColor,
                    ),
                    borderRadius: BorderRadius.circular(defaultRadius)),
                child: Observer(
                  builder: (_) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languageTranslate('lblSpecialization'), style: primaryTextStyle(size: 12)),
                        16.height,
                        Wrap(
                          spacing: 8,
                          children: List.generate(
                            multiSelectStore.selectedStaticData.length,
                            (index) {
                              StaticData data = multiSelectStore.selectedStaticData[index]!;
                              return Chip(
                                label: Text('${data.label}', style: primaryTextStyle()),
                                backgroundColor: Theme.of(context).cardColor,
                                deleteIcon: Icon(Icons.clear),
                                deleteIconColor: Colors.red,
                                onDeleted: () {
                                  multiSelectStore.removeStaticItem(data);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  side: BorderSide(
                                    color: viewLineColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ).onTap(
                () async {
                  List<String?> ids = [];
                  if (multiSelectStore.selectedStaticData.validate().isNotEmpty) {
                    multiSelectStore.selectedStaticData.forEach((element) {
                      ids.add(element!.id);
                    });
                  }

                  bool? res = await MultiSelectSpecialization(selectedServicesId: ids).launch(context);
                  if (res ?? false) {
                    multiSelectStore.selectedStaticData.forEach((element) {
                      temp.add(Specialty(id: element!.id, label: element.label));
                    });
                    setState(() {});
                  }
                },
              ),
              16.height,
              AppTextField(
                controller: addressCont,
                focus: addressFocus,
                nextFocus: cityFocus,
                textFieldType: TextFieldType.ADDRESS,
                decoration: textInputStyle(context: context, label: 'lblAddress').copyWith(
                  alignLabelWithHint: true,
                  suffixIcon: commonImage(imageUrl: "images/icons/location.png", size: 10),
                ),
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
                decoration: textInputStyle(
                  context: context,
                  label: 'lblCity',
                  suffixIcon: commonImage(imageUrl: "images/icons/location.png", size: 10),
                ),
              ),
              16.height,
              AppTextField(
                controller: stateCont,
                focus: stateFocus,
                nextFocus: countryFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(
                  context: context,
                  label: 'lblState',
                  suffixIcon: commonImage(imageUrl: "images/icons/location.png", size: 10),
                ),
              ),
              16.height,
              AppTextField(
                controller: countryCont,
                focus: countryFocus,
                nextFocus: postalCodeFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(
                  context: context,
                  label: 'lblCountry',
                  suffixIcon: commonImage(imageUrl: "images/icons/location.png", size: 10),
                ),
              ),
              16.height,
              AppTextField(
                controller: postalCodeCont,
                focus: postalCodeFocus,
                textFieldType: TextFieldType.OTHER,
                decoration: textInputStyle(
                  context: context,
                  label: 'lblPostalCode',
                  suffixIcon: commonImage(imageUrl: "images/icons/location.png", size: 10),
                ),
              ),
              16.height,
              AppTextField(
                controller: experienceCont,
                focus: experienceCodeFocus,
                textFieldType: TextFieldType.OTHER,
                keyboardType: TextInputType.number,
                decoration: textInputStyle(
                  context: context,
                  label: 'lblExperience',
                  suffixIcon: commonImage(imageUrl: "images/icons/experience.png", size: 10),
                ),
              ),

              //Add New Code
              16.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  8.height,
                  Text("Price Range*", style: primaryTextStyle(size: 12)),
                  16.height,
                  Row(
                    children: [
                      Container(
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(unselectedWidgetColor: secondaryTxtColor.withOpacity(0.5)),
                          child: Radio(
                            value: 0,
                            activeColor: primaryColor,
                            groupValue: result,
                            onChanged: (dynamic value) {
                              result = value;
                              resultName = "range";
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 16, bottom: 16, right: 16),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                        ),
                        child: Text(languageTranslate('lblRange'), style: secondaryTextStyle(color: secondaryTxtColor)),
                      ),
                      16.width,
                      Container(
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(unselectedWidgetColor: secondaryTxtColor.withOpacity(0.5)),
                          child: Radio(
                            value: 1,
                            activeColor: primaryColor,
                            groupValue: result,
                            onChanged: (dynamic value) {
                              result = value;

                              resultName = "fixed";
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 16, bottom: 16, right: 16),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: context.cardColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                        ),
                        child: Text(languageTranslate('lblFixed'), style: secondaryTextStyle(color: secondaryTxtColor)),
                      ),
                    ],
                  ),
                  20.height,
                  Row(
                    children: [
                      Container(
                        child: AppTextField(
                          controller: toPriceCont,
                          focus: toPriceFocus,
                          textFieldType: TextFieldType.NAME,
                          keyboardType: TextInputType.number,
                          decoration: textInputStyle(
                            context: context,
                            label: 'lblToPrice',
                            suffixIcon: commonImage(imageUrl: "images/icons/dollarIcon.png", size: 10),
                          ),
                        ).expand(),
                      ),
                      20.width,
                      Container(
                        child: AppTextField(
                          controller: fromPriceCont,
                          focus: fromPriceFocus,
                          textFieldType: TextFieldType.NAME,
                          keyboardType: TextInputType.number,
                          decoration: textInputStyle(
                            context: context,
                            label: 'lblFromPrice',
                            suffixIcon: commonImage(imageUrl: "images/icons/dollarIcon.png", size: 10),
                          ),
                        ).expand(),
                      ),
                    ],
                  ).visible(result == 0),
                  Container(
                    child: AppTextField(
                      controller: fixedPriceCont,
                      focus: fixedPriceFocus,
                      textFieldType: TextFieldType.NAME,
                      keyboardType: TextInputType.number,
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblFixedPrice',
                        suffixIcon: commonImage(imageUrl: "images/icons/dollarIcon.png", size: 10),
                      ),
                    ),
                  ).visible(result == 1),
                  16.height,
                ],
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            saveDetails();
          },
          elevation: 0.0,
          child: Icon(Icons.arrow_forward, color: textPrimaryWhiteColor),
          backgroundColor: appSecondaryColor,
        ),
        body: body(),
      ),
    );
  }
}
