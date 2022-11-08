import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/AppConstants.dart';
import 'package:kivicare_flutter/main/utils/AppWidgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class WebViewPaymentScreen extends StatefulWidget {
  String? checkoutUrl;

  WebViewPaymentScreen({this.checkoutUrl});

  @override
  WebViewPaymentScreenState createState() => WebViewPaymentScreenState();
}

class WebViewPaymentScreenState extends State<WebViewPaymentScreen> {
  var mIsError = false;
  var mIsLoading = false;

  @override
  void initState() {
    super.initState();
    setDynamicStatusBarColor(color: appPrimaryColor);
  }

  @override
  void dispose() {
    super.dispose();
    setDynamicStatusBarColor();
  }

  void goBack() {
    if (appStore.isBookedFromDashboard) {
      finish(context);
      finish(context);
      finish(context, true);
    } else {
      finish(context, true);
      LiveStream().emit(APP_UPDATE, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: appAppBar(context,
            leading: Icon(Icons.arrow_back, color: Colors.white, size: 28).onTap(() {
              goBack();
            }),
            name: languageTranslate('lblPayment')),
        body: Stack(
          children: [
            WebView(
              initialUrl: widget.checkoutUrl,
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,
              onPageFinished: (String url) async {
                if (mIsError) return;
                if (url.contains('checkout/order-received')) {
                  mIsLoading = true;
                  toast(languageTranslate('lblAppointmentBookedSuccessfully'));
                  goBack();
                } else {
                  mIsLoading = false;
                }
              },
              onWebResourceError: (s) {
                mIsError = true;
              },
            ),
            CircularProgressIndicator().visible(mIsLoading).center(),
          ],
        ),
      ),
    );
  }
}
