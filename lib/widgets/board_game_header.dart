import 'package:flutter/material.dart';

class BoardGameHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;

  const BoardGameHeader({
    super.key,
    this.title,
    this.actions,
  });

  static TextStyle get dfTitleStyle =>
      TextStyle(color: Colors.white, fontSize: 20);
  static TextStyle get dfActionTextStyle => TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber[100]);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.home),
        color: Colors.amber[100],
      ),
      actions: actions ?? [],
      title: title ?? Container(),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
