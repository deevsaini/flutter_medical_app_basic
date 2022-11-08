import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/components/AppointmentWidget.dart';
import 'package:kivicare_flutter/main/model/DoctorDashboardModel.dart';
import 'package:nb_utils/nb_utils.dart';

class AppointmentListWidget extends StatefulWidget {
  final List<UpcomingAppointment>? upcomingAppointment;

  AppointmentListWidget({this.upcomingAppointment});

  @override
  _AppointmentListWidgetState createState() => _AppointmentListWidgetState();
}

class _AppointmentListWidgetState extends State<AppointmentListWidget> {
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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.upcomingAppointment!.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        UpcomingAppointment data = widget.upcomingAppointment![index];
        return AppointmentWidget(upcomingData: data,index:index).paddingOnly(bottom: 16);
      },
    );
  }
}
