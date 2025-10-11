import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pix Thefa Lib',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 250, 178, 95),
        ),
      ),
      home: const MyHomePage(title: 'Pix Thefa Lib Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      ConnectivityPage(), // 疎通確認
      ShootingPage(), // 撮影
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wifi_tethering),
            label: '疎通確認',
          ),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: '撮影'),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ConnectivityPage extends StatelessWidget {
  const ConnectivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_tethering, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 24),
            const Text(
              'RICOH THETAとの疎通確認',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () {
                // ここに疎通確認処理を後で追加
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('疎通確認ボタンが押されました')));
              },
              icon: const Icon(Icons.wifi),
              label: const Text('疎通確認を実行'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShootingPage extends StatelessWidget {
  const ShootingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              'THETAで撮影',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () {
                // ここに撮影処理を後で追加
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('撮影ボタンが押されました')));
              },
              icon: const Icon(Icons.camera),
              label: const Text('撮影する'),
            ),
          ],
        ),
      ),
    );
  }
}
