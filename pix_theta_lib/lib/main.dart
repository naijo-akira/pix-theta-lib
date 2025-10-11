import 'package:flutter/material.dart';
import 'pages/connectivity_page.dart';
import 'pages/shooting_page.dart';

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
