import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'viewmodels/auth_viewmodel.dart';

void main() {
  runApp(const FlyxyApp());
}

class FlyxyApp extends StatelessWidget {
  const FlyxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp.router(
        title: 'Flyxy',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
