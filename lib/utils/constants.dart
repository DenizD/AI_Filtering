class Constants {
  // SECTION RATIOS
  static final RATIO_IMAGE_CONTAINER = 0.84;
  static final RATIO_EFFECT_CONTAINER = 0.1;
  static final RATIO_IMAGE_PICKER_CONTAINER = 0.06;

  static final TITLE_NAME = 'AI Photo Filter';

  static final FILE_FILTER_DRAW = 'assets/images/draw_ai.png';
  static final FILE_FILTER_SEGMENT = 'assets/images/segment_ai.png';

  static final MODEL_FILE_CARTOON =
      'assets/models/whitebox_cartoon_gan_int8.tflite';

  static final MODEL_FILE_SEGMENTATION =
      'assets/models/deeplabv3_257_mv_gpu.tflite';
  static final LABELS_FILE_SEGMENTATION =
      'assets/models/deeplabv3_257_mv_gpu.txt';
}
