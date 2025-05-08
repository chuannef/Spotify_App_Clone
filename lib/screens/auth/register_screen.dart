import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/google_sign_in_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  // Định nghĩa màu sắc của các hãng
  final Color googleColor = const Color(0xFFDB4437);
  final Color facebookColor = const Color(0xFF4267B2);
  final Color appleColor = const Color(0xFF000000);
  final Color phoneColor = const Color(0xFF34B7F1);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
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
      case 'email-already-in-use':
        return 'Email đã được sử dụng. Vui lòng đăng nhập.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ';
      case 'operation-not-allowed':
        return 'Đăng ký bằng Email và Mật khẩu không được bật';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'sign-in-aborted':
        return 'Đăng nhập đã bị hủy bởi người dùng';
      case 'account-exists-with-different-credential':
        return 'Đã tồn tại một tài khoản với cùng địa chỉ email nhưng thông tin đăng nhập khác';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối của bạn';
      case 'api-not-enabled':
        return 'Dịch vụ xác thực chưa được thiết lập đầy đủ. Vui lòng liên hệ quản trị viên';
      case 'client-id-missing':
        return 'Cấu hình Client ID cho đăng nhập Google chưa được thiết lập đúng cách';
      case 'google-signin-failed':
        return 'Đăng nhập Google thất bại. Vui lòng thử lại sau';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.spotifyWhite),
          onPressed: () => Navigator.of(context).pop(),
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
                  // Title
                  const Text(
                    AppStrings.registerTitle,
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 30),
                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withAlpha(25),
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
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: AppInputDecorations.textFieldDecoration(
                      AppStrings.nameHint,
                    ),
                    style: const TextStyle(color: AppColors.spotifyWhite),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
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
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  // Register Button
                  CustomButton(
                    text: AppStrings.registerButton,
                    onPressed: _register,
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
                  // Thay nút đăng nhập Google bằng GoogleSignInButton mới
                  GoogleSignInButton(
                    text: 'SIGN UP WITH GOOGLE',
                    onLoading: (isLoading) {
                      setState(() {
                        _isGoogleLoading = isLoading;
                      });
                    },
                    onError: (error) {
                      setState(() {
                        if (error is FirebaseAuthException) {
                          _errorMessage = _getMessageFromErrorCode(error.code);
                          print('Google sign-in error: ${error.code} - ${error.message}');
                        } else {
                          _errorMessage = 'Đã xảy ra lỗi không xác định khi đăng nhập với Google';
                          print('Unknown error during Google sign-in: $error');
                        }
                      });
                    },
                    onSuccess: (credential) {
                      // Navigation will be handled by the auth state listener in main.dart
                      print('Đăng ký Google thành công: ${(credential as Map<String, dynamic>)['user']?.displayName}');
                    },
                  ),
                  const SizedBox(height: 15),
                  CustomButton(
                    text: 'SIGN UP WITH FACEBOOK',
                    onPressed: () {},
                    backgroundColor: facebookColor,
                    textColor: Colors.white,
                    hasBorder: false,
                    icon: FontAwesomeIcons.facebook,
                  ),
                  const SizedBox(height: 15),
                  // Thêm nút đăng ký bằng Apple
                  CustomButton(
                    text: 'SIGN UP WITH APPLE',
                    onPressed: () {},
                    backgroundColor: appleColor,
                    textColor: Colors.white,
                    hasBorder: false,
                    icon: FontAwesomeIcons.apple,
                  ),
                  const SizedBox(height: 15),
                  // Thêm nút đăng ký bằng số điện thoại
                  CustomButton(
                    text: 'SIGN UP WITH PHONE NUMBER',
                    onPressed: () {},
                    backgroundColor: phoneColor,
                    textColor: Colors.white,
                    hasBorder: false,
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 35),
                  // Log in section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.haveAccount,
                        style: TextStyle(
                          color: AppColors.spotifyLightGrey,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          AppStrings.logIn,
                          style: TextStyle(
                            color: AppColors.spotifyWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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