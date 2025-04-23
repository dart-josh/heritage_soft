import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String? loadingText;
  const LoadingScreen({Key? key, this.loadingText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),

                // loading text
                if (loadingText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      loadingText!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
