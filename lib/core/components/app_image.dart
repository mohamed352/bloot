import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bloot/core/components/image_error_placeholder.dart';
import 'package:bloot/core/components/network_image_widget.dart';

enum _ImageType { asset, network, file, memory }

class AppImage extends StatelessWidget {
  const AppImage.asset(
    this._source, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : _bytes = null,
       _type = _ImageType.asset;

  const AppImage.network({
    super.key,
    required String url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : _source = url,
       _bytes = null,
       _type = _ImageType.network;

  const AppImage.file({
    super.key,
    required String filePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : _source = filePath,
       _bytes = null,
       _type = _ImageType.file;

  const AppImage.memory({
    super.key,
    required Uint8List bytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : _source = null,
       _bytes = bytes,
       _type = _ImageType.memory;

  final String? _source;
  final Uint8List? _bytes;
  final _ImageType _type;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  static Future<void> precacheAssets(BuildContext context, List<String> paths) {
    return Future.wait(paths.map((p) => precacheImage(AssetImage(p), context)));
  }

  static Future<void> precacheNetwork(BuildContext context, List<String> urls) {
    return Future.wait(
      urls.map((u) => precacheImage(CachedNetworkImageProvider(u), context)),
    );
  }

  ImageProvider get _provider => switch (_type) {
    _ImageType.asset => AssetImage(_source!),
    _ImageType.network => CachedNetworkImageProvider(_source!),
    _ImageType.file => FileImage(File(_source!)),
    _ImageType.memory => MemoryImage(_bytes!),
  };

  @override
  Widget build(BuildContext context) {
    final image = _type == _ImageType.network
        ? NetworkImageWidget(
            url: _source!,
            width: width,
            height: height,
            fit: fit,
          )
        : _BaseImageWidget(
            provider: _provider,
            width: width,
            height: height,
            fit: fit,
          );

    return borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: image)
        : image;
  }
}

class _BaseImageWidget extends StatelessWidget {
  const _BaseImageWidget({
    required this.provider,
    this.width,
    this.height,
    required this.fit,
  });

  final ImageProvider provider;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: provider,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, error, stackTrace) =>
          ImageErrorPlaceholder(width: width, height: height),
    );
  }
}
