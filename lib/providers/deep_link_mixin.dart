////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

////////////////////////////////////////////////////////////////////////////////
/// deep link mixin
////////////////////////////////////////////////////////////////////////////////

mixin DeepLinkMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription? _sub;

  @override
  void initState() {
    _sub = uriLinkStream.listen(_onNewNotify);
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void onDeepLinkNotify(Uri? uri);

  void _onNewNotify(Uri? uri) {
    if (mounted) onDeepLinkNotify(uri);
  }
}

////////////////////////////////////////////////////////////////////////////////
/// deep link Provider
////////////////////////////////////////////////////////////////////////////////

class DeepLinkProvider extends ChangeNotifier {
  String _shiftFrameId = "";
  String get shiftFrameId => _shiftFrameId;

  set shiftFrameId(String id) {
    _shiftFrameId = id;
    notifyListeners();
  }
}
