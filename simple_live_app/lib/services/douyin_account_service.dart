import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/constant.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/models/account/douyin_user_info.dart';
import 'package:simple_live_app/services/local_storage_service.dart';
import 'package:simple_live_core/simple_live_core.dart';

class DouyinAccountService extends GetxService {
  static DouyinAccountService get instance => Get.find<DouyinAccountService>();

  var logged = false.obs;
  var cookie = "";
  var name = "未登录".obs;

  @override
  void onInit() {
    cookie = LocalStorageService.instance
        .getValue(LocalStorageService.kDouyinCookie, "");
    logged.value = cookie.isNotEmpty;
    loadUserInfo();
    super.onInit();
  }

  Future loadUserInfo() async {
    if (cookie.isEmpty) {
      return;
    }
    try {
      final site = (Sites.allSites[Constant.kDouyin]!.liveSite as DouyinSite);
      final data = await site.getUserInfoByCookie(cookie);
      if (data.isEmpty) {
        SmartDialog.showToast("抖音登录已失效，请重新登录");
        logout();
        return;
      }
      var info = DouyinUserInfoModel.fromJson(data);
      name.value = info.nickname!;
      logged.value = true;
      _setSite();
    } catch (e) {
      SmartDialog.showToast("获取抖音登录用户信息失败，可前往账号管理重试");
    }
  }

  void _setSite() {
    var site = (Sites.allSites[Constant.kDouyin]!.liveSite as DouyinSite);
    if (cookie.isEmpty) {
      site.headers.remove("cookie");
    } else {
      site.headers["cookie"] = cookie;
    }
  }

  void setCookie(String cookie) {
    this.cookie = cookie;
    LocalStorageService.instance
        .setValue(LocalStorageService.kDouyinCookie, cookie);
  }

  void logout() async {
    cookie = "";
    LocalStorageService.instance
        .setValue(LocalStorageService.kDouyinCookie, "");
    logged.value = false;
    name.value = "未登录";
    _setSite();
    if (Platform.isAndroid || Platform.isIOS) {
      CookieManager cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
    }
  }
}
