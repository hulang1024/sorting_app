import 'package:flutter/material.dart';
import '../screen.dart';
import 'version.dart';

class AboutScreen extends Screen {
  AboutScreen() : super(title: '关于', homeAction: false, addPadding: EdgeInsets.all(-8));
  @override
  State<StatefulWidget> createState() => AboutScreenState();
}

class AboutScreenState extends ScreenState<AboutScreen> {
  String version;
  VersionCheckingState _versionCheckingState = VersionCheckingState.checking;

  @override
  void initState() {
    super.initState();

    VersionManager.getCurrentVersion().then((version) {
      setState(() {
        this.version = version;
      });
    });
    VersionManager.checkUpdate(
        autoUpdate: false,
        onStateChange: (state) {
          setState(() {
            _versionCheckingState = state;
          });
        }
    );
  }

  @override
  Widget render(BuildContext context) {
    return Container(
      color: Color.fromRGBO(240,240,240,1),
      padding: EdgeInsets.only(top: 8),
      child: ListView(
        children: [
          Center(child: Text('版本' + version)),
          Container(
            margin: EdgeInsets.only(top: 8),
            color: Colors.white,
            child: ListTile(
              leading: Text('版本更新'),
              trailing: Text(['检查中', '已是最新版本', '有新版本，点击更新'][_versionCheckingState.index],
                style: TextStyle(color: [Colors.grey, Colors.green, Colors.orange][_versionCheckingState.index]),
              ),
              onTap: () {
                if (_versionCheckingState == VersionCheckingState.needUpdated) {
                  VersionManager.update();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

}
