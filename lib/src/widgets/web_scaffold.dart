//import 'package:flutter/material.dart';
//import 'package:webview_flutter/webview_flutter.dart';
//
//typedef onReceiveMessage = void Function(JavascriptMessage message);
//
//class WebScaffold extends StatefulWidget {
//
//  const WebScaffold({
//    Key key,
//    this.title,
//    this.id,
//    this.url,
//    this.onReceiveMessage,
//  }) : super(key: key);
//
//  final String title;
//  final String id;
//  final String url;
//  final Function onReceiveMessage;
//
//  @override
//  State<StatefulWidget> createState() {
//    return new WebScaffoldState();
//  }
//}
//
//class WebScaffoldState extends State<WebScaffold> {
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return new Scaffold(
//      appBar:new AppBar(
//        title: Text(widget.title),
//      ),
//      body: WebView(
//        initialUrl: widget.url,
//        javascriptMode: JavascriptMode.unrestricted,
//        onWebViewCreated: (WebViewController webViewController) {},
//        javascriptChannels: <JavascriptChannel>[
//          _nativeJavascriptChannel(context),
//        ].toSet(),
//        navigationDelegate: (NavigationRequest request) {
//          if (request.url.startsWith('https://www.youtube.com/')) {
//            print('blocking navigation to $request}');
//            return NavigationDecision.prevent;
//          }
//          print('allowing navigation to $request');
//          return NavigationDecision.navigate;
//        },
//        onPageFinished: (String url) {
//          print('Page finished loading: $url');
//        },
//      ),
//    );
//  }
//
//  //统一处理js{action:"toaster",data:{}}
//  JavascriptChannel _nativeJavascriptChannel(BuildContext context) {
//    return JavascriptChannel(
//        name: 'Flutter',
//        onMessageReceived: (JavascriptMessage message) {
//          widget.onReceiveMessage(message);
//        });
//  }
//
//}
