import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/appointment/component/DConfirmAppointmentScreen.dart';
import 'package:kivicare_flutter/doctor/screens/appointment/component/DFileUploadComponent.dart';
import 'package:kivicare_flutter/doctor/screens/appointment/component/DPatientSelectComponent.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/model/PatientListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorAddAppointmentStep2Screen extends StatefulWidget {
  final UpcomingAppointment? updatedData;

  DoctorAddAppointmentStep2Screen({this.updatedData});

  @override
  _DoctorAddAppointmentStep2ScreenState createState() => _DoctorAddAppointmentStep2ScreenState();
}

class _DoctorAddAppointmentStep2ScreenState extends State<DoctorAddAppointmentStep2Screen> {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer<PatientListModel> _memorizer = AsyncMemoizer();

  List<String> statusList = ['${languageTranslate("lblBooked")}', '${languageTranslate("lblCheckOut")}', '${languageTranslate("lblCheckIn")}', '${languageTranslate("lblCancelled")}'];
  List<String?> pName = [];
  List<PatientData> list = [];

  bool isLoading = false;
  bool isUpdate = false;

  String? statusCont = languageTranslate("lblBooked");

  TextEditingController descriptionCont = TextEditingController();
  TextEditingController patientNameCont = TextEditingController();
  TextEditingController patientIdCont = TextEditingController();

  Map<String, dynamic> request = {};

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    int? id = statusCont!.getStatus();
    appointmentAppStore.setStatusSelected(id);
    isUpdate = widget.updatedData != null;
    if (isUpdate) {
      appointmentAppStore.setSelectedDoctor(listAppStore.doctorList.firstWhereOrNull((element) => element!.iD == widget.updatedData!.doctor_id.toInt()));
      appointmentAppStore.setSelectedPatient(widget.updatedData!.patient_name);
      appointmentAppStore.setSelectedPatientId(widget.updatedData!.patient_id.toInt());
      patientNameCont.text = widget.updatedData!.patient_name!;
      patientIdCont.text = widget.updatedData!.patient_id!;
      descriptionCont.text = widget.updatedData!.description.validate();
    }
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : primaryColor, statusBarIconBrightness: Brightness.light);

    descriptionCont.dispose();
    patientNameCont.dispose();
    patientIdCont.dispose();
    super.dispose();
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: Column(
          children: [
            DFileUploadComponent(),
            16.height,
            AbsorbPointer(
              absorbing: isUpdate,
              child: Column(
                children: [
                  FutureBuilder<PatientListModel>(
                    future: _memorizer.runOnce(() => getPatientList()),
                    builder: (_, snap) {
                      if (snap.hasData) {
                        pName.clear();

                        snap.data!.patientData!.forEach((element) {
                          pName.add(element.display_name);
                        });
                        return AppTextField(
                          controller: patientNameCont,
                          textFieldType: TextFieldType.OTHER,
                          validator: (s) {
                            if (s!.trim().isEmpty) return languageTranslate('lblPatientNameIsRequired');
                            return null;
                          },
                          decoration: textInputStyle(
                            context: context,
                            label: 'lblPatientName',
                            isMandatory: true,
                            suffixIcon: commonImage(
                              imageUrl: "images/icons/user.png",
                              size: 10,
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            String? value = await DPatientSelectScreen(searchList: pName, name: languageTranslate('lblPatientName')).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                            if (value == null) {
                              patientNameCont.clear();
                            } else {
                              list = snap.data!.patientData!.where((element) {
                                return element.display_name == value;
                              }).toList();
                              appointmentAppStore.setSelectedPatient(value);
                              patientNameCont.text = value;
                              patientIdCont.text = list[0].iD.toString();

                              appointmentAppStore.setSelectedPatientId(patientIdCont.text.toInt());
                            }
                            return;
                          },
                        );
                      }

                      return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
                    },
                  ),
                  16.height,
                  DropdownButtonFormField(
                    decoration: textInputStyle(
                      context: context,
                      label: 'lblStatus',
                      isMandatory: true,
                      suffixIcon: commonImage(
                        imageUrl: "images/icons/arrowDown.png",
                        size: 10,
                      ),
                    ),
                    icon: SizedBox.shrink(),
                    isExpanded: true,
                    dropdownColor: Theme.of(context).cardColor,
                    value: statusCont,
                    onChanged: (dynamic value) {
                      statusCont = value;
                      int? id = statusCont!.getStatus();
                      appointmentAppStore.setStatusSelected(id);
                      setState(() {});
                    },
                    items: statusList
                        .map(
                          (data) => DropdownMenuItem(
                            value: data,
                            child: Text("$data", style: primaryTextStyle()),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            16.height,
            AppTextField(
              maxLines: 10,
              minLines: 5,
              controller: descriptionCont,
              textAlign: TextAlign.start,
              textFieldType: TextFieldType.ADDRESS,
              decoration: textInputStyle(
                context: context,
                label: 'lblDescription',
                suffixIcon: commonImage(
                  imageUrl: "images/icons/description.png",
                  size: 10,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor,
        appBar: appAppBar(context, name: languageTranslate('lblStep2')),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.done, color: textPrimaryWhiteColor),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              appointmentAppStore.setDescription(descriptionCont.text.trim());
              hideKeyboard(context);
              await showInDialog(
                context,
                barrierDismissible: false,
                backgroundColor: Theme.of(context).cardColor,
                builder: (p0) {
                  return isUpdate ? DConfirmAppointmentScreen(appointmentId: widget.updatedData?.id.toInt()) : DConfirmAppointmentScreen();
                },
              );
            }
          },
        ),
      ),
    );
  }
}
