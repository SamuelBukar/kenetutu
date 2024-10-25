import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  double progress = 0;
  var urlController = TextEditingController();
  var initialUrl = "https://kenetutu.com/app/";
  var isLoading = false;

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController!.canGoBack()) {
      webViewController!.goBack();
      return Future.value(false);
    } else {
      SystemNavigator.pop();
      return Future.value(true);
    }
  }


  @override
  void initState() {
    super.initState();

    refreshController = PullToRefreshController(
      onRefresh: () {
        webViewController!.reload();
      },
      options: PullToRefreshOptions(
        color: Colors.blue,
        backgroundColor: Colors.white,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: WillPopScope(
        onWillPop: () => _goBack(context),
        child: Column(
          children: [Expanded
            (child: Stack(
            alignment: Alignment.center,
            children: [
              InAppWebView(
                onLoadStart: (controller, url){
                  setState(() {
                    isLoading = true;
                  });
                },
                onLoadStop: (controller, url){
                  refreshController!.endRefreshing();
                  setState(() {
                    isLoading = false;
                  });
                },

                onProgressChanged: (controller, progress){
                  if(progress == 100){
                    refreshController!.endRefreshing();
                  }

                  setState(() {
                    this.progress = progress / 100;
                  });
                },

                pullToRefreshController: refreshController,
                onWebViewCreated: (controller) => webViewController = controller,
                initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(initialUrl))),

              ),
              Visibility(
                visible: isLoading,
                  child: CircularProgressIndicator(
                    value: progress,
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
              ))
            ],
          ))],
        ),
      ),
    );
  }
}

