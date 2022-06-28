import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static FirebaseStorage firebaseStorage([String? bucket]) => bucket != null
      ? FirebaseStorage.instanceFor(bucket: bucket)
      : FirebaseStorage.instance;

  static String? getExtension(String name) {
    try {
      return name.split('.').last;
    } catch (_) {}
    return null;
  }

  static Reference? refFromURL(String url) {
    try {
      return FirebaseStorage.instance.refFromURL(url);
    } catch (_) {}
    return null;
  }

  static Future<String?> getDownloadURL(String? path, [String? bucket]) async {
    if (path == null || path.trim().isEmpty) return null;

    String? downloadURL;
    try {
      final ref = StorageService.firebaseStorage(bucket).ref(path);
      downloadURL = await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return downloadURL;
  }

  static Future<Uint8List?> getBytes(String? path, [String? bucket]) async {
    if (path == null || path.trim().isEmpty) return null;
    Uint8List? bytes;
    try {
      final ref = StorageService.firebaseStorage(bucket).ref(path);
      bytes = await ref.getData();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return bytes;
  }

  static UploadTask uploadFile(Uint8List bytes, String path,
      {String? bucket, String? name, String? extension, String? mimeType}) {
    String fileName = name ?? const Uuid().v4();
    String fileExtension = extension != null ? '.$extension' : '';

    return StorageService.firebaseStorage(bucket)
        .ref('$path/$fileName$fileExtension')
        .putData(bytes,
            mimeType != null ? SettableMetadata(contentType: mimeType) : null);
  }

  static Future<bool> tryDeleteFile(String path, [String? bucket]) async {
    try {
      await deleteFile(path, bucket);
      return true;
    } catch (_) {}
    return false;
  }

  static Future<void> deleteFile(String path, [String? bucket]) =>
      StorageService.firebaseStorage(bucket).ref(path).delete();
}

abstract class FirebaseStorageImageCache {
  Future<Uint8List?> get(String key);

  Future<void> set(String key, Uint8List bytes);

  Future<void> evict(String key);
}

class FirebaseStorageImageProvider
    extends ImageProvider<FirebaseStorageImageProvider> {
  final String path;
  final String? bucket;

  final FirebaseStorageImageCache? cache;

  const FirebaseStorageImageProvider(this.path, {this.bucket, this.cache});

  @override
  Future<FirebaseStorageImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return SynchronousFuture<FirebaseStorageImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(
      FirebaseStorageImageProvider key, DecoderCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode, cache),
      scale: 1.0,
      chunkEvents: chunkEvents.stream,
      informationCollector: () sync* {
        yield ErrorDescription('FireStorageImageProvider : $bucket $path ');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      FirebaseStorageImageProvider key,
      StreamController<ImageChunkEvent> chunkEvents,
      DecoderCallback decode,
      FirebaseStorageImageCache? cache) async {
    try {
      assert(key == this);
      try {
        if (cache != null) {
          final cacheKey = _cacheKey(key);
          final cacheBytes = await cache.get(cacheKey);
          if (cacheBytes != null) {
            try {
              final codec = await decode(cacheBytes);
              return codec;
            } catch (e) {
              await cache.evict(cacheKey);
            }
          }
        }
      } catch (_) {}

      chunkEvents.add(const ImageChunkEvent(
        cumulativeBytesLoaded: 1,
        expectedTotalBytes: 100,
      ));

      Uint8List? bytes = await StorageService.getBytes(key.path, key.bucket);
      chunkEvents.add(const ImageChunkEvent(
        cumulativeBytesLoaded: 100,
        expectedTotalBytes: 100,
      ));

      if (bytes == null || bytes.lengthInBytes == 0) {
        // The file may become available later.
        PaintingBinding.instance.imageCache.evict(key);
        throw StateError(
            '${_cacheKey(key)} is empty and cannot be loaded as an image.');
      }

      try {
        final codec = await decode(bytes);
        try {
          if (cache != null) {
            await cache.set(_cacheKey(key), bytes);
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

  String _cacheKey(FirebaseStorageImageProvider key) {
    final sb = StringBuffer();
    if (key.bucket != null) {
      sb.write('${key.bucket}&');
    }
    sb.write(key.path);
    return sb.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirebaseStorageImageProvider &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          bucket == other.bucket;

  @override
  int get hashCode => path.hashCode ^ bucket.hashCode;
}

class FirebaseStorageImage extends StatelessWidget {
  final String? id;
  final String? bucket;

  final FirebaseStorageImageCache? cache;
  final double? width;
  final double? height;
  final double? size;
  final BoxFit fit;
  final Widget? loading;
  final Color? loadingColor;
  final Widget? error;
  final Color? errorColor;

  const FirebaseStorageImage(this.id,
      {super.key,
      this.bucket,
      this.cache,
      this.width,
      this.height,
      this.size,
      this.fit = BoxFit.cover,
      this.loading,
      this.loadingColor,
      this.error,
      this.errorColor});

  @override
  Widget build(BuildContext context) => id != null
      ? Image(
          image: FirebaseStorageImageProvider(
            id!,
            bucket: bucket,
            cache: cache,
          ),
          width: width ?? size,
          height: width ?? size,
          fit: fit,
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }
            return loading ??
                FirebaseStorageImageLoading(
                  color: loadingColor,
                );
          },
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) =>
              this.error ?? FirebaseStorageImageError(color: errorColor),
        )
      : error ?? FirebaseStorageImageError(color: errorColor);
}

class FirebaseStorageImageLoading extends StatelessWidget {
  final Color? color;

  const FirebaseStorageImageLoading({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Icon(
      Icons.downloading,
      color: color ?? Theme.of(context).hintColor,
    ));
  }
}

class FirebaseStorageImageError extends StatelessWidget {
  final Color? color;

  const FirebaseStorageImageError({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Icon(
      Icons.image_not_supported,
      color: color ?? Theme.of(context).hintColor,
    ));
  }
}
