import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/doctor/components/AddPrescriptionScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/PrescriptionModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class PrescriptionFragment extends StatefulWidget {
  final int? id;

  PrescriptionFragment({this.id});

  @override
  _PrescriptionFragmentState createState() => _PrescriptionFragmentState();
}

class _PrescriptionFragmentState extends State<PrescriptionFragment> {
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
  void didUpdateWidget(covariant PrescriptionFragment oldWidget) {
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
    return FutureBuilder<PrescriptionModel>(
      future: getPrescriptionResponse(widget.id.toString()),
      builder: (context, snap) {
        if (snap.hasData) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPatient())
                      Text(languageTranslate('lblPrescription') + ' (${snap.data!.total})', style: boldTextStyle(size: 18))
                    else
                      Row(
                        children: [
                          Text(languageTranslate('lblPrescription') + ' (${snap.data!.total})', style: boldTextStyle(size: 18)),
                          Spacer(),
                          AppButton(
                            text: languageTranslate("lblSend_prescription_on_mail"),
                            onTap: () async {
                              appStore.setLoading(true);
                              await sendPrescriptionMail(encounterId: widget.id.validate()).then((value) {
                                toast(value.message.toString());
                              }).catchError((e) {
                                //
                              });
                              appStore.setLoading(false);
                            },
                          ),
                        ],
                      ),
                    16.height,
                    ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: snap.data!.prescriptionData!.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        PrescriptionData data = snap.data!.prescriptionData![index];
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
                                    Text(
                                      tempDate.month.getMonthName()!,
                                      textAlign: TextAlign.center,
                                      style: secondaryTextStyle(size: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 80,
                                child: VerticalDivider(color: viewLineColor, width: 25, thickness: 1, indent: 1, endIndent: 1),
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
                                    style: primaryTextStyle(),
                                    trimLines: 1,
                                    trimMode: TrimMode.Line,
                                    locale: Localizations.localeOf(context),
                                  ),
                                ],
                              ).expand(),
                            ],
                          ),
                        ).onTap(() {
                          AddPrescriptionScreen(id: widget.id, pID: data.id.toInt(), prescriptionData: data).launch(context);
                        }, highlightColor: Colors.transparent, splashColor: Colors.transparent);
                      },
                    ).paddingBottom(60),
                  ],
                ),
              ),
              Observer(builder: (context) => Loader().visible(appStore.isLoading))
            ],
          );
        }
        return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
      },
    );
  }
}
