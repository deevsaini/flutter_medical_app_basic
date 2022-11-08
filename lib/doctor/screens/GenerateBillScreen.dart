import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/AddBillItem.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/EncounterDashboardModel.dart';
import 'package:kivicare_flutter/main/model/PatientBillModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class GenerateBillScreen extends StatefulWidget {
  EncounterDashboardModel? data;

  GenerateBillScreen({this.data});

  @override
  _GenerateBillScreenState createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  AsyncMemoizer<PatientBillModule> _memorizer = AsyncMemoizer();
  EncounterDashboardModel? patientData;

  TextEditingController totalCont = TextEditingController();
  TextEditingController discountCont = TextEditingController(text: '0');
  TextEditingController payableCont = TextEditingController();

  bool mIsLoading = false;
  bool isPaid = false;

  String? paymentStatus;

  int payableText = 0;

  List<BillItem> billItemData = [];

  List<String> dataList = ["Paid", "Unpaid"];

  int radioIndex = 0;

  int? _groupValue;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    patientData = widget.data;
    if (patientData!.payment_status != null) {
      paymentStatus = patientData!.payment_status.toString().toLowerCase();
    }
  }

  saveFrom() {
    if (billItemData.isNotEmpty) {
      mIsLoading = true;
      setState(() {});
      Map<String, dynamic> request = {
        "id": "${patientData!.bill_id == null ? "" : patientData!.bill_id}",
        "encounter_id": "${patientData!.id == null ? "" : patientData!.id}",
        "appointment_id": "${patientData!.appointment_id == null ? "" : patientData!.appointment_id}",
        "total_amount": "${totalCont.text.validate()}",
        "discount": "${discountCont.text.validate()}",
        "actual_amount": "${payableCont.text.validate()}",
        "payment_status": isPaid ? "paid" : "unpaid",
        "billItems": billItemData,
      };

      log("----------------------------$request--------------------------------------------");

      addPatientBill(request).then((value) {
        finish(context);
        successToast(languageTranslate('lblBillAddedSuccessfully'));
        LiveStream().emit(UPDATE, true);
        LiveStream().emit(APP_UPDATE, true);
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        mIsLoading = false;
        setState(() {});
      });
    } else {
      errorToast(languageTranslate('lblAtLeastSelectOneBillItem'));
    }
  }

  void getTotal() {
    payableText = 0;

    billItemData.forEach((element) {
      payableText += (element.price.validate().toInt() * element.qty.validate().toInt());
    });

    totalCont.text = payableText.toString();
    payableCont.text = payableText.toString();

    setTotalPayable(discountCont.text);
  }

  void setTotalPayable(String v) {
    if (v.isDigit()) {
      payableCont.text = "${payableText - v.toInt()}";
    }
    if (v.trim().isEmpty) {
      payableCont.text = payableText.toString();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    totalCont.dispose();
    discountCont.dispose();
    payableCont.dispose();
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  Widget body() {
    return FutureBuilder<PatientBillModule>(
      future: _memorizer.runOnce(() => getBillDetails(encounterId: patientData!.id.toInt())),
      builder: (_, snap) {
        if (snap.hasData) {
          if (billItemData.isEmpty) {
            billItemData.addAll(snap.data!.billItems!);
          }
          getTotal();
          return Container(
            child: Stack(
              children: [
                Column(
                  children: [
                    8.height,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      decoration: BoxDecoration(
                        color: appStore.isDarkModeOn ? cardDarkColor : black,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Text(languageTranslate('lblSRNo'), style: boldTextStyle(size: 12, color: white), textAlign: TextAlign.center).expand(),
                          Text("   ${languageTranslate('lblSERVICES')}", style: boldTextStyle(size: 12, color: white), textAlign: TextAlign.start).expand(flex: 2),
                          Text(languageTranslate('lblPRICE'), style: boldTextStyle(size: 12, color: white), textAlign: TextAlign.center).expand(),
                          Text(languageTranslate('lblQUANTITY'), style: boldTextStyle(size: 12, color: white), textAlign: TextAlign.center).expand(),
                          Text(languageTranslate('lblTOTAL'), style: boldTextStyle(size: 12, color: white), textAlign: TextAlign.center).expand(flex: 1),
                        ],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(maxHeight: context.height() * 0.39),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: billItemData.length,
                        itemBuilder: (context, index) {
                          BillItem data = billItemData[index];
                          int total = data.price.validate().toInt() * data.qty.validate().toInt();
                          return Row(
                            children: [
                              Text('${index + 1}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                              Text('      ${data.label.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.left).expand(flex: 2),
                              Text('${appStore.currency}${data.price.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                              Text('${data.qty.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                              Text('${appStore.currency}$total', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 1),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(color: viewLineColor);
                        },
                      ),
                    ),
                    24.height,
                  ],
                ).paddingAll(16),
                Positioned(
                  bottom: 230,
                  right: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    width: context.width(),
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                      backgroundColor: context.cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DETAILS', style: boldTextStyle()),
                        4.height,
                        Divider(color: gray.withOpacity(0.2)),
                        4.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(languageTranslate('lblTotal'), style: secondaryTextStyle(color: secondaryTxtColor)), Text("${appStore.currency}${totalCont.text.toString()}", style: boldTextStyle(), textAlign: TextAlign.right).expand()],
                        ),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(languageTranslate('lblDiscount'), style: secondaryTextStyle(color: secondaryTxtColor)),
                            Spacer(),
                            Container(
                              width: 60,
                              constraints: BoxConstraints(maxWidth: 90),
                              height: 30,
                              child: AppTextField(
                                controller: discountCont,
                                textFieldType: TextFieldType.PHONE,
                                keyboardType: TextInputType.number,
                                decoration: textInputStyle(context: context, label: '', isMandatory: false).copyWith(
                                  contentPadding: EdgeInsets.only(left: 8),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 1.0),
                                    borderRadius: radius(),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 1.0, color: Colors.red),
                                    borderRadius: radius(),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                                    borderRadius: radius(),
                                  ),
                                ),
                                onChanged: setTotalPayable,
                                onFieldSubmitted: setTotalPayable,
                              ),
                            ),
                          ],
                        ),
                        8.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(languageTranslate('lblPayableAmount'), style: secondaryTextStyle(color: secondaryTxtColor)),
                            Text("${appStore.currency}${payableCont.text.toString()}", style: boldTextStyle(), textAlign: TextAlign.right).expand(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: context.width(),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),
                      backgroundColor: context.cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languageTranslate('lblStatus').toUpperCase(), style: boldTextStyle()),
                        4.height,
                        Divider(color: gray.withOpacity(0.2)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            RadioListTile(
                              value: 0,
                              contentPadding: EdgeInsets.zero,
                              groupValue: _groupValue,
                              selectedTileColor: Colors.red,
                              title: Text("Paid"),
                              onChanged: (int? newValue) {
                                _groupValue = newValue.validate();
                                setState(() {});
                                isPaid = true;
                              },
                              activeColor: primaryColor,
                              selected: true,
                            ).expand(),
                            RadioListTile(
                              value: 1,
                              contentPadding: EdgeInsets.zero,
                              groupValue: _groupValue,
                              selectedTileColor: Colors.red,
                              title: Text("Unpaid"),
                              onChanged: (int? newValue) {
                                _groupValue = newValue.validate();
                                isPaid = false;

                                setState(() {});
                              },
                              activeColor: primaryColor,
                              selected: true,
                            ).expand(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: context.width(),
                    decoration: boxDecorationWithShadow(
                      border: Border(top: BorderSide(color: viewLineColor)),
                      blurRadius: 0,
                      spreadRadius: 0,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            finish(context);
                          },
                          child: Text(languageTranslate('lblCancel').toUpperCase(), style: boldTextStyle(color: appStore.isDarkModeOn ? white : secondaryTxtColor)),
                        ).expand(),
                        16.width,
                        AppButton(
                          color: appStore.isDarkModeOn ? cardDarkColor : appSecondaryColor,
                          child: Text('${isPaid ? languageTranslate('lblSaveAndCloseEncounter') : languageTranslate('lblSave').toUpperCase()}', style: boldTextStyle(color: Colors.white)),
                          onTap: () {
                            saveFrom();
                          },
                        ).expand(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return snapWidgetHelper(snap);
      },
    );
  }

  Widget body1() {
    return Stack(
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: boxDecorationWithShadow(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
                padding: EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: primaryColor, size: 20),
                    4.width,
                    Text(languageTranslate('lblAddBillItem'), style: boldTextStyle(color: primaryColor)),
                    4.width,
                  ],
                ),
              ).onTap(() async {
                bool? res = await AddBillItem(billId: patientData!.bill_id.toInt(), billItem: billItemData).launch(context);
                if (res ?? false) {
                  getTotal();
                  setState(() {});
                }
              }),
            ),
            32.height,
            Row(
              children: [
                Text(languageTranslate('lblSRNo'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                Text(languageTranslate('lblSERVICES'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 2),
                Text(languageTranslate('lblPRICE'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                Text(languageTranslate('lblQUANTITY'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                Text(languageTranslate('lblTOTAL'), style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 1),
              ],
            ),
            16.height,
            ListView.separated(
              shrinkWrap: true,
              itemCount: billItemData.length,
              itemBuilder: (context, index) {
                BillItem data = billItemData[index];
                int total = data.price.validate().toInt() * data.qty.validate().toInt();
                return Row(
                  children: [
                    Text('${index + 1}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                    Text('${data.label.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 2),
                    Text('${data.price.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                    Text('${data.qty.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                    Text('$total', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(flex: 1),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return Divider(color: viewLineColor);
              },
            )
          ],
        ).paddingAll(16),
        Positioned(
          bottom: 80,
          child: Container(
            padding: EdgeInsets.all(16),
            width: context.width(),
            decoration: boxDecorationWithShadow(
              border: Border(top: BorderSide(color: viewLineColor)),
              blurRadius: 0,
              spreadRadius: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Row(
              children: [
                AppTextField(
                  controller: totalCont,
                  textFieldType: TextFieldType.NAME,
                  decoration: textInputStyle(context: context, label: 'lblTotal', isMandatory: true),
                  readOnly: true,
                ).expand(),
                16.width,
                AppTextField(
                  controller: discountCont,
                  textFieldType: TextFieldType.NAME,
                  keyboardType: TextInputType.number,
                  decoration: textInputStyle(context: context, label: 'lblDiscount', isMandatory: true),
                  onChanged: setTotalPayable,
                  onFieldSubmitted: setTotalPayable,
                ).expand(),
                16.width,
                AppTextField(
                  controller: payableCont,
                  textFieldType: TextFieldType.NAME,
                  decoration: textInputStyle(context: context, label: 'lblPayableAmount'),
                  readOnly: true,
                ).expand(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: EdgeInsets.all(16),
            width: context.width(),
            decoration: boxDecorationWithShadow(
              border: Border(top: BorderSide(color: viewLineColor)),
              blurRadius: 0,
              spreadRadius: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  shapeBorder: Border.all(color: primaryColor),
                  color: Colors.transparent,
                  elevation: 0,
                  child: Text(languageTranslate('lblCancel'), style: boldTextStyle(color: primaryColor)),
                  onTap: () {
                    //
                  },
                ).cornerRadiusWithClipRRect(defaultRadius).expand(),
                16.width,
                AppButton(
                  color: primaryColor,
                  child: Text('${isPaid ? languageTranslate('lblSaveAndCloseEncounter') : languageTranslate('lblSave')}', style: boldTextStyle(color: Colors.white)),
                  onTap: () {
                    saveFrom();
                  },
                ).expand(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblGenerateInvoice'), actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(1),
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(defaultRadius),
                  border: Border.all(color: white, width: 1),
                ),
                child: Icon(Icons.add, color: white, size: 14),
              ),
              6.width,
              Text(languageTranslate('lblAddBillItem').toUpperCase(), style: boldTextStyle(color: white, size: 16)),
              4.width,
            ],
          ).paddingOnly(right: 16, left: 8).onTap(() async {
            bool? res = await AddBillItem(billId: patientData!.bill_id.toInt(), billItem: billItemData, doctorId: patientData!.doctor_id.toInt()).launch(context);
            if (res ?? false) {
              getTotal();
              setState(() {});
            }
          }),
        ]),
        body: patientData!.bill_id == null ? body1().visible(!mIsLoading, defaultWidget: setLoader()) : body().visible(!mIsLoading, defaultWidget: setLoader()),
      ),
    );
  }
}
