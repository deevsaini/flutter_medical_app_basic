import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:nb_utils/nb_utils.dart';

class ThemeSelectionDialog extends StatefulWidget {
  static String tag = '/ThemeSelectionDialog';

  @override
  ThemeSelectionDialogState createState() => ThemeSelectionDialogState();
}

class ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  List<String> themeModeList = [languageTranslate('lblLight'), languageTranslate('lblDark'), languageTranslate('lblSystemDefault')];

  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: themeModeList.length,
        itemBuilder: (BuildContext context, int index) {
          return Theme(
            data: ThemeData(
              unselectedWidgetColor: context.dividerColor,
            ),
            child: RadioListTile(
              value: index,
              groupValue: currentIndex,
              title: Text(themeModeList[index], style: primaryTextStyle()),
              onChanged: (dynamic val) {
                setState(() {
                  currentIndex = val;

                  if (val == ThemeModeSystem) {
                    appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
                  } else if (val == ThemeModeLight) {
                    appStore.setDarkMode(false);
                  } else if (val == ThemeModeDark) {
                    appStore.setDarkMode(true);
                  }

                  setIntAsync(THEME_MODE_INDEX, val);
                });

                finish(context);
              },
            ),
          );
        },
      ),
    );
  }
}
