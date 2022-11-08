import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/model/ServiceModel.dart';
import 'package:kivicare_flutter/main/model/StaticDataModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/receiptionist/components/MultiSelectDoctorDropDown.dart';
import 'package:nb_utils/nb_utils.dart';

class AddServiceScreen extends StatefulWidget {
  final ServiceData? serviceData;

  AddServiceScreen({this.serviceData});

  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer<StaticDataModel> _memorizer = AsyncMemoizer();

  ServiceData? serviceData;

  bool isLoading = false;
  bool isUpdate = false;
  bool mIsAllSelected = false;

  StaticData? category;

  List<StaticData> servicesList = [];

  List<int> selectedItems = [];
  List<DoctorList?> selectedDoctorList = [];

  TextEditingController serviceNameCont = TextEditingController();
  TextEditingController serviceChargesCont = TextEditingController();
  TextEditingController doctorCont = TextEditingController();
  int? serviceStatus = 1;

  FocusNode serviceCategoryFocus = FocusNode();
  FocusNode serviceNameFocus = FocusNode();
  FocusNode serviceChargesFocus = FocusNode();
  FocusNode serviceStatusFocus = FocusNode();

  List<int?> selectedDoctorId = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  deleteServices() async {
    isLoading = true;
    setState(() {});

    Map<String, dynamic> request = {};

    request = {
      "id": serviceData!.id,
      "doctor_id": serviceData!.doctor_id,
    };

    request.putIfAbsent("service_mapping_id", () => widget.serviceData!.mapping_table_id);

    deleteServiceData(request).then((value) {
      successToast('${value['message']}');
      finish(context, true);
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      isLoading = false;
      setState(() {});
    });
  }

  insertServices() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});

      Map request = {};

      if (isReceptionist()) {
        request = {
          "type": category!.value,
          "charges": serviceChargesCont.text,
          "name": serviceNameCont.text,
          "clinic_id": getIntAsync(USER_CLINIC),
          "doctor_id": appointmentAppStore.selectedDoctor,
          "status": serviceStatus,
        };
      } else {
        request = {
          "type": category!.value,
          "charges": serviceChargesCont.text,
          "name": serviceNameCont.text,
          "clinic_id": getIntAsync(USER_CLINIC),
          "status": serviceStatus,
          "doctor_id": [getIntAsync(USER_ID)],
        };
      }

      addServiceData(request).then((value) {
        successToast('${value['message']}');
        finish(context, true);
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }

  updateServices() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      isLoading = true;
      setState(() {});

      Map<String, dynamic> request = {};

      if (isReceptionist()) {
        request = {
          "id": serviceData!.id,
          "type": category!.value,
          "charges": serviceChargesCont.text,
          "name": serviceNameCont.text,
          "clinic_id": getIntAsync(USER_CLINIC),
          "doctor_id": [serviceData!.doctor_id],
          "status": serviceStatus,
        };
      } else {
        request = {
          "id": serviceData!.id,
          "type": category!.value,
          "charges": serviceChargesCont.text,
          "name": serviceNameCont.text,
          "clinic_id": getIntAsync(USER_CLINIC),
          "status": serviceStatus,
          "doctor_id": [getIntAsync(USER_ID)],
        };
      }

      request.putIfAbsent("service_mapping_id", () => widget.serviceData!.mapping_table_id);

      addServiceData(request).then((value) {
        successToast('${value['message']}');
        finish(context, true);
      }).catchError((e) {
        errorToast(e.toString());
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor, statusBarIconBrightness: Brightness.light);

    isUpdate = widget.serviceData != null;
    if (isUpdate) {
      serviceData = widget.serviceData;
      serviceNameCont.text = serviceData!.name!;
      serviceChargesCont.text = serviceData!.charges!;
      serviceStatus = serviceData!.status.toInt();

      listAppStore.doctorList.forEach((element) {
        if (element!.iD!.toInt() == serviceData!.doctor_id.toInt()) {
          selectedDoctorId.add(element.iD);
          selectedDoctorList.add(element);
        }
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor, statusBarIconBrightness: Brightness.light);

    serviceNameCont.dispose();
    serviceChargesCont.dispose();
    doctorCont.dispose();

    serviceCategoryFocus.dispose();
    serviceNameFocus.dispose();
    serviceChargesFocus.dispose();
    serviceStatusFocus.dispose();
    super.dispose();
  }

  Widget body() {
    return FutureBuilder<StaticDataModel?>(
      future: _memorizer.runOnce(() => getStaticDataResponse(SERVICE_TYPE)),
      builder: (_, snap) {
        if (snap.hasData) {
          if (isUpdate) {
            category = snap.data!.staticData!.firstWhereOrNull((element) => element!.value == serviceData!.type);
          }
          // if (servicesList.isEmpty) {
          //   servicesList.addAll(snap.data.staticData);
          // }
          return Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<StaticData>(
                    focusNode: serviceCategoryFocus,
                    icon: SizedBox.shrink(),
                    dropdownColor: Theme.of(context).cardColor,
                    decoration: textInputStyle(
                      context: context,
                      label: 'lblCategory',
                      suffixIcon: commonImage(
                        imageUrl: "images/icons/arrowDown.png",
                        size: 10,
                      ),
                    ),
                    isExpanded: true,
                    validator: (s) {
                      if (s == null) return languageTranslate('lblServiceCategoryIsRequired');
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    value: category,
                    onChanged: !isUpdate
                        ? (value) {
                            category = value;
                          }
                        : null,
                    items: snap.data!.staticData!.map<DropdownMenuItem<StaticData>>((value) {
                      return DropdownMenuItem<StaticData>(
                        value: value,
                        child: Text(value!.label!, style: primaryTextStyle()),
                      );
                    }).toList(),
                  ),
                  16.height,
                  AppTextField(
                    focus: serviceNameFocus,
                    nextFocus: serviceChargesFocus,
                    controller: serviceNameCont,
                    errorThisFieldRequired: languageTranslate('lblServiceNameIsRequired'),
                    textFieldType: TextFieldType.NAME,
                    textAlign: TextAlign.justify,
                    decoration: textInputStyle(
                      context: context,
                      label: 'lblName',
                      suffixIcon: commonImage(
                        imageUrl: "images/icons/user.png",
                        size: 10,
                      ),
                    ),
                  ),
                  16.height,
                  AppTextField(
                    focus: serviceChargesFocus,
                    nextFocus: serviceStatusFocus,
                    controller: serviceChargesCont,
                    errorThisFieldRequired: languageTranslate('lblServiceChargesIsRequired'),
                    textFieldType: TextFieldType.NAME,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.justify,
                    decoration: textInputStyle(
                      context: context,
                      label: 'lblCharges',
                      suffixIcon: commonImage(
                        imageUrl: "images/icons/dollarIcon.png",
                        size: 10,
                      ),
                    ),
                  ),
                  16.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: doctorCont,
                        textFieldType: TextFieldType.OTHER,
                        decoration: textInputStyle(context: context, label: 'lblSelectDoctor').copyWith(
                          alignLabelWithHint: true,
                        ),
                        readOnly: true,
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            enableDrag: true,
                            builder: (BuildContext context) {
                              List<String> ids = [];
                              if (selectedDoctorList.validate().isNotEmpty) {
                                selectedDoctorList.forEach((element) {
                                  ids.add(element!.iD.toString());
                                });
                              }

                              return MultiSelectDoctorDropDown(selectedServicesId: ids);
                            },
                          ).then((value) {
                            if (selectedDoctorList.isNotEmpty) {
                              selectedDoctorList.clear();
                              selectedDoctorList.addAll(value);
                              List<int> temp = [];
                              selectedDoctorList.forEach((element) {
                                temp.add(element!.iD!.toInt());
                              });
                              appointmentAppStore.addSelectedDoctor(temp);
                              return;
                            } else {
                              selectedDoctorList.addAll(value);
                              List<int?> temp = [];
                              selectedDoctorList.forEach((element) {
                                temp.add(element!.iD);
                              });
                              appointmentAppStore.addSelectedDoctor(temp);
                              return;
                            }
                          });
                          setState(() {});
                        },
                      ),
                      16.height,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          selectedDoctorList.length.toString().isEmpty ? 0 : selectedDoctorList.length,
                          (index) {
                            DoctorList data = selectedDoctorList[index]!;
                            return Chip(
                              backgroundColor: context.cardColor,
                              shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
                              label: Text('${data.display_name}', style: primaryTextStyle(color: context.iconColor)),
                              avatar: Icon(CupertinoIcons.person, size: 16, color: context.iconColor),
                            );
                          },
                        ),
                      ),
                      16.height,
                    ],
                  ).visible(!isDoctor()),
                  DropdownButtonFormField<int>(
                    value: serviceStatus,
                    focusNode: serviceStatusFocus,
                    icon: SizedBox.shrink(),
                    dropdownColor: Theme.of(context).cardColor,
                    decoration: textInputStyle(
                      context: context,
                      label: 'lblStatus',
                      suffixIcon: commonImage(
                        imageUrl: "images/icons/arrowDown.png",
                        size: 10,
                      ),
                    ),
                    isExpanded: true,
                    validator: (s) {
                      if (s == null) return languageTranslate('lblStatusIsRequired');
                      return null;
                    },
                    items: [0, 1]
                        .map(
                          (e) => DropdownMenuItem<int>(
                            child: Text(e == 0 ? languageTranslate('lblInActive') : languageTranslate('lblActive'), style: primaryTextStyle()),
                            value: e,
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      serviceStatus = value;
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(
          context,
          name: !isUpdate ? languageTranslate('lblAddService') : languageTranslate('lblEditService'),
          actions: !isUpdate
              ? []
              : [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool? res = await showConfirmDialog(context, languageTranslate('lblAreYouSure'), buttonColor: primaryColor);
                      if (res ?? false) {
                        deleteServices();
                      }
                    },
                  ),
                ],
        ),
        body: body().visible(!isLoading, defaultWidget: setLoader()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            isUpdate ? updateServices() : insertServices();
          },
          child: Icon(Icons.done, color: Colors.white),
        ),
      ),
    );
  }
}
