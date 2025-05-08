// Import script cho Google Identity Services API
(function() {
  const script = document.createElement('script');
  script.src = 'https://accounts.google.com/gsi/client';
  script.async = true;
  script.defer = true;
  document.head.appendChild(script);
})();

// Google Identity Services API Integration

// Khai báo biến global để lưu trữ ID của Google API
window.googleClientId = "157680094456-qqeklm5vd0fmcltqr6qlebbkqpu318tf.apps.googleusercontent.com";

// Khởi tạo Google Identity Services sau khi trang web đã tải xong
window.addEventListener('load', function() {
  // Kiểm tra nếu Google API đã được tải
  if (typeof google !== 'undefined' && google.accounts) {
    console.log('Google Identity Services API loaded successfully');
    
    // Khởi tạo Google API và thiết lập các tham số
    initializeGoogleAPI();
  } else {
    console.error('Google Identity Services API failed to load');
  }
});

// Khởi tạo Google API
function initializeGoogleAPI() {
  try {
    // Khởi tạo Google Identity Services với Client ID
    google.accounts.id.initialize({
      client_id: window.googleClientId,
      callback: handleGoogleSignIn,
      auto_select: false,
      cancel_on_tap_outside: true,
    });
    
    // Khởi tạo Google OAuth2 API
    window.tokenClient = google.accounts.oauth2.initTokenClient({
      client_id: window.googleClientId,
      scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
      callback: (response) => {
        if (response.error !== undefined) {
          throw response;
        }
        
        // Chuyển access token về Flutter để tiến hành đăng nhập Firebase
        if (window.googleSignInCallback) {
          window.googleSignInCallback(response.access_token);
        }
      },
    });
    
    console.log('Google API initialized successfully');
  } catch (error) {
    console.error('Failed to initialize Google API:', error);
  }
}

// Xử lý kết quả đăng nhập Google
function handleGoogleSignIn(response) {
  try {
    if (response.credential) {
      // Chuyển ID token về Flutter để tiến hành đăng nhập Firebase
      if (window.googleSignInCallback) {
        window.googleSignInCallback(response.credential);
      }
    }
  } catch (error) {
    console.error('Google sign-in error:', error);
  }
}

// Hiển thị nút đăng nhập Google
window.showGoogleSignInButton = function(elementId) {
  try {
    google.accounts.id.renderButton(
      document.getElementById(elementId),
      {
        type: 'standard',
        theme: 'outline',
        size: 'large',
        text: 'signin_with',
        shape: 'rectangular',
        logo_alignment: 'left',
        width: 240
      }
    );
  } catch (error) {
    console.error('Failed to render Google Sign-In button:', error);
  }
};

// Đăng nhập Google bằng OAuth2
window.signInWithGoogleOAuth = function() {
  try {
    if (window.tokenClient) {
      window.tokenClient.requestAccessToken();
    }
  } catch (error) {
    console.error('Failed to request Google access token:', error);
  }
};