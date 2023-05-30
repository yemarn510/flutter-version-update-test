import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:dio/dio.dart';
import './application.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  bool isDownloading = false;
  double downloadProgress = 0;
  String downloadedFilePath = "";

  Future<Map<String, dynamic>> loadJsonFromGithub() async {
    final response = await http.read(Uri.parse(
      'https://raw.githubusercontent.com/yemarn510/flutter-version-update-test/main/app_versions_check/version.json',
    ));
    return jsonDecode(response);
  }

  Future<void> _checkForUpdates() async {
    final jsonVal = await loadJsonFromGithub();
    debugPrint("Response $jsonVal");
    showUpdateDialog(jsonVal);
  }

  Future downloadNewVersion(String appPath) async {
    final fileName = appPath.split("/").last;
    isDownloading = true;
    setState(() {});

    final dio = Dio();

    downloadedFilePath =
    "${(await getApplicationDocumentsDirectory()).path}/$fileName";

    await dio.download(
      "https://github.com/AgnelSelvan/Blogs/raw/main/in_app_update_flutter_desktop/app_versions_check/$appPath",
      downloadedFilePath,
      onReceiveProgress: (received, total) {
        final progress = (received / total) * 100;
        debugPrint('Rec: $received , Total: $total, $progress%');
        downloadProgress = double.parse(progress.toStringAsFixed(1));
        setState(() {});
      },
    );
    debugPrint("File Downloaded Path: $downloadedFilePath");
    // if (Platform.isWindows) {
    //   await openExeFile(downloadedFilePath);
    // }
    isDownloading = false;
    setState(() {});
  }



  showUpdateDialog(Map<String, dynamic> versionJson) {
    final version = versionJson['version'];
    final updates = versionJson['description'] as List;

    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(10),
            title: Text("Latest Version $version"),
            children: [
              Text("What's new in $version"),
              const SizedBox(
                height: 5,
              ),
              ...updates
                  .map((e) => Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "$e",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ))
                  .toList(),
              const SizedBox(
                height: 10,
              ),
              TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (Platform.isMacOS) {
                      downloadNewVersion(versionJson["macos_file_name"]);
                    }
                    if (Platform.isWindows) {
                      downloadNewVersion(versionJson["windows_file_name"]);
                    }
                  },
                  icon: const Icon(Icons.update),
                  label: const Text("Update")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Current version is 1.0',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkForUpdates,
        tooltip: 'Check Updates',
        child: const Icon(Icons.check_circle),
      ),
    );
  }
}
