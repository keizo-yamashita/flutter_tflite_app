////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_app/components/style.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// App Widget
////////////////////////////////////////////////////////////////////////////////////////////
class AppNavigationBar extends ConsumerWidget {
  const AppNavigationBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;
  int get currentIndex => navigationShell.currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: navigationShell,
      drawer: isLandscape ? Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          children: [
            ListTile(
              leading: const Icon(Icons.car_rental, size: 28),
              title: const Text('Viewer'),
              onTap: () => navigationShell.goBranch(0),
            ),
            ListTile(
              leading: const Icon(Icons.settings, size: 28),
              title: const Text('Parameters'),
              onTap: () => navigationShell.goBranch(2),
            ),
          ],
        ),
      ) : null,
      bottomNavigationBar: !isLandscape ? Container(
        height: 56.0 + MediaQuery.of(context).padding.bottom,
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey,
              blurRadius: 0.3,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          onTap: (index) async {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_display, size: 24),
              activeIcon: Icon(Icons.smart_display, size: 28),
              label: 'Viewer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 24),
              activeIcon: Icon(Icons.settings, size: 28),
              label: 'Parameters',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          fixedColor: Styles.primaryColor,
        ),
      ) : null,
    );
    
  }
}
