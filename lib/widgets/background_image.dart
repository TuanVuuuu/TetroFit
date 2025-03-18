import 'package:flutter/material.dart';

class BackGroundImage extends StatelessWidget {
  const BackGroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Image.asset("assets/images/bg_app.jpg", fit: BoxFit.fitHeight),
        ),
      ],
    );
  }
}
