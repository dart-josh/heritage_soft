import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';

class QRCodeDialog extends StatefulWidget {
  final String user_id;
  const QRCodeDialog({super.key, required this.user_id});

  @override
  State<QRCodeDialog> createState() => _QRCodeDialogState();
}

class _QRCodeDialogState extends State<QRCodeDialog> {
  WidgetsToImageController screenshotController = WidgetsToImageController();

  // convert barcode to image
  Future<Uint8List?> _capturePng() async {
    Uint8List? final_image;

    try {
      final_image = await screenshotController.capture();
    } catch (e) {
      print(e);
      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'An Error occurred, Try again',
        icon: Icons.error,
      );
      final_image = null;
    }

    return final_image;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 415,
            width: 370,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color.fromARGB(255, 248, 212, 149),
            ),
            child: Column(
              children: [
                // top bar
                Stack(
                  children: [
                    // title
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      height: 45,
                      child: Center(
                          child: Text(
                        widget.user_id,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )),
                    ),

                    // close button
                    Positioned(
                      top: 0,
                      right: 5,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),

                // barcode
                WidgetsToImage(
                  controller: screenshotController,
                  child: Container(
                    width: 275,
                    height: 335,
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),

                        // barcode
                        Container(
                          width: 255,
                          height: 255,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: QrImageView(
                              data: widget.user_id,
                              version: QrVersions.auto,
                              // eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.circle),
                              size: 240,
                              gapless: true,
                              embeddedImage: AssetImage('images/logo.jpg'),
                              embeddedImageStyle: QrEmbeddedImageStyle(
                                size: Size(40, 40),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 18),

                        // user id
                        Text(
                          widget.user_id,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),
              ],
            ),
          ),

          SizedBox(height: 10),

          // save button
          if (!kIsWeb)
            if (Platform.isAndroid)
              InkWell(
                onTap: () async {
                  Helpers.showLoadingScreen(context: context);
                  Uint8List? image = await _capturePng();
                  Navigator.pop(context);

                  if (image == null) return;

                  await Share.file('ESYS AMLOG', '${widget.user_id}.jpg', image,
                      'image/jpg');
                },
                child: Container(
                  height: 40,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 25,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Send to Client',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
