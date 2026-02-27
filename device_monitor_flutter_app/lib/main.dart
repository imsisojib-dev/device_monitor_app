import 'package:flutter/material.dart';
import 'package:device_monitor/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initEnvConfig();
  await initApp();
}
