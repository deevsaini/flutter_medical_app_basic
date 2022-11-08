import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nb_utils/nb_utils.dart';

class YouTubeEmbedWidget extends StatelessWidget {
  final String videoId;
  final bool? fullIFrame;

  YouTubeEmbedWidget(this.videoId, {this.fullIFrame});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: fullIFrame.validate()
          ? '<html><iframe height="230" style="width:100%" src="$videoId"></iframe></html>'
          : '<html><iframe height="230" style="width:100%" src="https://www.youtube.com/embed/$videoId" allow="autoplay; fullscreen" allowfullscreen="allowfullscreen"></iframe></html>',
    );
  }
}
