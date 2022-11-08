import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/doctor/screens/DoctorDashboardScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DemoLoginModel.dart';
import 'package:kivicare_flutter/main/screens/SignUpScreen.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/main/utils/DataGeneretor.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/screens/PatientDashBoardScreen.dart';
import 'package:kivicare_flutter/receiptionist/screens/RDashBoardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/ForgotPasswordDailogComponent.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var formKey = GlobalKey<FormState>();
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  bool isRemember = false;

  var emailFocus = FocusNode();
  var passwordFocus = FocusNode();

  List<DemoLoginModel> demoLoginData = demoLoginList();

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);
    selectedIndex = 0;
    emailCont.text = "";
    passwordCont.text = "";

    if (getBoolAsync(IS_REMEMBER_ME)) {
      isRemember = true;
      emailCont.text = getStringAsync(USER_NAME);
      passwordCont.text = getStringAsync(USER_PASSWORD);
    }
  }

  saveForm() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      hideKeyboard(context);
      appStore.setLoading(true);
      setState(() {});

      Map req = {
        'username': emailCont.text,
        'password': passwordCont.text,
      };

      await login(req).then((value) {
        if (isRemember) {
          setValue(USER_NAME, emailCont.text);
          setValue(USER_PASSWORD, passwordCont.text);
          setValue(IS_REMEMBER_ME, true);
        }

        // toast(value.role.validate());
        appStore.setLoading(false);
        if (appStore.userRole!.toLowerCase() == UserRoleDoctor) {
          toast(languageTranslate('lblLoginSuccessfully'));

          DoctorDashboardScreen().launch(context, isNewTask: true);
        } else if (appStore.userRole!.toLowerCase() == UserRolePatient) {
          toast(languageTranslate('lblLoginSuccessfully'));

          PatientDashBoardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        } else if (appStore.userRole!.toLowerCase() == UserRoleReceptionist) {
          toast(languageTranslate('lblLoginSuccessfully'));

          RDashBoardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        } else {
          errorToast(languageTranslate('lblWrongUser'));
        }
      }).catchError((e) {
        appStore.setLoading(false);
        setState(() {});
        log(e.toString());
      });
      setState(() {});
    }
  }

  void forgotPasswordDialog() {
    showInDialog(context, title: Text(languageTranslate("lblForgotPassword"), style: boldTextStyle(), textAlign: TextAlign.justify), barrierColor: Colors.black45, backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
        builder: (context) {
      return ForgotPasswordDailogComponent();
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    32.height,
                    Image.asset('images/appIcon.png', height: 100, width: 100).center(),
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
                    Text(
                      languageTranslate('lblSignInToContinue'),
                      style: secondaryTextStyle(size: 14, color: !appStore.isDarkModeOn ? textPrimaryBlackColor : textPrimaryWhiteColor),
                    ).center(),
                    32.height,
                    AppTextField(
                      controller: emailCont,
                      focus: emailFocus,
                      nextFocus: passwordFocus,
                      textStyle: primaryTextStyle(),
                      textFieldType: TextFieldType.EMAIL,
                      decoration: textInputStyle(
                        context: context,
                        label: 'lblEmail',
                        suffixIcon: commonImage(imageUrl: "images/icons/user.png", size: 18),
                      ),
                    ),
                    24.height,
                    AppTextField(
                      controller: passwordCont,
                      focus: passwordFocus,
                      textStyle: primaryTextStyle(),
                      textFieldType: TextFieldType.PASSWORD,
                      suffixPasswordVisibleWidget: commonImage(imageUrl: "images/icons/showPassword.png", size: 18),
                      suffixPasswordInvisibleWidget: commonImage(imageUrl: "images/icons/hidePassword.png", size: 18),
                      decoration: textInputStyle(context: context, label: 'lblPassword'),
                    ),
                    4.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            4.width,
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: Theme(
                                data: ThemeData(unselectedWidgetColor: context.iconColor),
                                child: Checkbox(
                                  activeColor: appSecondaryColor,
                                  value: isRemember,
                                  onChanged: (value) async {
                                    isRemember = value.validate();
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                            8.width,
                            TextButton(
                              onPressed: () {
                                isRemember = !isRemember;
                                setState(() {});
                              },
                              child: Text(languageTranslate("lblRememberMe"), style: secondaryTextStyle()),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            return forgotPasswordDialog();
                          },
                          child: Text(
                            languageTranslate("lblForgotPassword"),
                            style: secondaryTextStyle(color: appSecondaryColor, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    24.height,
                    AppButton(
                      width: context.width(),
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
                      onTap: () {
                        saveForm();
                      },
                      color: primaryColor,
                      padding: EdgeInsets.all(16),
                      child: Text(languageTranslate('lblSignIn'), style: boldTextStyle(color: textPrimaryWhiteColor)),
                    ),
                    60.height,
                    HorizontalList(
                      itemCount: demoLoginData.length,
                      spacing: 16,
                      itemBuilder: (context, index) {
                        DemoLoginModel data = demoLoginData[index];
                        bool isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            selectedIndex = index;
                            setState(() {});

                            if (index == 0) {
                              emailCont.text = patientEmail;
                              passwordCont.text = loginPassword;
                            } else if (index == 1) {
                              emailCont.text = receptionistEmail;
                              passwordCont.text = loginPassword;
                            } else if (index == 2) {
                              emailCont.text = doctorEmail;
                              passwordCont.text = loginPassword;
                            }
                          },
                          child: Container(
                            child: Image.asset(
                              data.loginTypeImage.validate(),
                              height: 22,
                              width: 22,
                              fit: BoxFit.cover,
                              color: isSelected ? white : appSecondaryColor,
                            ),
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              backgroundColor: isSelected
                                  ? appSecondaryColor
                                  : appStore.isDarkModeOn
                                      ? cardDarkColor
                                      : white,
                            ),
                            padding: EdgeInsets.all(12),
                          ),
                        );
                      },
                    ),
                    16.height,
                    loginRegisterWidget(
                      context,
                      title: languageTranslate('lblNewMember'),
                      subTitle: languageTranslate('lblSignUp'),
                      onTap: () {
                        SignUpScreen().launch(context);
                      },
                    ),
                    /* UserDemoModeScreen(
                      onChanged: (String email, String password) {
                        emailCont.text = email;
                        passwordCont.text = password;
                        setState(() {});
                      },
                    ),*/
                  ],
                ),
              ),
              Observer(
                builder: (context) => setLoader().withSize(width: 40, height: 40).visible(appStore.isLoading).center(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
