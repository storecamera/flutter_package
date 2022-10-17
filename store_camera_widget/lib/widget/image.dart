import 'package:flutter/material.dart';

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
    final url = this.url;
    final width = this.width ?? size;
    final height = this.height ?? size;

    if (url == null || url.trim().isEmpty) {
      return error ??
          ImageNotSupported(
            width: width,
            height: height,
            color: errorColor,
          );
    }
    return Image.network(
      url,
      width: width,
      height: height,
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
              width: width,
              height: height,
              color: loadingColor,
            );
      },
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) =>
          this.error ??
          ImageNotSupported(width: width, height: height, color: errorColor),
    );
  }
}

class ImageLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const ImageLoading({super.key, this.width, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        alignment: AlignmentDirectional.center,
        child: Icon(
          Icons.downloading,
          color: color ?? Theme.of(context).hintColor,
        ));
  }
}

class ImageNotSupported extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const ImageNotSupported({super.key, this.width, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: AlignmentDirectional.center,
      child: Icon(
        Icons.image_not_supported,
        color: color ?? Theme.of(context).hintColor,
      ),
    );
  }
}
