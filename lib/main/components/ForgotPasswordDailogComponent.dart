import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class ForgotPasswordDailogComponent extends StatefulWidget {
  @override
  ForgotPasswordDailogComponentState createState() => ForgotPasswordDailogComponentState();
}

class ForgotPasswordDailogComponentState extends State<ForgotPasswordDailogComponent> {
  var formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();
  FocusNode emailFocus = FocusNode();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> forgotPasswordUser() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      isLoading = true;
      hideKeyboard(context);
      Map<String, dynamic> req = {
        'email': emailCont.text,
      };
      forgotPassword(req).then((value) {
        toast(value.message);
        isLoading = false;
        finish(context);
      }).catchError((e) {
        toast(e.toString());
        isLoading = false;
        finish(context);
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              onChanged: (value) {},
              controller: emailCont,
              textFieldType: TextFieldType.EMAIL,
              decoration: textInputStyle(
                context: context,
                label: 'lblEmail',
                suffixIcon: commonImage(imageUrl: "images/icons/message.png", size: 18),
              ),
            ),
            16.height,
            AppButton(
              color: primaryColor,
              height: 40,
              text: languageTranslate('lblSubmit'),
              textStyle: boldTextStyle(color: Colors.white),
              width: context.width() - context.navigationBarHeight,
              onTap: () {
                forgotPasswordUser();
              },
            )
          ],
        ).visible(!isLoading, defaultWidget: setLoader()).center(),
      ),
    );
  }
}
