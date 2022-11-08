import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/ServiceModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class MultiSelectWidget extends StatefulWidget {
  final int? id;
  List<String?>? selectedServicesId;

  MultiSelectWidget({this.id, this.selectedServicesId});

  @override
  _MultiSelectWidgetState createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  TextEditingController search = TextEditingController();

  List<ServiceData> searchServicesList = [];

  List<ServiceData> servicesList = [];
  List<ServiceData> selectedServicesList = [];

  bool mIsLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : primaryColor, statusBarIconBrightness: Brightness.light);
    getData();
  }

  @override
  void dispose() {
    2.milliseconds.delay;
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : primaryColor, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  void getData() {
    mIsLoading = true;
    setState(() {});
    getServiceResponse(
      id: appointmentAppStore.mDoctorSelected != null ? appointmentAppStore.mDoctorSelected!.iD : getIntAsync(USER_ID),
      page: 1,
    ).then((value) {
      servicesList.addAll(value.serviceData!);
      searchServicesList.addAll(value.serviceData!);
      setState(() {});
      multiSelectStore.clearList();
      servicesList.forEach((element) {
        if (widget.selectedServicesId!.contains(element.id)) {
          multiSelectStore.addSingleItem(element, isClear: false);
          element.isCheck = true;
        }
      });
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      mIsLoading = false;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  List<ServiceData> getSelectedData() {
    List<ServiceData> selected = [];

    servicesList.forEach((value) {
      if (value.isCheck == true) {
        selected.add(value);
      }
    });
    setState(() {});
    return selected;
  }

  onSearchTextChanged(String text) async {
    servicesList.clear();

    if (text.isEmpty) {
      servicesList.addAll(searchServicesList);
      setState(() {});
      return;
    }
    searchServicesList.forEach((element) {
      if (element.name!.toLowerCase().contains(text)) servicesList.add(element);
    });
    setState(() {});
  }

  Widget floatingActionButton() {
    return FloatingActionButton(
      backgroundColor: primaryColor,
      child: Icon(Icons.done, color: Colors.white),
      onPressed: () {
        finish(context, selectedServicesList.isEmpty);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblServices')),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(languageTranslate('lblSelectServices'), style: boldTextStyle(size: 18)),
              Divider(),
              8.height,
              AppTextField(
                decoration: textInputStyle(context: context, label: 'lblSearch'),
                controller: search,
                onChanged: onSearchTextChanged,
                autoFocus: false,
                textInputAction: TextInputAction.go,
                textFieldType: TextFieldType.OTHER,
                suffix: Icon(
                  Icons.search,
                  size: 20,
                ),
              ),
              8.height,
              ListView.builder(
                itemCount: servicesList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  ServiceData data = servicesList[index];
                  return Theme(
                    data: ThemeData(
                      unselectedWidgetColor: primaryColor,
                    ),
                    child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.all(0),
                      value: data.isCheck,
                      onChanged: (v) {
                        data.isCheck = !data.isCheck;
                        if (v!) {
                          multiSelectStore.addSingleItem(data, isClear: false);
                          widget.selectedServicesId!.add(data.id);
                        } else {
                          multiSelectStore.removeItem(data);
                          widget.selectedServicesId!.remove(data.id);
                        }
                        setState(() {});
                      },
                      title: Text(
                        data.name.capitalizeFirstLetter().validate(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: primaryTextStyle(),
                      ),
                      secondary: Text(getStringAsync(CURRENCY) + "${data.charges.validate()}", style: boldTextStyle()),
                    ),
                  );
                },
              ).visible(!mIsLoading, defaultWidget: setLoader()),
            ],
          ),
        ),
        floatingActionButton: floatingActionButton(),
      ),
    );
  }
}
