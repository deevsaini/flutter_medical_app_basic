import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController oldPassCont = TextEditingController();
  TextEditingController newPassCont = TextEditingController();
  TextEditingController confNewPassCont = TextEditingController();

  FocusNode newPassFocus = FocusNode();
  FocusNode confPassFocus = FocusNode();

  bool oldPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confPasswordVisible = false;

  bool mIsLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
  }

  void submit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      Map req = {
        'old_password': oldPassCont.text.trim(),
        'new_password': newPassCont.text.trim(),
      };

      mIsLoading = true;
      setState(() {});

      await changePassword(req).then((value) async {
        setStringAsync(PASSWORD, newPassCont.text.trim());
        finish(context);
        successToast(value["message"]);
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        mIsLoading = false;
        setState(() {});
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    oldPassCont.dispose();
    newPassCont.dispose();
    confNewPassCont.dispose();

    newPassFocus.dispose();
    confPassFocus.dispose();
    setDynamicStatusBarColor(color: scaffoldBgColor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblChangePassword')),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    AppTextField(
                      controller: oldPassCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: textInputStyle(context: context, label: 'lblOldPassword'),
                      nextFocus: newPassFocus,
                      suffixPasswordVisibleWidget: commonImage(
                        imageUrl: "images/icons/showPassword.png",
                        size: 10,
                      ),
                      suffixPasswordInvisibleWidget: commonImage(
                        imageUrl: "images/icons/hidePassword.png",
                        size: 10,
                      ),
                      textStyle: primaryTextStyle(),
                    ),
                    16.height,
                    AppTextField(
                      controller: newPassCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: textInputStyle(context: context, label: 'lblNewPassword'),
                      focus: newPassFocus,
                      suffixPasswordVisibleWidget: commonImage(
                        imageUrl: "images/icons/showPassword.png",
                        size: 10,
                      ),
                      suffixPasswordInvisibleWidget: commonImage(
                        imageUrl: "images/icons/hidePassword.png",
                        size: 10,
                      ),
                      nextFocus: confPassFocus,
                      textStyle: primaryTextStyle(),
                    ),
                    16.height,
                    AppTextField(
                      controller: confNewPassCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: textInputStyle(context: context, label: 'lblConfirmPassword'),
                      focus: confPassFocus,
                      suffixPasswordVisibleWidget: commonImage(
                        imageUrl: "images/icons/showPassword.png",
                        size: 10,
                      ),
                      suffixPasswordInvisibleWidget: commonImage(
                        imageUrl: "images/icons/hidePassword.png",
                        size: 10,
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) return errorThisFieldRequired;
                        if (value.length < passwordLengthGlobal) return languageTranslate('lblPasswordLengthMessage') + ' $passwordLengthGlobal';
                        if (value.trim() != newPassCont.text.trim()) return languageTranslate('lblBothPasswordMatched');
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (s) {
                        submit();
                      },
                      textStyle: primaryTextStyle(),
                    ),
                    30.height,
                    AppButton(
                      onTap: () {
                        hideKeyboard(context);

                        if (appStore.demoEmails.any((e) => e.toString() == appStore.userEmail)) {
                          toast(languageTranslate('lblDemoUserPasswordNotChanged'));
                        } else {
                          submit();
                        }
                      },
                      text: languageTranslate('lblSave'),
                      textStyle: boldTextStyle(color: textPrimaryWhiteColor),
                      width: context.width(),
                    ),
                  ],
                ),
              ),
            ),
            setLoader().withSize(height: 40, width: 40).center().visible(mIsLoading),
          ],
        ),
      ),
    );
  }
}
