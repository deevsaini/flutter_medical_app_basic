import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/components/AppointmentListWidget.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/model/PatientEncounterModel.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientUpcomingAppointment extends StatefulWidget {
  @override
  _PatientUpcomingAppointmentState createState() => _PatientUpcomingAppointmentState();
}

class _PatientUpcomingAppointmentState extends State<PatientUpcomingAppointment> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientEncounterModel>(
      future: getPatientAppointmentList(patientId: getIntAsync(USER_ID), status: "1"),
      builder: (_, snap) {
        if (snap.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languageTranslate('lblTodaySAppointments') + ' (${snap.data!.upcomingAppointmentData!.length})',
                style: boldTextStyle(size: 16),
              ),
              8.height,
              AppointmentListWidget(upcomingAppointment: snap.data!.upcomingAppointmentData).visible(
                snap.data!.upcomingAppointmentData != null,
                defaultWidget: NoDataFoundWidget(iconSize: 130).center(),
              ),
            ],
          ).visible(snap.connectionState != ConnectionState.waiting, defaultWidget: setLoader().center());
        }
        return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
      },
    );
  }
}
