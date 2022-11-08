import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:nb_utils/nb_utils.dart';

class NoDataFoundWidget extends StatelessWidget {
  final String? text;
  final double? iconSize;

  NoDataFoundWidget({this.text, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          appStore.isDarkModeOn ? "images/darkModeNoImage.png" : "images/noDataFound.png",
          height: iconSize ?? 180,
          fit: BoxFit.fitHeight,
        ),
        Text(text ?? '${languageTranslate('lblNoMatch')}', style: boldTextStyle(size: 18)),
        8.height.visible(false),
        Text(
          '${languageTranslate('lblNoDataSubTitle')}',
          textAlign: TextAlign.center,
          style: secondaryTextStyle(color: secondaryTxtColor),
        ).visible(false),
      ],
    ).paddingAll(16);
  }
}
