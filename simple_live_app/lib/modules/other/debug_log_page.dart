import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/log.dart';

class DebugLogPage extends StatelessWidget {
  const DebugLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log"),
        actions: [
          IconButton(
            onPressed: () async {
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final msg = Log.debugLogs
                  .map((x) => "${x.datetime}\r\n${x.content}")
                  .join('\r\n\r\n');
              final dir = await getApplicationDocumentsDirectory();
              final fileName = '$timestamp.log';
              final logFile = File('${dir.path}/$fileName');
              await logFile.writeAsString(msg);

              final params = ShareParams(
                files: [XFile(logFile.path)],
                text: '分享日志文件',
              );

              await SharePlus.instance.share(params);
            },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              Log.debugLogs.clear();
            },
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Obx(
        () => ListView.separated(
          itemCount: Log.debugLogs.length,
          separatorBuilder: (_, i) => const Divider(),
          padding: AppStyle.edgeInsetsA12,
          itemBuilder: (_, i) {
            var item = Log.debugLogs[i];
            return SelectableText(
              "${item.datetime.toString()}\r\n${item.content}",
              style: TextStyle(
                color: item.color,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
    );
  }
}
