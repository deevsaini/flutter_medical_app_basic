import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:nb_utils/nb_utils.dart';

class DPatientSelectScreen extends StatefulWidget {
  final List<String?>? searchList;
  final String? name;

  DPatientSelectScreen({this.searchList, this.name});

  @override
  _DPatientSelectScreenState createState() => _DPatientSelectScreenState();
}

class _DPatientSelectScreenState extends State<DPatientSelectScreen> {
  TextEditingController prescriptionNameSearch = TextEditingController();

  List<String?> mainList = [];
  List<String?> searchList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : primaryColor, statusBarIconBrightness: Brightness.light);

    mainList.addAll(widget.searchList.validate());
    searchList.addAll(mainList.validate());
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : primaryColor, statusBarIconBrightness: Brightness.light);

    prescriptionNameSearch.dispose();
    super.dispose();
  }

  void filterSearchResults(String query) {
    List<String?> dummySearchList = [];
    dummySearchList.addAll(mainList);
    if (query.isNotEmpty) {
      List<String?> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item!.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        searchList.clear();
        searchList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        searchList.clear();
        searchList.addAll(mainList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(
          languageTranslate('lblPatientName'),
          color: appStore.isDarkModeOn ? scaffoldDarkColors : primaryColor,
          textColor: Colors.white,
          actions: [
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  finish(context);
                }),
            6.width,
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                finish(context);
              },
            ),
          ],
        ),
        body: Container(
          height: context.height(),
          // color: Theme.of(context).cardColor,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 30),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: prescriptionNameSearch,
                  textFieldType: TextFieldType.NAME,
                  decoration: textInputStyle(context: context, label: 'lblSearch'),
                  onFieldSubmitted: (s) {
                    finish(context, s);
                  },
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                ),
                24.height,
                Text(languageTranslate("lblPatients"), style: boldTextStyle(size: 18)).paddingLeft(4),
                16.height,
                ListView.separated(
                  itemCount: searchList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(8),
                      child: Text(searchList[index].validate().capitalizeFirstLetter(), style: primaryTextStyle()),
                    ).onTap(() {
                      finish(context, searchList[index]);
                      toast(languageTranslate('lblPatientSelected'));
                    });
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 8);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
