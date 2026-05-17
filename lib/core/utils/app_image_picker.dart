import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/generated/locale_keys.g.dart';

abstract class AppImagePicker {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage(BuildContext context) async {
    final ImageSource? source = await _showSourceSheet(context);
    if (source == null) return null;

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        AppLogger.debug('Image pick cancelled', tag: LogTags.ui);
        return null;
      }

      AppLogger.debug('Image picked: ${picked.name}', tag: LogTags.ui);
      return File(picked.path);
    } catch (error) {
      AppLogger.error('Image pick failed: $error', tag: LogTags.ui);
      return null;
    }
  }

  static Future<ImageSource?> _showSourceSheet(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded),
                  title: Text(LocaleKeys.imageSourceCamera.tr()),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: Text(LocaleKeys.imageSourceGallery.tr()),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
