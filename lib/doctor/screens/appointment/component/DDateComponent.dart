import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:nb_utils/nb_utils.dart';

class DDateComponent extends StatefulWidget {
  final DateTime? initialDate;

  DDateComponent({this.initialDate});

  @override
  State<DDateComponent> createState() => _DDateComponentState();
}

class _DDateComponentState extends State<DDateComponent> {
  TextEditingController appointmentDateCont = TextEditingController();

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      appointmentDateCont.text = widget.initialDate!.getFormattedDate(CONVERT_DATE);
      appointmentAppStore.setSelectedAppointmentDate(widget.initialDate!);
      appointmentAppStore.selectedAppointmentDate = widget.initialDate!;
    } else {
      appointmentDateCont.text = DateTime.now().add(appStore.restrictAppointmentPre.days).getFormattedDate(CONVERT_DATE);
      appointmentAppStore.setSelectedAppointmentDate(DateTime.now().add(appStore.restrictAppointmentPre.days));
    }
    setState(() {});
    if (widget.initialDate != null) {
      selectedDate = widget.initialDate;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppTextField(
          controller: appointmentDateCont,
          textFieldType: TextFieldType.OTHER,
          decoration: textInputStyle(
            context: context,
            label: 'lblAppointmentDate',
            isMandatory: true,
            suffixIcon: commonImage(
              imageUrl: "images/icons/calendar.png",
              size: 10,
            ),
          ),
          readOnly: true,
          onTap: () async {
            selectedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now().add(appStore.restrictAppointmentPre.days),
              firstDate: DateTime.now().add(appStore.restrictAppointmentPre.days),
              lastDate: DateTime.now().add(appStore.restrictAppointmentPost.days),
              helpText: "Select Appointment Date",
              builder: (context, child) {
                return child!;
              },
            );

            appointmentDateCont.text = DateFormat(CONVERT_DATE).format(selectedDate!);
            appointmentAppStore.setSelectedAppointmentDate(selectedDate!);
            LiveStream().emit(CHANGE_DATE, true);
            setState(() {});
          },
          validator: (s) {
            if (s!.trim().isEmpty) return languageTranslate('lblDateIsRequired');
            return null;
          },
        ).expand(),
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}
