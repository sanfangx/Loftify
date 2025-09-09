import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_notifier/local_notifier.dart';

class IToast {
  static FToast? show(
    String text, {
    Icon? icon,
    String? decription,
    int seconds = 2,
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    if (ResponsiveUtil.isLandscapeLayout()) {
      NotificationManager().show(
        chewieProvider.rootContext,
        text,
        description: decription,
        duration: Duration(seconds: seconds),
        style: NotificationStyle(icon: icon?.icon, iconColor: icon?.color),
      );
    } else {
      FToast toast = FToast().init(chewieProvider.rootContext);
      toast.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: ChewieTheme.defaultDecoration,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: ChewieTheme.bodyMedium,
          ),
        ),
        gravity: gravity,
        toastDuration: Duration(seconds: seconds),
      );
      return toast;
    }
    return null;
  }

  static FToast? showTop(
    String text, {
    Icon? icon,
    String? decription,
  }) {
    if (text.nullOrEmpty) return null;
    return show(
      text,
      icon: icon,
      decription: decription,
    );
  }

  static FToast? showBottom(
    String text, {
    Icon? icon,
  }) {
    return show(text, icon: icon, gravity: ToastGravity.BOTTOM);
  }

  static LocalNotification? showDesktopNotification(
    String title, {
    String? subTitle,
    String? body,
    List<String> actions = const [],
    Function()? onClick,
    Function(int)? onClickAction,
  }) {
    if (!ResponsiveUtil.isDesktop()) return null;
    var nActions =
        actions.map((e) => LocalNotificationAction(text: e)).toList();
    LocalNotification notification = LocalNotification(
      identifier: StringUtil.generateUid(),
      title: title,
      subtitle: subTitle,
      body: body,
      actions: nActions,
    );
    notification.onShow = () {};
    notification.onClose = (closeReason) {
      switch (closeReason) {
        case LocalNotificationCloseReason.userCanceled:
          break;
        case LocalNotificationCloseReason.timedOut:
          break;
        default:
      }
    };
    notification.onClick = onClick;
    notification.onClickAction = onClickAction;
    notification.show();
    return notification;
  }
}
