import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'RestAPI.dart';
import 'globals.dart';

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'FCM_01',
  '원격요청 알림',
  description: '원격요청 결과 알림 채널',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
FlutterLocalNotificationsPlugin();

// 백그라운드 핸들러 - top-level 함수여야 함 (별도 isolate로 실행)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await _localNotifications
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
  >()
      ?.createNotificationChannel(_channel);

  await _localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  print('백그라운드 FCM 수신: ${message.data}');
  _showNotification(message.data, skipSyscodeCheck: true);
}

Future<void> initFCM() async {
  // 알림 채널 생성 (Android)
  await _localNotifications
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
  >()
      ?.createNotificationChannel(_channel);

  await _localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  // 알림 권한 요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // iOS: 포그라운드에서도 알림 배너 표시
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // 백그라운드 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 포그라운드 메시지 처리
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('포그라운드 FCM 수신 data: ${message.data}');
    print('포그라운드 FCM notification: ${message.notification?.title} / ${message.notification?.body}');

    if (Platform.isIOS) {
      // iOS: setForegroundNotificationPresentationOptions로 시스템이 알림을 표시하므로
      // data 메시지일 경우에만 로컬 알림으로 직접 표시
      if (message.data.containsKey('msg')) {
        _showNotification(message.data, skipSyscodeCheck: false);
      }
      // notification 타입은 iOS 시스템이 자동으로 배너 표시
    } else {
      // Android: 포그라운드에서 시스템이 알림을 표시하지 않으므로 직접 표시
      if (message.data.containsKey('msg')) {
        _showNotification(message.data, skipSyscodeCheck: false);
      } else if (message.notification != null) {
        _showSimpleNotification(
          message.notification!.title ?? '',
          message.notification!.body ?? '',
        );
      }
    }
  });

  // 토큰 갱신 시 서버에 재등록
  FirebaseMessaging.instance.onTokenRefresh.listen((token) {
    _registerToken(token);
  });

  // 최초 토큰 서버 등록
  try {
    // iOS는 APNS 토큰을 먼저 확보해야 FCM 토큰 발급 가능
    if (Platform.isIOS) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      print('APNS 토큰: $apnsToken');
      if (apnsToken == null) {
        print('APNS 토큰 없음 (시뮬레이터일 경우 정상)');
        return;
      }
    }
    final token = await FirebaseMessaging.instance.getToken();
    print('현재 FCM 토큰: $token');
    if (token != null) {
      _registerToken(token);
    }
  } catch (e) {
    print('FCM 토큰 취득 실패 (시뮬레이터일 경우 정상): $e');
  }
}

Future<void> _registerToken(String token) async {


  try {
    await RestApiService().registUpdate(syscode, token, phoneCode);
    print('FCM 토큰 등록 완료: $token');
  } catch (e) {
    print('FCM 토큰 등록 실패: $e');
  }
}

// 로그인 완료 후 호출 - 현재 FCM 토큰을 서버에 등록
Future<void> registerFCMTokenAfterLogin() async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await _registerToken(token);
  }
}

void _showSimpleNotification(String title, String body) {
  if (title.isEmpty && body.isEmpty) return;

  _localNotifications.show(
    601,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

void _showNotification(
    Map<String, dynamic> data, {
      bool skipSyscodeCheck = false,
    }) {
  final msg = data['msg'] as String?;
  print('FCM msg 필드: $msg');
  if (msg == null || msg.isEmpty) return;

  final parts = msg.split('');
  print('FCM parts 개수: ${parts.length}, parts: $parts');
  if (parts.length < 9) return;

  print('FCM 개통코드 비교: parts[0]=${parts[0]}, syscode=$syscode');
  // 포그라운드: syscode 일치 여부 확인 / 백그라운드: 별도 isolate라 생략
  if (!skipSyscodeCheck && parts[0] != syscode) return;

  final storeName = parts[4]; // 상호명
  final command = parts[5]; // 원격제어명령 (0=해제, 1=경계, 2=선로점검, 4=부분경계, 7=문열림, 8=문닫힘)
  final status = parts[6]; // 진행상태 (0=접수, 10/30/40=실패, 20=완료)
  final isDone = parts[7]; // 원격완료여부 ("True"/"False")
  final isReceived = parts[8]; // 원격접수여부 ("True"/"False")

  String notifyMessage = '';

  if (status == '20') {
    if (isDone == 'True') {
      notifyMessage = _buildCommandMessage(command, '처리');
    } else {
      notifyMessage = '원격요청이 실패하였습니다. 관제실로 연락바랍니다.';
    }
  } else if (status == '0') {
    if (isReceived == 'True') {
      notifyMessage = _buildCommandMessage(command, '접수');
    } else {
      notifyMessage = '원격요청이 실패하였습니다. 관제실로 연락바랍니다.';
    }
  } else {
    notifyMessage = '원격요청이 실패하였습니다. 관제실로 연락바랍니다.';
  }

  if (notifyMessage.isEmpty) return;

  _localNotifications.show(
    600,
    '원격요청 알림서비스',
    '[$storeName]  $notifyMessage',
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

String _buildCommandMessage(String command, String action) {
  switch (command) {
    case '0':
      return '원격해제 요청이 ${action}되었습니다.';
    case '1':
      return '원격경계 요청이 ${action}되었습니다.';
    case '2':
      return '원격선로점검 요청이 ${action}되었습니다.';
    case '4':
      return '원격부분경계 요청이 ${action}되었습니다.';
    case '7':
      return '원격문열림 요청이 ${action}되었습니다.';
    case '8':
      return '원격문닫힘 요청이 ${action}되었습니다.';
    default:
      return '원격 요청이 ${action}되었습니다.';
  }
}
