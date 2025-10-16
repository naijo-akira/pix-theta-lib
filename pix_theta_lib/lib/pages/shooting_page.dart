import 'package:flutter/material.dart';
import 'package:pix_theta_utils/pix_theta_utils.dart';

class ShootingPage extends StatefulWidget {
  const ShootingPage({super.key});

  @override
  State<ShootingPage> createState() => _ShootingPageState();
}

class _ShootingPageState extends State<ShootingPage> {
  final _ipCtrl = TextEditingController(text: thetaConfig.hostName); // デフォルトIP
  late ThetaApiDigestAuth _api;
  bool _shooting = false;
  String? _fileUrl; // 撮影結果のURL（返ってくれば表示）
  String? _message; // 補足メッセージ（stateやidなど）
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = ThetaApiDigestAuth(
      host: _ipCtrl.text.trim(),
      user: 'XXX',
      password: 'XXX',
    );
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  Future<void> _shoot() async {
    setState(() {
      _shooting = true;
      _error = null;
      _fileUrl = null;
      _message = null;
    });

    // 入力IPを反映
    _api.setHost(_ipCtrl.text.trim());

    try {
      final res = await _api.takePicture(); // 撮影→必要なら完了待ち
      // 代表的な返却（機種/ファームで差異あり）
      final state = res['state']?.toString();
      final results = res['results'] as Map<String, dynamic>?;

      setState(() {
        _message = 'state: $state';
        _fileUrl = results?['fileUrl']?.toString();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_fileUrl != null ? '撮影完了' : '撮影コマンド完了')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('撮影エラー: $e')));
    } finally {
      if (mounted) setState(() => _shooting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.camera_alt, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 24),
          const Text(
            'THETAで撮影',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ipCtrl,
            decoration: const InputDecoration(
              labelText: 'THETAのシリアルナンバーorIPアドレス',
              hintText: '例) THETAYN12345678.local or 192.168.1.1',
              prefixIcon: Icon(Icons.router),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _shooting ? null : _shoot,
            icon: const Icon(Icons.camera),
            label: _shooting ? const Text('撮影中…') : const Text('撮影する'),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.error_outline),
                title: const Text('エラー'),
                subtitle: Text(_error!),
              ),
            ),
          if (_message != null || _fileUrl != null)
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text('撮影結果'),
                  ),
                  if (_message != null) const Divider(height: 1),
                  if (_message != null)
                    ListTile(
                      title: const Text('メッセージ'),
                      subtitle: Text(_message!),
                    ),
                  if (_fileUrl != null) const Divider(height: 1),
                  if (_fileUrl != null)
                    ListTile(
                      title: const Text('fileUrl'),
                      subtitle: Text(_fileUrl!),
                      trailing: const Icon(Icons.link),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
