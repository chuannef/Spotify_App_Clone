import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emailSent = false;
    });

    try {
      await _authService.resetPassword(_emailController.text.trim());
      setState(() {
        _emailSent = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getMessageFromErrorCode(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Your email address appears to be malformed';
      case 'user-not-found':
        return 'User with this email doesn\'t exist';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'An undefined error happened';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.spotifyWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: AppColors.spotifyWhite),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Forgot your password?',
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter your registered email below to receive password reset instructions',
                    style: TextStyle(color: AppColors.spotifyLightGrey),
                  ),
                  const SizedBox(height: 30),
                  // Success Message
                  if (_emailSent) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.spotifyGreen.withAlpha(25), // 0.1 opacity
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.spotifyGreen,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Password reset email sent. Please check your inbox.',
                              style: TextStyle(
                                color: AppColors.spotifyGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withAlpha(25), // 0.1 opacity
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: AppInputDecorations.textFieldDecoration(
                      AppStrings.emailHint,
                    ),
                    style: const TextStyle(color: AppColors.spotifyWhite),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  // Reset Password Button
                  CustomButton(
                    text: 'SEND RESET LINK',
                    onPressed: _resetPassword,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  // Back to login
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Back to login',
                        style: TextStyle(
                          color: AppColors.spotifyWhite,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}