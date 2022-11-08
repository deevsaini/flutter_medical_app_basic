import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/main/model/PrescriptionModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/patient/model/PatientEncounterDashboardModel.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class PrescriptionWidget extends StatefulWidget {
  Prescription? prescription;

  PrescriptionWidget({this.prescription});

  @override
  _PrescriptionWidgetState createState() => _PrescriptionWidgetState();
}

class _PrescriptionWidgetState extends State<PrescriptionWidget> {
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
  void didUpdateWidget(covariant PrescriptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor(color: appPrimaryColor);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(languageTranslate('lblPrescription') + ' (${widget.prescription!.total})', style: boldTextStyle()),
          16.height,
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.prescription!.prescriptionData!.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              PrescriptionData data = widget.prescription!.prescriptionData![index];
              DateTime tempDate = new DateFormat(CONVERT_DATE).parse(data.created_at!);
              return Container(
                decoration: boxDecorationWithShadow(
                  blurRadius: 0,
                  spreadRadius: 0,
                  backgroundColor: Theme.of(context).cardColor,
                  border: Border.all(color: context.dividerColor),
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(text: tempDate.day.toString(), style: boldTextStyle(size: 22)),
                                WidgetSpan(
                                  child: Transform.translate(
                                    offset: const Offset(2, -10),
                                    child: Text(
                                      getDayOfMonthSuffix(tempDate.day).toString(),
                                      textScaleFactor: 0.7,
                                      style: boldTextStyle(size: 14),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(tempDate.month.getMonthName()!, textAlign: TextAlign.center, style: secondaryTextStyle(size: 14)),
                        ],
                      ),
                    ),
                    Container(
                      height: 80,
                      child: VerticalDivider(
                        color: viewLineColor,
                        width: 25,
                        thickness: 1,
                        indent: 1,
                        endIndent: 1,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(data.name.validate(), style: boldTextStyle(size: 16, color: primaryColor)),
                        5.height,
                        Text(data.frequency.validate(), style: primaryTextStyle(size: 14)),
                        5.height,
                        Text("${data.duration.validate()} " + languageTranslate('lblDays'), style: primaryTextStyle(size: 14)),
                        5.height,
                        ReadMoreText(
                          data.instruction.validate(),
                          trimLines: 1,
                          style: primaryTextStyle(),
                          trimMode: TrimMode.Line,
                          locale: Localizations.localeOf(context),
                        ),
                      ],
                    ).expand(),
                  ],
                ),
              );
            },
          ).paddingBottom(60),
        ],
      ),
    );
  }
}
