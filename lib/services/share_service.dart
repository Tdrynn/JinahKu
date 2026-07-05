import 'dart:async';
import 'package:share_handler/share_handler.dart';

class ShareService {
  static final ShareHandlerPlatform _handler =
      ShareHandlerPlatform.instance;

  static StreamSubscription? subscription;

  static void startListening(
      Function(SharedMedia media) onReceive) {

    subscription = _handler.sharedMediaStream.listen((media) {
      onReceive(media);
    });
  }

  static Future<SharedMedia?> getInitialMedia() async {
    return await _handler.getInitialSharedMedia();
  }

  static void dispose() {
    subscription?.cancel();
  }
}