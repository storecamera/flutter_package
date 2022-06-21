import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static String? getExtension(String name) {
    try {
      return name.split('.').last;
    } catch (_) {}
    return null;
  }

  static Future<String?> getDownloadURL(String? path) async {
    if (path == null || path.trim().isEmpty) return null;

    String? downloadURL;
    try {
      final ref = FirebaseStorage.instance.ref(path);
      downloadURL = await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return downloadURL;
  }

  static Future<Uint8List?> getBytes(String? path) async {
    if (path == null || path.trim().isEmpty) return null;

    Uint8List? bytes;
    try {
      final ref = FirebaseStorage.instance.ref(path);
      bytes = await ref.getData();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return bytes;
  }

  static UploadTask uploadFile(Uint8List bytes, String path,
      {String? name, String? extension, String? mimeType}) {
    String fileName = name ?? const Uuid().v4();
    String fileExtension = extension != null ? '.$extension' : '';

    return FirebaseStorage.instance
        .ref('$path/$fileName$fileExtension')
        .putData(bytes,
            mimeType != null ? SettableMetadata(contentType: mimeType) : null);
  }

  static Future<bool> tryDeleteFile(String path) async {
    try {
      await FirebaseStorage.instance.ref(path).delete();
      return true;
    } catch (_) {}
    return false;
  }

  static Future<void> deleteFile(String path) {
    return FirebaseStorage.instance.ref(path).delete();
  }
}

abstract class FireStorageImageCache {
  Future<Uint8List?> get(String key);

  Future<void> set(String key, Uint8List bytes);

  Future<void> evict(String key);
}

class FireStorageImageProvider extends ImageProvider<FireStorageImageProvider> {
  final String fireStoragePath;
  final FireStorageImageCache? cache;

  const FireStorageImageProvider(this.fireStoragePath, [this.cache]);

  @override
  Future<FireStorageImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FireStorageImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(
      FireStorageImageProvider key, DecoderCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode, cache),
      scale: 1.0,
      chunkEvents: chunkEvents.stream,
      informationCollector: () sync* {
        yield ErrorDescription('FireStorageImageProvider : $fireStoragePath');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      FireStorageImageProvider key,
      StreamController<ImageChunkEvent> chunkEvents,
      DecoderCallback decode,
      FireStorageImageCache? cache) async {
    try {
      assert(key == this);
      try {
        if (cache != null) {
          final cacheBytes = await cache.get(key.fireStoragePath);
          if (cacheBytes != null) {
            try {
              final codec = await decode(cacheBytes);
              return codec;
            } catch (e) {
              await cache.evict(key.fireStoragePath);
            }
          }
        }
      } catch (_) {}

      final url = await StorageService.getDownloadURL(key.fireStoragePath);
      if (url == null) {
        // The file may become available later.
        PaintingBinding.instance.imageCache.evict(key);
        throw StateError(
            '${key.fireStoragePath} url is empty and cannot be loaded as an image.');
      }

      chunkEvents.add(const ImageChunkEvent(
        cumulativeBytesLoaded: 100,
        expectedTotalBytes: 0,
      ));

      Uint8List bytes = await _downloads(Uri.parse(url), chunkEvents);
      if (bytes.lengthInBytes == 0) {
        // The file may become available later.
        PaintingBinding.instance.imageCache.evict(key);
        throw StateError(
            '${key.fireStoragePath} is empty and cannot be loaded as an image.');
      }

      try {
        final codec = await decode(bytes);
        try {
          if (cache != null) {
            await cache.set(key.fireStoragePath, bytes);
          }
        } catch (_) {}
        return codec;
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }

  Future<Uint8List> _downloads(
      Uri uri, StreamController<ImageChunkEvent> chunkEvents) {
    Completer<Uint8List> c = Completer();

    http.Client().send(http.Request('GET', uri)).then((response) {
      final total = response.contentLength;
      List<int> bytes = [];
      int received = 0;

      response.stream.listen((value) {
        bytes.addAll(value);
        received += value.length;

        if (total != null) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: received,
            expectedTotalBytes: total,
          ));
        }
      }, onDone: () {
        if (total != null) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: total,
            expectedTotalBytes: total,
          ));
        } else {
          chunkEvents.add(const ImageChunkEvent(
            cumulativeBytesLoaded: 100,
            expectedTotalBytes: 100,
          ));
        }

        c.complete(Uint8List.fromList(bytes));
      }, onError: (Object error, [StackTrace? stackTrace]) {
        c.completeError(error, stackTrace);
      });
    }, onError: (_) => c.completeError(_));

    return c.future;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FireStorageImageProvider &&
          runtimeType == other.runtimeType &&
          fireStoragePath == other.fireStoragePath;

  @override
  int get hashCode => fireStoragePath.hashCode;
}
