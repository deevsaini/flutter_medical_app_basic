import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:nb_utils/nb_utils.dart';

AppBar appAppBar(BuildContext context, {String? name, Widget? leading, Color? backgroundColor, List<Widget>? actions, double? elevation}) {
  return AppBar(
    actions: actions,
    leading: leading ??
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            finish(context);
          },
        ),
    elevation: elevation.validate(value: 4.0),
    shadowColor: shadowColorGlobal,
    backgroundColor: appPrimaryColor,
    title: Text(name.validate(value: languageTranslate('lblNameIsMissing'))),
    titleSpacing: 0,
  );
}

Widget noDataWidget({String? text, bool isInternet = false}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(isInternet ? 'images/no_internet.png' : 'images/noFound.png', height: 100, fit: BoxFit.fitHeight),
      8.height,
      Text(text.validate(value: languageTranslate('lblNoData')), style: boldTextStyle(size: 16)).center(),
    ],
  ).center();
}

Widget noDataTextWidget({String? text, bool isInternet = false}) {
  return Text(text.validate(value: languageTranslate('lblNoRecordsData')), style: boldTextStyle(size: 16, color: errorTextColor)).center();
}

Widget noAppointmentDataWidget({String? text, bool isInternet = false}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SvgPicture.asset("images/no_appointment_widget.svg", semanticsLabel: languageTranslate('lblNoAppointments'), height: 100, fit: BoxFit.fitHeight),
      8.height,
      Text(text.validate(value: languageTranslate('lblNoData')), style: boldTextStyle(size: 16)).center(),
    ],
  ).center();
}

Widget cachedImage(String? url, {double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, bool usePlaceholderIfUrlEmpty = true, double? radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
    );
  } else {
    return Image.asset(url!, height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset('images/placeholder.jpg', height: height, width: width, fit: fit ?? BoxFit.cover, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

Widget settingHeader({required String name}) {
  return Row(
    children: [
      // 16.width,
      Container(
        height: 12,
        width: 5,
        decoration: boxDecorationWithRoundedCorners(backgroundColor: primaryColor),
      ),
      6.width,
      Text(
        name.validate().toUpperCase(),
        style: primaryTextStyle(size: 12, letterSpacing: 1),
      )
    ],
  );
}

class AddFloatingButton extends StatelessWidget {
  final Widget? navigate;
  final Function? onTap;
  final IconData? icon;

  AddFloatingButton({this.navigate, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: primaryColor,
      child: Icon(
        icon == null ? Icons.add : icon,
        color: Colors.white,
      ),
      onPressed: () => navigate == null ? onTap!.call() : navigate.launch(context, pageRouteAnimation: PageRouteAnimation.Slide),
    );
  }
}

Widget setLoader() {
  return Loader(
    valueColor: AlwaysStoppedAnimation(
      defaultLoaderAccentColorGlobal ?? primaryColor,
    ),
  );
}
