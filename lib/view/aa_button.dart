import 'package:flutter/material.dart';

class AAButton extends StatelessWidget {
  final VoidCallback ontap;
  final String label;
  const AAButton({
    super.key,
    required this.ontap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: InkWell(
        onTap: ontap,
        child: Container(
          margin: EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: Colors.amber[100],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.brown[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
