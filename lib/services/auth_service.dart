// JS interop annotations cho Google Identity Services API
@JS('google.accounts.id')
library google_accounts_id;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:js/js.dart';

@JS()
external dynamic get googleId;

@JS('google.accounts.oauth2.initTokenClient')
external dynamic initTokenClient(dynamic config);

class AuthService {
  // Instances Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Instance Google Sign-in
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  // Getter cho user hiện tại
  User? get currentUser => _auth.currentUser;

  // Stream theo dõi thay đổi trạng thái xác thực
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Đăng nhập bằng email và password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Cập nhật lần đăng nhập cuối cùng
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Xử lý và chuyển tiếp lỗi
      throw e;
    }
  }

  // Đăng nhập với Google cho thiết bị di động và desktop
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Bắt đầu quy trình đăng nhập tương tác
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // Người dùng hủy quá trình đăng nhập
        throw FirebaseAuthException(
          code: 'user-cancelled',
          message: 'Đăng nhập Google đã bị hủy bởi người dùng',
        );
      }
      
      // Lấy thông tin xác thực từ request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Đăng nhập vào Firebase với credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Cập nhật hoặc tạo user document trong Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'displayName': userCredential.user!.displayName,
        'photoURL': userCredential.user!.photoURL,
        'lastLogin': Timestamp.now(),
        'createdAt': userCredential.additionalUserInfo!.isNewUser 
            ? Timestamp.now() 
            : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Xử lý và chuyển tiếp lỗi Firebase
      throw e;
    } catch (e) {
      // Xử lý các lỗi khác
      print('Google sign-in error: $e');
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Đăng nhập Google thất bại: $e',
      );
    }
  }
  
  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      throw FirebaseAuthException(
        code: 'sign-out-failed',
        message: 'Đăng xuất thất bại: $e',
      );
    }
  }
  
  // Kiểm tra email đã được sử dụng chưa
  Future<bool> isEmailInUse(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Check email in use error: $e');
      throw FirebaseAuthException(
        code: 'email-check-failed',
        message: 'Không thể kiểm tra email: $e',
      );
    }
  }

  // Đăng nhập với Google cho web
  Future<Map<String, dynamic>> signInWithGoogleWeb() async {
    try {
      // Tạo một Google Auth Provider
      final googleProvider = GoogleAuthProvider();
      
      // Thêm scope cần thiết
      googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
      googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');
      
      // Đặt tham số đăng nhập
      googleProvider.setCustomParameters({
        'prompt': 'select_account'
      });
      
      // Sử dụng Popup sign in cho web
      final userCredential = await _auth.signInWithPopup(googleProvider);
      
      // Kiểm tra nếu người dùng mới
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      // Cập nhật hoặc tạo user document trong Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'displayName': userCredential.user!.displayName,
        'photoURL': userCredential.user!.photoURL,
        'lastLogin': Timestamp.now(),
        'createdAt': isNewUser ? Timestamp.now() : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Trả về credential dưới dạng map
      return {
        'user': {
          'uid': userCredential.user!.uid,
          'displayName': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'photoURL': userCredential.user!.photoURL,
        },
        'isNewUser': isNewUser,
      };
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth Error: ${e.code} - ${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error during Google web sign in: $e');
      throw FirebaseAuthException(
        code: 'google-signin-failed',
        message: 'Đã xảy ra lỗi khi đăng nhập với Google trên web: $e',
      );
    }
  }

  // Đăng ký tài khoản mới với email và password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật tên hiển thị
      await userCredential.user!.updateDisplayName(displayName);
      
      // Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'createdAt': Timestamp.now(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Xử lý và chuyển tiếp lỗi
      throw e;
    }
  }
  
  // Đặt lại mật khẩu qua email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Xử lý và chuyển tiếp lỗi
      throw e;
    }
  }
}