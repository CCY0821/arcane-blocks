import 'package:shared_preferences/shared_preferences.dart';

/// 全局遊戲設置服務
/// 管理跨遊戲會話的用戶偏好設置
class GameSettings {
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() => _instance;
  GameSettings._internal();

  static const String _ghostPieceKey = 'setting_ghost_piece_enabled';

  // 默認開啟
  bool _isGhostPieceEnabled = true;

  bool get isGhostPieceEnabled => _isGhostPieceEnabled;

  /// 初始化設置（從 SharedPreferences 讀取）
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isGhostPieceEnabled = prefs.getBool(_ghostPieceKey) ?? true;
    print('[GameSettings] Ghost piece enabled: $_isGhostPieceEnabled');
  }

  /// 切換幽靈方塊開關
  /// 雖然這裡返回 Future，但調用方可以選擇不等待（fire and forget）
  Future<void> toggleGhostPiece() async {
    _isGhostPieceEnabled = !_isGhostPieceEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ghostPieceKey, _isGhostPieceEnabled);
    print('[GameSettings] Ghost piece toggled: $_isGhostPieceEnabled');
  }

  /// 顯式設置幽靈方塊開關（預留給可能的擴展）
  Future<void> setGhostPieceEnabled(bool enabled) async {
    if (_isGhostPieceEnabled == enabled) return;

    _isGhostPieceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ghostPieceKey, _isGhostPieceEnabled);
    print('[GameSettings] Ghost piece set to: $_isGhostPieceEnabled');
  }
}
