import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class GoogleSignInButton extends StatefulWidget {
  final String text;
  final Function(bool) onLoading;
  final Function(Map<String, dynamic>) onSuccess;
  final Function(dynamic) onError;

  const GoogleSignInButton({
    Key? key,
    required this.text,
    required this.onLoading,
    required this.onSuccess,
    required this.onError,
  }) : super(key: key);

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    widget.onLoading(true);

    try {
      // Cả hai phương thức đều trả về Map<String, dynamic> giờ đây
      final Map<String, dynamic> result = kIsWeb
          ? await _authService.signInWithGoogleWeb()
          : await _authService.signInWithGoogle();
      
      // Kết quả đã được chuẩn hóa, truyền trực tiếp
      widget.onSuccess(result);    } catch (error) {
      print('Google Sign In Error: $error');
      
      String errorMessage = 'Đăng nhập Google thất bại';
      
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'popup-blocked':
            errorMessage = 'Cửa sổ đăng nhập bị chặn. Vui lòng cho phép pop-up và thử lại';
            break;
          case 'popup-closed-by-user':
            errorMessage = 'Quá trình đăng nhập bị ngắt bởi người dùng';
            break;
          case 'network-request-failed':
            errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet';
            break;
          case 'unauthorized-domain':
            errorMessage = 'Tên miền hiện tại không được xác thực. Vui lòng liên hệ quản trị viên';
            break;
          case 'user-cancelled':
            errorMessage = 'Đăng nhập đã bị hủy bởi người dùng';
            break;
          case 'api-not-enabled':
            errorMessage = 'API Google không được kích hoạt hoặc chưa được cấu hình đúng';
            break;
          default:
            errorMessage = 'Lỗi đăng nhập: ${error.code} - ${error.message}';
        }
      }
      
      widget.onError(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.spotifyWhite,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        side: const BorderSide(
          color: AppColors.spotifyLightGrey,
          width: 1,
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.spotifyBlack,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.g_mobiledata,
                      size: 24,
                      color: AppColors.spotifyBlack,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      color: AppColors.spotifyBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }
}