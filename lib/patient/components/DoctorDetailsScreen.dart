import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/receiptionist/screens/RAddNewDoctor.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  final DoctorList? data;

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
      width: context.width(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 46,
            decoration: boxDecorationWithShadow(backgroundColor: context.iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(defaultRadius)),
          ).center(),
          16.height,
          Row(
            children: [
              Text(languageTranslate('lblDoctorDetails'), style: boldTextStyle(size: 16)).expand(),
              Divider(color: appSecondaryColor.withOpacity(0.4)).visible(widget.data!.available.validate().isNotEmpty),
              if (isReceptionist())
                IconButton(
                  icon: FaIcon(Icons.edit, size: 20),
                  onPressed: () async {
                    finish(context);
                    bool? res = await RAddNewDoctor(doctorList: widget.data, isUpdate: true).launch(context);
                    if (res ?? false) {}
                  },
                ),
              if (isReceptionist())
                IconButton(
                  icon: FaIcon(Icons.delete, size: 20),
                  onPressed: () async {
                    bool? res = await showConfirmDialog(context, languageTranslate('lblAreYouWantToDeleteDoctor'));
                    if (res ?? false) {
                      finish(context);

                      Map<String, dynamic> request = {
                        "doctor_id": widget.data!.iD,
                      };
                      deleteDoctor(request).then((value) {
                        successToast(languageTranslate('lblDoctorDeleted'));
                      }).catchError((e) {
                        errorToast(e.toString());
                      }).whenComplete(() {
                        //
                      });
                    }
                  },
                ),
            ],
          ),
          Divider(color: viewLineColor),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  doctorDetailWidget(
                    image: "images/icons/user.png",
                    bgColor: appStore.isDarkModeOn ? cardDarkColor : Color(0xFFFEF5F5),
                    title: languageTranslate('lblName'),
                    subTitle: "${widget.data!.display_name.validate()}",
                  ),
                  16.height,
                  doctorDetailWidget(
                    image: "images/icons/experience.png",
                    bgColor: appStore.isDarkModeOn ? cardDarkColor : Color(0xFFFEF5F5),
                    title: languageTranslate('lblExperience'),
                    subTitle: "${widget.data!.no_of_experience.validate()} " + languageTranslate('lblYearsExperience'),
                  ),
                ],
              ).expand(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  doctorDetailWidget(
                    image: "images/icons/message.png",
                    bgColor: appStore.isDarkModeOn ? cardDarkColor : Color(0xFFFEF5F5),
                    title: languageTranslate('lblEmail'),
                    subTitle: "${widget.data!.user_email.validate()}",
                  ),
                  16.height,
                  doctorDetailWidget(
                    image: "images/icons/phone.png",
                    bgColor: appStore.isDarkModeOn ? cardDarkColor : Color(0xFFFEF5F5),
                    title: languageTranslate('lblContact'),
                    subTitle: "${widget.data!.mobile_number.validate()}",
                  ),
                ],
              ).expand()
            ],
          ),
          32.height,
          Text(languageTranslate('lblAvailableOn'), style: boldTextStyle(size: 16)),
          4.height,
          Divider(color: appSecondaryColor.withOpacity(0.4)).visible(widget.data!.available.validate().isNotEmpty),
          widget.data!.available != null ? 16.height : Offstage(),
          widget.data!.available != null
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    widget.data!.available!.split(",").length,
                    (index) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: appStore.isDarkModeOn ? cardDarkColor : appPrimaryColor,
                      ),
                      child: Text(
                        '${widget.data!.available!.split(",")[index].capitalizeFirstLetter()}',
                        style: primaryTextStyle(color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                )
              : NoDataFoundWidget(iconSize: 120).center(),
        ],
      ),
    );
  }
}
