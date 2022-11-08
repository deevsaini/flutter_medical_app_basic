import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/model/LanguageModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class LanguageScreen extends StatefulWidget {
  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor, statusBarIconBrightness: Brightness.light);

    currentIndex = getIntAsync(SELECTED_LANGUAGE, defaultValue: 0);
    setState(() {});
  }

  @override
  void dispose() {
    setStatusBarColor(
      appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
      statusBarIconBrightness: appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
    );
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate("lblLanguage"), elevation: 0.0),
        body: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 16),
          shrinkWrap: true,
          itemCount: Language.getLanguages().length,
          itemBuilder: (BuildContext context, int index) {
            Language data = Language.getLanguages()[index];
            return Theme(
              data: ThemeData(
                unselectedWidgetColor: context.dividerColor,
              ),
              child: RadioListTile(
                value: index,
                groupValue: currentIndex,
                controlAffinity: ListTileControlAffinity.trailing,
                title: Text(data.name.validate(), style: primaryTextStyle()),
                secondary: Image.asset(data.flag.validate(), width: 30, height: 30),
                onChanged: (dynamic val) async {
                  hideKeyboard(context);
                  currentIndex = val;
                  setValue(SELECTED_LANGUAGE, val);
                  appStore.setLanguage(data.languageCode, context: context);
                  finish(context);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
