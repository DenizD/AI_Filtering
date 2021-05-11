import 'dart:typed_data';
import 'package:ai_filtering/components/rectangle_image_button_component.dart';
import 'package:ai_filtering/components/image_effects_component.dart';
import 'package:flutter/material.dart';
import 'package:ai_filtering/components/image_selection_component.dart';
import 'package:before_after/before_after.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:ai_filtering/utils/constants.dart';
import 'package:image_pixels/image_pixels.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showProgress = false;

  double _screenWidth = 0;
  double _screenHeight = 0;
  double _screenWidthPixel = 0;
  double _screenHeightPixel = 0;

  File inputImageFile;
  Uint8List outputImageData;

  void getScreenSizes(context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height - 20;
    _screenWidthPixel = window.physicalSize.width;
    _screenHeightPixel = window.physicalSize.height;

    print('Logical size: $_screenWidth, $_screenHeight');
    print(
        'Physical size: ${_screenWidthPixel.floor()}, ${_screenHeightPixel.floor()}');
  }

  @override
  Widget build(BuildContext context) {
    getScreenSizes(context);

    return Stack(
      children: [
        Opacity(
          opacity: _showProgress ? 0.3 : 1.0,
          child: Column(
            children: [
              ImagePixels.container(
                defaultColor: Colors.white,
                imageProvider:
                    inputImageFile != null ? FileImage(inputImageFile) : null,
                colorAlignment: Alignment.topLeft,
                child: Container(
                  height: _screenHeight * Constants.RATIO_IMAGE_CONTAINER,
                  width: _screenWidth,
                  child: (inputImageFile != null && outputImageData == null)
                      ? Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff7c94b6),
                              image: DecorationImage(
                                image: FileImage(inputImageFile),
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                          ),
                        )
                      : (inputImageFile != null && outputImageData != null)
                          ? BeforeAfter(
                              imageCornerRadius: 12.0,
                              thumbRadius: 12.0,
                              thumbColor: Colors.white,
                              beforeImage: Image.file(inputImageFile),
                              afterImage: Image.memory(outputImageData),
                            )
                          : SizedBox(height: 0),
                ),
              ),
              inputImageFile != null
                  ? ImageEffectsComponent(
                      _screenWidth,
                      _screenHeight * Constants.RATIO_EFFECT_CONTAINER,
                      inputImageFile,
                      () {
                        setState(() {
                          _showProgress = true;
                        });
                      },
                      (Uint8List outputData) {
                        setState(() {
                          outputImageData = outputData;
                          _showProgress = false;
                        });
                      },
                    )
                  : SizedBox(
                      height: _screenHeight * Constants.RATIO_EFFECT_CONTAINER),
              Container(
                height:
                    _screenHeight * Constants.RATIO_IMAGE_PICKER_CONTAINER + 20,
                width: _screenWidth,
                child: Row(
                  mainAxisAlignment: outputImageData == null
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        ImageSelectionComponent(
                          _screenHeight *
                              Constants.RATIO_IMAGE_PICKER_CONTAINER,
                          (_screenHeightPixel * Constants.RATIO_IMAGE_CONTAINER)
                              .floor(),
                          _screenWidthPixel.floor(),
                          () {
                            setState(() {
                              inputImageFile = null;
                              outputImageData = null;
                            });
                          },
                          (File inputFile) {
                            setState(() {
                              inputImageFile = inputFile;
                            });
                          },
                        ),
                        SizedBox(height: 2.0),
                        Text('Upload a Photo')
                      ],
                    ),
                    outputImageData != null
                        ? Column(
                            children: [
                              RectangleImageButton(
                                _screenHeight *
                                    Constants.RATIO_IMAGE_PICKER_CONTAINER,
                                Icons.save_alt_rounded,
                                () async {
                                  final result =
                                      await ImageGallerySaver.saveImage(
                                    outputImageData,
                                    quality: 100,
                                    name: "ai_filter",
                                  );
                                  if (result['isSuccess']) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Image is successfully saved to gallery'),
                                    ));
                                  } else {
                                    print('Image is not saved');
                                    print(result);
                                  }
                                },
                              ),
                              SizedBox(height: 2.0),
                              Text('Save Image')
                            ],
                          )
                        : SizedBox(height: 0),
                  ],
                ),
              ),
            ],
          ),
        ),
        _showProgress
            ? Center(
                child: Container(
                  alignment: Alignment.center,
                  height: 180.0,
                  width: 180.0,
                  child: LiquidCircularProgressIndicator(
                    value: 0.5,
                    valueColor: AlwaysStoppedAnimation(Colors.grey[600]),
                    backgroundColor: Colors.white,
                    borderColor: Colors.red,
                    borderWidth: 0.0,
                    direction: Axis.horizontal,
                    center: Text("Processing..."),
                  ),
                ),
              )
            : Container(height: 0),
      ],
    );
  }
}
