import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/components/HtmlWidget.dart';
import 'package:kivicare_flutter/patient/model/NewsModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';

class FeedDetailsScreen extends StatefulWidget {
  final NewsData? newsData;
  FeedDetailsScreen({this.newsData});

  @override
  _FeedDetailsScreenState createState() => _FeedDetailsScreenState();
}

class _FeedDetailsScreenState extends State<FeedDetailsScreen> {
  NewsData? newsData;
  String postContent = "";
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    newsData = widget.newsData;
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    setPostContent(widget.newsData!.post_content.validate());
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> setPostContent(String text) async {
    postContent = widget.newsData!.post_content
        .validate()
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('[embed]', '<embed>')
        .replaceAll('[/embed]', '</embed>')
        .replaceAll('[caption]', '<caption>')
        .replaceAll('[/caption]', '</caption>');

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor(color: scaffoldBgColor);
  }

  Widget body() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                  child: Text(languageTranslate('lblNews'), style: boldTextStyle(color: Colors.white, size: 8)),
                  decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt(), backgroundColor: primaryColor),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: textSecondaryColorGlobal, size: 16),
                    4.width,
                    Text(newsData!.readable_date.validate(), style: secondaryTextStyle()),
                  ],
                ),
              ],
            ).paddingOnly(top: 16, bottom: 8, left: 16, right: 16),
            8.height,
            Text(parseHtmlString(newsData!.post_title.validate()), style: boldTextStyle(size: 26)).paddingOnly(left: 16, right: 16),
            HtmlWidget(postContent: postContent.validate()).paddingOnly(left: 8, right: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(
          context,
          name: '${parseHtmlString(newsData!.post_title.validate())}',
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Share.share(newsData!.share_url.validate());
              },
            )
          ],
        ),
        body: body(),
      ),
    );
  }
}
