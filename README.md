# 🎮 Arcane Blocks: Rune Grid

一個基於 Flutter 的現代魔法方塊遊戲，結合經典方塊消除玩法與創新符文系統。

## 🚀 快速開始

### 本地 Web 測試
```bash
# 1. 編譯 Web 版本
flutter build web

# 2. 啟動本地伺服器
node simple_server.js

# 3. 在瀏覽器中訪問
http://localhost:3000
```

### 行動裝置編譯
```bash
# Android
flutter build apk

# iOS (需要 macOS 和 Xcode)
flutter build ios
```

## 🛠️ 開發

### 環境需求
- Flutter SDK 3.0+
- Dart 2.17+
- Node.js (用於本地伺服器)

### 專案結構
```
lib/
├── core/           # 核心常數和配置
├── game/           # 遊戲邏輯和 UI 組件
├── models/         # 資料模型 (Tetromino 等)
├── services/       # 服務層 (音頻、得分等)
├── theme/          # UI 主題和樣式
└── widgets/        # 可重用 UI 組件
```

---

🎯 **目標**：提供專業級魔法方塊遊戲體驗，結合經典玩法與創新符文系統

🚀 **願景**：成為 Flutter 生態系統中最完整的魔法方塊遊戲實現
