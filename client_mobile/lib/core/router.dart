import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../views/main_wrapper.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/register_view.dart';
import '../views/account_view.dart';
import '../viewmodels/auth_viewmodel.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapper(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileWrapper(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),
  ],
);

class ProfileWrapper extends StatelessWidget {
  const ProfileWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    if (auth.isAuthenticated) {
      return AccountView(
        firstName: auth.firstName,
        lastName: auth.lastName,
        onLogout: () {
          context.read<AuthViewModel>().logout();
        },
      );
    }
    return const LoginView();
  }
}
