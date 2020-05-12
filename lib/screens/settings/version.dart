import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sorting/widgets/message.dart';
import '../../api/http_api.dart';

/// 版本检查状态枚举。
enum VersionCheckingState {
  checking, currentIsLatest, needUpdated
}

/// 版本管理
class VersionManager {
  static bool _initialized = false;
  static Completer<String> _currentVersionCompleter;
  static Map _latestVersionInfo;

  static void checkUpdate({ValueChanged onStateChange, autoUpdate = true}) async {
    onStateChange = onStateChange ?? (v) {};
    onStateChange(VersionCheckingState.checking);
    String currentVersion = await getCurrentVersion();
    Result ret = await api.get('/app_version/latest_info');
    if (ret.isOk) {
      _latestVersionInfo = ret.data;
      VersionCheckingState state = compareVersion(currentVersion, _latestVersionInfo['version']) >= 0
          ? VersionCheckingState.currentIsLatest
          : VersionCheckingState.needUpdated;
      onStateChange(state);
      if (autoUpdate && state == VersionCheckingState.needUpdated) {
        update();
      }
    } else {
      onStateChange(VersionCheckingState.currentIsLatest);
    }
  }

  static Future<String> getCurrentVersion() async {
    if (_currentVersionCompleter == null) {
      _currentVersionCompleter = Completer<String>();
      String version = (await PackageInfo.fromPlatform()).version;
      _currentVersionCompleter.complete(version);
    }
    return _currentVersionCompleter.future;
  }

  static void update() {
    Messager.info('应用有新版本，正在更新');
    _download(_latestVersionInfo);
  }

  static void _download(versionInfo) async {
    if (!_initialized) {
      await FlutterDownloader.initialize();
      _initialized = true;
    }

    await FlutterDownloader.enqueue(
      url: api.options.baseUrl + '/' + versionInfo['url'],
      savedDir: await getAppPath(),
      fileName: versionInfo['version'] + '.apk',
      showNotification: true,
      openFileFromNotification: true,
    );
    FlutterDownloader.registerCallback(_downloadCallback);
  }

  static void _downloadCallback(taskId, status, progress) async {
    if (status == DownloadTaskStatus.complete) {
      await FlutterDownloader.initialize();
      //FlutterDownloader.open(taskId: taskId);
      InstallPlugin.installApk(await getAppPath(), "io.github.hulang1024");
    } else if (status == DownloadTaskStatus.failed) {
    }
  }

  static Future<String> getAppPath() async {
    return (await getExternalStorageDirectory()).path;
  }
}

int compareVersion(String version1, String version2) {
  List<int> parseNumbers(String version) {
    return version.split('\.').map((s) => int.parse(s)).toList();
  }
  List<int> numbers1 = parseNumbers(version1);
  List<int> numbers2 = parseNumbers(version2);
  for (int i = 0, l = numbers1.length; i < l; i++) {
    int ret = numbers1[i] - numbers2[i];
    if (ret != 0) {
      return ret;
    }
  }
  return 0;
}