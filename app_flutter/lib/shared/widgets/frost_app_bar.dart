import 'package:flutter/material.dart';

class FrostAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostAppBar({super.key, this.canPop = false});

  final bool canPop;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: const Text('AndeanSense'),
    );
  }
}
