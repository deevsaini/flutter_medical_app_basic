import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/LoginResponseModel.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:nb_utils/nb_utils.dart';

class SelectedClinicWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String maleImage = "images/patientAvatars/patient3.png";
    String image = maleImage;
    Clinic? data = appointmentAppStore.mClinicSelected;
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
          data == null
              ? Image.asset(image, height: 60, width: 60)
              : cachedImage(
                  data.profile_image,
                  height: 60,
                  width: 60,
                  radius: defaultRadius,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRect(
                  defaultRadius,
                ),
          8.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(" ${data?.clinic_name.validate()}", style: boldTextStyle(size: 16)),
              6.height,
              Text("${data?.clinic_email.validate()}", style: secondaryTextStyle(), textAlign: TextAlign.center).paddingOnly(left: 4),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
