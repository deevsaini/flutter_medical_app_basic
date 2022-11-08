import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor(color: scaffoldBgColor);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblAboutUs')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(appName, style: primaryTextStyle(size: 30)),
            16.height,
            Container(
              decoration: BoxDecoration(color: primaryColor, borderRadius: radius(4)),
              height: 4,
              width: 100,
            ),
            16.height,
            Text(languageTranslate('lblVersion'), style: secondaryTextStyle()),
            Text('${packageInfo.versionName}', style: primaryTextStyle()),
            16.height,
            Text(
              languageTranslate('lblAboutUsDes'),
              style: primaryTextStyle(size: 14),
              textAlign: TextAlign.justify,
            ),
            16.height,
            AppButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('images/icons/contect.png', height: 24, color: Colors.white),
                  8.width,
                  Text(languageTranslate('lblContactUs'), style: primaryTextStyle(color: Colors.white)),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              onTap: () {
                launchUrl('mailto:$mailto');
              },
            ),
            AppButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('images/icons/purchase.png', height: 24, color: Colors.white),
                  8.width,
                  Text(languageTranslate('lblPurchase'), style: primaryTextStyle(color: Colors.white)),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              onTap: () {
                launchUrl(codeCanyonURL);
              },
            ),
          ],
        ).paddingAll(16),
      ),
    );
  }
}
