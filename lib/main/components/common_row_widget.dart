import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:nb_utils/nb_utils.dart';

class CommonRowWidget extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final bool isMarquee;

  CommonRowWidget({required this.title, required this.value, this.isMarquee = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.antiAlias,
          fit: BoxFit.scaleDown,
          child: Text(title, style: secondaryTextStyle(color: secondaryTxtColor, size: 16)),
        ).expand(),
        (isMarquee
                ? Marquee(
                    child: Text(value, style: boldTextStyle(size: 16)),
                  )
                : Text(value, style: boldTextStyle(color: valueColor, size: 16)))
            .expand(flex: 3),
      ],
    );
  }
}
