import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? socket;
  static String? _currentToken;

  static final ValueNotifier<bool> connectionStatus =
  ValueNotifier<bool>(false);

  static bool get connected => connectionStatus.value;

  static void connect(String token) {
    if (socket != null && socket!.connected && _currentToken == token) {
      return;
    }

    if (_currentToken != null && _currentToken != token) {
      disconnect();
    }

    _currentToken = token;
    print("====================connecting function");
    socket = IO.io(
      'http://3.231.62.206:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'access_token': token})
          .enableReconnection()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      connectionStatus.value = true;
      debugPrint(' Socket connected');
    });

    socket!.onDisconnect((_) {
      connectionStatus.value = false;
      debugPrint(' Socket disconnected');
    });

    socket!.onConnectError((e) {
      connectionStatus.value = false;
      debugPrint(' Socket error: $e');
    });
  }

  static void disconnect() {
    socket?.clearListeners();
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    _currentToken = null;
  }

  static void on(String event, Function(dynamic) cb) {
    socket?.on(event, cb);
  }

  static void off(String event) {
    socket?.off(event);
  }


  // static void onAny() {
  //   socket?.onAny((event, data) {
  //     debugPrint('📡 SOCKET EVENT => $event');
  //     debugPrint('📦 DATA => $data');
  //   });
  // }
}
