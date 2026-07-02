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
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          context.go(AppRoutes.splash);
        },
        child: Scaffold(
          backgroundColor: AppColors.hessaBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.hessaBrown,
              ),
              onPressed: () => context.go(AppRoutes.splash),
            ),
          ),
          body: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                sl<SecureStorage>().hasParentPin().then((hasPin) {
                  if (hasPin) {
                    context.go(AppRoutes.appEntryLock);
                  } else {
                    context.go(AppRoutes.home);
                  }
                });
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
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/logo.png',
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'قم بتسجيل الدخول',
                                  style: GoogleFonts.cairo(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.hessaTextBrown,
                                  ),
                                ).animate().fadeIn(delay: 200.ms),
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8)),

                        const SizedBox(height: 32),

                        // Form card
                        Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.hessaBrown,
                                  width: 1.5,
                                ),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: AppColors.hessaInputBg,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: const BorderSide(
                                        color: AppColors.hessaBrown,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: const BorderSide(
                                        color: AppColors.error,
                                        width: 1.5,
                                      ),
                                    ),
                                    hintStyle: GoogleFonts.cairo(
                                      color: AppColors.hessaBrown.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'اسم المستخدم',
                                        style: GoogleFonts.cairo(
                                          color: AppColors.hessaTextBrown,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      QubahTextField(
                                        controller: _emailController,
                                        hintText: 'اسم المستخدم',
                                        prefixIcon: Icons.person_outline,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'يرجى إدخال البريد الإلكتروني'
                                            : null,
                                      ),

                                      const SizedBox(height: 24),

                                      Text(
                                        'كلمة المرور',
                                        style: GoogleFonts.cairo(
                                          color: AppColors.hessaTextBrown,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      QubahTextField(
                                        controller: _passwordController,
                                        hintText: 'كلمة المرور',
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AppColors.hessaBrown,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? 'يرجى إدخال كلمة المرور'
                                            : null,
                                      ),

                                      const SizedBox(height: 50),

                                      QubahButton(
                                        text: 'دخول',
                                        isLoading: state is AuthLoading,
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.hessaBrown,
                                            AppColors.hessaBrown,
                                          ],
                                        ),
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            sl<SecureStorage>().saveIsGuest(
                                              false,
                                            );
                                            context.read<AuthCubit>().login(
                                              email: _emailController.text
                                                  .trim(),
                                              password:
                                                  _passwordController.text,
                                            );
                                          }
                                        },
                                      ),

                                      const SizedBox(height: 16),
                                      
                                      TextButton(
                                        onPressed: () => context.push(AppRoutes.support),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.hessaBrown,
                                        ),
                                        child: Text(
                                          'نسيت البريد الإلكتروني أو كلمة المرور؟ تواصل مع الدعم',
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
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
            );
          },
        ),
      ),
      ),
    );
  }
}
