import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 拓展FocusNode
class AppFocusNode extends FocusNode {
  var isFocused = false.obs;
  AppFocusNode() {
    isFocused.value = hasFocus;
    addListener(updateFocus);
  }

  updateFocus() {
    isFocused.value = hasFocus;
  }

  @override
  void dispose() {
    removeListener(updateFocus);
    super.dispose();
  }
}
