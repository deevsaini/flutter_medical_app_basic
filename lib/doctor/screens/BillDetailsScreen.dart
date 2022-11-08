import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/PatientBillModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class BillDetailsScreen extends StatefulWidget {
  final int? encounterId;

  BillDetailsScreen({this.encounterId});

  @override
  _BillDetailsScreenState createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  AsyncMemoizer<PatientBillModule> _memorizer = AsyncMemoizer();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblInvoiceDetail')),
        body: body(),
      ),
    );
  }

  Widget body() {
    return FutureBuilder<PatientBillModule>(
      future: _memorizer.runOnce(() => getBillDetails(encounterId: widget.encounterId)),
      builder: (_, snap) {
        if (snap.hasData) {
          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 130),
                children: [
                  Text(languageTranslate('lblClinicDetails').toUpperCase(), style: boldTextStyle(size: 16)),
                  Divider(color: viewLineColor),
                  clinicDetails(patientBillData: snap.data!),
                  Divider(color: viewLineColor),
                  16.height,
                  Text(languageTranslate('lblPatientDetails').toUpperCase(), style: boldTextStyle(size: 16)),
                  Divider(color: viewLineColor),
                  patientDetails(patientBillData: snap.data!),
                  Divider(color: viewLineColor),
                  16.height,
                  Text(languageTranslate('lblServices').toUpperCase(), style: boldTextStyle(size: 16)),
                  Divider(color: viewLineColor),
                  servicesDetails(patientBillData: snap.data!),
                ],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('', style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                        Text('', style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 2),
                        Text('', style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                        Text(languageTranslate('lblTotal'), style: boldTextStyle(size: 12), textAlign: TextAlign.end).expand(),
                        Text('${snap.data!.clinic!.extra!.currency_prefix}${snap.data!.total_amount.validate()}${snap.data!.clinic!.extra!.currency_postfix.validate()}', style: boldTextStyle(size: 12), textAlign: TextAlign.end).expand(flex: 1),
                      ],
                    ).paddingRight(8),
                    Divider(color: viewLineColor),
                    Row(
                      children: [
                        Text('', style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                        Text('', style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 2),
                        Text('', style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                        Text(languageTranslate('lblDiscount'), style: boldTextStyle(size: 12), textAlign: TextAlign.end).expand(),
                        Text('${snap.data!.clinic!.extra!.currency_prefix}${snap.data!.discount.validate()}', style: boldTextStyle(size: 12), textAlign: TextAlign.end).expand(flex: 1),
                      ],
                    ).paddingRight(8),
                    Divider(color: viewLineColor),
                    Row(
                      children: [
                        Text('', style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                        Text('', style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 2),
                        Text('', style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                        Text(languageTranslate('lblAmountDue'), style: boldTextStyle(size: 12), textAlign: TextAlign.end).expand(),
                        Text('${snap.data!.clinic!.extra!.currency_prefix}${snap.data!.actual_amount.validate()}', style: boldTextStyle(size: 12), textAlign: TextAlign.end).expand(flex: 1),
                      ],
                    ).paddingRight(8),
                    Divider(color: viewLineColor),
                  ],
                ).paddingAll(16),
              )
            ],
          );
        }
        return snapWidgetHelper(snap);
      },
    );
  }

  Widget clinicDetails({required PatientBillModule patientBillData}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${patientBillData.clinic!.clinic_name.validate()}', style: boldTextStyle()),
                4.height,
                createRichText(
                  list: [
                    TextSpan(text: languageTranslate('lblInvoiceId') + ': ', style: boldTextStyle(size: 12)),
                    TextSpan(text: '#${patientBillData.id.validate()} ', style: primaryTextStyle(size: 12)),
                  ],
                ),
                4.height,
                createRichText(
                  list: [
                    TextSpan(text: languageTranslate('lblCreatedAt') + ': ', style: boldTextStyle(size: 12)),
                    TextSpan(
                      text: '${patientBillData.created_at.validate().getFormattedDate('dd MMM yyyy')} ',
                      style: primaryTextStyle(size: 12),
                    ),
                  ],
                ),
              ],
            ),
            12.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${patientBillData.clinic!.city.validate()}', style: primaryTextStyle(size: 14)),
                2.height,
                Text('${patientBillData.clinic!.country.validate()}', style: primaryTextStyle(size: 14)),
                2.height,
                Text('${patientBillData.clinic!.clinic_email.validate()} ', style: primaryTextStyle(size: 14)),
                2.height,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(languageTranslate('lblPaymentStatus') + ': ', style: primaryTextStyle(size: 14)),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: patientBillData.payment_status == 'paid' ? successBackGroundColor : errorBackGroundColor,
                      ),
                      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text(
                        '${patientBillData.payment_status.validate().toUpperCase()}',
                        style: primaryTextStyle(
                          color: patientBillData.payment_status == 'paid' ? successTextColor : errorTextColor,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ).expand(),
          ],
        ),
      ],
    );
  }

  Widget patientDetails({required PatientBillModule patientBillData}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        createRichText(
          list: [
            TextSpan(text: languageTranslate('lblPatientName') + ': ', style: boldTextStyle(size: 12)),
            TextSpan(text: '${patientBillData.patient!.display_name.validate()}', style: primaryTextStyle(size: 12)),
          ],
        ),
        6.height,
        createRichText(
          list: [
            TextSpan(text: languageTranslate('lblGender2') + ': ', style: boldTextStyle(size: 12)),
            TextSpan(text: '${patientBillData.patient!.gender.validate().capitalizeFirstLetter()}', style: primaryTextStyle(size: 12)),
          ],
        ),
        6.height,
        createRichText(
          list: [
            TextSpan(text: languageTranslate('lblDOB') + ': ', style: boldTextStyle(size: 12)),
            TextSpan(text: '${patientBillData.patient?.dob?.getFormattedDate('dd MMM yyyy')}', style: primaryTextStyle(size: 12)),
          ],
        ),
      ],
    );
  }

  Widget servicesDetails({required PatientBillModule patientBillData}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 8, bottom: 10, right: 8),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Text(languageTranslate('lblSRNo'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                Text(languageTranslate('lblItemName'), style: boldTextStyle(size: 12), textAlign: TextAlign.start).expand(flex: 2),
                Text(languageTranslate('lblPRICE'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                Text(languageTranslate('lblQUANTITY'), style: boldTextStyle(size: 12), textAlign: TextAlign.start).expand(),
                Text(languageTranslate('lblTOTAL'), style: boldTextStyle(size: 12), textAlign: TextAlign.end).expand(flex: 1),
              ],
            ),
          ),
          16.height,
          ListView.separated(
            shrinkWrap: true,
            itemCount: patientBillData.billItems!.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              BillItem data = patientBillData.billItems![index];
              int total = data.price.validate().toInt() * data.qty.validate().toInt();
              return Container(
                padding: EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Text('${index + 1}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                    Text('${data.label.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.start).expand(flex: 2),
                    Text('${patientBillData.clinic!.extra!.currency_prefix}${data.price.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                    Text('${data.qty.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.end).expand(),
                    Text('${patientBillData.clinic!.extra!.currency_prefix}$total', style: primaryTextStyle(size: 12), textAlign: TextAlign.end).expand(flex: 1),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider(color: viewLineColor);
            },
          ),
        ],
      ),
    );
  }
}
