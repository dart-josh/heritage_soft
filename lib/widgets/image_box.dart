import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:camera/camera.dart';

class EditProfileImage extends StatefulWidget {
  final bool is_edit;
  final String? user_image;
  const EditProfileImage({super.key, required this.is_edit, this.user_image});

  @override
  State<EditProfileImage> createState() => _EditProfileImageState();
}

class _EditProfileImageState extends State<EditProfileImage> {
  late List<CameraDescription> _cameras;
  CameraController? controller;

  Uint8List? image_file;

  bool del = false;

  String? image;

  bool camera_on = false;

  @override
  void initState() {
    image = widget.user_image;
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  // get camera details
  get_camera_details() async {
    _cameras = await availableCameras();

    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 500,
        ),
        child: Container(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2),

                    // title
                    Stack(
                      children: [
                        // title
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              widget.is_edit
                                  ? 'Edit Client Image'
                                  : 'Set Client Image',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        // action buttons
                        Positioned(
                          top: 0,
                          right: 0,
                          left: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // close button
                              IconButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 22,
                                ),
                              ),

                              // delete button
                              if (widget.is_edit && image != null)
                                IconButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    image_file = null;
                                    image = null;
                                    del = true;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // horizontal line
                    Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),

                    SizedBox(height: 4),

                    // subtitle
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(
                        widget.is_edit
                            ? 'Update the client\'s Profile image\nMake sure the device camera is enabled before proceeding.'
                            : 'Upload client\'s Profile image\nMake sure the device camera is enabled before proceeding.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 5),

              // image box
              Container(
                height: 200,
                width: 200,
                padding: EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: camera_on
                    ? camera_preview()
                    : image_file != null
                        ? Image.memory(
                            image_file!,
                            width: 200,
                            height: 200,
                          )
                        : image != null
                            ? Image.network(
                                image!,
                                width: 200,
                                height: 200,
                              )
                            : Container(),
              ),

              SizedBox(height: 10),

              // action
              capture_btn(),

              upload_btn(),

              submit_btn(),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGETS

  // camera preview
  Widget camera_preview() {
    if (controller == null) {
      return Center(child: Container());
    }
    if (!controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return CameraPreview(controller!);
  }

  // upload button
  Widget upload_btn() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () async {
          camera_on = false;
          var tt = await Helpers.selectFile();

          if (tt != null) {
            image_file = tt;
          }
          del = false;
          setState(() {});
        },
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xFF3cff7f).withOpacity(0.6),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_rounded,
                  color: Colors.white,
                  size: 25,
                ),
                SizedBox(width: 10),
                Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // capture image button
  Widget capture_btn() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          del = false;
          camera_on = true;
          setState(() {});
          get_camera_details();
        },
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xFFff3c3c).withOpacity(0.6),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera,
                  color: Colors.white,
                  size: 25,
                ),
                SizedBox(width: 10),
                Text(
                  'Capture',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // submit button
  Widget submit_btn() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          if (del) {
            Navigator.pop(context, 'del');
          } else {
            Navigator.pop(context, image_file);
          }
        },
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xFF3c5bff).withOpacity(0.6),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Center(
            child: Text(
              del ? 'Remove' : 'Submit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
