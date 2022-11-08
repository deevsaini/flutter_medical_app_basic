import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/StaticDataModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class MultiSelectSpecialization extends StatefulWidget {
  final int? id;
  List<String?>? selectedServicesId;

  MultiSelectSpecialization({this.id, this.selectedServicesId});

  @override
  _MultiSelectSpecializationState createState() => _MultiSelectSpecializationState();
}

class _MultiSelectSpecializationState extends State<MultiSelectSpecialization> {
  TextEditingController search = TextEditingController();

  List<StaticData?> searchSpecializationList = [];

  List<StaticData?> specializationList = [];
  List<StaticData> selectedSpecializationList = [];

  bool mIsLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : primaryColor, statusBarIconBrightness: Brightness.light);

    getData();
  }

  void getData() {
    mIsLoading = true;
    setState(() {});
    getStaticDataResponse("specialization").then((value) {
      specializationList.addAll(value.staticData!);
      searchSpecializationList.addAll(value.staticData!);
      setState(() {});
      multiSelectStore.clearStaticList();
      specializationList.forEach((element) {
        if (widget.selectedServicesId!.contains(element!.id)) {
          multiSelectStore.addSingleStaticItem(element, isClear: false);
          element.isSelected = true;
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

  @override
  void dispose() {
    setStatusBarColor(appPrimaryColor, statusBarIconBrightness: Brightness.light);

    super.dispose();
  }

  onSearchTextChanged(String text) async {
    specializationList.clear();

    if (text.isEmpty) {
      specializationList.addAll(searchSpecializationList);
      setState(() {});
      return;
    }
    searchSpecializationList.forEach((element) {
      if (element!.value!.toLowerCase().contains(text)) specializationList.add(element);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblSpecialization')),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(languageTranslate('lblSelectSpecialization'), style: boldTextStyle(size: 18)),
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
                  color: Colors.black,
                  size: 25,
                ),
              ),
              8.height,
              ListView.builder(
                itemCount: specializationList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  StaticData data = specializationList[index]!;
                  return Theme(
                    data: ThemeData(
                      unselectedWidgetColor: primaryColor,
                    ),
                    child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.all(0),
                      value: data.isSelected,
                      onChanged: (v) {
                        data.isSelected = !data.isSelected;
                        if (v!) {
                          multiSelectStore.addSingleStaticItem(data, isClear: false);
                          widget.selectedServicesId!.add(data.id);
                        } else {
                          multiSelectStore.removeStaticItem(data);
                          widget.selectedServicesId!.remove(data.id);
                        }
                        setState(() {});
                      },
                      title: Text(data.label.validate(), maxLines: 2, overflow: TextOverflow.ellipsis, style: primaryTextStyle()),
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

  Widget floatingActionButton() {
    return FloatingActionButton(
      backgroundColor: primaryColor,
      child: Icon(Icons.done, color: Colors.white),
      onPressed: () {
        finish(context, true);
      },
    );
  }
}
