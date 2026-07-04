import 'package:flutter/widgets.dart';
import 'nav_items.dart';

class TabSwitcher extends InheritedWidget {
  const TabSwitcher({super.key, required this.go, required super.child});

  final void Function(AppTab tab) go;

  static TabSwitcher of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<TabSwitcher>();
    assert(widget != null, 'TabSwitcher.of() called with no TabSwitcher ancestor');
    return widget!;
  }

  @override
  bool updateShouldNotify(TabSwitcher oldWidget) => oldWidget.go != go;
}
