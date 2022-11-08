import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/model/ClinicListModel.dart';
import 'package:kivicare_flutter/main/model/LoginResponseModel.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class ClinicDropDown extends StatefulWidget {
  void Function(Clinic? clinic) onSelected;
  bool isValidate;
  Clinic? clinic;
  final int? clinicId;

  ClinicDropDown({required this.onSelected, this.isValidate = false, this.clinic, this.clinicId});

  @override
  _ClinicDropDownState createState() => _ClinicDropDownState();
}

class _ClinicDropDownState extends State<ClinicDropDown> {
  final AsyncMemoizer<ClinicListModel> _memoizer = AsyncMemoizer();

  Clinic? clinic;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    clinic = widget.clinic;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClinicListModel>(
      future: _memoizer.runOnce(() => getClinicList()),
      builder: (_, snap) {
        if (snap.hasData) {
          if (widget.clinicId != null) {
            snap.data!.clinicData!.forEach((element) {
              if (element.clinic_id.toInt() == widget.clinicId) {
                clinic = element;
              }
              appointmentAppStore.setSelectedClinic(clinic);
            });
          }
          return DropdownButtonFormField<Clinic>(
            decoration: textInputStyle(
              context: context,
              label: 'lblSelectClinic',
              isMandatory: true,
              suffixIcon: commonImage(
                imageUrl: "images/icons/arrowDown.png",
                size: 10,
              ),
            ),
            icon: SizedBox.shrink(),
            isExpanded: true,
            value: clinic,
            dropdownColor: Theme.of(context).cardColor,
            validator: widget.isValidate
                ? (v) {
                    if (v == null) return languageTranslate('lblClinicIsRequired');
                    return null;
                  }
                : (v) {
                    return null;
                  },
            onChanged: (value) {
              clinic = value;
              widget.onSelected.call(value);
              setState(() {});
              LiveStream().emit(CHANGE_DATE, true);
            },
            items: snap.data!.clinicData!
                .map(
                  (element) => DropdownMenuItem(
                    value: element,
                    child: Text("${element.clinic_name} ", style: primaryTextStyle()),
                  ),
                )
                .toList(),
          );
        }
        return snapWidgetHelper(snap);
      },
    );
  }
}
