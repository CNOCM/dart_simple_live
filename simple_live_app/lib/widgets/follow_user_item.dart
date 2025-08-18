import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/models/db/follow_user.dart';
import 'package:simple_live_app/widgets/net_image.dart';

class FollowUserItem extends StatefulWidget {
  final FollowUser item;
  final Function()? onRemove;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool playing;

  const FollowUserItem({
    required this.item,
    this.onRemove,
    this.onTap,
    this.onLongPress,
    this.playing = false,
    super.key,
  });

  @override
  State<FollowUserItem> createState() => _FollowUserItemState();
}

class _FollowUserItemState extends State<FollowUserItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final site = Sites.allSites[item.siteId]!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: AppStyle.radius12,
        splashColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: .08),
        child: Container(
          margin: AppStyle.edgeInsetsV8,
          padding: AppStyle.edgeInsetsA16,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppStyle.radius12,
            border: Border.all(
              color: Colors.grey.withValues(alpha: .08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 头像 + 呼吸光圈
              Stack(
                alignment: Alignment.center,
                children: [
                  if (item.liveStatus.value == 2)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.red.withValues(alpha: .25),
                              Colors.red.withValues(alpha: .05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.liveStatus.value == 2
                            ? Colors.red
                            : Colors.grey.withValues(alpha: .3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: AppStyle.radius24,
                      child: NetImage(item.face, width: 50, height: 50),
                    ),
                  ),
                ],
              ),

              AppStyle.hGap16,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户名 + 分区 + 状态
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.userName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: .2,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              AppStyle.hGap8,
                            ],
                          ),
                        ),
                        if (item.liveAreaName.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.liveAreaName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppStyle.hGap8, // 🔥 在这里插入间隔
                        ],
                        if (item.liveStatus.value != 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.liveStatus.value == 2
                                  ? Colors.red.withValues(alpha: .12)
                                  : Colors.grey.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              getStatus(item.liveStatus.value),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: item.liveStatus.value == 2
                                    ? Colors.red
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                      ],
                    ),

                    AppStyle.vGap4,

                    // 平台 + 直播标题
                    Row(
                      children: [
                        Image.asset(site.logo, width: 18),
                        AppStyle.hGap8,
                        Text(
                          site.name,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        if (item.liveStatus.value == 2 &&
                            item.liveTitle.isNotEmpty) ...[
                          AppStyle.hGap12,
                          Expanded(
                            child: Text(
                              item.liveTitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // 正在观看 / 开播时间
                    if (widget.playing ||
                        (item.liveStatus.value == 2 &&
                            item.liveStartTime != null))
                      Padding(
                        padding: AppStyle.edgeInsetsT4,
                        child: Text(
                          widget.playing
                              ? "正在观看"
                              : '已开播 ${formatLiveDuration(item.liveStartTime)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight:
                                        widget.playing ? FontWeight.w600 : null,
                                    color: widget.playing
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),

              // 移除按钮
              if (widget.onRemove != null && !widget.playing) ...[
                AppStyle.hGap8,
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Remix.dislike_line,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String getStatus(int status) {
    if (status == 0) return "读取中";
    if (status == 1) return "未开播";
    return "直播中";
  }

  String formatLiveDuration(String? startTimeStampString) {
    if (startTimeStampString == null ||
        startTimeStampString.isEmpty ||
        startTimeStampString == "0") {
      return "";
    }
    try {
      int startTimeStamp = int.parse(startTimeStampString);
      int currentTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int durationInSeconds = currentTimeStamp - startTimeStamp;
      int hours = durationInSeconds ~/ 3600;
      int minutes = (durationInSeconds % 3600) ~/ 60;

      if (hours == 0 && minutes == 0) return "不足1分钟";
      return '${hours > 0 ? "$hours小时" : ""}${minutes > 0 ? "$minutes分钟" : ""}';
    } catch (_) {
      return "--小时--分钟";
    }
  }
}
