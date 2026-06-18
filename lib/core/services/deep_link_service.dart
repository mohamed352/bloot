import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';

@lazySingleton
class DeepLinkService {
  DeepLinkService({required AppLinks appLinks}) : _appLinks = appLinks;

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  final StreamController<Uri> _linkController = StreamController<Uri>.broadcast();

  Stream<Uri> get onLink => _linkController.stream;

  Future<void> initialize() async {
    // Handle app already running
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      AppLogger.info('Deep link received: $uri', tag: 'DeepLink');
      _linkController.add(uri);
    });

    // Handle cold start
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      AppLogger.info('Deep link cold start: $initialUri', tag: 'DeepLink');
      _linkController.add(initialUri);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _linkController.close();
  }
}
