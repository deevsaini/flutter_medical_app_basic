import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/doctor/screens/appointment/DoctorAddAppointmentStep2Screen.dart';
import 'package:kivicare_flutter/doctor/screens/appointment/component/DDateComponent.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/AppoitmentSlots.dart';
import 'package:kivicare_flutter/main/components/ClinicDropDown.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/LoginResponseModel.dart';
import 'package:kivicare_flutter/main/model/ServiceModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/screens/MultiSelect.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorAddAppointmentStep1Screen extends StatefulWidget {
  final int? id;
  final UpcomingAppointment? data;

  DoctorAddAppointmentStep1Screen({this.id, this.data});

  @override
  _DoctorAddAppointmentStep1ScreenState createState() => _DoctorAddAppointmentStep1ScreenState();
}

class _DoctorAddAppointmentStep1ScreenState extends State<DoctorAddAppointmentStep1Screen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController appointmentDateCont = TextEditingController();
  TextEditingController appointmentSlotsCont = TextEditingController();
  TextEditingController servicesCont = TextEditingController();

  List<String> pName = [];
  List<String?> ids = [];
  List<int> selectedItems = [];
  List<ServiceData> selectedServicesList = [];

  bool isUpdate = false;
  bool isLoading = false;
  bool? res;

  String date = DateTime.now().getFormattedDate(CONVERT_DATE);
  String serviceData = "";

  int? serviceDataId;
  int doctorDataId = -1;
  int selected = -1;
  int mainSelected = -1;

  String slot = "";

  DateTime? selectedDate;

  DoctorList? selectedDoctor;

  UpcomingAppointment? upcomingAppointment;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    multiSelectStore.clearList();
    isUpdate = widget.data != null;

    if (isUpdate) {
      upcomingAppointment = widget.data;

      if (upcomingAppointment!.visit_type != null) {
        upcomingAppointment!.visit_type!.forEach((element) {
          multiSelectStore.selectedService.add(ServiceData(id: element.id, name: element.service_name, service_id: element.service_id));
        });
        servicesCont.text = "${multiSelectStore.selectedService.length} " + languageTranslate('lblServicesSelected');
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
    } else {
      appointmentAppStore.setSelectedAppointmentDate(DateTime.now());
    }
    if (widget.id != null) {
      doctorDataId = widget.id.validate();
    }

    await getConfiguration().catchError(log);

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setDynamicStatusBarColor(color: scaffoldBgColor);
    appointmentAppStore.setSelectedClinic(null);
    appointmentAppStore.setSelectedDoctor(null);
    appointmentAppStore.setDescription(null);
    appointmentAppStore.setSelectedPatient(null);
    appointmentAppStore.setSelectedTime(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
        appBar: appAppBar(context, name: languageTranslate('lblStep1')),
        body: body(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.arrow_forward_outlined, color: textPrimaryWhiteColor),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();

              DoctorAddAppointmentStep2Screen(updatedData: upcomingAppointment).launch(context);
            }
          },
        ),
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 16),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AbsorbPointer(
              absorbing: isUpdate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isProEnabled()
                      ? ClinicDropDown(
                          isValidate: true,
                          clinicId: upcomingAppointment?.clinic_id?.toInt(),
                          onSelected: (Clinic? value) {
                            appointmentAppStore.setSelectedClinic(value);
                          },
                        ).paddingSymmetric(vertical: 8, horizontal: 16)
                      : Offstage(),
                  8.height,
                  AppTextField(
                    controller: servicesCont,
                    textFieldType: TextFieldType.ADDRESS,
                    decoration: textInputStyle(
                      context: context,
                      label: 'lblSelectServices',
                      isMandatory: true,
                      suffixIcon: commonImage(
                        imageUrl: "images/icons/arrowDown.png",
                        size: 10,
                      ),
                    ),
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
                          ids.clear();
                          if (multiSelectStore.selectedService.validate().isNotEmpty) {
                            multiSelectStore.selectedService.forEach((element) async {
                              ids.add(element.id);
                            });
                          }
                        } else {
                          toast("in");
                          ids.clear();
                          if (multiSelectStore.selectedService.validate().isNotEmpty) {
                            multiSelectStore.selectedService.forEach((element) async {
                              ids.add(element.service_id);
                            });
                          }
                        }

                        res = await MultiSelectWidget(selectedServicesId: ids).launch(context);

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
                  Observer(
                    builder: (_) {
                      return Wrap(
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
                      );
                    },
                  ).paddingSymmetric(vertical: 8, horizontal: 16),
                ],
              ),
            ),
            8.height,
            isUpdate
                ? DDateComponent(
                    initialDate: DateTime.parse(upcomingAppointment!.appointment_start_date.validate()),
                  )
                : DDateComponent(),
            24.height,
            isUpdate
                ? AppointmentSlots(
                    doctorId: upcomingAppointment!.doctor_id.toInt(),
                    appointmentTime: DateFormat(DATE_FORMAT).parse(upcomingAppointment!.appointment_start_time.validate()).getFormattedDate(FORMAT_12_HOUR),
                  ).paddingSymmetric(horizontal: 16)
                : AppointmentSlots().paddingSymmetric(horizontal: 16),
            50.height,
          ],
        ),
      ),
    );
  }
}
