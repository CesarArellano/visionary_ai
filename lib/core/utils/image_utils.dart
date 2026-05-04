import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:visionary_ai/core/constants/app_constants.dart';

class ImageUtils {
  Future<Uint8List> compress(XFile file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: AppConstants.kImageMaxWidth,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return bytes;
    }

    return byteData.buffer.asUint8List();
  }
}