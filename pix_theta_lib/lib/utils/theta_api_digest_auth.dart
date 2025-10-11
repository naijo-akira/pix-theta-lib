// lib/utils/theta_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http; // 型だけ使う（close等）
import 'package:http_auth/http_auth.dart' as http_auth;

class ThetaApi {
  ThetaApi({
    String host = 'XXX',
    required String user,
    required String password,
  }) : _host = host,
       _user = user,
       _password = password,
       baseUrl = 'http://$host/osc',
       _client = http_auth.DigestAuthClient(user, password);

  String baseUrl;
  String _host;
  String _user;
  String _password;

  http.BaseClient _client; // DigestAuthClient は BaseClient を継承

  Uri get _info => Uri.parse('$baseUrl/info');
  Uri get _state => Uri.parse('$baseUrl/state');
  Uri get _execute => Uri.parse('$baseUrl/commands/execute');
  Uri get _status => Uri.parse('$baseUrl/commands/status');

  /// /osc/info で基本情報を取得（model, firmwareVersion など）
  Future<Map<String, dynamic>> getInfo({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final res = await _client.get(_info).timeout(timeout);
    if (res.statusCode >= 400) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  /// /osc/state で状態を取得
  Future<Map<String, dynamic>> getState({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    // /osc/state は POST
    final res = await _client.post(_state).timeout(timeout);
    if (res.statusCode >= 400) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  /// 疎通確認（/osc/info を叩いて到達可否だけ返す）
  Future<bool> ping() async {
    try {
      await getInfo();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 接続先（ホスト名/IP）を変更
  void setHost(String host) {
    _host = host;
    baseUrl = 'http://$host/osc';
  }

  /// 認証情報を変更（CLモードのユーザID・パスワード）
  void setCredentials({required String user, required String password}) {
    _user = user;
    _password = password;
    // DigestAuthClient は再生成する
    _client.close();
    _client = http_auth.DigestAuthClient(_user, _password);
  }

  /// リソース解放（不要なら呼ばなくても動くが、明示的に閉じたい場合に）
  void close() {
    _client.close();
  }

  /// 写真撮影を実行 (camera.takePicture)
  /// 成功すると撮影結果JSONを返す
  Future<Map<String, dynamic>> takePicture({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final body = {"name": "camera.takePicture"};
    final res = await _client
        .post(
          _execute,
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: jsonEncode(body),
        )
        .timeout(timeout);

    if (res.statusCode >= 400) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final result =
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    // inProgress の場合は status をポーリング
    if (result['state'] == 'inProgress' && result['id'] != null) {
      final id = result['id'];
      return await _waitForCommandDone(id);
    }

    return result;
  }

  /// コマンドの完了待ち (/osc/commands/status)
  Future<Map<String, dynamic>> _waitForCommandDone(
    String id, {
    Duration interval = const Duration(seconds: 1),
    int maxTries = 15,
  }) async {
    for (var i = 0; i < maxTries; i++) {
      await Future.delayed(interval);
      final res = await _client.post(
        _status,
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode({"id": id}),
      );
      if (res.statusCode >= 400) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      final result =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      if (result['state'] == 'done') return result;
    }
    throw Exception('撮影タイムアウト: コマンドが完了しませんでした');
  }
}
