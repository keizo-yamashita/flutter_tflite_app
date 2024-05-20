import 'package:flutter/material.dart';
import 'package:tflite_app/components/style.dart';

enum SnackBarType { info, warning, error }

class SnackBarManager {
  static final List<OverlayEntry> _snackBars = [];
  static const int maxSnackBars = 3;
  
  static void removeSnackBar(OverlayEntry entry) {
    _snackBars.remove(entry);
    _updateSnackBarsPosition();
  }

  static void _updateSnackBarsPosition() {
    for (var i = 0; i < _snackBars.length; i++) {
      _snackBars[i].markNeedsBuild();
    }
  }

  static void addSnackBar(OverlayEntry entry) {
    if (_snackBars.length >= maxSnackBars) {
      _snackBars.first.remove();
      _snackBars.removeAt(0);
    }
    _snackBars.add(entry);
    _updateSnackBarsPosition();
  }

  static bool isSnackBarDisplayed(OverlayEntry entry) {
    return _snackBars.contains(entry);
  }

  static Color getSnackBarColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.info:
        return Styles.primaryColor;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.error:
        return Colors.red;
      default:
        return Styles.primaryColor;
    }
  }
  static IconData getSnackIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.info:
        return Icons.info;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.error:
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}

void showSnackBar({
  required BuildContext context,
  required String message,
  required SnackBarType type,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);
  
  AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: overlay as TickerProvider,
  );
  var canceled = false;

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      final index = SnackBarManager._snackBars.indexOf(overlayEntry);
      final topPosition = 40.0 + (index * 50.0);

      return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          top: canceled ? 0 : topPosition,
          left: 8,
          right: 8,
          child: Material(
          color: Colors.transparent,
          child: Dismissible(
            direction: DismissDirection.up,
            onDismissed: (direction) {
              canceled = true;
              SnackBarManager.removeSnackBar(overlayEntry);
              overlayEntry.remove();
            },
            key: ValueKey(message),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: SnackBarManager.getSnackBarColor(type),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 5),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(SnackBarManager.getSnackIcon(type), color: Colors.white, size: 15),
                    ),
                    Expanded(
                      child: Text(
                        message,
                        style: Styles.defaultStyleWhite13,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 15),
                      onPressed: () {
                        if (!canceled) {
                          canceled = true;
                          SnackBarManager.removeSnackBar(overlayEntry);
                          overlayEntry.remove();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  SnackBarManager.addSnackBar(overlayEntry);
  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    if (!canceled && SnackBarManager.isSnackBarDisplayed(overlayEntry)) {
      canceled = true;
      controller.forward().then((value) {
        SnackBarManager.removeSnackBar(overlayEntry);
        overlayEntry.remove();
      });
    }
  });
}
