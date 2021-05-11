import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:ai_filtering/utils/constants.dart';
import 'dart:io';
import 'dart:ui' show Color;
import 'package:image/image.dart' as IMG;

class ImageProcessModel {
  Uint8List outputImageData;

  // Make output data same size with input data
  Uint8List matchInputOutputSize(Uint8List inputData, Uint8List outputData) {
    IMG.Image inputImg = IMG.decodeImage(inputData);
    IMG.Image outputImg = IMG.decodeImage(outputData);

    IMG.Image resizedImg = IMG.copyResize(outputImg,
        width: inputImg.width, height: inputImg.height);

    Uint8List resizedData = IMG.encodePng(resizedImg);

    return resizedData;
  }

  Uint8List extractForegroundMask(Uint8List inputData, Uint8List maskData) {
    IMG.Image inputImg = IMG.decodeImage(inputData);
    IMG.Image maskImg = IMG.decodeImage(maskData);

    IMG.Image outputImg = inputImg & maskImg;

    Uint8List outputData = IMG.encodePng(outputImg);

    return outputData;
  }

  // Uint8List imageToByteListFloat32(IMG.Image image, int inputWidth,
  //     int inputHeight, double mean, double std) {
  //   var convertedBytes = Float32List(1 * inputWidth * inputHeight * 3);
  //   var buffer = Float32List.view(convertedBytes.buffer);
  //   int pixelIndex = 0;
  //   for (var i = 0; i < inputHeight; i++) {
  //     for (var j = 0; j < inputWidth; j++) {
  //       var pixel = image.getPixel(j, i);
  //       buffer[pixelIndex++] = (IMG.getRed(pixel) - mean) / std;
  //       buffer[pixelIndex++] = (IMG.getGreen(pixel) - mean) / std;
  //       buffer[pixelIndex++] = (IMG.getBlue(pixel) - mean) / std;
  //     }
  //   }
  //   return convertedBytes.buffer.asUint8List();
  // }

  // Load tflite model file
  loadModel(String modelFile, {String labelsFile}) async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        model: modelFile,
        labels: labelsFile,
      );
      print(res);
    } on PlatformException {
      print("cant load model");
    }
  }

  // White Box Cartoonization
  // Ref : https://systemerrorwang.github.io/White-box-Cartoonization/
  cartoonize(File inputFile) async {
    print('Loading model ...');
    await loadModel(Constants.MODEL_FILE_CARTOON);
    print('Model loaded.');

    Uint8List inputData = await inputFile.readAsBytes();

    Uint8List outputData = await Tflite.runPix2PixOnImage(
      path: inputFile.path,
      imageMean: 127.5,
      imageStd: 127.5,
      outputType: 'png',
      asynch: true,
    );

    outputImageData = matchInputOutputSize(inputData, outputData);
  }

  // DeepLab Image Segmentation
  // Ref : https://paperswithcode.com/paper/rethinking-atrous-convolution-for-semantic
  bgRemoval(File inputFile) async {
    print('Loading model ...');
    await loadModel(Constants.MODEL_FILE_SEGMENTATION,
        labelsFile: Constants.LABELS_FILE_SEGMENTATION);
    print('Model loaded.');
    List<int> labelColors = [
      Color.fromARGB(255, 0, 0, 0).value, // background
      Color.fromARGB(255, 128, 0, 0).value, // aeroplane
      Color.fromARGB(255, 0, 128, 0).value, // biyclce
      Color.fromARGB(255, 128, 128, 0).value, // bird
      Color.fromARGB(255, 0, 0, 128).value, // boat
      Color.fromARGB(255, 128, 0, 128).value, // bottle
      Color.fromARGB(255, 0, 128, 128).value, // bus
      Color.fromARGB(255, 128, 128, 128).value, // car
      Color.fromARGB(255, 64, 0, 0).value, // cat
      Color.fromARGB(255, 192, 0, 0).value, // chair
      Color.fromARGB(255, 64, 128, 0).value, // cow
      Color.fromARGB(255, 192, 128, 0).value, // diningtable
      Color.fromARGB(255, 64, 0, 128).value, // dog
      Color.fromARGB(255, 192, 0, 128).value, // horse
      Color.fromARGB(255, 64, 128, 128).value, // motorbike
      Color.fromARGB(255, 255, 255, 255).value, // person
      Color.fromARGB(255, 0, 64, 0).value, // potted plant
      Color.fromARGB(255, 128, 64, 0).value, // sheep
      Color.fromARGB(255, 0, 192, 0).value, // sofa
      Color.fromARGB(255, 128, 192, 0).value, // train
      Color.fromARGB(255, 0, 64, 128).value, // tv-monitor
    ];
    Uint8List outputData = await Tflite.runSegmentationOnImage(
        path: inputFile.path, // required
        imageMean: 0.0, // defaults to 0.0
        imageStd: 255.0, // defaults to 255.0
        labelColors: labelColors,
        outputType: "png", // defaults to "png"
        asynch: true // defaults to true
        );

    Uint8List inputData = await inputFile.readAsBytes();
    outputImageData = matchInputOutputSize(inputData, outputData);
    outputImageData = extractForegroundMask(inputData, outputImageData);
  }
}
