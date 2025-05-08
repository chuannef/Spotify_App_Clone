import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/google_sign_in_button.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  // Define brand colors
  final Color googleColor = const Color(0xFFDB4437);
  final Color facebookColor = const Color(0xFF4267B2);
  final Color appleColor = const Color(0xFF000000);
  final Color phoneColor = const Color(0xFF34B7F1);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Navigation will be handled by the auth state listener in main.dart
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
        return 'Địa chỉ email không hợp lệ';
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      case 'user-not-found':
        return 'Không tìm thấy người dùng với email này';
      case 'user-disabled':
        return 'Tài khoản người dùng đã bị vô hiệu hóa';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      case 'operation-not-allowed':
        return 'Đăng nhập bằng Email và Mật khẩu không được bật';
      case 'sign-in-aborted':
        return 'Đăng nhập đã bị hủy bởi người dùng';
      case 'account-exists-with-different-credential':
        return 'Đã tồn tại một tài khoản với cùng địa chỉ email nhưng thông tin đăng nhập khác';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối của bạn';
      case 'google-signin-failed':
        return 'Đăng nhập Google thất bại. Vui lòng thử lại sau';
      case 'api-not-enabled':
        return 'Dịch vụ xác thực chưa được thiết lập đầy đủ. Vui lòng liên hệ quản trị viên'; 
      case 'client-id-missing':
        return 'Cấu hình Client ID cho đăng nhập Google chưa được thiết lập đúng cách';
      case 'popup-blocked':
        return 'Cửa sổ đăng nhập bị chặn. Vui lòng cho phép cửa sổ pop-up và thử lại';
      case 'popup-closed-by-user':
        return 'Cửa sổ đăng nhập đã bị đóng. Vui lòng thử lại';
      case 'unauthorized-domain':
        return 'Tên miền không được phép sử dụng đăng nhập Google. Vui lòng liên hệ quản trị viên';
      case 'internal-error':
        return 'Đã xảy ra lỗi nội bộ. Vui lòng thử lại sau';
      default:
        return 'Đã xảy ra lỗi không xác định ($errorCode)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Spotify Logo
                  Icon(
                    FontAwesomeIcons.spotify,
                    size: 50,
                    color: AppColors.spotifyGreen,
                  ),
                  const SizedBox(height: 30),
                  // Title
                  const Text(
                    AppStrings.loginTitle,
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 40),
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: AppInputDecorations.textFieldDecoration(
                      AppStrings.passwordHint,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.spotifyLightGrey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: AppColors.spotifyWhite),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResetPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          color: AppColors.spotifyWhite,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Login Button
                  CustomButton(
                    text: AppStrings.loginButton,
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 30),
                  // Divider with OR text
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.spotifyLightGrey),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppStrings.or,
                          style: TextStyle(
                            color: AppColors.spotifyLightGrey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppColors.spotifyLightGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Social login buttons with brand colors
                  GoogleSignInButton(
                    text: 'CONTINUE WITH GOOGLE',
                    onLoading: (loading) {
                      setState(() => _isGoogleLoading = loading);
                    },
                    onSuccess: (result) {
                      // Authentication sẽ được xử lý bởi AuthListener
                      print('Google sign in success: ${result['user']['displayName']}');
                    },
                    onError: (error) {
                      setState(() {
                        _errorMessage = error is Exception
                            ? error.toString().replaceAll('Exception: ', '')
                            : 'Đăng nhập với Google thất bại. Vui lòng thử lại.';
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  CustomButton(
                    text: 'CONTINUE WITH FACEBOOK',
                    onPressed: () {},
                    backgroundColor: facebookColor,
                    textColor: Colors.white,
                    hasBorder: false,
                    icon: FontAwesomeIcons.facebook,
                  ),
                  const SizedBox(height: 15),
                  CustomButton(
                    text: 'CONTINUE WITH APPLE',
                    onPressed: () {},
                    backgroundColor: appleColor,
                    textColor: Colors.white,
                    hasBorder: false,
                    icon: FontAwesomeIcons.apple,
                  ),
                  const SizedBox(height: 15),
                  CustomButton(
                    text: 'CONTINUE WITH PHONE NUMBER',
                    onPressed: () {},
                    backgroundColor: phoneColor,
                    textColor: Colors.white,
                    hasBorder: false,
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 35),
                  // Sign up section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.noAccount,
                        style: TextStyle(
                          color: AppColors.spotifyLightGrey,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          AppStrings.signUp,
                          style: TextStyle(
                            color: AppColors.spotifyWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Web-specific notice
                  if (kIsWeb)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'NOTE: NON.',
                        style: TextStyle(
                          color: AppColors.spotifyLightGrey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
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