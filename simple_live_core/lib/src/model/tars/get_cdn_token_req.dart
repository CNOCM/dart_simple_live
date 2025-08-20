import 'package:tars_flutter/tars/codec/tars_displayer.dart';
import 'package:tars_flutter/tars/codec/tars_input_stream.dart';
import 'package:tars_flutter/tars/codec/tars_output_stream.dart';
import 'package:tars_flutter/tars/codec/tars_struct.dart';

class GetCdnTokenReq extends TarsStruct {
  String url = "";

  String cdnType = "";

  String streamName = "";

  int presenterUid = 0;

  @override
  void readFrom(TarsInputStream inputStream) {
    url = inputStream.read(url, 0, false);
    cdnType = inputStream.read(cdnType, 1, false);
    streamName = inputStream.read(streamName, 2, false);
    presenterUid = inputStream.read(presenterUid, 3, false);
  }

  @override
  void writeTo(TarsOutputStream outputStream) {
    outputStream.write(url, 0);
    outputStream.write(cdnType, 1);
    outputStream.write(streamName, 2);
    outputStream.write(presenterUid, 3);
  }

  @override
  Object deepCopy() {
    return GetCdnTokenReq()
      ..url = url
      ..cdnType = cdnType
      ..streamName = streamName
      ..presenterUid = presenterUid;
  }

  @override
  void displayAsString(StringBuffer sb, int level) {
    TarsDisplayer disPlayer = TarsDisplayer(sb, level: level);
    disPlayer.DisplayString(url, "url");
    disPlayer.DisplayString(cdnType, "cdnType");
    disPlayer.DisplayString(streamName, "streamName");
    disPlayer.DisplayInt(presenterUid, "presenterUid");
  }
}
