import 'package:flutter/material.dart';

/// Reusable app bar to keep screen-level AppBar setup consistent.
class SagaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color backgroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const SagaAppBar({
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor = Colors.white,
    this.elevation = 0,
    this.bottom,
    super.key,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      bottom: bottom,
    );
  }
}
