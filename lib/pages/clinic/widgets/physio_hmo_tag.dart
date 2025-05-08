import 'package:flutter/material.dart';

class PhysioHMOTag extends StatelessWidget {
  const PhysioHMOTag({super.key, required this.hmo});

  final String hmo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: (hmo == 'No HMO')
            ? Color.fromARGB(255, 232, 186, 93).withOpacity(0.4)
            : Color.fromARGB(255, 232, 93, 218).withOpacity(0.4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: EdgeInsets.only(left: 10, top: 2),
      child: Text(
        (hmo == 'No HMO') ? 'Walk-In' : hmo,
        style: TextStyle(
          fontSize: 9,
          letterSpacing: 1,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
