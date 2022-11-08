import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/doctor/screens/appointment/component/DFileUploadComponent.dart';
import 'package:kivicare_flutter/doctor/screens/appointment/component/DPatientSelectComponent.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/model/PatientListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/receiptionist/screens/appointment/component/RConfirmAppointmentScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class RAppointmentScreen2 extends StatefulWidget {
  final UpcomingAppointment? updatedData;

  RAppointmentScreen2({this.updatedData});

  @override
  _RAppointmentScreen2State createState() => _RAppointmentScreen2State();
}

class _RAppointmentScreen2State extends State<RAppointmentScreen2> {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer<PatientListModel> _memorizer = AsyncMemoizer();

  List<String> statusList = [languageTranslate("lblBooked"), languageTranslate("lblCheckOut"), languageTranslate("lblCheckIn"), languageTranslate("lblCancelled")];
  List<String?> pName = [];

  bool isLoading = false;
  bool isUpdate = false;

  String? statusCont = languageTranslate("lblBooked");
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController patientNameCont = TextEditingController();
  TextEditingController patientIdCont = TextEditingController();
  Map<String, dynamic> request = {};
  List<PatientData> list = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    int? id = statusCont!.getStatus();
    appointmentAppStore.setStatusSelected(id);
    isUpdate = widget.updatedData != null;
    if (isUpdate) {
      appointmentAppStore.setSelectedDoctor(listAppStore.doctorList.firstWhereOrNull(
        (element) => element!.iD == widget.updatedData!.doctor_id.toInt(),
      ));
      appointmentAppStore.setSelectedPatient(widget.updatedData!.patient_name);
      appointmentAppStore.setSelectedPatientId(widget.updatedData!.patient_id.toInt());
      patientNameCont.text = widget.updatedData!.patient_name!;
      patientIdCont.text = widget.updatedData!.patient_id!;
      descriptionCont.text = widget.updatedData!.description.validate();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    descriptionCont.dispose();
    patientNameCont.dispose();
    patientIdCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblStep2')),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(Icons.done, color: textPrimaryWhiteColor),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              appointmentAppStore.setDescription(descriptionCont.text);
              hideKeyboard(context);
              await showInDialog(
                context,
                barrierDismissible: false,
                backgroundColor: Theme.of(context).cardColor,
                builder: (p0) {
                  return isUpdate ? RConfirmAppointmentScreen(appointmentId: widget.updatedData?.id.toInt()) : RConfirmAppointmentScreen();
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget body() {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DFileUploadComponent(),
            16.height,
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
                    decoration: textInputStyle(context: context, label: 'lblPatientName', isMandatory: true),
                    readOnly: true,
                    onTap: () async {
                      String? name = await DPatientSelectScreen(searchList: pName, name: languageTranslate('lblPatientName')).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);

                      if (name == null) {
                        patientNameCont.clear();
                      } else {
                        list = snap.data!.patientData!.where((element) {
                          return element.display_name == name;
                        }).toList();
                        appointmentAppStore.setSelectedPatient(name);
                        patientNameCont.text = name;
                        patientIdCont.text = list[0].iD.toString();

                        appointmentAppStore.setSelectedPatientId(patientIdCont.text.toInt());
                      }
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
                suffixIcon: commonImage(imageUrl: "images/icons/arrowDown.png", size: 10),
              ),
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              value: statusCont,
              icon: SizedBox.shrink(),
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
            16.height,
            AppTextField(
              maxLines: 10,
              minLines: 5,
              controller: descriptionCont,
              textAlign: TextAlign.start,
              textFieldType: TextFieldType.ADDRESS,
              decoration: textInputStyle(context: context, label: 'lblDescription'),
            )
          ],
        ),
      ),
    );
  }
}
