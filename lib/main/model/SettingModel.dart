import 'package:flutter/cupertino.dart';

class SettingModel {
  String? name;
  String? subTitle;
  Widget? wSubTitle;
  Widget? icon;
  String? image;
  Function? onTap;
  Widget? widget;

  SettingModel({this.name, this.wSubTitle, this.subTitle, this.icon, this.onTap, this.widget, this.image});
}
