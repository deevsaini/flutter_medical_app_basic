import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/model/PatientBillModel.dart';
import 'package:kivicare_flutter/main/model/ServiceModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class AddBillItem extends StatefulWidget {
  List<BillItem>? billItem;
  final int? billId;
  final int? doctorId;

  AddBillItem({this.billItem, this.billId, this.doctorId});

  @override
  _AddBillItemState createState() => _AddBillItemState();
}

class _AddBillItemState extends State<AddBillItem> {
  AsyncMemoizer<ServiceListModel> _memorizer = AsyncMemoizer();

  var formKey = GlobalKey<FormState>();

  ServiceData? serviceData;
  TextEditingController priceCont = TextEditingController();
  TextEditingController quantityCont = TextEditingController();
  TextEditingController totalCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(appPrimaryColor, statusBarIconBrightness: Brightness.light);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    priceCont.dispose();
    quantityCont.dispose();
    totalCont.dispose();
    setStatusBarColor(appPrimaryColor, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            FutureBuilder<ServiceListModel>(
              future: isDoctor() ? _memorizer.runOnce(() => getServiceResponse(id: getIntAsync(USER_ID), page: 1)) : _memorizer.runOnce(() => getServiceResponse(id: widget.doctorId, page: 1)),
              builder: (_, snap) {
                if (snap.hasData) {
                  return Column(
                    children: [
                      DropdownButtonFormField<ServiceData>(
                        dropdownColor: Theme.of(context).cardColor,
                        decoration: textInputStyle(context: context, text: languageTranslate('lblSelectServices'), isMandatory: true),
                        validator: (v) {
                          if (v == null) return languageTranslate('lblServiceIsRequired');
                          return null;
                        },
                        items: snap.data!.serviceData!
                            .map(
                              (e) => DropdownMenuItem(
                                child: Text('${e.name}', style: primaryTextStyle()),
                                value: e,
                              ),
                            )
                            .toList(),
                        onChanged: (ServiceData? e) {
                          serviceData = e;
                          priceCont.text = e!.charges!;
                          quantityCont.text = languageTranslate('lblOne');
                          totalCont.text = "${e.charges.toInt() * quantityCont.text.toInt()}";
                        },
                      ),
                      16.height,
                      AppTextField(
                        controller: priceCont,
                        textFieldType: TextFieldType.PHONE,
                        decoration: textInputStyle(context: context, label: 'lblPrice', isMandatory: true),
                        onChanged: (s) {
                          totalCont.text = "${s.toInt() * quantityCont.text.toInt()}";
                        },
                      ),
                      16.height,
                      AppTextField(
                        controller: quantityCont,
                        textFieldType: TextFieldType.PHONE,
                        keyboardType: TextInputType.number,
                        decoration: textInputStyle(context: context, label: 'lblQuantity', isMandatory: true),
                        onChanged: (s) {
                          totalCont.text = "${priceCont.text.toInt() * s.toInt()}";
                        },
                      ),
                      16.height,
                      AppTextField(
                        controller: totalCont,
                        textFieldType: TextFieldType.PHONE,
                        decoration: textInputStyle(context: context, label: 'lblTotal', isMandatory: true),
                        readOnly: true,
                      ),
                    ],
                  );
                }
                return snapWidgetHelper(snap);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appAppBar(context, name: languageTranslate('lblAddBillItem')),
        body: body(),
        floatingActionButton: AddFloatingButton(
          icon: Icons.done,
          onTap: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              widget.billItem!.add(
                BillItem(
                  id: "",
                  label: serviceData!.name.validate(),
                  bill_id: "${widget.billId == null ? "" : widget.billId}",
                  item_id: serviceData!.id,
                  qty: quantityCont.text.validate(),
                  price: priceCont.text.validate(),
                ),
              );
              finish(context, true);
            }
          },
        ),
      ),
    );
  }
}
