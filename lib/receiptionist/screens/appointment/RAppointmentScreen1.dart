import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/AppoitmentSlots.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/ServiceModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/patient/screens/MultiSelect.dart';
import 'package:kivicare_flutter/receiptionist/components/DoctorDropDown.dart';
import 'package:kivicare_flutter/receiptionist/screens/appointment/RAppointmentScreen2.dart';
import 'package:kivicare_flutter/receiptionist/screens/appointment/component/RDateComponent.dart';
import 'package:nb_utils/nb_utils.dart';

class RAppointmentScreen1 extends StatefulWidget {
  final int? id;
  final UpcomingAppointment? data;

  RAppointmentScreen1({this.id, this.data});

  @override
  _RAppointmentScreen1State createState() => _RAppointmentScreen1State();
}

class _RAppointmentScreen1State extends State<RAppointmentScreen1> {
  var formKey = GlobalKey<FormState>();

  TextEditingController appointmentDateCont = TextEditingController();
  TextEditingController appointmentSlotsCont = TextEditingController();
  TextEditingController servicesCont = TextEditingController();

  List<String?> ids = [];
  List<ServiceData> selectedServicesList = [];

  bool isUpdate = false;

  int doctorDataId = -1;

  UpcomingAppointment? upcomingAppointment;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    isUpdate = widget.data != null;

    if (widget.id != null) {
      doctorDataId = widget.id.validate();
    }
    if (isUpdate) {
      upcomingAppointment = widget.data;
      if (upcomingAppointment != null) {
        for (int i = 0; i < upcomingAppointment!.visit_type.validate().length; i++) {
          multiSelectStore.selectedService.add(ServiceData(id: upcomingAppointment!.visit_type![i].id, name: upcomingAppointment!.visit_type![i].service_name, service_id: upcomingAppointment!.visit_type![i].service_id));
        }
        servicesCont.text = multiSelectStore.selectedService.length.toString() + ' ' + languageTranslate('lblServicesSelected');
        List<int> temp = [];

        multiSelectStore.selectedService.forEach((element) {
          temp.add(element.service_id.toInt());
        });

        appointmentAppStore.addSelectedService(temp);
        setState(() {});
      }
      if (upcomingAppointment!.appointment_report!.isNotEmpty) {
        appointmentAppStore.addReportListString(data: upcomingAppointment!.appointment_report!);
      }
    }

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : scaffoldBgColor);
    appointmentSlotsCont.dispose();
    appointmentDateCont.dispose();
    appointmentAppStore.setSelectedClinic(null);
    appointmentAppStore.setSelectedDoctor(null);
    appointmentAppStore.setDescription(null);
    appointmentAppStore.setSelectedPatient(null);
    appointmentAppStore.setSelectedTime(null);
    super.dispose();

    multiSelectStore.clearList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblStep1')),
        body: body(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.arrow_forward_outlined, color: textPrimaryWhiteColor),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              RAppointmentScreen2(updatedData: upcomingAppointment).launch(context);
            }
          },
        ),
      ),
    );
  }

  Widget body() {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            AbsorbPointer(
              absorbing: isUpdate,
              child: DoctorDropDown(
                isValidate: true,
                doctorId: upcomingAppointment?.doctor_id.validate().toInt(),
                onSelected: (DoctorList? doctorCont) {
                  appointmentAppStore.setSelectedDoctor(doctorCont);
                  multiSelectStore.clearList();
                  LiveStream().emit(CHANGE_DATE, true);
                  setState(() {});
                },
              ).paddingSymmetric(horizontal: 16),
            ),
            16.height,
            AbsorbPointer(
              absorbing: isUpdate,
              child: AppTextField(
                controller: servicesCont,
                textFieldType: TextFieldType.ADDRESS,
                decoration: textInputStyle(context: context, label: 'lblSelectServices', isMandatory: true),
                validator: (v) {
                  if (v!.trim().isEmpty) return languageTranslate('lblServicesIsRequired');
                  return null;
                },
                readOnly: true,
                onTap: () async {
                  if (appointmentAppStore.mDoctorSelected == null && !isDoctor()) {
                    errorToast(languageTranslate('lblPleaseSelectDoctor'));
                  } else {
                    if (!isUpdate) {
                      if (multiSelectStore.selectedService.validate().isNotEmpty) {
                        multiSelectStore.selectedService.forEach((element) {
                          ids.add(element.id);
                        });
                      }
                    } else {
                      ids.clear();
                      if (multiSelectStore.selectedService.validate().isNotEmpty) {
                        multiSelectStore.selectedService.forEach((element) {
                          ids.add(element.service_id);
                        });
                      }
                    }

                    bool? res = await MultiSelectWidget(selectedServicesId: ids).launch(context);
                    if (res ?? false) {
                      List<int> temp = [];

                      multiSelectStore.selectedService.forEach((element) {
                        temp.add(element.id.toInt());
                      });

                      appointmentAppStore.addSelectedService(temp);
                      if (multiSelectStore.selectedService.length > 0) {
                        servicesCont.text = "${multiSelectStore.selectedService.length} " + languageTranslate('lblServicesSelected');
                      }
                      setState(() {});
                    }
                  }
                  setState(() {});
                },
              ).paddingSymmetric(horizontal: 16),
            ),
            Observer(
              builder: (_) {
                return AbsorbPointer(
                  absorbing: isUpdate,
                  child: Wrap(
                    spacing: 8,
                    children: List.generate(
                      multiSelectStore.selectedService.length,
                      (index) {
                        ServiceData data = multiSelectStore.selectedService[index];
                        return Chip(
                          label: Text('${data.name}', style: primaryTextStyle()),
                          backgroundColor: Theme.of(context).cardColor,
                          deleteIcon: Icon(Icons.clear),
                          deleteIconColor: Colors.red,
                          onDeleted: () {
                            multiSelectStore.removeItem(data);

                            if (multiSelectStore.selectedService.length > 0) {
                              servicesCont.text = "${multiSelectStore.selectedService.length} " + languageTranslate('lblServicesSelected');
                            } else {
                              servicesCont.clear();
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            side: BorderSide(
                              color: viewLineColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ).paddingSymmetric(vertical: 8, horizontal: 16),
            8.height,
            isUpdate
                ? RDateComponent(
                    initialDate: DateTime.parse(upcomingAppointment!.appointment_start_date.validate()),
                  )
                : RDateComponent(),
            16.height,
            isUpdate
                ? AppointmentSlots(
                    doctorId: upcomingAppointment!.doctor_id.toInt(),
                    appointmentTime: DateFormat(DATE_FORMAT).parse(upcomingAppointment!.appointment_start_time!).getFormattedDate(FORMAT_12_HOUR),
                  ).paddingSymmetric(horizontal: 16)
                : AppointmentSlots().paddingSymmetric(horizontal: 16),
            16.height,
          ],
        ),
      ),
    );
  }
}
