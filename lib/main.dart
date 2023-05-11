import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sw_eventos/pages/home.dart';
import 'package:sw_eventos/pages/login.dart';
import 'package:sw_eventos/providers/push_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.prefs}) : super(key: key);
  final SharedPreferences prefs;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final pushProvider = PushNotication();
    pushProvider.initNotification();

    pushProvider.mensajes.listen((data) {
      final notification = FlutterLocalNotificationsPlugin();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: android);
      notification.initialize(initSettings);
      const androidDetails = AndroidNotificationDetails(
          'channel_id', 'channel_name', 'channel_description');
      const platform = NotificationDetails(android: androidDetails);

      notification.show(
        0, // id de la notificación
        'Hey!, Apareciste en una foto', // título
        'Guarda tus recuerdos!', // cuerpo
        platform, // detalles de la plataforma
        payload: data, // información adicional
      );
      FlutterLocalNotificationsPlugin().initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onSelectNotification: (String? payload) async {
          if (payload != null) {
            // ignore: deprecated_member_use
            await launch(payload);
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tus Recuerdos",
      home: widget.prefs.getString('user') != null ? GalleryScreen() : login(),
    );
  }
}
