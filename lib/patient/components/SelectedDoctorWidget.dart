import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

class SelectedDoctorWidget extends StatefulWidget {
  @override
  State<SelectedDoctorWidget> createState() => _SelectedDoctorWidgetState();
}

class _SelectedDoctorWidgetState extends State<SelectedDoctorWidget> {
  String maleImage = "images/doctorAvatars/doctor2.png";
  String femaleImage = "images/doctorAvatars/doctor1.png";

  String? image = '';

  DoctorList data = appointmentAppStore.mDoctorSelected!;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image = appointmentAppStore.mDoctorSelected?.gender!.toLowerCase() == "male" ? maleImage : femaleImage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: boxDecorationWithShadow(
        blurRadius: 0,
        spreadRadius: 0,
        borderRadius: BorderRadius.circular(defaultRadius),
        backgroundColor: Theme.of(context).cardColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          data.profile_image == null
              ? Image.asset(image.validate(), height: 60, width: 60)
              : cachedImage(data.profile_image, height: 60, width: 60, radius: defaultRadius, fit: BoxFit.cover).cornerRadiusWithClipRRect(
                  defaultRadius,
                ),
          8.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dr. ${data.display_name.validate()}", style: boldTextStyle(size: 16)),
              6.height,
              Text("${data.specialties.validate()}", style: secondaryTextStyle(), textAlign: TextAlign.center),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
