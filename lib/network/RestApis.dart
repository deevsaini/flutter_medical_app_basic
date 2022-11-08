import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/AppoinmentModel.dart';
import 'package:kivicare_flutter/main/model/AppointmentSlotModel.dart';
import 'package:kivicare_flutter/main/model/BaseResponse.dart';
import 'package:kivicare_flutter/main/model/ClinicListModel.dart';
import 'package:kivicare_flutter/main/model/ConfirmAppointmentResponseModel.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/DoctorScheduleModel.dart';
import 'package:kivicare_flutter/main/model/EncounterDashboardModel.dart';
import 'package:kivicare_flutter/main/model/GetDoctorDetailModel.dart';
import 'package:kivicare_flutter/main/model/GetUserDetailModel.dart';
import 'package:kivicare_flutter/main/model/HolidayModel.dart';
import 'package:kivicare_flutter/main/model/LoginResponseModel.dart';
import 'package:kivicare_flutter/main/model/MedicalHistroyModel.dart';
import 'package:kivicare_flutter/main/model/PatientBillModel.dart';
import 'package:kivicare_flutter/main/model/PatientDashboardModel.dart';
import 'package:kivicare_flutter/main/model/PatientEncounterListModel.dart';
import 'package:kivicare_flutter/main/model/PatientListModel.dart';
import 'package:kivicare_flutter/main/model/PrescriptionModel.dart';
import 'package:kivicare_flutter/main/model/ReportModel.dart';
import 'package:kivicare_flutter/main/model/ResponseModel.dart';
import 'package:kivicare_flutter/main/model/SendPrescriptionMail.dart';
import 'package:kivicare_flutter/main/model/ServiceModel.dart';
import 'package:kivicare_flutter/main/model/StaticDataModel.dart';
import 'package:kivicare_flutter/main/model/TelemedModel.dart';
import 'package:kivicare_flutter/main/model/TelemedStatusChanged.dart';
import 'package:kivicare_flutter/main/model/UserConfiguration.dart';
import 'package:kivicare_flutter/main/screens/SignInScreen.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/network/NetworkUtils.dart';
import 'package:kivicare_flutter/patient/model/NewsModel.dart';
import 'package:kivicare_flutter/patient/model/PatientEncounterDashboardModel.dart';
import 'package:kivicare_flutter/patient/model/PatientEncounterModel.dart';
import 'package:nb_utils/nb_utils.dart';

Future<LoginResponseModel> login(Map req) async {
  LoginResponseModel value = LoginResponseModel.fromJson(await (handleResponse(await buildHttpResponse('jwt-auth/v1/token', request: req, method: HttpMethod.POST))));

  setValue(TOKEN, value.token!);
  if (value.clinic!.isNotEmpty) {
    appStore.setCurrency(value.clinic!.first.extra!.currency_prefix.validate(), initiliaze: true);
    setValue(USER_CLINIC, value.clinic!.first.clinic_id.toInt());
  }
  setValue(PASSWORD, req['password']);
  setValue(USER_LOGIN, value.user_nicename!.validate());
  setValue(USER_DATA, jsonEncode(value));
  setValue(USER_ENCOUNTER_MODULES, jsonEncode(value.enocunter_modules));
  setValue(USER_PRESCRIPTION_MODULE, jsonEncode(value.prescription_module));
  setValue(USER_MODULE_CONFIG, jsonEncode(value.module_config));

  appStore.setLoggedIn(true);
  appStore.setUserEmail(value.user_email.validate(), initiliaze: true);
  appStore.setUserProfile(value.profile_image.validate(), initiliaze: true);
  appStore.setUserId(value.user_id.validate(), initiliaze: true);
  appStore.setFirstName(value.first_name.validate(), initiliaze: true);
  appStore.setLastName(value.last_name.validate(), initiliaze: true);
  appStore.setRole(value.role.validate(), initiliaze: true);
  appStore.setUserDisplayName(value.user_display_name.validate(), initiliaze: true);
  appStore.setUserMobileNumber(value.mobile_number.validate(), initiliaze: true);
  appStore.setUserGender(value.gender.validate(), initiliaze: true);
  appStore.setUserProEnabled(value.isKiviCareProOnName.validate(), initiliaze: true);
  appStore.setUserTelemedOn(value.isTeleMedActive.validate(), initiliaze: true);
  appStore.setUserEnableGoogleCal(value.is_enable_google_cal.validate(), initiliaze: true);
  appStore.setUserDoctorGoogleCal(value.is_enable_doctor_gcal.validate(), initiliaze: true);

  return value;
}

// /kivicare/api/v1/doctor/get-zoom-configuration
Future<GetDoctorDetailModel> getUserProfile(int? id) async {
  return GetDoctorDetailModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/user/get-detail?ID=$id'))));
}

Future<NewsModel> getNewsList() async {
  return NewsModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/news/get-news-list'))));
}

Future<ClinicListModel> getClinicList({int? page}) async {
  return ClinicListModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/clinic/get-list?page=${page != null ? page : ''}'))));
}

//region Google Calender
Future<ResponseModel> connectGoogleCalendar({required Map<String, dynamic> request}) async {
  return ResponseModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/google-calendar/connect-doctor', request: request, method: HttpMethod.POST))));
}

Future<ResponseModel> disconnectGoogleCalendar() async {
  return ResponseModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/google-calendar/disconnect-doctor'))));
}

//region Google Calender
Future<ResponseModel> connectMeet({required Map<String, dynamic> request}) async {
  return ResponseModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/connect-googlemeet-doctor', request: request, method: HttpMethod.POST))));
}

Future<ResponseModel> disconnectMeet({required Map<String, dynamic> request}) async {
  return ResponseModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/disconnect-googlemeet-doctor', request: request, method: HttpMethod.POST))));
}

Future<UserConfiguration> getConfiguration() async {
  UserConfiguration value = UserConfiguration.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/user/get-configuration'))));

  appStore.setUserProEnabled(value.isKiviCareProOnName.validate(), initiliaze: true);
  appStore.setUserTelemedOn(value.isTeleMedActive.validate(), initiliaze: true);
  appStore.setUserMeetService(value.isKiviCareGooglemeetActive.validate(), initiliaze: true);
  appStore.setUserEnableGoogleCal(value.is_enable_google_cal.validate(), initiliaze: true);
  appStore.setUserDoctorGoogleCal(value.is_enable_doctor_gcal.validate(), initiliaze: true);
  appStore.setTelemedType(value.telemed_type.validate(), initiliaze: true);
  appStore.setRestrictAppointmentPost(value.restrict_appointment!.post!.validate().toInt(), initiliaze: true);
  appStore.setRestrictAppointmentPre(value.restrict_appointment!.pre!.validate().toInt(), initiliaze: true);
  return value;
}

//endregion

//Encounter Details API
Future<MedicalHistoryModel> getMedicalHistoryResponse(int id, String type) async {
  MedicalHistoryModel value = MedicalHistoryModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/encounter/get-medical-history?encounter_id=$id&type=$type'))));
  return value;
}

Future<EncounterType> saveMedicalHistoryData(Map request) async {
  return EncounterType.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/patient/save-medical-history', request: request, method: HttpMethod.POST))));
}

Future<EncounterType> deleteMedicalHistoryData(Map request) async {
  return EncounterType.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/patient/delete-medical-history', request: request, method: HttpMethod.POST))));
}

Future<TelemedStatus> changeTelemedType({required Map<String, dynamic> request}) async {
  return TelemedStatus.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/user/change-telemed-type', request: request, method: HttpMethod.POST))));
}

//End of Encounter Details API

//Prescription List
Future<PrescriptionModel> getPrescriptionResponse(String id) async {
  return PrescriptionModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/prescription/list?encounter_id=$id'))));
}

Future<PrescriptionData> savePrescriptionData(Map request) async {
  return PrescriptionData.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/prescription/save', request: request, method: HttpMethod.POST))));
}

Future<PrescriptionData> deletePrescriptionData(Map request) async {
  return PrescriptionData.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/prescription/delete', request: request, method: HttpMethod.POST))));
}

Future deleteDoctor(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/delete-doctor', request: request, method: HttpMethod.POST));
}
// End Prescription

//view Profile
Future<LoginResponseModel> viewUserProfile(int id) async {
  return LoginResponseModel.fromJson(await (handleResponse(await buildHttpResponse('/kivicare/api/v1/user/get-detail?id=$id'))));
}

//Get APis
Future<DoctorDashboardModel> getDoctorDashBoard() async {
  return DoctorDashboardModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/user/get-dashboard?page=1&limit=5'))));
}

Future<PatientDashboardModel> getPatientDashBoard() async {
  return PatientDashboardModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/user/get-dashboard?page=1&limit=5'))));
}

Future<EncounterDashboardModel> getEncounterDetailsDashBoard(int id) async {
  return EncounterDashboardModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/encounter/get-encounter-detail?id=$id'))));
}

Future<PatientEncounterDashboardModel> getPatientEncounterDetailsDashBoard(int id) async {
  return PatientEncounterDashboardModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/encounter/get-encounter-detail?id=$id'))));
}

Future<StaticDataModel> getStaticDataResponse(String req) async {
  return StaticDataModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/staticdata/get-list?type=$req'))));
}

Future changePassword(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/user/change-password', request: request, method: HttpMethod.POST));
}

//Start Service API
Future<ServiceListModel> getServiceResponse({int? id, int? page}) async {
  return ServiceListModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/service/get-list?page=$page&limit=$PER_PAGE&doctor_id=${id != null ? id : ''}'))));
}

Future addServiceData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/service/add-service', request: request, method: HttpMethod.POST));
}

Future deleteServiceData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/service/delete-service', request: request, method: HttpMethod.POST));
}
//End Service API

//Start Holidays API
Future<HolidayModel> getHolidayResponse() async {
  return HolidayModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/setting/clinic-schedule-list'))));
}

Future addHolidayData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/setting/save-clinic-schedule', request: request, method: HttpMethod.POST));
}

Future deleteHolidayData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/setting/delete-clinic-schedule', request: request, method: HttpMethod.POST));
}
//End Holidays API

// Start Encounter List

Future<PatientEncounterModel> getPatientAppointmentList({String? status, int? patientId}) async {
  PatientEncounterModel value = PatientEncounterModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/get-appointment?status=$status&patient_id=$patientId&page=1&limit=10'))));
  return value;
}

Future addEncounterData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/encounter/save', request: request, method: HttpMethod.POST));
}

// End Encounter List

Future<PatientListModel> getPatientList({int? page}) async {
  if (page == null) {
    return PatientListModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/patient/get-list?limit=-1'))));
  } else {
    return PatientListModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/patient/get-list?limit=$PER_PAGE&page=$page'))));
  }
}

Future<DoctorListModel> getDoctorList({int? page, int? clinicId}) async {
  int? id;
  if (isReceptionist()) {
    id = getIntAsync(USER_CLINIC);
  } else if (isDoctor() || isPatient()) {
    id = clinicId;
  }

  if (page == null) {
    return DoctorListModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/get-list?clinic_id=${id != null ? id : ''}&limit=-1'))));
  } else {
    return DoctorListModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/get-list?clinic_id=${id != null ? id : ''}&limit=$PER_PAGE&page=$page'))));
  }
}

//region Appointment

Future<AppointmentModel> getAppointmentData({bool isPast = false, String? todayDate, String? startDate, String? endDate, String status = "all", int? page}) async {
  AppointmentModel value;

  if (todayDate == null) {
    value = AppointmentModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/get-appointment?page=1&limit=10&start=$startDate&end=$endDate'))));
  } else {
    if (isPast) {
      value = AppointmentModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/get-appointment?status=$status&page=$page&limit=$PER_PAGE'))));
    } else {
      value = AppointmentModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/get-appointment?status=$status&page=$page&limit=$PER_PAGE&date=$todayDate'))));
    }
  }
  return value;
}

Future<SendPrescriptionMail> sendPrescriptionMail({required int encounterId}) async {
  return SendPrescriptionMail.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/prescription/prescription-mail', method: HttpMethod.POST, request: {"encounter_id": '$encounterId'}))));
}

Future<AppointmentModel> getAppointmentInCalender({String? todayDate, int? page}) async {
  AppointmentModel value;

  value = AppointmentModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/get-appointment?&page=$page&limit=$PER_PAGE&date=$todayDate'))));
  return value;
}

//region
Future<PatientBillModule> getBillDetails({int? encounterId}) async {
  return PatientBillModule.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/bill/bill-details?encounter_id=$encounterId'))));
}

Future addPatientBill(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/bill/add-bill', request: request, method: HttpMethod.POST));
}

//endregion

Future<List<List<AppointmentSlotModel>>> getAppointmentList({String? appointmentDate, int? id, int? clinicId}) async {
  Iterable it = await (handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/appointment-time-slot?clinic_id=$clinicId&date=$appointmentDate&doctor_id=${id != null ? id : ''}&appointment_id=')));

  List<List<AppointmentSlotModel>> list = [];

  it.forEach((element) {
    Iterable v = element;
    list.add(v.map((e) => AppointmentSlotModel.fromJson(e)).toList());
  });

  return list;
}

//Report
Future<ReportModel> getReportData({int? patientId}) async {
  return ReportModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/patient/get-patient-report?patient_id=$patientId&page=1&limit=10'))));
}

Future<bool> addReportData(Map data, {File? file, String? toastMessage}) async {
  var multiPartRequest = await getMultiPartRequest('kivicare/api/v1/patient/upload-patient-report');

  multiPartRequest.fields['name'] = data['name'];
  multiPartRequest.fields['patient_id'] = data['patient_id'];
  multiPartRequest.fields['date'] = data['date'];

  if (file != null) multiPartRequest.files.add(await MultipartFile.fromPath('upload_report', file.path));

  multiPartRequest.headers.addAll(buildHeaderTokens());

  Response response = await Response.fromStream(await multiPartRequest.send());

  if (response.statusCode.isSuccessful()) {
    successToast("Report added successfully");
    return true;
  } else {
    toast(errorSomethingWentWrong);
    return false;
  }
}

Future deleteReport(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/patient/delete-patient-report', request: request, method: HttpMethod.POST));
}
//End Report

//Telemed

Future addTelemedServices(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/save-zoom-configuration', request: request, method: HttpMethod.POST));
}

Future<TelemedModel> getTelemedServices() async {
  return TelemedModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/get-zoom-configuration'))));
}

//End Telemed

Future<ConfirmAppointmentResponseModel> addAppointmentData(Map request) async {
  return ConfirmAppointmentResponseModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/save', request: request, method: HttpMethod.POST))));
}

Future updateAppointmentStatus(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/update-status', request: request, method: HttpMethod.POST));
}

Future deleteAppointment(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/delete', request: request, method: HttpMethod.POST));
}

//endregion

//region Doctor Sessions
Future<DoctorSessionModel> getDoctorSessionData({int? clinicData}) async {
  return DoctorSessionModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/setting/get-doctor-clinic-session?clinic_id=${clinicData != null ? clinicData : ''}'))));
}

Future addDoctorSessionData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/setting/save-doctor-clinic-session', request: request, method: HttpMethod.POST));
}

Future deleteDoctorSessionData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/setting/delete-doctor-clinic-session', request: request, method: HttpMethod.POST));
}

//endregion

//Add patient

Future addNewPatientData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/auth/registration', request: request, method: HttpMethod.POST));
}

Future updatePatientData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/user/profile-update', request: request, method: HttpMethod.POST));
}

Future deletePatientData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/patient/delete-patient', request: request, method: HttpMethod.POST));
}

Future deleteEncounterData(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/encounter/delete', request: request, method: HttpMethod.POST));
}

// End Patient
Future<GetUserDetailModel> getUserDetails(int? id) async {
  return GetUserDetailModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/user/get-detail?ID=$id'))));
}

Future<PatientEncounterListModel> getPatientEncounterList(int? req, {int? page}) async {
  if (isReceptionist()) {
    return PatientEncounterListModel.fromJson(
      await (handleResponse(await buildHttpResponse('kivicare/api/v1/encounter/get-encounter-list?limit$PER_PAGE&page=$page'))),
    );
  } else {
    return PatientEncounterListModel.fromJson(
      await (handleResponse(await buildHttpResponse('kivicare/api/v1/encounter/get-encounter-list?limit$PER_PAGE&page=$page&patient_id=$req'))),
    );
  }
}

Future encounterClose(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/encounter/close', request: request, method: HttpMethod.POST));
}

Future validateToken() async {
  return await handleResponse(await buildHttpResponse('jwt-auth/v1/token/validate', request: {}, method: HttpMethod.POST));
}

//Post API Change

Future<void> logout(BuildContext context) async {
  await removeKey(TOKEN);
  await removeKey(USER_ID);
  await removeKey(FIRST_NAME);
  await removeKey(LAST_NAME);
  await removeKey(USER_EMAIL);
  await removeKey(USER_DISPLAY_NAME);
  await removeKey(PROFILE_IMAGE);
  await removeKey(USER_MOBILE);
  await removeKey(USER_GENDER);
  await removeKey(USER_ROLE);
  await removeKey(PASSWORD);

  appStore.setLoggedIn(false);
  push(SignInScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
}

Future<bool> updateProfile(Map data, {File? file, String? toastMessage}) async {
  var multiPartRequest = await getMultiPartRequest('kivicare/api/v1/user/profile-update');

  multiPartRequest.fields['ID'] = data['ID'];
  multiPartRequest.fields['user_email'] = data['user_email'];
  multiPartRequest.fields['user_login'] = data['user_login'];
  multiPartRequest.fields['first_name'] = data['first_name'];
  multiPartRequest.fields['last_name'] = data['last_name'];
  multiPartRequest.fields['gender'] = data['gender'];
  multiPartRequest.fields['dob'] = data['dob'];
  multiPartRequest.fields['address'] = data['address'];
  multiPartRequest.fields['city'] = data['city'];
  multiPartRequest.fields['state'] = data['state'];
  multiPartRequest.fields['country'] = data['country'];
  multiPartRequest.fields['postal_code'] = data['postal_code'];
  multiPartRequest.fields['mobile_number'] = data['mobile_number'];
  multiPartRequest.fields['qualifications'] = data['qualifications'];
  multiPartRequest.fields['specialties'] = data['specialties'];
  multiPartRequest.fields['price_type'] = data['price_type'];
  if (data['price_type'] == 'range') {
    multiPartRequest.fields['minPrice'] = data['minPrice'];
    multiPartRequest.fields['maxPrice'] = data['maxPrice'];
  } else {
    multiPartRequest.fields['price'] = data['price'];
  }
  multiPartRequest.fields['no_of_experience'] = data['no_of_experience'];

  if (file != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', file.path));

  multiPartRequest.headers.addAll(buildHeaderTokens());

  Response response = await Response.fromStream(await multiPartRequest.send());

  if (response.statusCode.isSuccessful()) {
    LoginResponseModel data = LoginResponseModel.fromJson(jsonDecode(response.body)['data']);
    setValue(FIRST_NAME, data.first_name.validate());
    setValue(LAST_NAME, data.last_name.validate());
    setValue(USER_DISPLAY_NAME, data.user_display_name.validate());

    appStore.setFirstName(data.first_name.validate());
    appStore.setLastName(data.last_name.validate());
    appStore.setUserDisplayName(data.user_display_name.validate());

    if (data.profile_image != null) {
      setValue(PROFILE_IMAGE, data.profile_image!);
      appStore.setUserProfile(data.profile_image.validate(), initiliaze: true);
    }
    toast(toastMessage ?? 'Profile updated successfully');

    return true;
  } else {
    toast(errorSomethingWentWrong);
    return false;
  }
}

Future<bool> addDoctor(Map data, {File? file, String? toastMessage}) async {
  var multiPartRequest = await getMultiPartRequest('kivicare/api/v1/doctor/add-doctor');

  multiPartRequest.fields['user_email'] = data['user_email'];
  multiPartRequest.fields['first_name'] = data['first_name'];
  multiPartRequest.fields['last_name'] = data['last_name'];
  multiPartRequest.fields['gender'] = data['gender'];
  multiPartRequest.fields['dob'] = data['dob'];
  multiPartRequest.fields['address'] = data['address'];
  multiPartRequest.fields['clinic_id'] = data['clinic_id'];
  multiPartRequest.fields['city'] = data['city'];
  multiPartRequest.fields['state'] = data['state'];
  multiPartRequest.fields['country'] = data['country'];
  multiPartRequest.fields['postal_code'] = data['postal_code'];
  multiPartRequest.fields['mobile_number'] = data['mobile_number'];
  multiPartRequest.fields['qualifications'] = data['qualifications'];
  multiPartRequest.fields['specialties'] = data['specialties'];
  multiPartRequest.fields['price_type'] = data['price_type'];
  if (data['price_type'] == 'range') {
    multiPartRequest.fields['minPrice'] = data['minPrice'];
    multiPartRequest.fields['maxPrice'] = data['maxPrice'];
  } else {
    multiPartRequest.fields['price'] = data['price'];
  }
  if (data['enableTeleMed'] == true) {
    multiPartRequest.fields['enableTeleMed'] = data['enableTeleMed'];
    multiPartRequest.fields['enableTeleMed'] = data['enableTeleMed'];
    multiPartRequest.fields['api_key'] = data['api_key'];
    multiPartRequest.fields['video_price'] = data['video_price'];
  }
  multiPartRequest.fields['no_of_experience'] = data['no_of_experience'];

  if (file != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', file.path));

  multiPartRequest.headers.addAll(buildHeaderTokens());

  Response response = await Response.fromStream(await multiPartRequest.send());

  if (response.statusCode.isSuccessful()) {
    toast(toastMessage ?? 'Doctor Added Successfully');

    return true;
  } else {
    toast(errorSomethingWentWrong);
    return false;
  }
}

Future<bool> updateReceptionistDoctor(Map data, {File? file, String? toastMessage}) async {
  var multiPartRequest = await getMultiPartRequest('kivicare/api/v1/doctor/add-doctor');

  multiPartRequest.fields['ID'] = data['ID'];
  multiPartRequest.fields['user_email'] = data['user_email'];
  multiPartRequest.fields['first_name'] = data['first_name'];
  multiPartRequest.fields['last_name'] = data['last_name'];
  multiPartRequest.fields['gender'] = data['gender'];
  multiPartRequest.fields['dob'] = data['dob'];
  multiPartRequest.fields['address'] = data['address'];
  multiPartRequest.fields['clinic_id'] = data['clinic_id'];
  multiPartRequest.fields['city'] = data['city'];
  multiPartRequest.fields['state'] = data['state'];
  multiPartRequest.fields['country'] = data['country'];
  multiPartRequest.fields['postal_code'] = data['postal_code'];
  multiPartRequest.fields['mobile_number'] = data['mobile_number'];
  multiPartRequest.fields['qualifications'] = data['qualifications'];
  multiPartRequest.fields['specialties'] = data['specialties'];
  multiPartRequest.fields['price_type'] = data['price_type'];
  if (data['price_type'] == 'range') {
    multiPartRequest.fields['minPrice'] = data['minPrice'];
    multiPartRequest.fields['maxPrice'] = data['maxPrice'];
  } else {
    multiPartRequest.fields['price'] = data['price'];
  }
  if (data['enableTeleMed'] == true) {
    multiPartRequest.fields['enableTeleMed'] = data['enableTeleMed'];
    multiPartRequest.fields['enableTeleMed'] = data['enableTeleMed'];
    multiPartRequest.fields['api_key'] = data['api_key'];
    multiPartRequest.fields['video_price'] = data['video_price'];
  }
  multiPartRequest.fields['no_of_experience'] = data['no_of_experience'];

  if (file != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', file.path));

  multiPartRequest.headers.addAll(buildHeaderTokens());

  Response response = await Response.fromStream(await multiPartRequest.send());

  if (response.statusCode.isSuccessful()) {
    toast(toastMessage ?? 'Doctor Updated Successfully');

    return true;
  } else {
    toast(errorSomethingWentWrong);
    return false;
  }
}

Future<bool> updatePatientProfile(Map data, {File? file, String? toastMessage}) async {
  var multiPartRequest = await getMultiPartRequest('kivicare/api/v1/user/profile-update');

  multiPartRequest.fields['ID'] = data['ID'];
  multiPartRequest.fields['user_email'] = data['user_email'];
  multiPartRequest.fields['user_login'] = getStringAsync(USER_LOGIN);
  multiPartRequest.fields['first_name'] = data['first_name'];
  multiPartRequest.fields['last_name'] = data['last_name'];
  multiPartRequest.fields['gender'] = data['gender'];
  multiPartRequest.fields['dob'] = data['dob'];
  multiPartRequest.fields['address'] = data['address'];
  multiPartRequest.fields['city'] = data['city'];
  multiPartRequest.fields['country'] = data['country'];
  multiPartRequest.fields['postal_code'] = data['postal_code'];
  multiPartRequest.fields['mobile_number'] = data['mobile_number'];

  if (file != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', file.path));

  multiPartRequest.headers.addAll(buildHeaderTokens());

  Response response = await Response.fromStream(await multiPartRequest.send());
  if (response.statusCode.isSuccessful()) {
    LoginResponseModel data = LoginResponseModel.fromJson(jsonDecode(response.body)['data']);
    appStore.setFirstName(data.first_name.validate());
    appStore.setLastName(data.last_name.validate());
    appStore.setUserMobileNumber(data.mobile_number.validate());

    if (data.profile_image != null) {
      appStore.setUserProfile(data.profile_image.validate(), initiliaze: true);
    }

    toast(toastMessage ?? 'Profile updated successfully');

    return true;
  } else {
    toast(errorSomethingWentWrong);
    return false;
  }
}

Future<BaseResponses> forgotPassword(Map<String, dynamic> request) async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse('kivicare/api/v1/user/forgot-password', request: request, method: HttpMethod.POST)));
}

class AppointmentRequest {
  Future<ConfirmAppointmentResponseModel?> addAppointment(Map<String, dynamic> data, {String? toastMessage}) async {
    var multiPartRequest = await getMultiPartRequest('kivicare/api/v2/appointment/save');

    multiPartRequest.fields['id'] = data['id'];
    multiPartRequest.fields['appointment_start_date'] = data['appointment_start_date'];
    multiPartRequest.fields['appointment_start_time'] = data['appointment_start_time'];
    multiPartRequest.fields['clinic_id'] = data['clinic_id'];
    multiPartRequest.fields['doctor_id'] = data['doctor_id'];
    multiPartRequest.fields['patient_id'] = data['patient_id'];
    multiPartRequest.fields['description'] = data['description'];
    multiPartRequest.fields['status'] = data['status'];

    if (appointmentAppStore.selectedService.isNotEmpty) {
      appointmentAppStore.selectedService.forEachIndexed((index, element) {
        multiPartRequest.fields["visit_type[$element]"] = data['visit_type[$element]'];
      });
    }

    if (appointmentAppStore.reportList.isNotEmpty) {
      multiPartRequest.fields['attachment_count'] = data['attachment_count'];

      await Future.forEach<PlatformFile>(appointmentAppStore.reportList, (element) async {
        multiPartRequest.files.add(await MultipartFile.fromPath('appointment_report_${appointmentAppStore.reportList.indexOf(element)}', File(element.path.validate()).path));
      });
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());

    return await Response.fromStream(await multiPartRequest.send()).then((value) {
      log("value ${value.body}");
      if (value.statusCode.isSuccessful()) {
        return ConfirmAppointmentResponseModel.fromJson(jsonDecode(value.body));
      } else {
        log(value.statusCode);
        toast(errorSomethingWentWrong);
      }
    });
    /* Response response = await Response.fromStream(await multiPartRequest.send());
    if (response.statusCode.isSuccessful()) {
      toast(toastMessage ?? 'Appointment Booked Successfully');

      return true;
    } else {
      log(response.statusCode);
      toast(errorSomethingWentWrong);
      return false;
    }*/
  }
}

AppointmentRequest appointmentRequest = AppointmentRequest();
