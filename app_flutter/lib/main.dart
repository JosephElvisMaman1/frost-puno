import 'package:flutter/material.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'core/settings/user_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSettings.instance.load();
  await NotificationService.init();
  runApp(const FrostPunoApp());
}
