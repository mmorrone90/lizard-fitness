import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/screens/splash/splash_screen.dart';
import 'package:lizard_fitness/screens/auth/login_screen.dart';
import 'package:lizard_fitness/screens/auth/signup_screen.dart';
import 'package:lizard_fitness/screens/onboarding/onboarding_screen.dart';
import 'package:lizard_fitness/screens/home/home_screen.dart';
import 'package:lizard_fitness/screens/workout/workout_screen.dart';
import 'package:lizard_fitness/screens/workout/active_workout_screen.dart';
import 'package:lizard_fitness/screens/workout/workout_completion_screen.dart';
import 'package:lizard_fitness/screens/exercises/exercises_screen.dart';
import 'package:lizard_fitness/screens/exercises/exercise_detail_screen.dart';
import 'package:lizard_fitness/screens/exercises/workout_builder_screen.dart';
import 'package:lizard_fitness/screens/profile/profile_screen.dart';
import 'package:lizard_fitness/screens/profile/edit_profile_screen.dart';
import 'package:lizard_fitness/models/workout.dart';
import 'package:lizard_fitness/models/workout_session.dart';
import 'package:lizard_fitness/widgets/common/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return '/splash';

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final location = state.uri.path;

      if (!isLoggedIn && location != '/login' && location != '/signup' && location != '/splash') {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/workout',
            pageBuilder: (_, __) => const NoTransitionPage(child: WorkoutScreen()),
            routes: [
              GoRoute(
                path: 'active',
                builder: (_, __) => const ActiveWorkoutScreen(),
              ),
              GoRoute(
                path: 'complete',
                builder: (_, state) {
                  final session = state.extra as WorkoutSession?;
                  return WorkoutCompletionScreen(session: session);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/exercises',
            pageBuilder: (_, __) => const NoTransitionPage(child: ExercisesScreen()),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ExerciseDetailScreen(exerciseId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'builder/new',
                builder: (_, state) {
                  final workout = state.extra as CustomWorkout?;
                  return WorkoutBuilderScreen(existingWorkout: workout);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen()),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, __) => const EditProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
