import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class MultiSelectDoctorDropDown extends StatefulWidget {
  List<String>? selectedServicesId;

  MultiSelectDoctorDropDown({this.selectedServicesId});

  @override
  _MultiSelectDoctorDropDownState createState() => _MultiSelectDoctorDropDownState();
}

class _MultiSelectDoctorDropDownState extends State<MultiSelectDoctorDropDown> {
  TextEditingController search = TextEditingController();

  List<DoctorList> searchDoctorList = [];

  List<DoctorList> doctorList = [];

  bool mIsLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void getData() {
    mIsLoading = true;
    setState(() {});

    getDoctorList(clinicId: isReceptionist() ? getIntAsync(USER_CLINIC) : "" as int?).then((value) {
      doctorList.addAll(value.doctorList!);
      searchDoctorList.addAll(value.doctorList!);
      doctorList.forEach((element) {
        if (widget.selectedServicesId!.contains(element.iD.toString())) {
          element.isCheck = true;
        }
      });
      setState(() {});
    }).catchError((e) {
      errorToast(e.toString());
    }).whenComplete(() {
      mIsLoading = false;
      setState(() {});
    });
  }

  List<DoctorList> getSelectedData() {
    List<DoctorList> selected = [];

    doctorList.forEach((value) {
      if (value.isCheck == true) {
        selected.add(value);
      }
    });
    setState(() {});
    return selected;
  }

  init() async {
    getData();
  }

  onSearchTextChanged(String text) async {
    doctorList.clear();

    if (text.isEmpty) {
      doctorList.addAll(searchDoctorList);
      setState(() {});
      return;
    }
    searchDoctorList.forEach((element) {
      if (element.display_name!.toLowerCase().contains(text)) doctorList.add(element);
    });
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appStore.isDarkModeOn ? Colors.black : Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 60),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  height: 4,
                  width: 30,
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
                ).center(),
                8.height,
                Row(
                  children: [
                    Text(languageTranslate('lblSelectDoctor'), style: boldTextStyle(size: 18)).expand(),
                    IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () {
                        finish(context, getSelectedData());
                      },
                    )
                  ],
                ),
                Divider(),
                8.height,
              ],
            ),
            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withOpacity(0.2),
              ),
              child: TextField(
                onChanged: onSearchTextChanged,
                autofocus: false,
                onTap: () {},
                textInputAction: TextInputAction.go,
                controller: search,
                style: boldTextStyle(size: 20),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.white,
                  hintText: languageTranslate('lblSearch'),
                  hintStyle: secondaryTextStyle(size: 20),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 25,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            ListView.builder(
              itemCount: doctorList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                DoctorList data = doctorList[index];
                return Theme(
                  data: ThemeData(
                    unselectedWidgetColor: primaryColor,
                  ),
                  child: CheckboxListTile(
                    value: data.isCheck,
                    onChanged: (v) {
                      data.isCheck = !data.isCheck;
                      if (v!) {
                        widget.selectedServicesId!.add(data.iD.toString());
                      } else {
                        widget.selectedServicesId!.remove(data.iD.toString());
                      }
                      setState(() {});
                    },
                    title: Text(
                      data.display_name.validate(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: primaryTextStyle(),
                    ),
                  ),
                );
              },
            ),
          ],
        ).visible(!mIsLoading, defaultWidget: setLoader()),
      ),
    );
  }
}
