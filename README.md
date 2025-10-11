# pix-theta-lib

## 1. 開発環境の構築

* Flutterバージョン管理にはFVM（Flutter Version Management）
* 基本的には開発時点のバージョンを固定とする。

---

### Step 1: 開発ツールのインストール

* 前提ツール

| ツール | 用途 |
|--------|------|
| Git | バージョン管理 |
| Homebrew（macOSのみ） | パッケージマネージャー |
| Java 17 以上 | Androidビルドに必要 |
| Android Studio | Android SDK / AVD 管理 |
| Xcode（macOS） | iOSビルド・実機デバッグ用 |
| CocoaPods | iOS ライブラリ管理 |

#### macOS での例
```bash
# Homebrewのインストール（未導入の場合）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Java・Git・CocoaPodsをインストール
brew install openjdk@17 git cocoapods
```

### Step 2: FVM の導入（Flutter Version Management）

* Flutter SDK をプロジェクト単位で管理するために FVM を導入

#### Dart コマンドでインストール
```bash
dart pub global activate fvm
```

### Step 3: Flutter の最新安定版をインストールして固定
```bash
# インストール
fvm install stable
fvm global stable

# バージョン確認
fvm list

# 環境チェック
fvm flutter doctor -v
```

* すべての項目に ✅ がついていれば準備完了です。

---

## 2. スモールプロジェクトの作成

### Step 1: 新規プロジェクトの作成

```bash
fvm flutter create pix_theta_lib
cd pix_theta_lib
```

### Step 2: 初回起動確認

```bash
fvm flutter run
```

* FVMを使っている場合、IDEが正しいSDKを認識するよう設定します。
* VSCode では .vscode/settings.json に以下を追加してください。

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk"
}
```

---

## 3. 実機確認

```bash
# デバイス確認
fvm flutter devices

# 起動
fvm flutter run --profile -d <device id>
```

* 実機ではDebugモードでの実行不可のためProfileモードで起動

---