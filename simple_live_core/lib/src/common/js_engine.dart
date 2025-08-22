import 'package:flutter_js/flutter_js.dart';
import 'package:flutter/services.dart';
import 'package:simple_live_core/simple_live_core.dart';

class JsEngine {
  static JavascriptRuntime? _jsRuntime;
  static bool _initialized = false;

  static JavascriptRuntime get jsRuntime {
    if (_jsRuntime == null) {
      throw Exception("JsEngine not initialized. Call JsEngine.init() first.");
    }
    return _jsRuntime!;
  }

  static void init() {
    if (_initialized) return;

    try {
      _jsRuntime ??= getJavascriptRuntime();
      jsRuntime.enableHandlePromises();
      _initialized = true;
    } catch (e, st) {
      CoreLog.e("JsEngine init error: $e", st);
    }
  }

  static Future<JsEvalResult> evaluateAsync(String code) async {
    if (!_initialized) init();
    try {
      return await jsRuntime.evaluateAsync(code);
    } catch (e, st) {
      CoreLog.e("JsEngine evaluateAsync error: $e", st);
      rethrow;
    }
  }

  static JsEvalResult evaluate(String code) {
    if (!_initialized) init();
    try {
      return jsRuntime.evaluate(code);
    } catch (e, st) {
      CoreLog.e("JsEngine evaluate error: $e", st);
      rethrow;
    }
  }

  static Future<void> loadJSFile(String path) async {
    if (!_initialized) init();
    try {
      final jsCode = await rootBundle.loadString(path);
      jsRuntime.evaluate(jsCode);
    } catch (e, st) {
      CoreLog.e("JsEngine loadJSFile error: $e", st);
    }
  }

  static void dispose() {
    try {
      if (_jsRuntime != null) {
        try {
          _jsRuntime?.dispose();
          CoreLog.i('JsEngine disposed');
        } catch (e, st) {
          CoreLog.e("JsEngine dispose error: $e", st);
        }
      }
    } catch (e, st) {
      CoreLog.e("JsEngine dispose outer error: $e", st);
    } finally {
      _jsRuntime = null;
      _initialized = false;
      CoreLog.i('JsEngine cleared');
    }
  }
}
