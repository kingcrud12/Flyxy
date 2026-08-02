import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../views/main_wrapper.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/register_view.dart';
import '../views/account_view.dart';
import '../views/map_view.dart';
import '../views/saved_view.dart';
import '../views/feed_view.dart';
import '../views/create_post_view.dart';
import '../views/post_details_view.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/favorites_viewmodel.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/create-post',
      builder: (context, state) => const CreatePostView(),
    ),
    GoRoute(
      path: '/post-details',
      builder: (context, state) {
        final post = state.extra;
        return PostDetailsView(post: post);
      },
    ),
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
              routes: [
                GoRoute(
                  path: 'map',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return MapViewScreen(
                      initialLat: extra?['lat'],
                      initialLon: extra?['lon'],
                      initialStopId: extra?['stopId'],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => const SavedViewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/feed',
              builder: (context, state) => const FeedViewScreen(),
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
        email: auth.email,
        onLogout: () {
          context.read<AuthViewModel>().logout();
          context.read<FavoritesViewModel>().clearFavorites();
        },
      );
    }
    return const LoginView();
  }
}
