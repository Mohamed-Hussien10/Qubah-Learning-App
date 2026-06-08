import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/services/dependency_injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/qubah_button.dart';
import '../../../../../core/widgets/qubah_text_field.dart';
import '../../../../../core/storage/secure_storage.dart';
import '../../manager/cubit/auth_cubit.dart';
import '../../manager/state/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go(AppRoutes.appEntryLock);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return Container(
              decoration:  BoxDecoration(gradient: AppColors.heroGradient),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                          const SizedBox(height: 20),
                          Text(
                            'مرحباً بعودتك!',
                            style: GoogleFonts.cairo(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 8),
                          Text(
                            'سجل الدخول لمتابعة التعلم',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 40),
                          // Form card
                          Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      QubahTextField(
                                        controller: _emailController,
                                        hintText: 'البريد الإلكتروني',
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'يرجى إدخال البريد الإلكتروني'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      QubahTextField(
                                        controller: _passwordController,
                                        hintText: 'كلمة المرور',
                                        prefixIcon: Icons.lock_outline_rounded,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'يرجى إدخال كلمة المرور'
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            'نسيت كلمة المرور؟',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      QubahButton(
                                        text: 'تسجيل الدخول',
                                        isLoading: state is AuthLoading,
                                        icon: Icons.login_rounded,
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            sl<SecureStorage>().saveIsGuest(false);
                                            context.read<AuthCubit>().login(
                                              email: _emailController.text
                                                  .trim(),
                                              password:
                                                  _passwordController.text,
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton(
                                        onPressed: () async {
                                          await sl<SecureStorage>().saveIsGuest(true);
                                          if (context.mounted) {
                                            context.go('/home');
                                          }
                                        },
                                        child: Text(
                                          'تجربة مجانية',
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .slideY(begin: 0.15, end: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
