import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scan/scan.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  ScanController controller = ScanController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pause();
    }
    controller.resume();
  }

  @override
  void dispose() {
    //
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          ScanView(
            controller: controller,
            scanAreaScale: .7,
            scanLineColor: primaryColor,
            onCapture: (data) async {
              if (data.validate().isNotEmpty) {
                HapticFeedback.heavyImpact();
                if (data.validate().isNotEmpty && data.validateURL()) {
                  final uri = Uri.parse(data.validate());

                  String username = uri.queryParameters['user'].validate();
                  String url = data.splitBefore('?');

                  appStore.setBaseUrl(url, initiliaze: true);
                  appStore.setDemoDoctor("doctor_$username@kivicare.com", initiliaze: true);
                  appStore.setDemoReceptionist("receptionist_$username@kivicare.com", initiliaze: true);
                  appStore.setDemoPatient("patient_$username@kivicare.com", initiliaze: true);
                }
                finish(context, true);
              }
            },
          ),
          Positioned(
            top: context.height() * 0.28,
            left: 0,
            right: 0,
            child: Text(languageTranslate('lblQrScanner'), style: boldTextStyle(color: white, size: 24), textAlign: TextAlign.center),
          ),
          Positioned(
            top: 32,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: white),
              onPressed: () {
                finish(context);
              },
            ),
          ),
          Observer(builder: (_) => Loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
