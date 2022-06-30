import 'package:flutter/material.dart';
import 'package:store_camera_widget/painting/edge_insets.dart';

class ImageUrlWidget extends StatelessWidget {
  final String? url;

  final double? width;
  final double? height;
  final double? size;
  final BoxFit fit;
  final Widget? loading;
  final Color? loadingColor;
  final Widget? error;
  final Color? errorColor;

  const ImageUrlWidget(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.size,
    required this.fit,
    this.loading,
    this.loadingColor,
    this.error,
    this.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    return url != null
        ? Image.network(
            url!,
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
                  ImageLoading(
                    color: loadingColor,
                  );
            },
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) =>
                this.error ?? ImageError(color: errorColor),
          )
        : error ?? ImageError(color: errorColor);
  }
}

class ImageLoading extends StatelessWidget {
  final Color? color;

  const ImageLoading({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Icon(
      Icons.downloading,
      color: color ?? Theme.of(context).hintColor,
    ));
  }
}

class ImageError extends StatelessWidget {
  final Color? color;

  const ImageError({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Icon(
      Icons.image_not_supported,
      color: color ?? Theme.of(context).hintColor,
    ));
  }
}
