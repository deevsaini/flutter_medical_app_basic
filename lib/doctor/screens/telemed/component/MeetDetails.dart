import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/doctor/screens/telemed/TelemedScreen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/ResponseModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class MeetDetails extends StatefulWidget {
  @override
  _MeetDetailsState createState() => _MeetDetailsState();
}

class _MeetDetailsState extends State<MeetDetails> {
  bool isDisconnected = false;
  bool isSwitchEnabled = false;

  String? userName = "";
  String? photoUrl = "";
  String? userEmail = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    LiveStream().on("isMeetEnabled", (p0) {
      setState(() {});
    });

    if (appStore.telemedType == "meet") {
      isDisconnected = true;
      userName = getStringAsync('meetUserName');
      photoUrl = getStringAsync('meetPhotoUrl');
      userEmail = getStringAsync('meetUserEmail');
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void disableZoom() async {
    appStore.setLoading(true);
    Map<String, dynamic> request = {
      "enableTeleMed": false,
      "api_key": "",
      "api_secret": "",
    };
    log(request);
    await addTelemedServices(request).then((value) async {
      toast(languageTranslate('lblTelemedServicesUpdated'));

      isZoomOn = false;
      LiveStream().emit("isZoomEnabled");
      isMeetOn = true;
      setState(() {});

      await setTelemedType(type: '');

      appStore.setLoading(false);
    }).catchError((e) {
      errorToast(e.toString());
    });
    appStore.setLoading(false);
  }

  Widget googleMeet() {
    return SizedBox(
      width: context.width(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isDisconnected)
            Text('${languageTranslate('lblYouAreConnectedWithTheGoogleCalender.')}', style: boldTextStyle())
          else
            Text('${languageTranslate('lblPleaseConnectWithYourGoogleAccountToGetAppointmentsInGoogleCalendarAutomatically.')}', style: boldTextStyle()),
          cachedImage(photoUrl.validate(), height: 150, width: 150, radius: 20).cornerRadiusWithClipRRect(80).visible(photoUrl!.isNotEmpty),
          16.height,
          Text(userName.validate(value: ""), style: boldTextStyle(size: 24)).visible(userName!.isNotEmpty),
          16.height,
          Text(userEmail.validate(value: ''), style: secondaryTextStyle()).visible(userEmail!.isNotEmpty),
          16.height,
          if (!isDisconnected)
            AppButton(
              color: context.scaffoldBackgroundColor,
              elevation: 4,
              textStyle: primaryTextStyle(color: Colors.white),
              child: TextIcon(
                spacing: 16,
                prefix: GoogleLogoWidget(size: 20),
                text: languageTranslate('lblConnectWithGoogle'),
                onTap: null,
              ),
              onTap: () async {
                setMeetService();
              },
            )
          else
            AppButton(
              color: context.primaryColor,
              elevation: 4,
              textStyle: primaryTextStyle(color: Colors.white),
              text: languageTranslate('lblDisconnect'),
              onTap: () async {
                showConfirmDialogCustom(
                  context,
                  onAccept: (c) async {
                    disconnectMeet(request: {"doctor_id": appStore.userId}).then((value) {
                      userName = "";
                      photoUrl = "";
                      userEmail = "";
                      removeKey("meetUserName");
                      removeKey("meetPhotoUrl");
                      removeKey("meetUserEmail");
                      isDisconnected = false;

                      setState(() {});

                      toast(value.message.validate());
                    }).catchError((e) {
                      errorToast(e.toString());
                    });
                  },
                  title: languageTranslate('lblAreYouSureYouWantToDisconnect'),
                  dialogType: DialogType.CONFIRMATION,
                  positiveText: languageTranslate('lblYes'),
                );
                await getConfiguration();
              },
            ),
        ],
      ).paddingAll(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                SettingItemWidget(
                  title: "${languageTranslate('lblGoogleMeet')}" + ' ${appStore.userTelemedOn.validate(value: false) ? languageTranslate('lblOn') : languageTranslate('lblOff')}',
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
                          if (isZoomOn) {
                            if (appStore.telemedType == 'zoom') {
                              await showConfirmDialogCustom(
                                context,
                                dialogType: DialogType.ACCEPT,
                                title: "${languageTranslate('lblYouCanUseOneMeetingServiceAtTheTimeWeAreDisablingZoomService.')}",
                                onAccept: (c) {
                                  disableZoom();
                                },
                              );
                            } else {
                              isZoomOn = false;
                              LiveStream().emit("isZoomEnabled");
                              isMeetOn = true;
                            }
                          } else {
                            isMeetOn = true;
                          }
                        } else {
                          if (appStore.telemedType == 'googleMeet') {
                            setTelemedType(type: '');
                          }
                          isMeetOn = false;
                        }
                        setState(() {});
                      },
                      value: isMeetOn,
                    ),
                  ),
                ),
                googleMeet().visible(isMeetOn),
              ],
            ),
          ],
        );
      },
    );
  }

  void setMeetService() async {
    await authService.signInWithGoogle().then((user) async {
      //
      if (user != null) {
        Map<String, dynamic> request = {
          'doctor_id': appStore.userId,
          'code': await user.getIdToken().then((value) => value),
        };

        await connectMeet(request: request).then((value) async {
          ResponseModel data = value;

          userName = user.displayName;
          photoUrl = user.photoURL;
          userEmail = user.email;

          setValue("meetUserName", user.displayName.toString().validate());
          setValue("meetPhotoUrl", user.photoURL.toString().validate());
          setValue("meetUserEmail", user.email.toString().validate());

          isDisconnected = true;
          setState(() {});

          await setTelemedType(type: 'googleMeet');

          toast(data.message);
        }).catchError((e) {
          successToast(e.toString());
        });
      }
    }).catchError((e) {
      toast(e.toString());
    });
  }
}
