import 'dart:io';

import 'package:hive/hive.dart';

import '../../native_platform/native_platform.dart';
import 'active_window.dart';
import 'logger.dart';
import 'storage.dart';

/// Toggle suspend / resume for the active, foreground window.
Future<void> toggleActiveWindow({
  bool shouldLog = false,
  required NativePlatform nativePlatform,
}) async {
  Logger.shouldLog = shouldLog;
  Hive.init(Directory.systemTemp.path);
  final storage = Storage();

  final activeWindow = ActiveWindow(
    nativePlatform,
    ProcessRepository.init(),
    storage,
    await nativePlatform.activeWindow(),
  );

  final savedPid = await storage.getInt('pid');

  if (savedPid != null) {
    final successful = await activeWindow.resume(savedPid);
    if (!successful) await Logger.log('Failed to resume successfully.');
  } else {
    final successful = await activeWindow.suspend();
    if (!successful) await Logger.log('Failed to suspend successfully.');
  }

  await Hive.close();
}
