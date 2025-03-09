import 'package:flutter/material.dart';

class Pixel extends StatelessWidget {
  final Color? color;
  final int child;
  const Pixel({super.key, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: color,
        border: Border.all(color: Colors.brown, width: 0.25),
      ),
      child:
          color == null
              ? Image.asset("assets/images/bg_app.jpg", fit: BoxFit.cover)
              : SizedBox.shrink(),
      // child: Center(
      //   child: Text(child.toString(), style: TextStyle(color: Colors.white)),
      // ),
    );
  }
}
