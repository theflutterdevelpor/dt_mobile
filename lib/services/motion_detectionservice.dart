import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RealtimeSocketService {
  static IO.Socket? _socket;
  static String? _currentToken;


  static final ValueNotifier<bool> connectionStatus =
  ValueNotifier<bool>(false);

  static bool get isConnected => connectionStatus.value;

  // ================= CONNECT =================
  static void connect(String token) {
    debugPrint(' [SOCKET] connect() called');


    if (_socket != null && _socket!.connected && _currentToken == token) {
      debugPrint(' [SOCKET] Already connected');
      return;
    }


    if (_currentToken != null && _currentToken != token) {
      debugPrint(' [SOCKET] Token changed → reconnecting');
      disconnect();
    }

    _currentToken = token;

    debugPrint(' [SOCKET] Connecting to server...');

    _socket = IO.io(
      'http://3.231.62.206:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'access_token': token})
          .enableReconnection()
          .build(),
    );

    _registerBaseListeners();

    _socket!.connect();
  }

  // ================= BASE LISTENERS =================
  static void _registerBaseListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      connectionStatus.value = true;
      debugPrint(' [SOCKET] Connected successfully');
      debugPrint(' Socket ID: ${_socket!.id}');
    });

    _socket!.onDisconnect((reason) {
      connectionStatus.value = false;
      debugPrint(' [SOCKET] Disconnected: $reason');
    });

    _socket!.onConnectError((error) {
      connectionStatus.value = false;
      debugPrint(' [SOCKET] Connect Error: $error');
    });

    _socket!.onError((error) {
      debugPrint(' [SOCKET] General Error: $error');
    });


    // _socket!.onAny((event, data) {
    //   debugPrint('📡 [SOCKET EVENT] $event');
    //   debugPrint('📦 [DATA] $data');
    // });
  }

  // ================= EVENT LISTEN =================
  static void on(String event, Function(dynamic data) callback) {
    if (_socket == null) {
      debugPrint(' [SOCKET] on() failed → socket null');
      return;
    }

    debugPrint(' [SOCKET] Listening on: $event');

    _socket!.on(event, (data) {
      debugPrint('📥 [$event] DATA RECEIVED');
      callback(data);
    });
  }


  static void off(String event) {
    _socket?.off(event);
    debugPrint(' [SOCKET] Stop listening: $event');
  }


  static void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      debugPrint(' [SOCKET] Emit failed → not connected');
      return;
    }

    debugPrint(' [SOCKET] Emit → $event');
    _socket!.emit(event, data);
  }

  // ================= DISCONNECT =================
  static void disconnect() {
    debugPrint(' [SOCKET] Disconnecting...');

    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();

    _socket = null;
    _currentToken = null;
    connectionStatus.value = false;
  }
}

