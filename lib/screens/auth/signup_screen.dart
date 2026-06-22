import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/widgets/common/lf_text_field.dart';
import 'package:lizard_fitness/widgets/common/social_auth_buttons.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signUp(
      email: _email.text.trim(),
      password: _password.text,
      displayName: _name.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    ref.listen(authStateProvider, (_, next) {
      if (next.valueOrNull != null && mounted) {
        context.go('/onboarding');
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create account', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 4),
                Text('Start your fitness journey today', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 36),
                LFTextField(
                  controller: _name,
                  label: 'Full name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                LFTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Enter your email';
                    if (!v!.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                LFTextField(
                  controller: _password,
                  label: 'Password',
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Enter a password';
                    if (v!.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                LFTextField(
                  controller: _confirm,
                  label: 'Confirm password',
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) {
                    if (v != _password.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SocialAuthButtons(
                  onGoogle: () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                  onApple: () => ref.read(authNotifierProvider.notifier).signInWithApple(),
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 28),
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
                      : const Text('CREATE ACCOUNT'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kTextMuted)),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyError(String error) {
    if (error.contains('email-already-in-use')) return 'An account with this email already exists';
    if (error.contains('weak-password')) return 'Password is too weak';
    return 'Sign up failed. Please try again.';
  }
}
