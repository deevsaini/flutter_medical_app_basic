import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/components/NewsItemWidget.dart';
import 'package:kivicare_flutter/patient/model/NewsModel.dart';

class NewsListWidget extends StatefulWidget {
  final List<NewsData>? newsData;

  NewsListWidget({this.newsData});

  @override
  _NewsListWidgetState createState() => _NewsListWidgetState();
}

class _NewsListWidgetState extends State<NewsListWidget> {
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
    setDynamicStatusBarColor();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblArticles')),
        body: body(),
      ),
    );
  }

  Widget body() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      shrinkWrap: true,
      itemCount: widget.newsData!.length,
      itemBuilder: (context, index) {
        return NewsItemWidget(newsData: widget.newsData![index]);
      },
    );
  }
}
