import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

Future showNotification() async {
  int rndmIndex = Random().nextInt(10000);

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    '$rndmIndex.0',
    'appId',
    channelDescription: 'appName desc',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );
  var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    threadIdentifier: 'thread_id',
  );
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin?.show(
    rndmIndex,
    'test Title',
    'test Desc',
    platformChannelSpecifics,
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = DarwinInitializationSettings();

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  WidgetsFlutterBinding.ensureInitialized();

  flutterLocalNotificationsPlugin?.initialize(
    initializationSettings,
  );

  Workmanager().executeTask((taskName, inputData) {
    print('Inside WorkManager execute');
    showNotification();
    return Future.value(true);
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    initWorkManager();
    super.initState();
  }

  void initWorkManager() async {
    try {
      print('iniside try,,,,,,,,,,,catch workmanager block');
      Workmanager()
          .initialize(callbackDispatcher, isInDebugMode: true)
          .then((_) async {
        await Workmanager().registerPeriodicTask(
          simplePeriodicTask,
          simplePeriodicTask,
        );
      });
    } catch (e) {
      print('Exception in register work manager');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Work manager Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
    );
  }
}
