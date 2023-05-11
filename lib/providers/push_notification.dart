import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotication {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _mensajesStreamController = StreamController<String>.broadcast();
  Stream<String> get mensajes => _mensajesStreamController.stream;

  initNotification() {
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then((token) async {
      print('===== FCM Token =====');
      print(token);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("tokenMobile", token!);

      // fTEMf4FGQh67t-DT73TNob:APA91bFz1OnwkPL7zHubdRVKA62cCM4NJB6Ld6nff9QUIzzs8dG4X-NIUo5jBOcV9vSt6sWD4AMPhC3xrvZk3JS-O6BT5IeloZzcL8kZStcQO12xQEgiqtOAPDAeZi0u7e2_WoC2fxH0
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data['url'];
      _mensajesStreamController.sink.add(data);
    });

    // Escucha las notificaciones cuando la app está cerrada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data['url'];
      _mensajesStreamController.sink.add(data);
    });

    // Future<void> _firebaseMessagingBackgroundHandler(
    //     RemoteMessage message) async {
    //   final data = message.data['url'];
    //   _mensajesStreamController.sink.add(data);
    // }

    // // Escucha las notificaciones cuando la app está en segundo plano
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // // Función para manejar las notificaciones en segundo plano
  }

  dispose() {
    _mensajesStreamController.close();
  }
}
