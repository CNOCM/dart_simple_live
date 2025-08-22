import 'package:jsf/jsf.dart';
import 'package:flutter/services.dart';

class JsEngine {
  static JsRuntime? _jsRuntime;

  static JsRuntime get jsRuntime => _jsRuntime ??= JsRuntime();

  static void init() {
    _jsRuntime ??= JsRuntime();
  }

  static dynamic evaluate(String code) {
    return jsRuntime.eval(code);
  }

  static Future<void> loadJSFile(String path) async {
    final jsCode = await rootBundle.loadString(path);
    jsRuntime.eval(jsCode);
  }

  static void dispose() {
    _jsRuntime?.dispose();
    _jsRuntime = null;
  }
}
