import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// App-wide theme mode. Overridden at startup from SharedPreferences.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
