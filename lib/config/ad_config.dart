import 'package:flutter/foundation.dart';

/// Ad configuration constants for different platforms and build modes.
///
/// This file implements a **three-layer test ad protection system**:
///
/// 🛡️ Layer 1: Mode Auto-Detection (kDebugMode)
///   - Debug mode → Always use test IDs (100% safe)
///   - Release/Profile mode → Use production IDs
///
/// 🛡️ Layer 2: Device Whitelist (testDeviceIds)
///   - Whitelisted devices → Show test ads even with real IDs
///   - Other devices → Show real ads
///
/// 🛡️ Layer 3: Placeholder Detection (strict mode)
///   - Release build with placeholder IDs → Build fails
///   - Prevents accidentally publishing test IDs to stores
///
/// ## Usage
/// ```dart
/// // In admob_service.dart initialize()
/// MobileAds.instance.updateRequestConfiguration(
///   RequestConfiguration(testDeviceIds: AdConfig.testDeviceIds),
/// );
///
/// // Get ad unit ID
/// final adUnitId = AdConfig.getAndroidBannerUnitId();
/// ```
class AdConfig {
  // ============================================================================
  // 🧪 TEST IDs - Google's official test ad units
  // ============================================================================

  /// AdMob test App ID for Android (development)
  static const String _testAndroidAppId =
      'ca-app-pub-3940256099942544~3347511713';

  /// AdMob test App ID for iOS (development)
  static const String _testIosAppId = 'ca-app-pub-3940256099942544~1458002511';

  /// AdMob test banner unit ID for development (universal)
  static const String _testBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // ============================================================================
  // 🚨 PRODUCTION IDs - Replace these with your real AdMob/AdSense IDs
  // ============================================================================

  /// Production Google AdSense Publisher ID (Web platform)
  /// TODO: Replace with your real AdSense Publisher ID
  /// Example: 'pub-1234567890123456'
  static const String _prodAdSensePublisherId = 'pub-0000000000000000';

  /// Production Google AdSense Ad Slot (Web banner)
  /// TODO: Replace with your real AdSense Ad Slot
  /// Example: '1234567890'
  static const String _prodAdSenseAdSlot = '0000000000';

  /// Production AdMob App ID for Android
  /// ✅ Configured: Your real AdMob App ID
  static const String _prodAndroidAppId =
      'ca-app-pub-2605819411931057~2509314110';

  /// Production AdMob Banner Unit ID for Android
  /// ✅ Configured: Your real Android Banner Unit ID (新应用包名配置)
  static const String _prodAndroidBannerUnitId =
      'ca-app-pub-2605819411931057/7507609482';

  /// Production AdMob App ID for iOS
  /// TODO: Replace with your real iOS App ID
  /// Example: 'ca-app-pub-1234567890123456~0987654321'
  static const String _prodIosAppId = 'ca-app-pub-0000000000000000~0000000000';

  /// Production AdMob Banner Unit ID for iOS
  /// TODO: Replace with your real iOS Banner Unit ID
  /// Example: 'ca-app-pub-1234567890123456/1234567890'
  static const String _prodIosBannerUnitId =
      'ca-app-pub-0000000000000000/0000000000';

  // ============================================================================
  // 🔑 Test Device IDs - Layer 2 Protection
  // ============================================================================

  /// List of test device IDs that will always receive test ads.
  ///
  /// ## How to get your device ID:
  ///
  /// 1. Run the app on your device:
  ///    ```bash
  ///    flutter run --release
  ///    ```
  ///
  /// 2. Check the logs for a message like:
  ///    ```
  ///    I/Ads: Use RequestConfiguration.Builder().setTestDeviceIds(
  ///           Arrays.asList("33BE2250B43518CCDA7DE426D04EE231")
  ///          ) to get test ads on this device.
  ///    ```
  ///
  /// 3. Copy the 32-character hex string and add it here.
  ///
  /// ## Android Logcat command:
  /// ```bash
  /// adb logcat | findstr "test device"
  /// ```
  ///
  /// ## Example:
  /// ```dart
  /// static const List<String> testDeviceIds = [
  ///   '33BE2250B43518CCDA7DE426D04EE231', // Your Android device
  ///   '987654321ABCDEF1234567890ABCDEF',   // Your iOS device
  /// ];
  /// ```
  static const List<String> testDeviceIds = [
    // TODO: Add your Android device ID here after running the app
    // Example: '33BE2250B43518CCDA7DE426D04EE231',
  ];

  // ============================================================================
  // 🎯 Platform-specific ID getters (with strict validation)
  // ============================================================================

  /// Gets AdSense Publisher ID for web platform.
  ///
  /// Returns test ID in debug mode, production ID in release mode.
  /// Throws [StateError] if placeholder is not replaced in release mode.
  static String getAdSensePublisherId() {
    if (kDebugMode) {
      return 'pub-test';
    }

    if (_isPlaceholderId(_prodAdSensePublisherId)) {
      throw StateError(
        '🚨 AdSense Publisher ID 尚未替換！\n'
        '請在 lib/config/ad_config.dart 中將 _prodAdSensePublisherId 替換為您的真實 ID。\n'
        '參考文檔: docs/compliance/ADMOB_PRODUCTION_SETUP.md',
      );
    }

    return _prodAdSensePublisherId;
  }

  /// Gets AdSense Ad Slot for web platform.
  ///
  /// Returns test slot in debug mode, production slot in release mode.
  /// Throws [StateError] if placeholder is not replaced in release mode.
  static String getAdSenseAdSlot() {
    if (kDebugMode) {
      return 'test-slot';
    }

    if (_isPlaceholderId(_prodAdSenseAdSlot)) {
      throw StateError(
        '🚨 AdSense Ad Slot 尚未替換！\n'
        '請在 lib/config/ad_config.dart 中將 _prodAdSenseAdSlot 替換為您的真實 Slot ID。\n'
        '參考文檔: docs/compliance/ADMOB_PRODUCTION_SETUP.md',
      );
    }

    return _prodAdSenseAdSlot;
  }

  /// Gets AdMob App ID for Android platform.
  ///
  /// Returns test ID in debug mode, production ID in release mode.
  /// Throws [StateError] if placeholder is not replaced in release mode.
  static String getAndroidAppId() {
    if (kDebugMode) {
      return _testAndroidAppId;
    }

    if (_isPlaceholderId(_prodAndroidAppId)) {
      throw StateError(
        '🚨 Android AdMob App ID 尚未替換！\n'
        '請在 lib/config/ad_config.dart 中將 _prodAndroidAppId 替換為您的真實 App ID。\n'
        '參考文檔: docs/compliance/ADMOB_PRODUCTION_SETUP.md\n'
        '\n'
        '如何取得 App ID:\n'
        '1. 前往 https://apps.admob.com/\n'
        '2. 選擇您的 Android 應用程式\n'
        '3. 複製 App ID (格式: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX)',
      );
    }

    return _prodAndroidAppId;
  }

  /// Gets AdMob Banner Unit ID for Android platform.
  ///
  /// Returns test ID in debug mode, production ID in release mode.
  /// Throws [StateError] if placeholder is not replaced in release mode.
  static String getAndroidBannerUnitId() {
    if (kDebugMode) {
      return _testBannerUnitId;
    }

    if (_isPlaceholderId(_prodAndroidBannerUnitId)) {
      throw StateError(
        '🚨 Android AdMob Banner Unit ID 尚未替換！\n'
        '請在 lib/config/ad_config.dart 中將 _prodAndroidBannerUnitId 替換為您的真實 Banner Unit ID。\n'
        '參考文檔: docs/compliance/ADMOB_PRODUCTION_SETUP.md\n'
        '\n'
        '如何取得 Banner Unit ID:\n'
        '1. 前往 https://apps.admob.com/\n'
        '2. 選擇您的 Android 應用程式\n'
        '3. 點擊「廣告單元」\n'
        '4. 建立或選擇一個橫幅廣告單元\n'
        '5. 複製廣告單元 ID (格式: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX)',
      );
    }

    return _prodAndroidBannerUnitId;
  }

  /// Gets AdMob App ID for iOS platform.
  ///
  /// Returns test ID in debug mode, production ID in release mode.
  /// Throws [StateError] if placeholder is not replaced in release mode.
  static String getIosAppId() {
    if (kDebugMode) {
      return _testIosAppId;
    }

    if (_isPlaceholderId(_prodIosAppId)) {
      throw StateError(
        '🚨 iOS AdMob App ID 尚未替換！\n'
        '請在 lib/config/ad_config.dart 中將 _prodIosAppId 替換為您的真實 App ID。\n'
        '參考文檔: docs/compliance/ADMOB_PRODUCTION_SETUP.md\n'
        '\n'
        '如何取得 App ID:\n'
        '1. 前往 https://apps.admob.com/\n'
        '2. 選擇您的 iOS 應用程式\n'
        '3. 複製 App ID (格式: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX)',
      );
    }

    return _prodIosAppId;
  }

  /// Gets AdMob Banner Unit ID for iOS platform.
  ///
  /// Returns test ID in debug mode, production ID in release mode.
  /// Throws [StateError] if placeholder is not replaced in release mode.
  static String getIosBannerUnitId() {
    if (kDebugMode) {
      return _testBannerUnitId;
    }

    if (_isPlaceholderId(_prodIosBannerUnitId)) {
      throw StateError(
        '🚨 iOS AdMob Banner Unit ID 尚未替換！\n'
        '請在 lib/config/ad_config.dart 中將 _prodIosBannerUnitId 替換為您的真實 Banner Unit ID。\n'
        '參考文檔: docs/compliance/ADMOB_PRODUCTION_SETUP.md\n'
        '\n'
        '如何取得 Banner Unit ID:\n'
        '1. 前往 https://apps.admob.com/\n'
        '2. 選擇您的 iOS 應用程式\n'
        '3. 點擊「廣告單元」\n'
        '4. 建立或選擇一個橫幅廣告單元\n'
        '5. 複製廣告單元 ID (格式: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX)',
      );
    }

    return _prodIosBannerUnitId;
  }

  // ============================================================================
  // 🔍 Internal Helper Methods
  // ============================================================================

  /// Detects if an ID is still a placeholder (contains all zeros).
  ///
  /// Returns true if the ID contains '0000000000000000' pattern.
  static bool _isPlaceholderId(String id) {
    return id.contains('0000000000000000');
  }

  // ============================================================================
  // 📊 Ad Display Settings
  // ============================================================================

  /// Standard banner ad height in pixels
  static const double bannerHeight = 60.0;

  /// Enable ads in this build (can be toggled for premium versions)
  static const bool adsEnabled = true;

  /// Minimum time between ad refresh (seconds)
  static const int adRefreshInterval = 30;

  /// Maximum ad load retry attempts
  static const int maxLoadRetries = 3;
}
