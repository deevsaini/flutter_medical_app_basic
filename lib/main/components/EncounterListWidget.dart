import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/components/EncounterItemWidget.dart';
import 'package:kivicare_flutter/main/components/NoDataFoundWidget.dart';
import 'package:kivicare_flutter/main/model/MedicalHistroyModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:kivicare_flutter/network/RestApis.dart';
import 'package:nb_utils/nb_utils.dart';

class EncounterListWidget extends StatefulWidget {
  final String? encounterType;
  final int? id;
  final String? paymentStatus;

  EncounterListWidget({this.encounterType, this.id, this.paymentStatus});

  @override
  _EncounterListWidgetState createState() => _EncounterListWidgetState();
}

class _EncounterListWidgetState extends State<EncounterListWidget> {
  var formKey = GlobalKey<FormState>();

  AsyncMemoizer<MedicalHistoryModel> _memorizer = AsyncMemoizer();

  TextEditingController textCont = TextEditingController();

  bool isLoading = false;
  bool isInteractionOn = false;

  List<EncounterType>? encounterTypeList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    textCont.clear();
  }

  saveDetails() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      setState(() {});
      Map request = {
        "encounter_id": "${widget.id}",
        "type": "${widget.encounterType}",
        "title": textCont.text.trim(),
      };
      saveMedicalHistoryData(request).then((value) {
        encounterTypeList!.add(value);
        textCont.clear();
        isLoading = false;
        setState(() {});
        successToast("${widget.encounterType.capitalizeFirstLetter()} Added");
      }).catchError((e) {
        isLoading = false;
        setState(() {});
        errorToast(e.toString());
      });
    }
  }

  deleteDetails(int id, int index) {
    Map request = {
      "id": "$id",
    };
    deleteMedicalHistoryData(request).then((value) {
      textCont.clear();
      encounterTypeList!.removeAt(index);
      isInteractionOn = false;
      isLoading = false;
      setState(() {});
      successToast("${widget.encounterType} " + languageTranslate('lblAdded'));
    }).catchError((e) {
      isLoading = false;
      setState(() {});
      errorToast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    textCont.dispose();
    setStatusBarColor(appStore.isDarkModeOn ? scaffoldDarkColors : appPrimaryColor, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<MedicalHistoryModel>(
          future: _memorizer.runOnce(() => getMedicalHistoryResponse(widget.id.validate(), widget.encounterType!.toLowerCase())),
          builder: (context, snap) {
            if (snap.hasData) {
              encounterTypeList = snap.data!.encounterType;
              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${widget.encounterType.capitalizeFirstLetter()}s (${encounterTypeList!.length})", style: boldTextStyle()),
                    16.height,
                    ListView.separated(
                      itemCount: encounterTypeList!.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        EncounterType data = encounterTypeList![index];

                        return EncounterItemWidget(
                          data: data,
                          onTap: () {
                            deleteDetails(data.id.toInt(), index);
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(color: viewLineColor);
                      },
                    ),
                  ],
                ),
              );
            }
            return snapWidgetHelper(snap, errorWidget: noDataWidget(text: errorMessage, isInternet: true));
          },
        ).paddingBottom(60).visible(encounterTypeList!.length >= 0),
        NoDataFoundWidget(iconSize: 130).center().visible(encounterTypeList!.length < 0),
        !isPatient() && widget.paymentStatus != 'paid'
            ? Positioned(
                bottom: 16,
                right: 16,
                left: 16,
                child: Form(
                  key: formKey,
                  child: Container(
                    width: context.width() - 35,
                    child: AppTextField(
                      controller: textCont,
                      textFieldType: TextFieldType.NAME,
                      minLines: 1,
                      maxLines: 5,
                      autoFocus: false,
                      errorThisFieldRequired: "${widget.encounterType.capitalizeFirstLetter()} " + languageTranslate('lblFieldIsRequired'),
                      decoration: textInputStyle(context: context, text: languageTranslate('lblEnter') + ' ${widget.encounterType}'),
                      keyboardType: TextInputType.multiline,
                      suffix: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          saveDetails();
                        },
                      ),
                    ),
                  ),
                ),
              )
            : 0.height,
        setLoader().visible(isLoading)
      ],
    );
  }
}
