import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/components/DoctorDashboardWidget.dart';
import 'package:kivicare_flutter/receiptionist/screens/RAddNewDoctor.dart';
import 'package:nb_utils/nb_utils.dart';

class RDoctorListingScreen extends StatefulWidget {
  @override
  _RDoctorListingScreenState createState() => _RDoctorListingScreenState();
}

class _RDoctorListingScreenState extends State<RDoctorListingScreen> {
  int page = 1;

  bool isLastPage = false;
  bool isReady = false;

  List<DoctorList> doctorList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColor : scaffoldBgColor);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      floatingActionButton: AddFloatingButton(
        onTap: () async {
          bool? res = await RAddNewDoctor(isUpdate: false).launch(context);
          if (res ?? false) {
            setState(() {});
          }
        },
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NotificationListener(
            onNotification: (dynamic n) {
              if (!isLastPage && isReady) {
                if (n is ScrollEndNotification) {
                  page++;
                  isReady = false;
                  setState(() {});
                }
              }
              return !isLastPage;
            },
            child: FutureBuilder<DoctorListModel>(
              future: getDoctorList(page: page),
              builder: (_, snap) {
                if (snap.hasData) {
                  if (page == 1) doctorList.clear();

                  doctorList.addAll(snap.data!.doctorList.validate());
                  isReady = true;

                  isLastPage = snap.data!.total.validate() <= doctorList.length;
                  if (doctorList.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$TOTAL_DOCTOR (${doctorList.length})', style: boldTextStyle(size: 18)),
                        16.height,
                        Wrap(
                          alignment: WrapAlignment.start,
                          runSpacing: 16,
                          spacing: 16,
                          children: snap.data!.doctorList.validate().map((e) => DoctorDashboardWidget(data: e, isBooking: false)).toList(),
                        ),
                      ],
                    );
                  } else {
                    return NoDataFoundWidget(text: languageTranslate('lblNoDataFound'), iconSize: 130).center();
                  }
                }
                return snapWidgetHelper(snap);
              },
            ),
          ),
          70.height,
        ],
      ),
    );
  }
}
