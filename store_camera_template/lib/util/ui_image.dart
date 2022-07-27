import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';

class UiImageUtil {
  static Future<ui.Image> decodeImageFromList(Uint8List bytes) {
    Completer<ui.Image> c = Completer();
    ui.decodeImageFromList(
      bytes,
      (ui.Image result) {
        c.complete(result);
      },
    );
    return c.future;
  }

  static Future<ui.Image> decodeImageFromPixels(
    int width,
    int height,
    Uint8List pixels, {
    ui.PixelFormat format = ui.PixelFormat.rgba8888,
  }) {
    Completer<ui.Image> c = Completer();
    ui.decodeImageFromPixels(pixels, width, height, format, (results) {
      c.complete(results);
    });
    return c.future;
  }
}
