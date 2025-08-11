import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:brotli/brotli.dart';
import 'package:simple_live_core/simple_live_core.dart';
import 'package:simple_live_core/src/common/web_socket_util.dart';

import '../common/binary_writer.dart';

class BiliBiliDanmakuArgs {
  final int roomId;
  final String token;
  final String buvid;
  final String serverHost;
  final int uid;
  final String cookie;
  BiliBiliDanmakuArgs({
    required this.roomId,
    required this.token,
    required this.serverHost,
    required this.buvid,
    required this.uid,
    required this.cookie,
  });
  @override
  String toString() {
    return json.encode({
      "roomId": roomId,
      "token": token,
      "serverHost": serverHost,
      "buvid": buvid,
      "uid": uid,
      "cookie": cookie,
    });
  }
}

class BiliBiliDanmaku implements LiveDanmaku {
  @override
  int heartbeatTime = 60 * 1000;

  @override
  Function(LiveMessage msg)? onMessage;
  @override
  Function(String msg)? onClose;
  @override
  Function()? onReady;

  //String serverUrl = "wss://broadcastlv.chat.bilibili.com/sub";

  WebSocketUtils? webSocketUtils;
  late BiliBiliDanmakuArgs danmakuArgs;
  @override
  Future start(dynamic args) async {
    danmakuArgs = args as BiliBiliDanmakuArgs;
    webSocketUtils = WebSocketUtils(
      url: "wss://${args.serverHost}/sub",
      heartBeatTime: heartbeatTime,
      headers: args.cookie.isEmpty
          ? null
          : {
              "cookie": args.cookie,
            },
      onMessage: (e) {
        decodeMessage(e);
      },
      onReady: () {
        onReady?.call();
        joinRoom(danmakuArgs);
      },
      onHeartBeat: () {
        heartbeat();
      },
      onReconnect: () {
        onClose?.call("与服务器断开连接，正在尝试重连");
      },
      onClose: (e) {
        onClose?.call("服务器连接失败$e");
      },
    );
    webSocketUtils?.connect();
  }

  void joinRoom(BiliBiliDanmakuArgs args) {
    var joinData = encodeData(
      json.encode({
        "uid": args.uid,
        "roomid": args.roomId,
        "protover": 3,
        "buvid": args.buvid,
        "platform": "web",
        "type": 2,
        "key": args.token,
      }),
      7,
    );
    webSocketUtils?.sendMessage(joinData);
  }

  @override
  void heartbeat() {
    webSocketUtils?.sendMessage(encodeData(
      "",
      2,
    ));
  }

  @override
  Future stop() async {
    onMessage = null;
    onClose = null;
    webSocketUtils?.close();
  }

  List<int> encodeData(String msg, int action) {
    var data = utf8.encode(msg);
    //头部长度固定16
    var length = data.length + 16;
    var buffer = Uint8List(length);

    var writer = BinaryWriter([]);

    //数据包长度
    writer.writeInt(buffer.length, 4);
    //数据包头部长度,固定16
    writer.writeInt(16, 2);

    //协议版本，0=JSON,1=Int32,2=Buffer
    writer.writeInt(0, 2);

    //操作类型
    writer.writeInt(action, 4);

    //数据包头部长度,固定1

    writer.writeInt(1, 4);

    writer.writeBytes(data);

    return writer.buffer;
  }

  void decodeMessage(List<int> data) {
    try {
      //协议版本。0为JSON，可以直接解析；1为房间人气值,Body为4位Int32；2为压缩过Buffer，需要解压再处理
      int protocolVersion = readInt(data, 6, 2);
      //操作类型。3=心跳回应，内容为房间人气值；5=通知，弹幕、广播等全部信息；8=进房回应，空
      int operation = readInt(data, 8, 4);
      //内容
      var body = data.skip(16).toList();
      if (operation == 3) {
        var online = readInt(body, 0, 4);

        onMessage?.call(
          LiveMessage(
            type: LiveMessageType.online,
            data: online,
            color: LiveMessageColor.white,
            message: "",
            userName: "",
          ),
        );
      } else if (operation == 5) {
        if (protocolVersion == 2) {
          body = zlib.decode(body);
        } else if (protocolVersion == 3) {
          body = brotli.decode(body);
        }

        var text = utf8.decode(body, allowMalformed: true);

        var group =
            text.split(RegExp(r"[\x00-\x1f]+", unicode: true, multiLine: true));
        for (var item
            in group.where((x) => x.length > 2 && x.startsWith('{'))) {
          parseMessage(item);
        }
      }
    } catch (e) {
      CoreLog.error(e);
    }
  }

  void parseMessage(String jsonMessage) {
    try {
      var obj = json.decode(jsonMessage);
      var cmd = obj["cmd"]?.toString() ?? '';
      if (cmd.contains("DANMU_MSG")) {
        final info = obj["info"];
        if (info == null || info.length == 0) return;

        final message = info[1].toString();
        final color = info[0][3];
        final username = info[2][1].toString();
        final imageUrls = _extractImageUrls(info);

        final liveMsg = LiveMessage(
          type: LiveMessageType.chat,
          userName: username,
          message: message,
          color: color == 0
              ? LiveMessageColor.white
              : LiveMessageColor.numberToColor(color),
          imageUrls: imageUrls,
        );

        onMessage?.call(liveMsg);
      } else if (cmd == "SUPER_CHAT_MESSAGE") {
        final data = obj["data"];
        if (data == null) return;

        final sc = LiveSuperChatMessage(
          backgroundBottomColor: data["background_bottom_color"].toString(),
          backgroundColor: data["background_color"].toString(),
          endTime: DateTime.fromMillisecondsSinceEpoch(data["end_time"] * 1000),
          face: "${data["user_info"]["face"]}@200w.jpg",
          message: data["message"].toString(),
          price: data["price"],
          startTime:
              DateTime.fromMillisecondsSinceEpoch(data["start_time"] * 1000),
          userName: data["user_info"]["uname"].toString(),
        );

        final liveMsg = LiveMessage(
          type: LiveMessageType.superChat,
          userName: "SUPER_CHAT_MESSAGE",
          message: "SUPER_CHAT_MESSAGE",
          color: LiveMessageColor.white,
          data: sc,
        );
        onMessage?.call(liveMsg);
      }
    } catch (e) {
      CoreLog.error(e);
    }
  }

  List<String>? _extractImageUrls(List<dynamic> info) {
    List<String>? imageUrls;

    try {
      // 情况1：直接在 info[0][13]["url"]
      final raw13 = info[0][13];
      if (raw13 is Map && raw13["url"] is String) {
        imageUrls ??= [];
        imageUrls.add(raw13["url"]);
      }

      // 情况2：info[0][15]["extra"] 解析 emots
      final extraStr = info[0][15]?["extra"];
      if (extraStr is String) {
        final extra = json.decode(extraStr);
        final emots = extra["emots"];
        if (emots != null && emots is Map) {
          imageUrls ??= [];

          final message = info[1].toString();
          final matches = RegExp(r'\[[^\[\]]+\]').allMatches(message);
          for (final match in matches) {
            final key = match.group(0);
            if (key != null &&
                emots.containsKey(key) &&
                emots[key]["url"] != null) {
              imageUrls.add(emots[key]["url"]);
            }
          }
        }
      }
    } catch (_) {}

    return imageUrls;
  }

  int readInt(List<int> buffer, int start, int len) {
    var bytes =
        Uint8List.fromList(buffer.getRange(start, start + len).toList());
    var byteBuffer = bytes.buffer;
    var data = ByteData.view(byteBuffer);
    var result = 0;

    if (len == 1) {
      result = data.getUint8(0);
    }
    if (len == 2) {
      result = data.getInt16(0, Endian.big);
    }
    if (len == 4) {
      result = data.getInt32(0, Endian.big);
    }
    if (len == 8) {
      result = data.getInt64(0, Endian.big);
    }

    return result;
  }
}
