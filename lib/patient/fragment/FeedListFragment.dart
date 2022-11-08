import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/fragment/FeedDetailsScreen.dart';
import 'package:kivicare_flutter/patient/model/NewsModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';

class FeedListFragment extends StatefulWidget {
  @override
  _FeedListFragmentState createState() => _FeedListFragmentState();
}

class _FeedListFragmentState extends State<FeedListFragment> {
  bool descTextShowFlag = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NewsModel>(
      future: getNewsList(),
      builder: (_, snap) {
        if (snap.hasData) {
          return ListView.builder(
            itemCount: snap.data!.newsData!.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 16, left: 16, bottom: 24, right: 16),
            itemBuilder: (BuildContext context, int index) {
              NewsData data = snap.data!.newsData![index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cachedImage(
                    "${data.image.validate()}",
                    fit: BoxFit.fitWidth,
                    width: context.width(),
                    height: 200,
                  ).cornerRadiusWithClipRRectOnly(topLeft: 8, topRight: 8),
                  Container(
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                      backgroundColor: context.cardColor,
                    ),
                    width: context.width(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        8.height,
                        Text(
                          '${data.readable_date.validate()}',
                          style: secondaryTextStyle(color: secondaryTxtColor),
                        ).paddingOnly(right: 8),
                        8.height,
                        Text('${data.post_title.validate()}', style: boldTextStyle(size: 18)),
                        22.height,
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(80)),
                                child: cachedImage(data.image.validate(), fit: BoxFit.cover),
                              ).onTap(
                                () {},
                              ),
                            ),
                            16.width,
                            Text('${data.post_author_name.validate()}', style: boldTextStyle()).expand(),
                            AppButton(
                              onTap: () {
                                Share.share(data.share_url.validate());
                              },
                              color: context.cardColor,
                              child: Row(
                                children: [
                                  Image.asset(
                                    "images/icons/share.png",
                                    height: 16,
                                    width: 16,
                                    fit: BoxFit.cover,
                                    color: secondaryTxtColor,
                                  ),
                                  8.width,
                                  Text(languageTranslate('lblShare'), style: secondaryTextStyle(color: secondaryTxtColor)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  24.height,
                ],
              ).onTap(() {
                FeedDetailsScreen(newsData: data).launch(context);
              });
            },
          );
        }
        return snapWidgetHelper(snap);
      },
    );
  }
}
