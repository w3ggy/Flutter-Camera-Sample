import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: openBottomSheet,
          child: Text('Open camera preview'),
        ),
      ),
    );
  }

  Future<void> openBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        width: 200,
        height: 200,
        child: CameraPreviewPage(showButton: true),
      ),
    );
  }
}

class CameraPreviewPage extends StatefulWidget {
  const CameraPreviewPage({this.showButton = false, super.key});

  final bool showButton;

  @override
  State<CameraPreviewPage> createState() => CameraPreviewPageState();
}

class CameraPreviewPageState extends State<CameraPreviewPage> {
  CameraController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _hasError = true;
        });
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _controller == null) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(
          child: Icon(Icons.camera_alt, size: 32, color: Colors.grey),
        ),
      );
    }

    if (!_controller!.value.isInitialized) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        if (widget.showButton)
          Center(
            child: ElevatedButton(
              onPressed: _openNextPage,
              child: Text('Open full screen camera'),
            ),
          ),
      ],
    );
  }

  Future<void> _openNextPage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CameraPreviewPage()));

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
