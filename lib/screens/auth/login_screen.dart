import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/widgets/common/lf_text_field.dart';
import 'package:lizard_fitness/widgets/common/social_auth_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signIn(
      email: _email.text.trim(),
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    ref.listen(authStateProvider, (_, next) {
      final user = next.valueOrNull;
      if (user == null) return;
      // Capture router + service synchronously; the screen disposes on
      // navigation, so we must not touch State.context after the async gap.
      final router = GoRouter.of(context);
      ref.read(authServiceProvider).isOnboardingCompleted(user.uid).then((done) {
        router.go(done ? '/home' : '/onboarding');
      });
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: kYellow.withOpacity(0.25), blurRadius: 32, spreadRadius: 4)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text('Welcome back', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 4),
                Text('Log in to continue your training', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kTextMuted)),
                const SizedBox(height: 32),

                // Social sign-in
                SocialAuthButtons(
                  onGoogle: () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                  onApple: () => ref.read(authNotifierProvider.notifier).signInWithApple(),
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 24),
                _OrDivider(),
                const SizedBox(height: 24),

                LFTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Enter your email' : null,
                ),
                const SizedBox(height: 14),
                LFTextField(
                  controller: _password,
                  label: 'Password',
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Enter your password' : null,
                ),
                const SizedBox(height: 24),
                if (auth.hasError)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: kError.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kError.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: kError, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _friendlyError(auth.error.toString()),
                            style: const TextStyle(color: kError, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kBlack))
                      : const Text('LOG IN'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kTextMuted)),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyError(String error) {
    if (error.contains('user-not-found') || error.contains('wrong-password') || error.contains('invalid-credential')) {
      return 'Invalid email or password';
    }
    if (error.contains('too-many-requests')) return 'Too many attempts. Try again later.';
    if (error.contains('cancelled') || error.contains('canceled')) return '';
    return 'Login failed. Please try again.';
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: kCardLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or continue with email', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kTextMuted)),
        ),
        const Expanded(child: Divider(color: kCardLight)),
      ],
    );
  }
}
