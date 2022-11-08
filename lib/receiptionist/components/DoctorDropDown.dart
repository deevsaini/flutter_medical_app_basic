import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/model/DoctorListModel.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class DoctorDropDown extends StatefulWidget {
  void Function(DoctorList? doctorCont) onSelected;
  bool isValidate;
  DoctorList? doctorCont;
  final int? doctorId;
  final int? clinicId;

  DoctorDropDown({required this.onSelected, this.isValidate = false, this.doctorCont, this.doctorId, this.clinicId});

  @override
  _DoctorDropDownState createState() => _DoctorDropDownState();
}

class _DoctorDropDownState extends State<DoctorDropDown> {
  final AsyncMemoizer<DoctorListModel> _memoizer = AsyncMemoizer();

  DoctorList? doctorCont;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    doctorCont = widget.doctorCont;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DoctorListModel>(
      future: _memoizer.runOnce(() => getDoctorList(clinicId: widget.clinicId)),
      builder: (_, snap) {
        if (snap.hasData) {
          if (widget.doctorId != null) {
            snap.data!.doctorList!.forEach((element) {
              if (element.iD == widget.doctorId) {
                doctorCont = element;
              }
            });
          }

          return DropdownButtonFormField<DoctorList>(
            decoration: textInputStyle(
              context: context,
              label: 'lblSelectDoctor',
              isMandatory: true,
              suffixIcon: commonImage(imageUrl: "images/icons/arrowDown.png", size: 10),
            ),
            isExpanded: true,
            value: doctorCont,
            icon: SizedBox.shrink(),
            dropdownColor: Theme.of(context).cardColor,
            validator: widget.isValidate
                ? (v) {
                    if (v == null) return languageTranslate('lblDoctorIsRequired');
                    return null;
                  }
                : (v) {
                    return null;
                  },
            onChanged: (value) {
              doctorCont = value;
              widget.onSelected.call(value);
              setState(() {});
            },
            items: snap.data!.doctorList
                .validate()
                .map(
                  (element) => DropdownMenuItem(
                    value: element,
                    child: Text("${element.display_name.validate()} (${element.specialties.validate()})", style: primaryTextStyle()),
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
