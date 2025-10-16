class ThetaConfig {
  final String hostName;
  final String username;
  final String password;

  const ThetaConfig({
    required this.hostName,
    required this.username,
    required this.password,
  });
}

/// デフォルトは --dart-define から埋め込み（define しなければ空文字）
const _defaultConfig = ThetaConfig(
  hostName: String.fromEnvironment('HOST_NAME', defaultValue: ''),
  username: String.fromEnvironment('USERNAME', defaultValue: ''),
  password: String.fromEnvironment('PASSWORD', defaultValue: ''),
);

/// 実行時に上書き可能な“現在の設定”
ThetaConfig _current = _defaultConfig;

/// 外から参照用
ThetaConfig get thetaConfig => _current;

/// 上書きするためのAPI（dotenv等もここで反映できる）
void initThetaConfig(ThetaConfig config) {
  _current = config;
}
