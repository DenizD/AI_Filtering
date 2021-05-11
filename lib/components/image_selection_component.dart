import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:ai_filtering/components/rectangle_image_button_component.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter/file_input.dart';

class ImageSelectionComponent extends StatelessWidget {
  File inputImageFile;
  final _picker = ImagePicker();

  final double size;
  final int maxImageHeight;
  final int maxImageWidth;
  final Function beforeImageSelected;
  final Function onImageSelected;

  ImageSelectionComponent(this.size, this.maxImageHeight, this.maxImageWidth,
      this.beforeImageSelected, this.onImageSelected);

  Future _pickImage(imageSource) async {
    beforeImageSelected();
    final pickedFile = await _picker.getImage(
      source: imageSource,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      inputImageFile = File(pickedFile.path);
      var size = ImageSizeGetter.getSize(FileInput(inputImageFile));

      inputImageFile = await ImageCropper.cropImage(
        maxHeight: maxImageHeight,
        maxWidth: maxImageWidth,
        compressQuality: 100,
        compressFormat: ImageCompressFormat.jpg,
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(
          ratioX: maxImageWidth.toDouble(),
          ratioY: maxImageHeight.toDouble(),
        ),
        androidUiSettings: AndroidUiSettings(),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );
      onImageSelected(inputImageFile);
    } else {
      print('No image selected.');
    }
  }

  void _showImagePicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _pickImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _pickImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return RectangleImageButton(
      size,
      Icons.add_circle,
      () {
        _showImagePicker(context);
      },
    );
  }
}
