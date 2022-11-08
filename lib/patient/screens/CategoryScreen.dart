import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/PatientDashboardModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppLogics.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryScreen extends StatefulWidget {
  final List<Service> service;

  CategoryScreen({required this.service});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor, statusBarIconBrightness: Brightness.light);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblClinicDoctor')),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Wrap(
            direction: Axis.horizontal,
            spacing: 16,
            runSpacing: 16,
            children: widget.service.map((data) {
              String image = getServicesImages()[widget.service.indexOf(data) % getServicesImages().length];
              return Container(
                width: context.width() / 4 - 18,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
                      child: Image.asset(image, height: 36),
                    ),
                    8.height,
                    Text(
                      '${data.name.validate()}',
                      textAlign: TextAlign.center,
                      style: secondaryTextStyle(color: secondaryTxtColor),
                      softWrap: true,
                      textWidthBasis: TextWidthBasis.longestLine,
                      textScaleFactor: 1,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
