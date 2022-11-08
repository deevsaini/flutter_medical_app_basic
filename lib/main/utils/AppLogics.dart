import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

void getPatient() {
  getPatientList().then((value) {
    listAppStore.addPatient(value.patientData.validate());
  }).catchError((e) {
    errorToast(e.toString());
  });
}

Future<void> getDoctor({int? clinicId}) async {
  await getDoctorList(clinicId: clinicId).then((value) {
    listAppStore.addDoctor(value.doctorList.validate());
  }).catchError((e) {
    toast(e.toString());
  });
}

void getSpecialization() {
  getStaticDataResponse(SPECIALIZATION.toLowerCase()).then((value) {
    listAppStore.addSpecialization(value.staticData.validate());
  }).catchError((e) {
    errorToast(e.toString());
  });
}

Future<void> getServices() async {
  getStaticDataResponse(SERVICE_TYPE).then((value) {
    listAppStore.addServices(value.staticData.validate(), isClear: true);
  }).catchError((e) {
    errorToast(e.toString());
  });
}

Future<void> getClinc() async {
  getClinicList(page: null).then((value) {
    listAppStore.addClinic(value.clinicData.validate(), isClear: true);
  }).catchError((e) {
    errorToast(e.toString());
  });
}

List<String> getImages() {
  List<String> images = [];

  for (int i = 1; i < 6; i++) {
    images.add("images/doctorAvatars/doctor$i.png");
  }
  return images;
}

List<String> getPatientImages() {
  List<String> images = [];

  for (int i = 1; i < 6; i++) {
    images.add("images/patientAvatars/patient$i.png");
  }
  return images;
}

List<String> getServicesImages() {
  List<String> images = [];

  for (int i = 1; i < 6; i++) {
    images.add("images/servicesicon/services$i.png");
  }
  return images;
}

bool get isRTL => RTLLanguage.contains(appStore.selectedLanguage);
