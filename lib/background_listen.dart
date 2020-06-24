import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundListen extends StatefulWidget {
  const BackgroundListen({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _BackgroundListenState createState() => _BackgroundListenState();
}

class _BackgroundListenState extends State<BackgroundListen> {
  final _channel = const MethodChannel('com.example/background_listen');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return true;
          } else {
            final res = await _channel.invokeMethod('sendToBackground');
            return false;
          }
        } else {
          return true;
        }
      },
      child: widget.child,
    );
  }
}
