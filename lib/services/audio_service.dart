import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();

  // 🔊 音效播放器池 - 支援同時播放多個音效
  final List<AudioPlayer> _sfxPlayerPool = [];
  static const int _maxSfxPlayers = 5; // 最多同時播放5個音效
  int _currentSfxPlayerIndex = 0;

  // 🔑 持久化設定的 Key
  static const String _musicEnabledKey = 'audio_music_enabled';
  static const String _sfxEnabledKey = 'audio_sfx_enabled';
  static const String _musicVolumeKey = 'audio_music_volume';
  static const String _sfxVolumeKey = 'audio_sfx_volume';

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.8;
  double _sfxVolume = 0.9;

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  // 初始化音頻服務
  Future<void> initialize() async {
    try {
      // 💾 從本地存儲加載用戶設定
      final prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = prefs.getBool(_musicEnabledKey) ?? true;
      _isSfxEnabled = prefs.getBool(_sfxEnabledKey) ?? true;
      _musicVolume = prefs.getDouble(_musicVolumeKey) ?? 0.8;
      _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? 0.9;

      print(
          '[AudioService] Loaded settings: Music=$_isMusicEnabled, SFX=$_isSfxEnabled, MusicVol=$_musicVolume, SfxVol=$_sfxVolume');

      // 確保先停止現有播放器
      await _backgroundMusicPlayer.stop();

      // 🔊 初始化音效播放器池
      _sfxPlayerPool.clear();
      for (int i = 0; i < _maxSfxPlayers; i++) {
        final player = AudioPlayer();
        await player.setVolume(_sfxVolume);
        // 設定釋放模式為釋放（播放完後自動準備下次播放）
        await player.setReleaseMode(ReleaseMode.release);
        _sfxPlayerPool.add(player);
      }

      // 重新設置音量
      await _backgroundMusicPlayer.setVolume(_musicVolume);

      print(
          'AudioService initialized with ${_sfxPlayerPool.length} SFX players');
    } catch (e) {
      print('AudioService initialization error: $e');
    }
  }

  // 播放背景音樂
  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
      print('Attempting to play background music...');
      print('Music enabled: $_isMusicEnabled');

      // 先停止現有音樂，避免重疊播放
      await _backgroundMusicPlayer.stop();

      // 設定循環模式，再播放
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer.play(
        AssetSource('audio/background_music.mp3'),
      );
      print('Background music started successfully!');
    } catch (e) {
      print('Error playing background music: $e'); // 暫時開啟除錯
      print('Audio file path: assets/audio/background_music.mp3');
      print('Music enabled: $_isMusicEnabled');
      // 如果音樂檔案不存在，使用預設的靜音處理
    }
  }

  // 停止背景音樂
  Future<void> stopBackgroundMusic() async {
    await _backgroundMusicPlayer.stop();
  }

  // 暫停背景音樂
  Future<void> pauseBackgroundMusic() async {
    await _backgroundMusicPlayer.pause();
  }

  // 恢復背景音樂
  Future<void> resumeBackgroundMusic() async {
    // 1. 如果全局开关没开，直接返回
    if (!_isMusicEnabled) return;

    // 2. 检查播放器当前状态
    final state = _backgroundMusicPlayer.state;

    if (state == PlayerState.playing) {
      // A. 已经在播放中：什么都不用做
      print('[AudioService] Music already playing, no action needed');
      return;
    } else if (state == PlayerState.paused) {
      // B. 处于暂停状态：恢复播放 (从暂停位置继续)
      print('[AudioService] Resuming paused music');
      await _backgroundMusicPlayer.resume();
    } else {
      // C. 处于停止(stopped)或初始(completed)状态：重新开始播放
      // 这完美解决了 initialize() 调用 stop() 后的问题
      print('[AudioService] Music stopped/completed, restarting playback');
      await playBackgroundMusic();
    }
  }

  // 播放音效
  Future<void> playSoundEffect(String soundName) async {
    if (!_isSfxEnabled) {
      print('[AudioService] SFX disabled, skipping: $soundName');
      return;
    }

    // 🔊 如果播放器池尚未初始化，先初始化
    if (_sfxPlayerPool.isEmpty) {
      print('[AudioService] Initializing SFX pool...');
      await initialize();
    }

    try {
      // 使用輪詢方式選擇播放器，避免音效互相覆蓋
      final player = _sfxPlayerPool[_currentSfxPlayerIndex];
      final playerIndex = _currentSfxPlayerIndex;
      _currentSfxPlayerIndex = (_currentSfxPlayerIndex + 1) % _maxSfxPlayers;

      print(
          '[AudioService] 🔊 Playing: $soundName on player #$playerIndex (volume: $_sfxVolume)');

      // 🎯 立即播放音效，不等待（允許同時播放多個音效）
      // 使用 unawaited 明確表示我們故意不等待
      player.play(AssetSource('audio/$soundName.mp3')).then((_) {
        print('[AudioService] ✅ Started: $soundName');
      }).catchError((e) {
        print('❌ [AudioService] Error loading $soundName: $e');
      });
    } catch (e) {
      print('❌ [AudioService] Error playing sound effect $soundName: $e');
    }
  }

  // 音樂開關
  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    if (_isMusicEnabled) {
      await playBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
    }

    // 💾 保存設定到本地
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, _isMusicEnabled);
    print('[AudioService] Saved music enabled: $_isMusicEnabled');
  }

  // 音效開關
  Future<void> toggleSfx() async {
    _isSfxEnabled = !_isSfxEnabled;

    // 💾 保存設定到本地
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sfxEnabledKey, _isSfxEnabled);
    print('[AudioService] Saved SFX enabled: $_isSfxEnabled');
  }

  // 設定音樂音量
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _backgroundMusicPlayer.setVolume(_musicVolume);

    // 💾 保存設定到本地
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicVolumeKey, _musicVolume);
    print('[AudioService] Saved music volume: $_musicVolume');
  }

  // 設定音效音量
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    // 🔊 更新所有音效播放器的音量
    for (final player in _sfxPlayerPool) {
      await player.setVolume(_sfxVolume);
    }

    // 💾 保存設定到本地
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sfxVolumeKey, _sfxVolume);
    print('[AudioService] Saved SFX volume: $_sfxVolume');
  }

  // 清理資源
  Future<void> dispose() async {
    try {
      await _backgroundMusicPlayer.stop();
      await _backgroundMusicPlayer.dispose();

      // 🔊 清理所有音效播放器
      for (final player in _sfxPlayerPool) {
        await player.stop();
        await player.dispose();
      }
      _sfxPlayerPool.clear();
    } catch (e) {
      print('AudioService dispose error: $e');
    }
  }
}
