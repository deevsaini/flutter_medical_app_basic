import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:kivicare_flutter/patient/screens/PatientUpcomingAppointment.dart';
import 'package:kivicare_flutter/patient/screens/appointment/AddAppointmentScreenStep1.dart';
import 'package:kivicare_flutter/patient/screens/appointment/AddAppointmentScreenStep3.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientUpcomingAppointmentFragment extends StatefulWidget {
  @override
  _PatientUpcomingAppointmentFragmentState createState() => _PatientUpcomingAppointmentFragmentState();
}

class _PatientUpcomingAppointmentFragmentState extends State<PatientUpcomingAppointmentFragment> {
  TextEditingController searchCont = TextEditingController();

  DateTime current = DateTime.now();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setDynamicStatusBarColor(color: appPrimaryColor);
    await getConfiguration().catchError(log);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    searchCont.dispose();
    setDynamicStatusBarColor();
  }

  @override
  void didUpdateWidget(covariant PatientUpcomingAppointmentFragment oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 70),
      child: PatientUpcomingAppointment(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblUpcomingAppointments')),
        floatingActionButton: AddFloatingButton(navigate: isProEnabled() ? AddAppointmentScreenStep3() : AddAppointmentScreenStep1()),
        body: body(),
      ),
    );
  }
}
