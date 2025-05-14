// AuthService class - Firebase Authentication Service
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'music_player_service.dart';

class AuthService {
  // Instances Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // Instance Google Sign-in với cấu hình nâng cao
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    // Thêm clientId cho Web để đảm bảo đăng nhập trên nền tảng web
    clientId: '157680094456-qqeklm5vd0fmcltqr6qlebbkqpu318tf.apps.googleusercontent.com',
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
  Future<Map<String, dynamic>> signInWithGoogle() async {
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
      
      // Kiểm tra xem người dùng đã tồn tại chưa để xác định isNewUser
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      bool isNewUser = !userDoc.exists || userCredential.additionalUserInfo?.isNewUser == true;
      
      // Cập nhật hoặc tạo user document trong Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'displayName': userCredential.user!.displayName,
        'photoURL': userCredential.user!.photoURL,
        'lastLogin': Timestamp.now(),
        'createdAt': isNewUser ? Timestamp.now() : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Trả về dạng map cho nhất quán với signInWithGoogleWeb
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
      print('Firebase Auth Error: ${e.code} - ${e.message}');
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
  Future<void> signOut(BuildContext? context) async {
    try {
      // Stop music playback if context is provided
      if (context != null) {
        final musicService = Provider.of<MusicPlayerService>(context, listen: false);
        await musicService.stopMusic();
        musicService.hideMiniPlayer();
      }
      
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
  }  // Đăng nhập với Google cho web
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
      
      // Sử dụng Popup sign-in cho web thay vì redirect
      final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
      
      // Lấy thông tin người dùng từ kết quả
      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Không tìm thấy thông tin người dùng sau khi đăng nhập',
        );
      }
      
      // Kiểm tra nếu người dùng mới - trong trường hợp redirect, không có additionalInfo
      // Thay vào đó hãy kiểm tra xem user document đã tồn tại chưa
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      bool isNewUser = !userDoc.exists;
      
      // Cập nhật hoặc tạo user document trong Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': Timestamp.now(),
        'createdAt': isNewUser ? Timestamp.now() : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Trả về credential dưới dạng map
      return {
        'user': {
          'uid': user.uid,
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
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