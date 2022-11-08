import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/doctor/screens/EncounterDashboardScreen.dart';
import 'package:kivicare_flutter/doctor/screens/appointment/DoctorAddAppointmentStep1Screen.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/AppointmentQuickView.dart';
import 'package:kivicare_flutter/main/components/cached_image_widget.dart';
import 'package:kivicare_flutter/main/components/common_row_widget.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/screens/PatientEncounterDashboardScreen.dart';
import 'package:kivicare_flutter/patient/screens/appointment/AddAppointmentScreenStep2.dart';
import 'package:kivicare_flutter/receiptionist/screens/appointment/RAppointmentScreen1.dart';
import 'package:nb_utils/nb_utils.dart';

class AppointmentWidget extends StatefulWidget {
  final UpcomingAppointment? upcomingData;
  final int index;

  AppointmentWidget({this.upcomingData, required this.index});

  @override
  _AppointmentWidgetState createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget> {
  bool isLoading = false;
  String today = DateTime.now().getFormattedDate('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  bool get isTelemed {
    bool mIsON = false;
    if (!isReceptionist()) {
      if (widget.upcomingData!.zoomData != null && widget.upcomingData!.status.toInt().getStatus() == CheckInStatus) {
        return mIsON = true;
      }
    }
    return mIsON;
  }

  bool get isCheckIn {
    bool mIsCheckIn = false;
    if (isPatient()) {
      mIsCheckIn = false;
    } else {
      if (widget.upcomingData!.status.toInt().getStatus() != CancelledStatus && widget.upcomingData!.status.toInt().getStatus() != CheckOutStatus) {
        mIsCheckIn = DateTime.parse(widget.upcomingData!.appointment_start_date!).difference(DateTime.parse(DateFormat(CONVERT_DATE).format(DateTime.now()))).inDays == 0;
      }
    }
    return mIsCheckIn;
  }

  bool get isEncounterDashboard {
    return widget.upcomingData!.status.toInt().getStatus() == CheckInStatus || widget.upcomingData!.status.toInt().getStatus() == CheckOutStatus;
  }

  bool get isEdit {
    return widget.upcomingData!.status.toInt().getStatus() != CheckOutStatus &&
        widget.upcomingData!.status.toInt().getStatus() != CancelledStatus &&
        widget.upcomingData!.status.toInt().getStatus() != CheckInStatus &&
        DateTime.parse(widget.upcomingData!.appointment_start_date.validate()).difference(DateTime.now()).inDays >= 0;
  }

  void changeAppointmentStatus(BuildContext context) async {
    await showConfirmDialogCustom(context,
        title: languageTranslate('lblUpdateAppointmentStatus'),
        cancelable: false,
        onCancel: (s) {
          finish(context);
        },
        primaryColor: primaryColor,
        dialogType: DialogType.CONFIRMATION,
        onAccept: (ctx) {
          if (widget.upcomingData!.status.toInt() == 1) {
            updateStatus(id: widget.upcomingData!.id.toInt(), status: 4);
          } else if (widget.upcomingData!.status.toInt() == 4) {
            if (getStringAsync(USER_DATA).isNotEmpty) {
              push(EncounterDashboardScreen(id: widget.upcomingData!.encounter_id));
            }
          }
        });
  }

  void deleteAppointmentValue(BuildContext context) async {
    bool? res = await showConfirmDialog(context, languageTranslate('lblAreDeleteAppointment'), buttonColor: primaryColor);
    if (res ?? false) {
      deleteAppointmentById(widget.upcomingData!.id.toInt());
    }
  }

  void get telemedData async {
    if (isDoctor()) {
      launchUrl(widget.upcomingData!.zoomData!.startUrl!);
    } else if (isPatient()) {
      launchUrl(widget.upcomingData!.zoomData!.joinUrl!);
    } else {
      toast(languageTranslate('lblYouCannotStart'));
    }
  }

  updateStatus({int? id, int? status}) {
    Map<String, dynamic> request = {
      "appointment_id": id.toString(),
      "appointment_status": status.toString(),
    };
    updateAppointmentStatus(request).then((value) {
      LiveStream().emit(UPDATE, true);
      LiveStream().emit(APP_UPDATE, true);
      successToast(languageTranslate('lblChangedTo') + " ${status.getStatus()}");
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  deleteAppointmentById(int id) {
    Map<String, dynamic> request = {"id": id};

    deleteAppointment(request).then((value) {
      LiveStream().emit(UPDATE, true);
      LiveStream().emit(APP_UPDATE, true);
      LiveStream().emit(DELETE, true);

      successToast(languageTranslate('lblAppointmentDeleted'));
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context1) {
    return Slidable(
      key: ValueKey(widget.upcomingData),
      enabled: isEdit,
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              if (isPatient()) {
                AddAppointmentScreenStep2(data: widget.upcomingData).launch(
                  context,
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
              } else if (isReceptionist()) {
                RAppointmentScreen1(id: getIntAsync(USER_ID), data: widget.upcomingData).launch(
                  context,
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
              } else {
                DoctorAddAppointmentStep1Screen(id: getIntAsync(USER_ID), data: widget.upcomingData).launch(
                  context,
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
              }
            },
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(defaultRadius),
              bottomLeft: Radius.circular(defaultRadius),
            ),
            icon: Icons.edit,
            label: languageTranslate('lblEdit'),
          ),
          SlidableAction(
            // An action can be bigger than the others.
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(defaultRadius),
              bottomRight: Radius.circular(defaultRadius),
            ),
            onPressed: deleteAppointmentValue,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: languageTranslate('lblDelete'),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithShadow(
              borderRadius: BorderRadius.circular(defaultRadius),
              spreadRadius: 0,
              blurRadius: 0,
              backgroundColor: Theme.of(context).cardColor,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedImageWidget(
                      // url: data.attchments.validate().isNotEmpty ? data.attchments!.first.validate() : '',
                      url: '',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      radius: 120,
                    ).paddingOnly(top: 16),
                    22.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            20.height,
                            isPatient()
                                ? Text(
                                    "Dr. ${widget.upcomingData!.doctor_name.validate().capitalizeFirstLetter()}",
                                    style: boldTextStyle(size: titleTextSize),
                                  )
                                : Text(
                                    "${widget.upcomingData!.patient_name.validate().capitalizeFirstLetter()}",
                                    style: boldTextStyle(size: titleTextSize),
                                  ),
                            24.height,
                          ],
                        ),
                        Wrap(
                          runSpacing: 10,
                          children: [
                            if (isReceptionist())
                              CommonRowWidget(
                                title: languageTranslate('lblDoctor'),
                                value: widget.upcomingData!.doctor_name.validate(),
                                isMarquee: true,
                              ),
                            CommonRowWidget(
                              title: languageTranslate('lblService'),
                              value: '${widget.upcomingData!.visit_type.validate().map((e) => e.service_name.validate()).join(" , ")}',
                            ),
                            CommonRowWidget(
                              title: languageTranslate('lblDate'),
                              value: widget.upcomingData!.appointment_start_date.validate().getFormattedDate('dd-MMM-yyyy'),
                            ),
                            CommonRowWidget(
                                title: languageTranslate('lblTime'),
                                value:
                                    '${DateFormat(DATE_FORMAT).parse(widget.upcomingData!.appointment_start_time!).getFormattedDate(FORMAT_12_HOUR)} - ${DateFormat(DATE_FORMAT).parse(widget.upcomingData!.appointment_end_time!).getFormattedDate(FORMAT_12_HOUR)}'),
                            CommonRowWidget(
                              title: languageTranslate('lblDesc'),
                              value: widget.upcomingData!.description.validate().trim().isNotEmpty ? widget.upcomingData!.description.validate() : 'NA',
                            ),
                            CommonRowWidget(
                              title: languageTranslate('lblPrice'),
                              value: '${appStore.currency.validate()}${widget.upcomingData!.all_service_charges}',
                              valueColor: primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ).expand(),
                  ],
                ),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppButton(
                            onTap: () {
                              showInDialog(
                                context,
                                contentPadding: EdgeInsets.zero,
                                title: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: boxDecorationWithRoundedCorners(backgroundColor: appSecondaryColor),
                                          child: Image.asset(
                                            "images/icons/appointment.png",
                                            fit: BoxFit.cover,
                                            height: 22,
                                            width: 22,
                                            color: white,
                                          ),
                                        ),
                                        16.width,
                                        Text(languageTranslate('lblAppointmentSummary'), style: boldTextStyle(size: 18)).flexible(),
                                      ],
                                    ).paddingOnly(top: 24),
                                    Positioned(
                                      right: -24,
                                      top: -24,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: boxDecorationWithRoundedCorners(
                                          backgroundColor: statusColor,
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(defaultRadius)),
                                        ),
                                        child: Text(
                                          getStatus(widget.upcomingData!.status.validate())!,
                                          style: boldTextStyle(size: 12, color: white),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                builder: (p0) {
                                  return AppointmentQuickView(
                                    upcomingAppointment: widget.upcomingData!,
                                  );
                                },
                              );
                            },
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: (isEncounterDashboard || isCheckIn)
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(defaultRadius),
                                      bottomLeft: Radius.circular(defaultRadius),
                                    )
                                  : BorderRadius.all(Radius.circular(defaultRadius)),
                            ),
                            child: FittedBox(
                              child: FittedBox(child: Text(languageTranslate('lblViewDetails'), style: boldTextStyle(color: white, size: 12))),
                            ),
                            color: appPrimaryColor,
                          ),
                        ),
                        Flexible(
                          child: AppButton(
                            onTap: () {
                              if (isPatient()) {
                                PatientEncounterDashboardScreen(
                                  id: widget.upcomingData!.encounter_id.validate().toInt(),
                                ).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                              } else {
                                EncounterDashboardScreen(
                                  id: widget.upcomingData!.encounter_id.validate(),
                                ).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                              }
                            },
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: isCheckIn
                                  ? BorderRadius.all(Radius.circular(0))
                                  : BorderRadius.only(
                                      topRight: Radius.circular(defaultRadius),
                                      bottomRight: Radius.circular(defaultRadius),
                                    ),
                            ),
                            child: FittedBox(child: Text(languageTranslate('lblEncounter'), style: boldTextStyle(color: white, size: 12))),
                            color: appStore.isDarkModeOn ? cardDarkColor : Colors.black,
                          ),
                        ).visible(isEncounterDashboard),
                        Flexible(
                          child: AppButton(
                            onTap: () {
                              changeAppointmentStatus(context);
                            },
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(defaultRadius),
                                topRight: Radius.circular(defaultRadius),
                              ),
                            ),
                            child: FittedBox(
                              child: Text(languageTranslate('lblCheckIn'), style: boldTextStyle(color: white, size: 12)).visible(
                                widget.upcomingData!.status.toInt().getStatus() != CheckInStatus,
                                defaultWidget: FittedBox(
                                  child: Text(languageTranslate('lblCheckOut'), style: boldTextStyle(color: white, size: 12)),
                                ),
                              ),
                            ),
                            color: appSecondaryColor,
                          ),
                        ).visible(isCheckIn),
                      ],
                    ).expand(),
                    24.width,
                    Container(
                      decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: appPrimaryColor),
                      padding: EdgeInsets.all(12),
                      child: Image.asset("images/icons/video.png", width: 16, height: 16, fit: BoxFit.cover, color: white),
                    ).visible(isTelemed).onTap(() => telemedData)
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: statusBgColor,
                borderRadius: BorderRadius.only(topRight: Radius.circular(defaultRadius)),
              ),
              child: Text(getStatus(widget.upcomingData!.status.validate())!, style: boldTextStyle(size: 12, color: white)),
            ),
          )
        ],
      ).paddingOnly(right: 4),
    );
  }
}
