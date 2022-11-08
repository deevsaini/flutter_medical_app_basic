import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/fragment/FeedDetailsScreen.dart';
import 'package:kivicare_flutter/patient/model/NewsModel.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class NewsItemWidget extends StatelessWidget {
  NewsData? newsData;

  NewsItemWidget({this.newsData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FeedDetailsScreen(newsData: newsData).launch(context);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          cachedImage(
            newsData!.image.validate(),
            height: 140,
            width: 140,
            fit: BoxFit.cover,
          ).cornerRadiusWithClipRRect(defaultRadius),
          8.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                parseHtmlString(newsData!.post_title.validate()),
                style: boldTextStyle(size: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              4.height,
              Text(
                parseHtmlString(newsData!.post_excerpt.validate()),
                style: secondaryTextStyle(),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
              8.height,
              Align(
                child: Text(newsData!.readable_date.validate(), style: secondaryTextStyle(size: 11)),
                alignment: Alignment.bottomRight,
              ),
            ],
          ).expand(),
        ],
      ).paddingSymmetric(vertical: 8),
    );
  }
}
