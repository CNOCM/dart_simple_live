import 'package:tars_flutter/tars/codec/tars_displayer.dart';
import 'package:tars_flutter/tars/codec/tars_input_stream.dart';
import 'package:tars_flutter/tars/codec/tars_output_stream.dart';
import 'package:tars_flutter/tars/codec/tars_struct.dart';

class GetCdnTokenResp extends TarsStruct {
  String url = "";

  String cdnType = "";

  String streamName = "";

  int presenterUid = 0;

  String antiCode = "";

  String sTime = "";

  String flvAntiCode = "";

  String hlsAntiCode = "";

  @override
  void readFrom(TarsInputStream inputStream) {
    url = inputStream.read(url, 0, false);
    cdnType = inputStream.read(cdnType, 1, false);
    streamName = inputStream.read(streamName, 2, false);
    presenterUid = inputStream.read(presenterUid, 3, false);
    antiCode = inputStream.read(antiCode, 4, false);
    sTime = inputStream.read(sTime, 5, false);
    flvAntiCode = inputStream.read(flvAntiCode, 6, false);
    hlsAntiCode = inputStream.read(hlsAntiCode, 7, false);
  }

  @override
  void writeTo(TarsOutputStream outputStream) {
    outputStream.write(url, 0);
    outputStream.write(cdnType, 1);
    outputStream.write(streamName, 2);
    outputStream.write(presenterUid, 3);
    outputStream.write(antiCode, 4);
    outputStream.write(sTime, 5);
    outputStream.write(flvAntiCode, 6);
    outputStream.write(hlsAntiCode, 7);
  }

  @override
  Object deepCopy() {
    return GetCdnTokenResp()
      ..url = url
      ..cdnType = cdnType
      ..streamName = streamName
      ..presenterUid = presenterUid
      ..antiCode = antiCode
      ..sTime = sTime
      ..flvAntiCode = flvAntiCode
      ..hlsAntiCode = hlsAntiCode;
  }

  @override
  void displayAsString(StringBuffer sb, int level) {
    TarsDisplayer displayer = TarsDisplayer(sb, level: level);
    displayer.DisplayString(url, "url");
    displayer.DisplayString(cdnType, "cdnType");
    displayer.DisplayString(streamName, "streamName");
    displayer.DisplayInt(presenterUid, "presenterUid");
    displayer.DisplayString(antiCode, "antiCode");
    displayer.DisplayString(sTime, "sTime");
    displayer.DisplayString(flvAntiCode, "flvAntiCode");
    displayer.DisplayString(hlsAntiCode, "hlsAntiCode");
  }
}
