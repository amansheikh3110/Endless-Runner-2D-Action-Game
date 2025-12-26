import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/start_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to landscape on app start
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Action Rider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}
