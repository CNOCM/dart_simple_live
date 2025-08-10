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

    return InkWell(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      borderRadius: AppStyle.radius12,
      splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
      child: Container(
        margin: AppStyle.edgeInsetsV8,
        padding: AppStyle.edgeInsetsA12,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppStyle.radius12,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 头像 + 红色呼吸光圈
            Stack(
              alignment: Alignment.center,
              children: [
                if (item.liveStatus.value == 2)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withValues(alpha: .2),
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
                    child: NetImage(item.face, width: 48, height: 48),
                  ),
                ),
              ],
            ),

            AppStyle.hGap12,

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户名 + 状态
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.userName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.liveStatus.value != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.liveStatus.value == 2
                                ? Colors.red.withValues(alpha: .15)
                                : Colors.grey.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            getStatus(item.liveStatus.value),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: item.liveStatus.value == 2
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),

                  AppStyle.vGap4,

                  Row(
                    children: [
                      Image.asset(site.logo, width: 18),
                      AppStyle.hGap8,
                      Text(
                        site.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
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
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (widget.playing ||
                      (item.liveStatus.value == 2 &&
                          item.liveStartTime != null))
                    Padding(
                      padding: AppStyle.edgeInsetsT4,
                      child: Text(
                        widget.playing
                            ? "正在观看"
                            : '开播了${formatLiveDuration(item.liveStartTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

            if (widget.onRemove != null && !widget.playing)
              Material(
                color: Colors.red.withValues(alpha: .08),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Remix.dislike_line,
                        size: 20, color: Colors.redAccent),
                  ),
                ),
              ),
          ],
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
