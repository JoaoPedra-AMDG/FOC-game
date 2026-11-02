import 'package:flutter/material.dart';

import 'screens/transform_lab.dart';
import 'theme/game_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'FOC FAST · Field Lab',
      debugShowCheckedModeBanner: false,
      theme: gameTheme(),
      home: const TransformLab(),
    ),
  );
}
