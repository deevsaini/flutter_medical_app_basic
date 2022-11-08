import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/screens/SignInScreen.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:nb_utils/nb_utils.dart';

class WalkThroughModel {
  String? image;
  String? title;
  String? subTitle;

  WalkThroughModel({this.image, this.title, this.subTitle});
}

class WalkThroughScreen extends StatefulWidget {
  @override
  _WalkThroughScreenState createState() => _WalkThroughScreenState();
}

class _WalkThroughScreenState extends State<WalkThroughScreen> {
  var selectedIndex = 0;
  PageController pageController = PageController();

  List<WalkThroughModel> list = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);

    list.add(WalkThroughModel(
      image: "images/walkThrough1.png",
      title: languageTranslate('lblWalkThroughTitle1'),
      subTitle: languageTranslate('lblWalkThroughSubTitle1'),
    ));
    list.add(WalkThroughModel(
      image: "images/walkThrough2.png",
      title: languageTranslate('lblWalkThroughTitle2'),
      subTitle: languageTranslate('lblWalkThroughSubTitle2'),
    ));
    list.add(WalkThroughModel(
      image: "images/walkThrough3.png",
      title: languageTranslate('lblWalkThroughTitle3'),
      subTitle: languageTranslate('lblWalkThroughSubTitle3'),
    ));
    list.add(WalkThroughModel(
      image: "images/walkThrough4.png",
      title: languageTranslate('lblWalkThroughTitle4'),
      subTitle: languageTranslate('lblWalkThroughSubTitle4'),
    ));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: pageController,
              children: list.map((e) {
                return Column(
                  children: [
                    Image.asset(e.image!, height: context.height() * 0.55),
                    Text(e.title!, style: boldTextStyle(size: 25)),
                    Text(e.subTitle!, textAlign: TextAlign.center, style: secondaryTextStyle()).paddingAll(32),
                  ],
                );
              }).toList(),
              onPageChanged: (index) {
                selectedIndex = index;
                setState(() {});
              },
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: DotIndicator(
                pageController: pageController,
                pages: list,
                indicatorColor: primaryColor,
              ),
            ),
            Positioned(
              right: 20,
              left: 150,
              bottom: 35,
              child: AnimatedCrossFade(
                sizeCurve: Curves.fastLinearToSlowEaseIn,
                firstChild: Container(
                  width: context.width(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(languageTranslate('lblWalkThroughGetStartedButton'), style: boldTextStyle(color: white)).center().expand(),
                      Icon(Icons.arrow_forward_outlined, color: Colors.white),
                    ],
                  ),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor: appPrimaryColor,
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                  padding: EdgeInsets.all(16),
                ).onTap(() {
                  setValue(IS_WALKTHROUGH_FIRST, true);
                  SignInScreen().launch(context);
                }),
                secondChild: SizedBox(),
                duration: Duration(milliseconds: 300),
                crossFadeState: selectedIndex == (list.length - 1) ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              ),
            ),
            selectedIndex != (list.length - 1)
                ? Positioned(
                    right: 20,
                    left: 150,
                    bottom: 35,
                    child: AnimatedContainer(
                            duration: Duration(seconds: 1),
                            decoration: boxDecorationWithRoundedCorners(backgroundColor: appPrimaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(languageTranslate('lblWalkThroughNextButton'), style: boldTextStyle(color: Colors.white)).center().expand(),
                                Icon(Icons.arrow_forward_outlined, color: Colors.white),
                              ],
                            ).center(),
                            padding: EdgeInsets.all(16))
                        .onTap(() {
                      //  SignInScreen().launch(context);
                      pageController.nextPage(duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
                    }),
                  )
                : SizedBox(),
            Positioned(
              left: 40,
              bottom: 40,
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                child: Text(languageTranslate('lblWalkThroughSkipButton'), style: boldTextStyle()),
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              ).onTap(
                () {
                  setValue(IS_WALKTHROUGH_FIRST, true);

                  SignInScreen().launch(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
