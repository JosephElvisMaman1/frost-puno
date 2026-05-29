import 'package:flutter/material.dart';

import 'frost_app_bar.dart';
import 'responsive_content.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    required this.child,
    super.key,
    this.canPop = true,
    this.bottomNavigationBar,
  });

  final Widget child;
  final bool canPop;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FrostAppBar(canPop: canPop),
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(child: ResponsiveContent(child: child)),
    );
  }
}
