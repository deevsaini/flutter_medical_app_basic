import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class RProfileBasicSettings extends StatefulWidget {
  GetDoctorDetailModel? getDoctorDetail;
  void Function(bool isChanged)? onSave;

  RProfileBasicSettings({this.getDoctorDetail, this.onSave});

  @override
  _RProfileBasicSettingsState createState() => _RProfileBasicSettingsState();
}

class _RProfileBasicSettingsState extends State<RProfileBasicSettings> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fixedPriceCont = TextEditingController();
  TextEditingController toPriceCont = TextEditingController();
  TextEditingController fromPriceCont = TextEditingController();
  TextEditingController videoPriceCont = TextEditingController();
  TextEditingController mAPIKeyCont = TextEditingController();
  TextEditingController mAPISecretCont = TextEditingController();

  FocusNode fixedPriceFocus = FocusNode();
  FocusNode toPriceFocus = FocusNode();
  FocusNode fromPriceFocus = FocusNode();
  FocusNode mAPIKeyFocus = FocusNode();
  FocusNode mAPISecretFocus = FocusNode();

  int? result = 0;
  String resultName = "range";

  bool? mIsTelemedOn = false;

  GetDoctorDetailModel? getDoctorDetail;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);

    getDoctorDetail = widget.getDoctorDetail;
    if (getDoctorDetail != null) {
      if (getDoctorDetail!.price_type.validate() == "range") {
        toPriceCont.text = getDoctorDetail!.price.validate().split('-')[0];
        fromPriceCont.text = getDoctorDetail!.price.validate().split('-')[1];
        result = 0;
        setState(() {});
      } else {
        resultName = 'fixed';
        fixedPriceCont.text = getDoctorDetail!.price.validate();
        result = 1;
        setState(() {});
      }
      videoPriceCont.text = getDoctorDetail!.video_price.toString();
      mAPIKeyCont.text = getDoctorDetail!.api_key!;
      mAPISecretCont.text = getDoctorDetail!.api_secret!;
      if (getDoctorDetail!.enableTeleMed != null) {
        mIsTelemedOn = getDoctorDetail!.enableTeleMed;
      } else {
        mIsTelemedOn = false;
      }
    }
  }

  saveBasicSettingData() async {
    Map<String, dynamic> request = {
      "price_type": "$resultName",
    };

    if (resultName == 'range') {
      fixedPriceCont.clear();
      request.putIfAbsent('minPrice', () => toPriceCont.text);
      request.putIfAbsent('maxPrice', () => fromPriceCont.text);
    } else {
      fromPriceCont.clear();
      toPriceCont.clear();
      request.putIfAbsent('price', () => fixedPriceCont.text);
    }

    if (mIsTelemedOn!) {
      request.putIfAbsent('enableTeleMed', () => "$mIsTelemedOn");
      request.putIfAbsent('api_key', () => mAPIKeyCont.text);
      request.putIfAbsent('api_secret', () => mAPISecretCont.text);
      request.putIfAbsent('video_price', () => videoPriceCont.text);
    }

    editProfileAppStore.addData(request);
    toast(languageTranslate('lblInformationSaved'));
    widget.onSave!.call(true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    fixedPriceCont.dispose();
    toPriceCont.dispose();
    fromPriceCont.dispose();
    videoPriceCont.dispose();
    mAPIKeyCont.dispose();
    mAPISecretCont.dispose();

    fixedPriceFocus.dispose();
    toPriceFocus.dispose();
    fromPriceFocus.dispose();
    mAPIKeyFocus.dispose();
    mAPISecretFocus.dispose();

    super.dispose();
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          10.height,
          Row(
            children: [
              Radio(
                activeColor: context.primaryColor,
                fillColor: MaterialStateProperty.all(context.primaryColor),
                value: 0,
                groupValue: result,
                onChanged: (dynamic value) {
                  result = value;
                  resultName = "range";

                  setState(() {});
                },
              ),
              Text(languageTranslate('lblRange'), style: primaryTextStyle()),
              Radio(
                activeColor: context.primaryColor,
                fillColor: MaterialStateProperty.all(context.primaryColor),
                value: 1,
                groupValue: result,
                onChanged: (dynamic value) {
                  result = value;
                  resultName = "fixed";
                  setState(() {});
                },
              ),
              Text(languageTranslate('lblFixed'), style: primaryTextStyle()),
            ],
          ),
          20.height,
          Row(
            children: [
              Container(
                child: AppTextField(
                  controller: toPriceCont,
                  focus: toPriceFocus,
                  textFieldType: TextFieldType.NAME,
                  keyboardType: TextInputType.number,
                  decoration: textInputStyle(context: context, label: 'lblToPrice'),
                ).expand(),
              ),
              20.width,
              Container(
                child: AppTextField(
                  controller: fromPriceCont,
                  focus: fromPriceFocus,
                  textFieldType: TextFieldType.NAME,
                  keyboardType: TextInputType.number,
                  decoration: textInputStyle(context: context, label: 'lblFromPrice'),
                ).expand(),
              ),
            ],
          ).visible(result == 0),
          Container(
            child: AppTextField(
              controller: fixedPriceCont,
              focus: fixedPriceFocus,
              textFieldType: TextFieldType.NAME,
              keyboardType: TextInputType.number,
              decoration: textInputStyle(context: context, label: 'lblFixedPrice'),
            ),
          ).visible(result == 1),
          16.height,
          telemed(),
        ],
      ),
    );
  }

  Widget telemed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageTranslate('lblZoomConfiguration'), style: boldTextStyle(size: 18, color: primaryColor)),
        16.height,
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(languageTranslate('lblTelemed') + ' ${mIsTelemedOn! ? languageTranslate('lblOn') : languageTranslate('lblOff')}', style: primaryTextStyle()),
          value: mIsTelemedOn!,
          inactiveTrackColor: Colors.grey.shade300,
          activeColor: context.primaryColor,
          selected: mIsTelemedOn!,
          secondary: Icon(FontAwesomeIcons.video, size: 20),
          onChanged: (v) {
            mIsTelemedOn = v;
            setState(() {});
          },
        ),
        Column(
          children: [
            16.height,
            AppTextField(
              controller: videoPriceCont,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(
                context: context,
                label: 'lblVideoPrice',
              ),
              validator: (v) {
                if (v!.trim().isEmpty) return languageTranslate('lblAPIKeyCannotBeEmpty');
                return null;
              },
            ),
            16.height,
            AppTextField(
              controller: mAPIKeyCont,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(
                context: context,
                label: 'lblAPIKey',
              ),
              validator: (v) {
                if (v!.trim().isEmpty) return languageTranslate('lblAPIKeyCannotBeEmpty');
                return null;
              },
            ),
            16.height,
            AppTextField(
              controller: mAPISecretCont,
              textFieldType: TextFieldType.OTHER,
              decoration: textInputStyle(
                context: context,
                label: 'lblAPISecret',
              ),
              validator: (v) {
                if (v!.trim().isEmpty) return languageTranslate('lblAPISecretCannotBeEmpty');
                return null;
              },
            ),
            16.height,
            zoomConfigurationGuide(),
          ],
        ).visible(mIsTelemedOn!),
      ],
    );
  }

  Widget zoomConfigurationGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(languageTranslate('lblZoomConfigurationGuide'), style: boldTextStyle(color: primaryColor, size: 18)),
        16.height,
        Container(
            decoration: BoxDecoration(border: Border.all(color: viewLineColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languageTranslate('lbl1'), style: boldTextStyle()),
                    6.width,
                    Text(languageTranslate('lblSignUpOrSignIn'), style: primaryTextStyle()),
                    Text(
                      languageTranslate('lblZoomMarketPlacePortal'),
                      style: boldTextStyle(color: primaryColor),
                    ).onTap(() {
                      launch("https://marketplace.zoom.us/");
                    }).expand(),
                  ],
                ).paddingAll(8),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languageTranslate('lbl2'), style: boldTextStyle()),
                    6.width,
                    createRichText(list: [
                      TextSpan(text: languageTranslate('lblClickOnDevelopButton'), style: primaryTextStyle()),
                      TextSpan(
                        text: languageTranslate('lblCreateApp'),
                        style: boldTextStyle(color: primaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch("https://marketplace.zoom.us/develop/create");
                          },
                      ),
                    ], maxLines: 5)
                        .expand(),
                  ],
                ).paddingAll(8),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languageTranslate('lbl3'), style: boldTextStyle()),
                    6.width,
                    Text(languageTranslate('lblChooseAppTypeToJWT'), style: primaryTextStyle()).expand(),
                  ],
                ).paddingAll(8),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languageTranslate('lbl4'), style: boldTextStyle()),
                    6.width,
                    Text(languageTranslate('lblMandatoryMessage'), style: primaryTextStyle()).expand(),
                  ],
                ).paddingAll(8),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languageTranslate('lbl5'), style: boldTextStyle()),
                    6.width,
                    Text(languageTranslate('lblCopyAndPasteAPIKey'), style: primaryTextStyle()).expand(),
                  ],
                ).paddingAll(8),
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: body(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            saveBasicSettingData();
          },
          elevation: 0.0,
          child: Icon(Icons.arrow_forward, color: textPrimaryWhiteColor),
          backgroundColor: appSecondaryColor,
        ),
      ),
    );
  }
}
