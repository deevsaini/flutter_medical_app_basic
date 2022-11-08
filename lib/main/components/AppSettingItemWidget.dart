import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:nb_utils/nb_utils.dart';

class AppSettingItemWidget extends StatelessWidget {
  final String? name;
  final String? subTitle;
  final Widget? wSubTitle;
  final Widget? icon;
  final String? image;
  final Function? onTap;
  final Widget? widget;
  final bool isNotTranslate;

  AppSettingItemWidget({this.name, this.subTitle, this.wSubTitle, this.icon, this.image, this.onTap, this.widget, this.isNotTranslate = false});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => GestureDetector(
        onTap: widget == null
            ? onTap as void Function()?
            : () {
                widget.launch(context);
              },
        child: Container(
          width: context.width() / 2 - 24,
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithShadow(
            borderRadius: BorderRadius.circular(defaultRadius),
            backgroundColor: Theme.of(context).cardColor,
            blurRadius: 0,
            spreadRadius: 0,
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "$image",
                    height: 35,
                    width: 30,
                    color: appStore.isDarkModeOn ? Colors.white : appSecondaryColor,
                  ).visible(
                    image != null,
                    defaultWidget: icon,
                  ),
                  16.height,
                  Text(languageTranslate(name), style: boldTextStyle(size: 16)),
                  8.height,
                  Text(
                    isNotTranslate != false ? subTitle.validate() : languageTranslate(subTitle),
                    style: secondaryTextStyle(size: 12, color: secondaryTxtColor),
                  ).visible(
                    subTitle != null,
                    defaultWidget: wSubTitle,
                  ),
                ],
              ).expand(),
            ],
          ),
        ),
      ),
    );
  }
}
