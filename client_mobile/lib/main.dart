import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/transport_viewmodel.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'viewmodels/social_viewmodel.dart';
import 'viewmodels/post_details_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';

import 'package:path_provider/path_provider.dart';
import 'core/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await DioClient.init(dir.path);
  runApp(const FlyxyApp());
}

class FlyxyApp extends StatelessWidget {
  const FlyxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => TransportViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => SocialViewModel()),
        ChangeNotifierProvider(create: (_) => PostDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
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
