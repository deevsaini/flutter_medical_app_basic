import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/doctor/screens/telemed/TelemedScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ZoomDetails extends StatefulWidget {
  @override
  State<ZoomDetails> createState() => _ZoomDetailsState();
}

class _ZoomDetailsState extends State<ZoomDetails> {
  var formKey = GlobalKey<FormState>();

  TextEditingController mAPIKeyCont = TextEditingController();
  TextEditingController mAPISecretCont = TextEditingController();

  FocusNode mAPIKeyFocus = FocusNode();
  FocusNode mAPISecretFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    LiveStream().on("isZoomEnabled", (p0) {
      setState(() {});
    });

    if (isZoomOn) {
      appStore.setLoading(true);

      await getTelemedServices().then((value) {
        appStore.setUserZoomService(value.telemedData!.enableTeleMed.validate(value: false));

        mAPIKeyCont.text = value.telemedData!.api_key.validate();
        mAPISecretCont.text = value.telemedData!.api_secret.validate();
        setState(() {});
      }).catchError((e) {
        toast(e.toString(), print: true);
      });

      appStore.setLoading(false);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  saveTelemedData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      appStore.setLoading(true);

      Map<String, dynamic> request = {
        "enableTeleMed": appStore.telemedType == 'zoom',
        "api_key": "${mAPIKeyCont.text}",
        "api_secret": "${mAPISecretCont.text}",
      };

      await addTelemedServices(request).then((value) async {
        toast(languageTranslate('lblTelemedServicesUpdated'));

        await setTelemedType(type: 'zoom');

        finish(context);
      }).catchError((e) {
        errorToast(e.toString());
      });
      appStore.setLoading(false);
      await getConfiguration();
    }
  }

  void disableMeet() async {
    disconnectMeet(request: {"doctor_id": appStore.userId}).then((value) async {
      removeKey("meetUserName");
      removeKey("meetPhotoUrl");
      removeKey("meetUserEmail");

      isMeetOn = false;
      LiveStream().emit("isMeetEnabled");
      isZoomOn = true;
      setState(() {});

      await setTelemedType(type: '');

      toast(value.message.validate());
    }).catchError((e) {
      errorToast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Observer(
            builder: (_) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingItemWidget(
                    title: languageTranslate('lblZoomConfiguration') + ' ${appStore.zoomService.validate() ? languageTranslate('lblOn') : languageTranslate('lblOff')}',
                    decoration: boxDecorationDefault(color: context.cardColor),
                    padding: EdgeInsets.all(8),
                    trailing: Transform.scale(
                      scale: 1,
                      child: Switch(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        inactiveTrackColor: Colors.grey.shade300,
                        activeColor: primaryColor,
                        onChanged: (bool value) async {
                          if (value) {
                            if (isMeetOn) {
                              if (appStore.telemedType == 'googleMeet') {
                                await showConfirmDialogCustom(
                                  context,
                                  dialogType: DialogType.ACCEPT,
                                  title: "${languageTranslate('lblYouCanUseOneMeetingServiceAtTheTimeWeAreDisablingGoogleMeetService.')}",
                                  onAccept: (c) {
                                    disableMeet();
                                  },
                                );
                              } else {
                                isMeetOn = false;
                                LiveStream().emit("isMeetEnabled");
                                isZoomOn = true;
                              }
                            } else {
                              isZoomOn = true;
                            }
                          } else {
                            if (appStore.telemedType == 'zoom') {
                              setTelemedType(type: '');
                            }
                            isZoomOn = false;
                          }
                          setState(() {});
                        },
                        value: isZoomOn,
                      ),
                    ),
                  ),
                  8.height,
                  if (isZoomOn)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: mAPIKeyCont,
                          textFieldType: TextFieldType.OTHER,
                          decoration: textInputStyle(context: context, label: 'lblAPIKey', isMandatory: true),
                          validator: (v) {
                            if (v!.trim().isEmpty) return languageTranslate('lblAPIKeyCannotBeEmpty');
                            return null;
                          },
                        ),
                        16.height,
                        AppTextField(
                          controller: mAPISecretCont,
                          textFieldType: TextFieldType.OTHER,
                          decoration: textInputStyle(context: context, label: 'lblAPISecret', isMandatory: true),
                          validator: (v) {
                            if (v!.trim().isEmpty) return languageTranslate('lblAPISecretCannotBeEmpty');
                            return null;
                          },
                        ),
                        16.height,
                        AppButton(
                          width: context.width(),
                          text: languageTranslate('lblSave'),
                          onTap: () {
                            saveTelemedData();
                          },
                        ),
                        16.height,
                        Text(languageTranslate('lblZoomConfigurationGuide'), style: boldTextStyle(color: primaryColor, size: 18)),
                        16.height,
                        Container(
                            decoration: BoxDecoration(border: Border.all(color: viewLineColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(languageTranslate('lbl1'), style: boldTextStyle()),
                                    6.width,
                                    createRichText(
                                      list: [
                                        TextSpan(text: languageTranslate('lblSignUpOrSignIn'), style: primaryTextStyle()),
                                        TextSpan(
                                          text: languageTranslate('lblZoomMarketPlacePortal'),
                                          style: boldTextStyle(color: primaryColor),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              launch("https://marketplace.zoom.us/");
                                            },
                                        ),
                                      ],
                                    ).expand(),
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
                                    Text(languageTranslate('lb13'), style: boldTextStyle()),
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
                            )),
                      ],
                    )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
