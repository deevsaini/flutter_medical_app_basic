import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GenderModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> bloodGroupList = ['A+', 'B+', 'AB+', 'O+', 'A-', 'B-', 'AB-', 'O-'];
  List<GenderModel> genderList = [];

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController dOBCont = TextEditingController();
  String? genderValue;
  String? bloodGroup;
  TextEditingController bloodGroupCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode dOBFocus = FocusNode();
  FocusNode genderFocus = FocusNode();
  FocusNode bloodGroupFocus = FocusNode();

  late DateTime birthDate;

  bool isLoading = false;

  int selectedGender = -1;

  signUp() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);
      setState(() {});

      Map request = {
        "first_name": firstNameCont.text.validate(),
        "last_name": lastNameCont.text.validate(),
        "user_email": emailCont.text.validate(),
        "mobile_number": contactNumberCont.text.validate(),
        "gender": genderValue.validate().toLowerCase(),
        "dob": birthDate.getFormattedDate(CONVERT_DATE).validate(),
        "blood_group": bloodGroup.validate(),
      };
      addNewPatientData(request).then((value) {
        finish(context, true);
        successToast(languageTranslate('lblRegisteredSuccessfully'));
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        appStore.setLoading(false);
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    genderList.add(GenderModel(name: languageTranslate("lblMale"), value: "Male"));
    genderList.add(GenderModel(name: languageTranslate("lblFemale"), value: "Female"));
    genderList.add(GenderModel(name: languageTranslate("lblOther"), value: "Other"));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> dateBottomSheet(context, {DateTime? bDate}) async {
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
                      if (DateTime.now().year - birthDate.year < 18) {
                        toast(
                          languageTranslate('lblMinimumAgeRequired') + languageTranslate('lblCurrentAgeIs') + ' ${DateTime.now().year - birthDate.year}',
                          bgColor: errorBackGroundColor,
                          textColor: errorTextColor,
                        );
                      } else {
                        finish(context);
                        dOBCont.text = birthDate.getFormattedDate(BIRTH_DATE_FORMAT).toString();
                      }
                    })
                  ],
                ).paddingOnly(top: 8, left: 8, right: 8, bottom: 8),
              ),
              Container(
                height: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: primaryTextStyle(size: 20)),
                  ),
                  child: CupertinoDatePicker(
                    minimumDate: DateTime(1900, 1, 1),
                    minuteInterval: 1,
                    initialDateTime: bDate == null ? DateTime.now() : bDate,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime dateTime) {
                      birthDate = dateTime;
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
  void dispose() {
    emailCont.dispose();
    passwordCont.dispose();
    firstNameCont.dispose();
    lastNameCont.dispose();
    contactNumberCont.dispose();
    dOBCont.dispose();
    bloodGroupCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
        body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('images/appIcon.png', height: 100, width: 100),
                    16.height,
                    RichTextWidget(
                      list: [
                        TextSpan(
                          text: appFirstName,
                          style: boldTextStyle(
                            size: 32,
                            letterSpacing: 1,
                            color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor,
                          ),
                        ),
                        TextSpan(
                          text: appSecondName,
                          style: primaryTextStyle(
                            size: 32,
                            letterSpacing: 1,
                            color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor,
                          ),
                        ),
                      ],
                    ).center(),
                    32.height,
                    Text(languageTranslate('lblSignUpAsPatient'), style: secondaryTextStyle(size: 14, color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor)).center(),
                    24.height,
                    AppTextField(
                      textStyle: primaryTextStyle(color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor),
                      controller: firstNameCont,
                      textFieldType: TextFieldType.NAME,
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblFirstName',
                        isMandatory: true,
                        suffixIcon: commonImage(
                          imageUrl: "images/icons/user.png",
                          size: 10,
                        ),
                      ),
                      focus: firstNameFocus,
                      errorThisFieldRequired: languageTranslate('lblFirstNameIsRequired'),
                      nextFocus: lastNameFocus,
                    ),
                    16.height,
                    AppTextField(
                      textStyle: primaryTextStyle(color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor),
                      controller: lastNameCont,
                      textFieldType: TextFieldType.NAME,
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblLastName',
                        isMandatory: true,
                        suffixIcon: commonImage(
                          imageUrl: "images/icons/user.png",
                          size: 10,
                        ),
                      ),
                      focus: lastNameFocus,
                      nextFocus: emailFocus,
                      errorThisFieldRequired: languageTranslate('lblLastNameIsRequired'),
                    ),
                    16.height,
                    AppTextField(
                      textStyle: primaryTextStyle(color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor),
                      controller: emailCont,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblEmail',
                        isMandatory: true,
                        suffixIcon: commonImage(
                          imageUrl: "images/icons/message.png",
                          size: 10,
                        ),
                      ),
                      focus: emailFocus,
                      nextFocus: passwordFocus,
                    ),
                    16.height,
                    AppTextField(
                      textStyle: primaryTextStyle(color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor),
                      controller: contactNumberCont,
                      focus: contactNumberFocus,
                      nextFocus: dOBFocus,
                      textFieldType: TextFieldType.PHONE,
                      validator: (s) {
                        if (s!.trim().isEmpty) return languageTranslate('lblContactNumberIsRequired');
                        return null;
                      },
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblContactNumber',
                        isMandatory: true,
                        suffixIcon: commonImage(
                          imageUrl: "images/icons/phone.png",
                          size: 10,
                        ),
                      ),
                    ),
                    16.height,
                    AppTextField(
                      textStyle: primaryTextStyle(color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor),
                      controller: dOBCont,
                      nextFocus: bloodGroupFocus,
                      focus: dOBFocus,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: languageTranslate('lblBirthDateIsRequired'),
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblDOB',
                        isMandatory: true,
                        suffixIcon: commonImage(
                          imageUrl: "images/icons/calendar.png",
                          size: 10,
                        ),
                      ),
                      readOnly: true,
                      onTap: () {
                        dateBottomSheet(context);
                      },
                    ),
                    16.height,
                    DropdownButtonFormField(
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblBloodGroup',
                        isMandatory: true,
                        suffixIcon: commonImage(
                          imageUrl: "images/icons/arrowDown.png",
                          size: 10,
                        ),
                      ),
                      icon: SizedBox.shrink(),
                      isExpanded: true,
                      focusColor: primaryColor,
                      dropdownColor: Theme.of(context).cardColor,
                      focusNode: bloodGroupFocus,
                      validator: (dynamic s) {
                        if (s == null) return languageTranslate('lblBloodGroupIsRequired');
                        return null;
                      },
                      onChanged: (dynamic value) {
                        bloodGroup = value;
                      },
                      items: bloodGroupList
                          .map(
                            (bloodGroup) => DropdownMenuItem(
                              value: bloodGroup,
                              child: Text("$bloodGroup", style: primaryTextStyle()),
                            ),
                          )
                          .toList(),
                    ),
                    16.height,
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text("${languageTranslate('lblGender1')} ${"*"}", style: primaryTextStyle(size: 12)),
                    ),
                    8.height,
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                            genderValue = genderList[index].value;
                            selectedGender = index;

                            setState(() {});
                          }, borderRadius: BorderRadius.circular(defaultRadius)).paddingRight(16);
                        },
                      ),
                    ),
                    60.height,
                    AppButton(
                      width: context.width(),
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
                      onTap: () {
                        signUp();
                      },
                      color: primaryColor,
                      padding: EdgeInsets.all(16),
                      child: Text(languageTranslate('lblSubmit'), style: boldTextStyle(color: textPrimaryWhiteColor)),
                    ),
                    24.height,
                    loginRegisterWidget(context, title: languageTranslate('lblAlreadyAMember'), subTitle: languageTranslate('lblLogin'), onTap: () {
                      finish(context);
                    }),
                    24.height,
                  ],
                ),
              ).center(),
              Observer(
                builder: (context) => setLoader().withSize(width: 40, height: 40).visible(appStore.isLoading).center(),
              ),
              Positioned(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () {
                    finish(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
