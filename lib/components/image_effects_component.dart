import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ai_filtering/components/effect_component.dart';
import 'package:ai_filtering/utils/constants.dart';
import 'dart:io';
import 'package:ai_filtering/models/image_process_model.dart';

class ImageEffectsComponent extends StatelessWidget {
  final double width;
  final double height;
  final File inputImageFile;
  final Function beforeImageUpload;
  final Function onImageUpload;

  Uint8List outputImageData;

  ImageEffectsComponent(this.width, this.height, this.inputImageFile,
      this.beforeImageUpload, this.onImageUpload);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment(0, 0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: false,
        children: <Widget>[
          EffectComponent(
            height,
            Constants.FILE_FILTER_DRAW,
            Colors.grey[500],
            'Cartoonize',
            () async {
              beforeImageUpload();
              ImageProcessModel imageProcessor = ImageProcessModel();
              await imageProcessor.cartoonize(inputImageFile);
              outputImageData = imageProcessor.outputImageData;
              onImageUpload(outputImageData);
            },
          ),
          EffectComponent(
            height,
            Constants.FILE_FILTER_SEGMENT,
            Colors.grey[500],
            'BgRemoval',
            () async {
              beforeImageUpload();
              ImageProcessModel imageProcessor = ImageProcessModel();
              await imageProcessor.bgRemoval(inputImageFile);
              outputImageData = imageProcessor.outputImageData;
              onImageUpload(outputImageData);
            },
          ),
        ],
      ),
    );
  }
}
