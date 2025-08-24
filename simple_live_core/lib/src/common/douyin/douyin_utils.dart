import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:dart_sm_new/dart_sm_new.dart';

import 'package:simple_live_core/simple_live_core.dart';
import 'package:simple_live_core/src/common/http_client.dart';

class StringProcessor {
  static String toOrdStr(String s) => s.codeUnits.join();
  static List<int> toCharArray(String s) => s.codeUnits;
  static String toCharStr(List<int> codes) => String.fromCharCodes(codes);

  static int jsShiftRight(int val, int n) => ((val & 0xFFFFFFFF) >> n);

  static String generateRandomBytes([int length = 3]) {
    final random = Random();
    List<int> generateByteSequence() {
      int rd = (random.nextDouble() * 10000).toInt();
      return [
        ((rd & 255) & 170) | 1,
        ((rd & 255) & 85) | 2,
        (jsShiftRight(rd, 8) & 170) | 5,
        (jsShiftRight(rd, 8) & 85) | 40,
      ];
    }

    List<int> result = [];
    for (int i = 0; i < length; i++) {
      result.addAll(generateByteSequence());
    }
    return String.fromCharCodes(result);
  }
}

class CryptoUtility {
  final String salt;
  final List<String> base64Alphabet;
  List<int> bigArray = [
    121,
    243,
    55,
    234,
    103,
    36,
    47,
    228,
    30,
    231,
    106,
    6,
    115,
    95,
    78,
    101,
    250,
    207,
    198,
    50,
    139,
    227,
    220,
    105,
    97,
    143,
    34,
    28,
    194,
    215,
    18,
    100,
    159,
    160,
    43,
    8,
    169,
    217,
    180,
    120,
    247,
    45,
    90,
    11,
    27,
    197,
    46,
    3,
    84,
    72,
    5,
    68,
    62,
    56,
    221,
    75,
    144,
    79,
    73,
    161,
    178,
    81,
    64,
    187,
    134,
    117,
    186,
    118,
    16,
    241,
    130,
    71,
    89,
    147,
    122,
    129,
    65,
    40,
    88,
    150,
    110,
    219,
    199,
    255,
    181,
    254,
    48,
    4,
    195,
    248,
    208,
    32,
    116,
    167,
    69,
    201,
    17,
    124,
    125,
    104,
    96,
    83,
    80,
    127,
    236,
    108,
    154,
    126,
    204,
    15,
    20,
    135,
    112,
    158,
    13,
    1,
    188,
    164,
    210,
    237,
    222,
    98,
    212,
    77,
    253,
    42,
    170,
    202,
    26,
    22,
    29,
    182,
    251,
    10,
    173,
    152,
    58,
    138,
    54,
    141,
    185,
    33,
    157,
    31,
    252,
    132,
    233,
    235,
    102,
    196,
    191,
    223,
    240,
    148,
    39,
    123,
    92,
    82,
    128,
    109,
    57,
    24,
    38,
    113,
    209,
    245,
    2,
    119,
    153,
    229,
    189,
    214,
    230,
    174,
    232,
    63,
    52,
    205,
    86,
    140,
    66,
    175,
    111,
    171,
    246,
    133,
    238,
    193,
    99,
    60,
    74,
    91,
    225,
    51,
    76,
    37,
    145,
    211,
    166,
    151,
    213,
    206,
    0,
    200,
    244,
    176,
    218,
    44,
    184,
    172,
    49,
    216,
    93,
    168,
    53,
    21,
    183,
    41,
    67,
    85,
    224,
    155,
    226,
    242,
    87,
    177,
    146,
    70,
    190,
    12,
    162,
    19,
    137,
    114,
    25,
    165,
    163,
    192,
    23,
    59,
    9,
    94,
    179,
    107,
    35,
    7,
    142,
    131,
    239,
    203,
    149,
    136,
    61,
    249,
    14,
    156,
  ];

  CryptoUtility(this.salt, this.base64Alphabet);

  static List<int> sm3ToArray(dynamic inputData) {
    List<int> inputBytes;
    if (inputData is String) {
      inputBytes = utf8.encode(inputData);
    } else if (inputData is List<int>) {
      inputBytes = inputData;
    } else {
      throw ArgumentError('Input must be String or List<int>');
    }

    String hexResult = SM3.hashBytes(inputBytes);
    List<int> result = [];
    for (int i = 0; i < hexResult.length; i += 2) {
      result.add(int.parse(hexResult.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  String addSalt(String param) => param + salt;

  dynamic processParam(dynamic param, bool addSaltFlag) {
    if (param is String && addSaltFlag) return addSalt(param);
    return param;
  }

  List<int> paramsToArray(dynamic param, [bool addSaltFlag = true]) {
    return sm3ToArray(processParam(param, addSaltFlag));
  }

  String transformBytes(List<int> bytesList) {
    String bytesStr = StringProcessor.toCharStr(bytesList);
    List<String> resultStr = [];
    int indexB = bigArray[1];
    int initialValue = 0;
    int valueE = 0;

    for (int index = 0; index < bytesStr.length; index++) {
      int sumInitial;
      if (index == 0) {
        initialValue = bigArray[indexB];
        sumInitial = indexB + initialValue;
        bigArray[1] = initialValue;
        bigArray[indexB] = indexB;
      } else {
        sumInitial = initialValue + valueE;
      }

      int charValue = bytesStr.codeUnitAt(index);
      sumInitial %= bigArray.length;
      int valueF = bigArray[sumInitial];
      int encryptedChar = charValue ^ valueF;
      resultStr.add(String.fromCharCode(encryptedChar));

      valueE = bigArray[(index + 2) % bigArray.length];
      sumInitial = (indexB + valueE) % bigArray.length;
      initialValue = bigArray[sumInitial];
      bigArray[sumInitial] = bigArray[(index + 2) % bigArray.length];
      bigArray[(index + 2) % bigArray.length] = initialValue;
      indexB = sumInitial;
    }
    return resultStr.join();
  }

  static List<int> rc4Encrypt(List<int> key, String plaintext) {
    List<int> S = List.generate(256, (i) => i);
    int j = 0;
    for (int i = 0; i < 256; i++) {
      j = (j + S[i] + key[i % key.length]) % 256;
      int tmp = S[i];
      S[i] = S[j];
      S[j] = tmp;
    }
    int i = 0;
    j = 0;
    List<int> ciphertext = [];
    for (var char in plaintext.codeUnits) {
      i = (i + 1) % 256;
      j = (j + S[i]) % 256;
      int tmp = S[i];
      S[i] = S[j];
      S[j] = tmp;
      int K = S[(S[i] + S[j]) % 256];
      ciphertext.add(char ^ K);
    }
    return ciphertext;
  }

  String abogusEncode(String abogusBytesStr, int selectedAlphabet) {
    List<String> abogus = [];
    for (int i = 0; i < abogusBytesStr.length; i += 3) {
      int n;
      if (i + 2 < abogusBytesStr.length) {
        n = (abogusBytesStr.codeUnitAt(i) << 16) |
            (abogusBytesStr.codeUnitAt(i + 1) << 8) |
            abogusBytesStr.codeUnitAt(i + 2);
      } else if (i + 1 < abogusBytesStr.length) {
        n = (abogusBytesStr.codeUnitAt(i) << 16) |
            (abogusBytesStr.codeUnitAt(i + 1) << 8);
      } else {
        n = abogusBytesStr.codeUnitAt(i) << 16;
      }

      List<int> masks = [0xFC0000, 0x03F000, 0x0FC0, 0x3F];
      for (int j = 18; j >= 0; j -= 6) {
        if (j == 6 && i + 1 >= abogusBytesStr.length) break;
        if (j == 0 && i + 2 >= abogusBytesStr.length) break;
        int mask = masks[(18 - j) ~/ 6];
        abogus.add(base64Alphabet[selectedAlphabet][(n & mask) >> j]);
      }
    }
    abogus.add('=' * ((4 - abogus.length % 4) % 4));
    return abogus.join();
  }
}

class BrowserFingerprintGenerator {
  static final Random _random = Random();
  static String generateFingerprint([String browserType = "Edge"]) {
    int innerWidth = 1024 + _random.nextInt(1920 - 1024 + 1);
    int innerHeight = 768 + _random.nextInt(1080 - 768 + 1);
    int outerWidth = innerWidth + 24 + _random.nextInt(9);
    int outerHeight = innerHeight + 75 + _random.nextInt(16);
    int screenX = 0;
    int screenY = _random.nextBool() ? 0 : 30;
    int sizeWidth = 1024 + _random.nextInt(1920 - 1024 + 1);
    int sizeHeight = 768 + _random.nextInt(1080 - 768 + 1);
    int availWidth = 1280 + _random.nextInt(1920 - 1280 + 1);
    int availHeight = 800 + _random.nextInt(1080 - 800 + 1);

    return "$innerWidth|$innerHeight|$outerWidth|$outerHeight|"
        "$screenX|$screenY|0|0|$sizeWidth|$sizeHeight|"
        "$availWidth|$availHeight|$innerWidth|$innerHeight|24|24|Win32";
  }
}

class ABogus {
  late CryptoUtility cryptoUtility;
  late String userAgent;
  late String browserFp;
  late Uint8List uaKey;
  final List<String> characterList = [
    "Dkdpgh2ZmsQB80/MfvV36XI1R45-WUAlEixNLwoqYTOPuzKFjJnry79HbGcaStCe",
    "ckdp1h4ZKsUB80/Mfvw36XIgR25+WQAlEi7NLboqYTOPuzmFjJnryx9HVGDaStCe",
  ];

  ABogus({String userAgent = "", String fp = ""}) {
    this.userAgent = userAgent.isNotEmpty
        ? userAgent
        : "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0";
    browserFp =
        fp.isNotEmpty ? fp : BrowserFingerprintGenerator.generateFingerprint();
    uaKey = Uint8List.fromList([0, 1, 14]);
    cryptoUtility = CryptoUtility("cus", characterList);
  }

  static String getMSToken({int randomLength = 107}) {
    const baseStr =
        'ABCDEFGHIGKLMNOPQRSTUVWXYZabcdefghigklmnopqrstuvwxyz0123456789=';
    final sb = StringBuffer();
    for (var i = 0; i < randomLength; i++) {
      var index = Random().nextInt(baseStr.length);
      sb.write(baseStr[index]);
    }
    return sb.toString();
  }

  Future<String> generateAbogus(String params, {String body = ""}) async {
    List<int> array1 = cryptoUtility.paramsToArray(
      cryptoUtility.paramsToArray(params),
    );
    List<int> array2 = cryptoUtility.paramsToArray(
      cryptoUtility.paramsToArray(body),
    );
    List<int> array3 = cryptoUtility.paramsToArray(
      cryptoUtility.abogusEncode(
        StringProcessor.toOrdStr(
          String.fromCharCodes(CryptoUtility.rc4Encrypt(uaKey, userAgent)),
        ),
        1,
      ),
      false,
    );

    List<int> combined = [...array1, ...array2, ...array3];
    String abBytesStr = StringProcessor.generateRandomBytes() +
        cryptoUtility.transformBytes(combined);
    return cryptoUtility.abogusEncode(abBytesStr, 0);
  }

  Future<Map<String, String>> getTtwidWebid({required String reqUrl}) async {
    // 先请求以获取 ttwid 等 Cookie，再解析页面的 RENDER_DATA 获取 user_unique_id
    final headers = <String, String>{
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36 Edg/125.0.0.0",
      "Accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
      "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
    };

    String? ttwid;
    String? webid;

    try {
      // 先用 HEAD 获取 Set-Cookie（包含 ttwid）
      final headResp = await HttpClient.instance.head(
        reqUrl,
        header: headers,
      );
      final setCookies = headResp.headers["set-cookie"];
      if (setCookies != null) {
        for (final cookieLine in setCookies) {
          final cookie = cookieLine.split(";").first;
          if (cookie.startsWith("ttwid=")) {
            ttwid = cookie.substring("ttwid=".length);
            break;
          }
        }
      }

      // 再用 GET 拉取页面 HTML，解析 RENDER_DATA
      final html = await HttpClient.instance.getText(
        reqUrl,
        header: headers,
      );

      // 提取 RENDER_DATA 脚本块
      final renderMatches = RegExp(
        r'<script id=\"RENDER_DATA\" type=\"application\/json\">(.*?)<\/script>',
        dotAll: true,
      ).allMatches(html);
      if (renderMatches.isNotEmpty) {
        var renderDataText = renderMatches.first.group(1) ?? "";
        // URL 解码
        try {
          renderDataText = Uri.decodeComponent(renderDataText);
        } catch (_) {}
        try {
          final data = jsonDecode(renderDataText) as Map<String, dynamic>;
          // 路径 app.odin.user_unique_id
          final app = data['app'] as Map<String, dynamic>?;
          final odin = app?['odin'] as Map<String, dynamic>?;
          final uid = odin?['user_unique_id'];
          if (uid != null) {
            webid = uid.toString();
          }
        } catch (e) {
          CoreLog.error('解析 RENDER_DATA 失败: $e');
        }
      }
    } catch (e) {
      CoreLog.error('get_ttwid_webid 错误: $e');
    }

    return {
      'ttwid': ttwid ?? '',
      'webid': webid ?? '',
    };
  }
}
