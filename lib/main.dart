import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/ai_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AiService().loadModel();
  runApp(const DrDermAi());
}

class DrDermAi extends StatelessWidget {
  const DrDermAi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dr.dermAi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
