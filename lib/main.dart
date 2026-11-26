import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/app_store.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.initialize();
  runApp(ChangeNotifierProvider.value(value: store, child: const TariqApp()));
}

class TariqApp extends StatelessWidget {
  const TariqApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'طريق النور',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark(),
    home: const HomeScreen(),
  );
}
