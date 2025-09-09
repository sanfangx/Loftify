import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';
import 'package:loftify/Api/user_api.dart';
import 'package:loftify/Models/user_response.dart';
import 'package:loftify/Screens/Info/user_detail_screen.dart';

import '../../Api/setting_api.dart';
import '../../Widgets/Item/item_builder.dart';
import '../../Widgets/Item/loftify_item_builder.dart';
import '../../l10n/l10n.dart';
import 'base_setting_screen.dart';

class BlacklistSettingScreen extends BaseSettingScreen {
  const BlacklistSettingScreen({
    super.key,
    super.padding,
    super.showTitleBar,
    super.searchConfig,
    super.searchText,
  });

  static const String routeName = "/setting/blacklist";

  @override
  State<BlacklistSettingScreen> createState() => _BlacklistSettingScreenState();
}

class _BlacklistSettingScreenState
    extends BaseDynamicState<BlacklistSettingScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  final EasyRefreshController _refreshController = EasyRefreshController();
  List<BlacklistItem> blacklist = [];
  bool _noMore = false;

  _fetchBlacklist({bool refresh = false}) async {
    if (loading) return;
    if (refresh) _noMore = false;
    loading = true;
    return await SettingApi.getBlacklist(offset: refresh ? 0 : blacklist.length)
        .then((value) {
      try {
        if (value == null) return IndicatorResult.fail;
        if (value['meta']['status'] != 200) {
          IToast.showTop(value['meta']['desc'] ?? value['meta']['msg']);
          return IndicatorResult.fail;
        } else {
          var tmp = (value['response']['blogs'] as List)
              .map((e) => BlacklistItem.fromJson(e))
              .toList();
          if (refresh) blacklist.clear();
          blacklist.addAll(tmp);
          if (tmp.isEmpty && !refresh) {
            _noMore = true;
            return IndicatorResult.noMore;
          }
          return IndicatorResult.success;
        }
      } catch (e, t) {
        ILogger.error("Failed to load blacklist", e, t);
        IToast.showTop(appLocalizations.loadBlacklistFailed);
        return IndicatorResult.fail;
      } finally {
        loading = false;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChewieTheme.getBackground(context),
      appBar: widget.showTitleBar
          ? ResponsiveAppBar(
              showBack: !ResponsiveUtil.isLandscapeLayout(),
              title: appLocalizations.blacklistSetting,
            )
          : null,
      body: EasyRefresh(
        controller: _refreshController,
        refreshOnStart: true,
        onRefresh: () async {
          return await _fetchBlacklist(refresh: true);
        },
        onLoad: () async {
          return await _fetchBlacklist();
        },
        triggerAxis: Axis.vertical,
        child: LoadMoreNotification(
          noMore: _noMore,
          onLoad: _fetchBlacklist,
          child: ListView.builder(
            itemCount: blacklist.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) =>
                _buildBlacklistRow(blacklist[index]),
          ),
        ),
      ),
    );
  }

  _buildBlacklistRow(BlacklistItem blacklistItem) {
    return GestureDetector(
      onTap: () {
        RouteUtil.pushPanelCupertinoRoute(
          context,
          UserDetailScreen(
              blogId: blacklistItem.blogInfo.blogId,
              blogName: blacklistItem.blogInfo.blogName),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            ItemBuilder.buildAvatar(
              context: context,
              imageUrl: blacklistItem.blogInfo.bigAvaImg,
              showLoading: false,
              showBorder: true,
              size: 40,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(blacklistItem.blogInfo.blogNickName),
            ),
            LoftifyItemBuilder.buildFramedDoubleButton(
              context: context,
              isFollowed: false,
              positiveText: appLocalizations.unlockBlacklist,
              negtiveText: appLocalizations.unlockBlacklist,
              onTap: () {
                DialogBuilder.showConfirmDialog(
                  context,
                  title: appLocalizations.unlockBlacklist,
                  message: appLocalizations.unlockBlacklistMessage(
                      blacklistItem.blogInfo.blogNickName),
                  confirmButtonText: appLocalizations.unlock,
                  onTapConfirm: () {
                    UserApi.blockOrUnBlock(
                      blogId: blacklistItem.blogInfo.blogId,
                      isBlock: false,
                    ).then((value) {
                      if (value['meta']['status'] != 200) {
                        IToast.showTop(
                            value['meta']['desc'] ?? value['meta']['msg']);
                      } else {
                        blacklist.remove(blacklistItem);
                        setState(() {});
                      }
                    });
                  },
                  onTapCancel: () {},
                  customDialogType: CustomDialogType.normal,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
