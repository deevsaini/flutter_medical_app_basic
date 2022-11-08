import 'package:kivicare_flutter/main/model/DemoLoginModel.dart';

List<DemoLoginModel> demoLoginList() {
  List<DemoLoginModel> demoLoginListData = [];
  demoLoginListData.add(DemoLoginModel(loginTypeImage: "images/icons/user.png"));
  demoLoginListData.add(DemoLoginModel(loginTypeImage: "images/icons/receptionistIcon.png"));
  demoLoginListData.add(DemoLoginModel(loginTypeImage: "images/icons/doctorIcon.png"));

  return demoLoginListData;
}
