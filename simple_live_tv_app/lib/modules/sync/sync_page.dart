import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simple_live_tv_app/app/app_focus_node.dart';
import 'package:simple_live_tv_app/app/app_style.dart';
import 'package:simple_live_tv_app/modules/sync/sync_controller.dart';
import 'package:simple_live_tv_app/services/sync_service.dart';
import 'package:simple_live_tv_app/widgets/app_scaffold.dart';
import 'package:simple_live_tv_app/widgets/button/highlight_button.dart';

class SyncPage extends GetView<SyncController> {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [
          AppStyle.vGap24,
          Row(
            children: [
              AppStyle.hGap48,
              HighlightButton(
                focusNode: AppFocusNode(),
                iconData: Icons.arrow_back,
                text: "返回",
                autofocus: true,
                onTap: () {
                  Get.back();
                },
              ),
              AppStyle.hGap32,
              Text(
                "局域网同步",
                style: AppStyle.titleStyleWhite.copyWith(
                  fontSize: 36.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppStyle.vGap24,
          Expanded(
            child: Center(
              child: Obx(
                () => Container(
                  padding: AppStyle.edgeInsetsA24,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(24.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .2),
                        blurRadius: 12.w,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "局域网同步",
                        style: AppStyle.titleStyleWhite.copyWith(
                          fontSize: 32.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppStyle.vGap16,
                      if (SyncService.instance.httpRunning.value)
                        QrImageView(
                          data: SyncService.instance.ipAddress.value,
                          version: QrVersions.auto,
                          backgroundColor: Colors.white,
                          padding: AppStyle.edgeInsetsA24,
                          size: 420.w,
                        ),
                      AppStyle.vGap24,
                      Text(
                        SyncService.instance.httpRunning.value
                            ? '服务已启动：${SyncService.instance.ipAddress.value.split(";").map((e) => "$e:${SyncService.httpPort}").join("；")}'
                            : 'HTTP服务未启动：${SyncService.instance.httpErrorMsg}，请尝试重启应用',
                        style: AppStyle.textStyleWhite.copyWith(
                          fontSize: 28.w,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppStyle.vGap12,
                      if (SyncService.instance.httpRunning.value)
                        Text(
                          "请扫描二维码或输入IP地址进行连接\n建立连接后可在APP端选择需要同步至TV端的数据",
                          style: AppStyle.textStyleWhite.copyWith(
                            fontSize: 24.w,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
