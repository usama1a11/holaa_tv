import 'dart:io';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController controller = WebViewController();
  bool isShowLoading = false;

  String url = "https://holaatv.com/in/";

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    Future.delayed(Duration.zero, () {
      loadWeb();
    });
  }

  void loadWeb() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print("Loading progress: $progress%");
          },
          onPageStarted: (String url) {
            setState(() {
              isShowLoading = true;
            });
            print("Page started loading: $url");
          },
          onPageFinished: (String url) {
            setState(() {
              isShowLoading = false;
            });
            print("Page finished loading: $url");
          },
          onWebResourceError: (WebResourceError error) {
            print("Web resource error: ${error.description}");
            // showToast("Failed to load page: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }
  void checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // showToast("Connected");
      }
    } on SocketException catch (_) {
      // showToast("Not connected");
    }
  }

  // void showToast(String message) {
  //   Fluttertoast.showToast(
  //       msg: message,
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.CENTER,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: isShowLoading,
        child: SafeArea(
          child: Scaffold(
              body: RefreshIndicator(
                onRefresh: () {
                  return controller.reload();
                },
                child: WebViewWidget(
                  controller: controller,
                ),
              )),
        ),
      ),
    );
  }
}
