import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../utils/colors.dart';
import '../services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _collegeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Do not pre-fill credentials for security/privacy
  }

  @override
  void dispose() {
    _collegeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // // Logo and Header
              // Container(
              //   padding: const EdgeInsets.all(32),
              //   decoration: BoxDecoration(
              //     color: AppColors.surface,
              //     borderRadius: BorderRadius.circular(24),
              //     boxShadow: [
              //       BoxShadow(
              //         color: AppColors.shadowMedium,
              //         blurRadius: 20,
              //         offset: const Offset(0, 8),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.all(20),
              //         decoration: BoxDecoration(
              //           gradient: AppColors.primaryGradient,
              //           borderRadius: BorderRadius.circular(20),
              //           boxShadow: [
              //             BoxShadow(
              //               color: AppColors.primary.withOpacity(0.3),
              //               blurRadius: 15,
              //               offset: const Offset(0, 8),
              //             ),
              //           ],
              //         ),
              //         child: 
              //            Image.asset(
              //             'assets/images/75+.png',
              //             width: 60,
              //             height: 60,
              //             fit: BoxFit.contain,
              //           ),
                      
              //       ),
              //       const SizedBox(height: 10),
              //       const Text(
              //         'BunkMeter',
              //         style: TextStyle(
              //           fontSize: 32,
              //           fontWeight: FontWeight.w700,
              //           color: AppColors.textPrimary,
              //           letterSpacing: -0.5,
              //         ),
              //       ),
              //       const SizedBox(height: 8),
              //       const Text(
              //         'Smart Attendance Tracking',
              //         style: TextStyle(
              //           fontSize: 16,
              //           color: AppColors.textSecondary,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              
              // const SizedBox(height: 40),
              
              // Login Card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowMedium,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please sign in to your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // College ID Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'College ID',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _collegeIdController,
                            decoration: InputDecoration(
                              hintText: 'Enter your college ID',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderLight),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.error),
                              ),
                              hintStyle: const TextStyle(color: AppColors.textTertiary),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your college ID';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderLight),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.error),
                              ),
                              hintStyle: const TextStyle(color: AppColors.textTertiary),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Login Button
                      Consumer<AttendanceProvider>(
                        builder: (context, provider, child) {
                          return Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: provider.isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: provider.isLoading
                                  ? const Text(
                                      'Signing in...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Test Connection Button
                      // Consumer<AttendanceProvider>(
                      //   builder: (context, provider, child) {
                      //     return SizedBox(
                      //       width: double.infinity,
                      //       height: 48,
                      //       child: OutlinedButton.icon(
                      //         onPressed: provider.isLoading ? null : _testConnection,
                      //         style: OutlinedButton.styleFrom(
                      //           side: const BorderSide(color: AppColors.primary, width: 1.5),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //           ),
                      //           backgroundColor: AppColors.background,
                      //         ),
                      //         icon: const Icon(
                      //           Icons.wifi_find_rounded,
                      //           color: AppColors.primary,
                      //         ),
                      //         label: const Text(
                      //           'Test Connection',
                      //           style: TextStyle(
                      //             color: AppColors.primary,
                      //             fontWeight: FontWeight.w600,
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                     
                      
                      // Error Message
                      Consumer<AttendanceProvider>(
                        builder: (context, provider, child) {
                          if (provider.error != null) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.error,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      provider.error!,
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.info,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please log in using your college portal credentials. Rest assured, none of your personal data is stored.',
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AttendanceProvider>();
    final username = _collegeIdController.text.trim();
    final password = _passwordController.text.trim();

    // Save credentials securely
    await SecureStorageService.saveCredentials(username, password);

    await provider.login(
      username,
      password,
    );

    if (provider.isLoggedIn && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}