import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
