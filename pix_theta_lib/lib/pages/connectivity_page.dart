import 'package:flutter/material.dart';
import '../utils/theta_api_digest_auth.dart';

class ConnectivityPage extends StatefulWidget {
  const ConnectivityPage({super.key});

  @override
  State<ConnectivityPage> createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  final _ipCtrl = TextEditingController(text: 'XXX'); // デフォルト
  late ThetaApi _api;
  bool _loading = false;
  String? _model;
  String? _firmware;
  String? _serial;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = ThetaApi(host: _ipCtrl.text.trim(), user: 'XXX', password: 'XXX');
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    setState(() {
      _loading = true;
      _error = null;
      _model = null;
      _firmware = null;
      _serial = null;
    });

    // 入力IPを反映
    _api.setHost(_ipCtrl.text.trim());

    try {
      final info = await _api.getInfo(); // /osc/info
      setState(() {
        _model = info['model']?.toString();
        _firmware = info['firmwareVersion']?.toString();
        _serial = info['serialNumber']?.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('疎通OK')));
      }
    } catch (e) {
      setState(() => _error = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('疎通NG: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.wifi_tethering, size: 80, color: Colors.blueGrey),
          const SizedBox(height: 24),
          const Text(
            'RICOH THETAとの疎通確認',
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
            onPressed: _loading ? null : _checkConnectivity,
            icon: const Icon(Icons.wifi),
            label: _loading ? const Text('実行中…') : const Text('疎通確認を実行'),
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
          if (_model != null || _firmware != null || _serial != null)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('本体情報 (/osc/info)'),
                    subtitle: Text('IP: ${_ipCtrl.text.trim()}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Model'),
                    subtitle: Text(_model ?? '-'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Firmware'),
                    subtitle: Text(_firmware ?? '-'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Serial Number'),
                    subtitle: Text(_serial ?? '-'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
