import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ProviderScope is the root of the Riverpod graph. Notification/timezone
  // initialization is added here on Day 3.
  runApp(const ProviderScope(child: MedTrackApp()));
}
