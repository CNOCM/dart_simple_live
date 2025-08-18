import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/routes/route_path.dart';
import 'package:simple_live_app/services/bilibili_account_service.dart';
import 'package:simple_live_app/services/douyin_account_service.dart';

class AccountController extends GetxController {
  Future<String?> cookieInput() async {
    final fullCookieController = TextEditingController();
    final sessdataController = TextEditingController();
    final biliJctController = TextEditingController();
    final dedeUserIdController = TextEditingController();
    final dedeUserIdckMd5Controller = TextEditingController();
    final sidController = TextEditingController();
    final buvid3Controller = TextEditingController();
    final buvid4Controller = TextEditingController();

    void parseCookie(String raw) {
      final cookie = raw.replaceAll(RegExp(r"[" '' "]"), '');
      final parts = cookie.split(';');
      for (var part in parts) {
        final kv = part.trim().split('=');
        if (kv.length < 2) continue;
        final key = kv[0];
        final value = kv.sublist(1).join('=');

        switch (key) {
          case 'SESSDATA':
            sessdataController.text = value;
            break;
          case 'bili_jct':
            biliJctController.text = value;
            break;
          case 'DedeUserID':
            dedeUserIdController.text = value;
            break;
          case 'DedeUserID__ckMd5':
            dedeUserIdckMd5Controller.text = value;
            break;
          case 'sid':
            sidController.text = value;
            break;
          case 'buvid3':
            buvid3Controller.text = value;
            break;
          case 'buvid4':
            buvid4Controller.text = value;
            break;
        }
      }
    }

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
    }

    return await Get.dialog<String>(
      AlertDialog(
        title: const Text('手动输入 Cookie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullCookieController,
                decoration: inputDecoration('粘贴完整 Cookie（自动解析）'),
                maxLines: 3,
                onChanged: (text) {
                  parseCookie(text);
                },
              ),
              AppStyle.hGap12,
              // SESSDATA
              TextField(
                controller: sessdataController,
                decoration: inputDecoration('SESSDATA'),
              ),
              AppStyle.hGap12,
              // bili_jct
              TextField(
                controller: biliJctController,
                decoration: inputDecoration('bili_jct'),
              ),
              AppStyle.hGap12,
              // DedeUserID
              TextField(
                controller: dedeUserIdController,
                decoration: inputDecoration('DedeUserID'),
              ),
              AppStyle.hGap12,
              // DedeUserID__ckMd5
              TextField(
                controller: dedeUserIdckMd5Controller,
                decoration: inputDecoration('DedeUserID__ckMd5'),
              ),
              AppStyle.hGap12,
              // sid
              TextField(
                controller: sidController,
                decoration: inputDecoration('sid'),
              ),
              AppStyle.hGap12,
              // buvid3
              TextField(
                controller: buvid3Controller,
                decoration: inputDecoration('buvid3'),
              ),
              AppStyle.hGap12,
              // buvid4
              TextField(
                controller: buvid4Controller,
                decoration: inputDecoration('buvid4'),
              ),
              AppStyle.hGap12,
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final sessdata = sessdataController.text.trim();
              final biliJct = biliJctController.text.trim();
              final dedeUserId = dedeUserIdController.text.trim();
              final dedeUserIdckMd5 = dedeUserIdckMd5Controller.text.trim();
              final sid = sidController.text.trim();
              final buvid3 = buvid3Controller.text.trim();
              final buvid4 = buvid4Controller.text.trim();

              if ([
                sessdata,
                biliJct,
                dedeUserId,
                dedeUserIdckMd5,
                sid,
                buvid3,
                buvid4
              ].any((e) => e.isEmpty)) {
                SmartDialog.showToast('请完整填写所有字段');
                return;
              }

              final cookie = [
                'SESSDATA=$sessdata',
                'bili_jct=$biliJct',
                'DedeUserID=$dedeUserId',
                'DedeUserID__ckMd5=$dedeUserIdckMd5',
                'sid=$sid',
                'buvid3=$buvid3',
                'buvid4=$buvid4',
              ].join('; ');
              Get.back(result: cookie);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void bilibiliTap() async {
    if (BiliBiliAccountService.instance.logged.value) {
      var result = await Utils.showAlertDialog("确定要退出哔哩哔哩账号吗？", title: "退出登录");
      if (result) {
        BiliBiliAccountService.instance.logout();
      }
    } else {
      //AppNavigator.toBiliBiliLogin();
      bilibiliLogin();
    }
  }

  void bilibiliLogin() {
    Utils.showBottomSheet(
      title: "登录哔哩哔哩",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: Platform.isAndroid || Platform.isIOS,
            child: ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text("Web登录"),
              subtitle: const Text("填写用户名密码登录"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                Get.toNamed(RoutePath.kBiliBiliWebLogin);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text("扫码登录"),
            subtitle: const Text("使用哔哩哔哩APP扫描二维码登录"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.back();
              Get.toNamed(RoutePath.kBiliBiliQRLogin);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text("Cookie登录"),
            subtitle: const Text("手动输入Cookie登录"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.back();
              doCookieLogin();
            },
          ),
        ],
      ),
    );
  }

  void doCookieLogin() async {
    final cookie = await cookieInput();
    if (cookie == null || cookie.isEmpty) {
      return;
    }

    BiliBiliAccountService.instance.setCookie(cookie);
    await BiliBiliAccountService.instance.loadUserInfo();
  }

  // 需要用户手动复制抖音的Cookie
  void douyinTap() async {
    if (DouyinAccountService.instance.logined.value) {
      var result =
          await Utils.showAlertDialog("确定要清除抖音Cookie吗？", title: "清除Cookie");
      if (result) {
        DouyinAccountService.instance.logout();
      }
    } else {
      final cookie = await Utils.showEditTextDialog(
        "",
        title: "请输入抖音Cookie",
        hintText: "ttwid=...; __ac_nonce=...; msToken=...",
      );
      if (cookie == null || cookie.isEmpty) return;
      DouyinAccountService.instance.setCookie(cookie);
      // 检查输入的cookie是否有效
      await DouyinAccountService.instance.loadUserInfo();
    }
  }
}
