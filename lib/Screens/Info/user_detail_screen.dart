import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:blur/blur.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart' hide AnimatedSlide;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loftify/Models/show_case_response.dart';
import 'package:loftify/Screens/Info/collection_screen.dart';
import 'package:loftify/Screens/Info/following_follower_screen.dart';
import 'package:loftify/Screens/Info/grain_screen.dart';
import 'package:loftify/Screens/Info/like_screen.dart';
import 'package:loftify/Screens/Info/post_screen.dart';
import 'package:loftify/Screens/Info/share_screen.dart';
import 'package:loftify/Screens/Info/supporter_screen.dart';
import 'package:loftify/Screens/Post/post_detail_screen.dart';
import 'package:loftify/Screens/Suit/user_market_screen.dart';
import 'package:loftify/Utils/enums.dart';
import 'package:loftify/Utils/hive_util.dart';
import 'package:loftify/Widgets/Item/item_builder.dart';

import '../../Api/user_api.dart';
import '../../Models/user_response.dart';
import '../../Utils/asset_util.dart';
import '../../Utils/utils.dart';
import '../../l10n/l10n.dart';
import '../Post/collection_detail_screen.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({
    super.key,
    required this.blogId,
    required this.blogName,
  });

  final int blogId;
  final String blogName;

  static const String routeName = "/user/detail";

  @override
  UserDetailScreenState createState() => UserDetailScreenState();
}

class UserDetailScreenState extends BaseDynamicState<UserDetailScreen>
    with TickerProviderStateMixin {
  TotalBlogData? _fullBlogData;
  bool? isMe = false;
  late TabController _tabController;
  List<Tab> tabList = [];
  List<ShowCaseItem> showCases = [];
  String _followButtonText = appLocalizations.follow;
  Color? _followButtonColor;
  SubordinateScrollController? controller;
  double _expandedHeight = 270;

  InfoMode get infoMode => isMe == true ? InfoMode.me : InfoMode.other;

  _fetchData() {
    UserApi.getUserDetail(blogId: widget.blogId, blogName: widget.blogName)
        .then((value) async {
      try {
        if (value['meta']['status'] != 200) {
          IToast.showTop(value['meta']['desc'] ?? value['meta']['msg']);
        } else {
          _fullBlogData = TotalBlogData.fromJson(value['response']);
          isMe = _fullBlogData!.blogInfo.blogId == await HiveUtil.getUserId();
          initTab();
          updateFollowStatus();
          _fetchShowCases();
          setState(() {});
        }
      } catch (e, t) {
        ILogger.error("Failed to get user detail", e, t);
        if (mounted) IToast.showTop(appLocalizations.loadFailed);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  initTab() {
    tabList.clear();
    tabList.add(Tab(text: appLocalizations.article));
    if (_fullBlogData!.showLike == 1) {
      tabList.add(Tab(text: appLocalizations.like));
    }
    if (_fullBlogData!.showShare == 1) {
      tabList.add(Tab(text: appLocalizations.recommend));
    }
    tabList.add(Tab(text: appLocalizations.collection));
    if (_fullBlogData!.showFoods == 1) {
      tabList.add(Tab(text: appLocalizations.grain));
    }
    _tabController = TabController(length: tabList.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ResponsiveUtil.isLandscapeLayout()
          ? ResponsiveAppBar(
              showBack: true, title: appLocalizations.personalHomepage)
          : null,
      body: _fullBlogData != null
          ? ExtendedNestedScrollView(
              headerSliverBuilder: (_, __) => _buildHeaderSlivers(),
              body: _mainContent())
          : LoadingWidget(
              background: ChewieTheme.getBackground(context),
            ),
    );
  }

  _buildHeaderSlivers() {
    if (!ResponsiveUtil.isLandscapeLayout()) {
      return <Widget>[
        SliverAppBarWrapper(
          context: context,
          expandedHeight: _expandedHeight,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          collapsedHeight: 56,
          backgroundWidget: _buildBackground(height: _expandedHeight + 60),
          actions: _appBarActions(),
          centerTitle: !ResponsiveUtil.isLandscapeLayout(),
          title: Text(
            appLocalizations.personalHomepage,
            style: Theme.of(context).textTheme.titleMedium?.apply(
                  color: Colors.white,
                  fontWeightDelta: 2,
                ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                _buildBackground(height: _expandedHeight + 60),
                _buildInfo(),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              decoration: BoxDecoration(
                color: ChewieTheme.getBackground(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: TabBarWrapper(
                tabController: _tabController,
                tabs: tabList,
                width: MediaQuery.sizeOf(context).width,
                forceUnscrollable: !ResponsiveUtil.isLandscapeLayout(),
              ),
            ),
          ),
        ),
      ];
    } else {
      return [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              _buildBackground(height: _expandedHeight - 84),
              _buildInfo(10),
            ],
          ),
        ),
        SliverPersistentHeader(
          key: ValueKey(StringUtil.getRandomString()),
          pinned: true,
          delegate: SliverAppBarDelegate(
            radius: 0,
            background: ChewieTheme.getBackground(context),
            tabBar: TabBarWrapper(
              tabController: _tabController,
              tabs: tabList,
              width: MediaQuery.sizeOf(context).width,
              showBorder: true,
              forceUnscrollable: !ResponsiveUtil.isLandscapeLayout(),
            ),
          ),
        ),
      ];
    }
  }

  Widget _mainContent() {
    return _buildTabView();
  }

  _buildMoreButtons() {
    return FlutterContextMenu(
      entries: [
        FlutterContextMenuItem(
          appLocalizations.viewThemeBg,
          iconData: Icons.color_lens_outlined,
          onPressed: () {
            RouteUtil.pushDialogRoute(
              context,
              showClose: false,
              fullScreen: true,
              useFade: true,
              HeroPhotoViewScreen(
                tagPrefix: StringUtil.getRandomString(),
                imageUrls: [Utils.removeImageParam(backgroudUrl)],
                useMainColor: false,
                title: appLocalizations.themeBg,
                captions: ["「${_fullBlogData!.blogInfo.blogNickName}」"],
              ),
            );
          },
        ),
        FlutterContextMenuItem(
          appLocalizations.viewShop,
          iconData: Icons.shopping_bag_outlined,
          onPressed: () {
            RouteUtil.pushPanelCupertinoRoute(context,
                UserMarketScreen(blogId: _fullBlogData!.blogInfo.blogId));
          },
        ),
        if (infoMode == InfoMode.other) ...[
          if (StringUtil.isNotEmpty(_fullBlogData!.blogInfo.avatarBoxImage))
            FlutterContextMenuItem(
              ChewieHiveUtil.getString(HiveUtil.customAvatarBoxKey) ==
                      _fullBlogData!.blogInfo.avatarBoxImage
                  ? appLocalizations.undressAvatarBox
                  : appLocalizations.dressAvatarBox,
              iconData: Icons.account_box,
              onPressed: () async {
                String? currentAvatarImg =
                    ChewieHiveUtil.getString(HiveUtil.customAvatarBoxKey);
                if (currentAvatarImg ==
                    _fullBlogData!.blogInfo.avatarBoxImage) {
                  await ChewieHiveUtil.put(HiveUtil.customAvatarBoxKey, "");
                  currentAvatarImg = "";
                  setState(() {});
                  IToast.showTop(appLocalizations.unDressSuccess);
                } else {
                  await ChewieHiveUtil.put(HiveUtil.customAvatarBoxKey,
                      _fullBlogData!.blogInfo.avatarBoxImage);
                  currentAvatarImg = _fullBlogData!.blogInfo.avatarBoxImage;
                  setState(() {});
                  IToast.showTop(appLocalizations.dressSuccess);
                }
              },
            ),
          FlutterContextMenuItem(
            appLocalizations.setRemark,
            iconData: Icons.credit_card,
            onPressed: () {
              BottomSheetBuilder.showBottomSheet(
                context,
                (sheetContext) => InputBottomSheet(
                  title: appLocalizations
                      .setRemarkMessage(_fullBlogData!.blogInfo.blogNickName),
                  text: _fullBlogData!.blogInfo.remarkName.trim(),
                  onConfirm: (text) {
                    UserApi.setRemark(
                      blogId: _fullBlogData!.blogInfo.blogId,
                      remark: text,
                    ).then((value) {
                      if (value['meta']['status'] != 200) {
                        IToast.showTop(
                            value['meta']['desc'] ?? value['meta']['msg']);
                      } else {
                        _fullBlogData!.blogInfo.remarkName = text;
                        setState(() {});
                        IToast.showTop(appLocalizations.setRemarkSuccess);
                      }
                    });
                  },
                ),
                preferMinWidth: 400,
                responsive: true,
              );
            },
          ),
          FlutterContextMenuItem.divider(),
          FlutterContextMenuItem(
            status: MenuItemStatus.warning,
            _fullBlogData!.isBlackBlog
                ? appLocalizations.unlockBlacklist
                : appLocalizations.blockBlacklist,
            iconData: Icons.block_rounded,
            onPressed: () {
              _doBlockUser(
                isBlock: !_fullBlogData!.isBlackBlog,
                onSuccess: () {
                  if (_fullBlogData!.isBlackBlog) {
                    IToast.showTop(appLocalizations.blockBlacklistSuccess);
                  } else {
                    IToast.showTop(appLocalizations.unblockBlacklistSuccess);
                  }
                  setState(() {});
                  updateFollowStatus();
                },
              );
            },
          ),
          if (_fullBlogData!.following) ...[
            FlutterContextMenuItem(
              status: MenuItemStatus.warning,
              _fullBlogData!.isShieldRecom == 1
                  ? appLocalizations.recoverViewRecommend
                  : appLocalizations.shieldViewRecommend,
              iconData: Icons.block_rounded,
              onPressed: () {
                UserApi.shieldRecommendOrUnShield(
                  blogId: _fullBlogData!.blogInfo.blogId,
                  isShield: !(_fullBlogData!.isShieldRecom == 1),
                ).then((value) {
                  if (value['meta']['status'] != 200) {
                    IToast.showTop(
                        value['meta']['desc'] ?? value['meta']['msg']);
                  } else {
                    _fullBlogData!.isShieldRecom =
                        _fullBlogData!.isShieldRecom == 1 ? 0 : 1;
                    setState(() {});
                  }
                });
              },
            ),
            FlutterContextMenuItem(
              status: MenuItemStatus.warning,
              _fullBlogData!.shieldUserTimeline
                  ? appLocalizations.recoverViewDynamic
                  : appLocalizations.shieldViewDynamic,
              iconData: Icons.block_rounded,
              onPressed: () {
                UserApi.shieldBlogOrUnShield(
                  blogId: _fullBlogData!.blogInfo.blogId,
                  isShield: !_fullBlogData!.shieldUserTimeline,
                ).then((value) {
                  if (value['code'] != 0) {
                    IToast.showTop(value['msg']);
                  } else {
                    _fullBlogData!.shieldUserTimeline =
                        !_fullBlogData!.shieldUserTimeline;
                    setState(() {});
                  }
                });
              },
            ),
          ],
        ],
        FlutterContextMenuItem.divider(),
        FlutterContextMenuItem(
          appLocalizations.copyHomepageLink,
          iconData: Icons.copy_rounded,
          onPressed: () {
            ChewieUtils.copy(context, _fullBlogData!.blogInfo.homePageUrl);
          },
        ),
        FlutterContextMenuItem(appLocalizations.openWithBrowser,
            iconData: Icons.open_in_browser_rounded, onPressed: () {
          UriUtil.openExternal(_fullBlogData!.blogInfo.homePageUrl);
        }),
        FlutterContextMenuItem(appLocalizations.shareToOtherApps,
            iconData: Icons.share_rounded, onPressed: () {
          UriUtil.share(_fullBlogData!.blogInfo.homePageUrl);
        }),
      ],
    );
  }

  _appBarActions() {
    return [
      CircleIconButton(
        onTap: () {
          BottomSheetBuilder.showContextMenu(context, _buildMoreButtons());
        },
        icon: const Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
        ),
      ),
    ];
  }

  _fetchShowCases() {
    UserApi.getShowCases(
            blogId: _fullBlogData!.blogInfo.blogId,
            blogName: _fullBlogData!.blogInfo.blogName)
        .then((value) {
      if (value['code'] != 200) {
        IToast.showTop(value['msg']);
      } else if (value['data']['showCaseList'] != null) {
        showCases = (value['data']['showCaseList'] as List)
            .map((e) => ShowCaseItem.fromJson(e))
            .toList();
        showCases = showCases
            .where(
                (e) => !(e.postCollection == null && e.postSimpleData == null))
            .toList();
        updateFollowStatus();
        if (showCases.isNotEmpty) {
          _expandedHeight = 430;
        }
        setState(() {});
      }
    });
  }

  getAvatarBoxImage() {
    if (infoMode == InfoMode.me) {
      String url = ChewieHiveUtil.getString(HiveUtil.customAvatarBoxKey) ?? "";
      return url.isNotEmpty ? url : _fullBlogData!.blogInfo.avatarBoxImage;
    } else {
      return _fullBlogData!.blogInfo.avatarBoxImage;
    }
  }

  Widget _buildInfo([double? topMargin]) {
    bool hasRemarkName =
        StringUtil.isNotEmpty(_fullBlogData!.blogInfo.remarkName);
    return Container(
      margin: EdgeInsets.only(
          top:
              topMargin ?? kToolbarHeight + MediaQuery.of(context).padding.top),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 12),
              ItemBuilder.buildAvatar(
                context: context,
                size: StringUtil.isNotEmpty(getAvatarBoxImage()) ? 54 : 80,
                showBorder: false,
                showDetailMode: ShowDetailMode.avatar,
                imageUrl:
                    Utils.removeImageParam(_fullBlogData!.blogInfo.bigAvaImg),
                avatarBoxImageUrl: getAvatarBoxImage(),
                title: appLocalizations.personalAvatar,
                caption: "「${_fullBlogData!.blogInfo.blogNickName}」",
                tagPrefix: StringUtil.getRandomString(),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ItemBuilder.buildCopyable(
                    context,
                    child: Text(
                      _fullBlogData!.blogInfo.blogNickName,
                      style: Theme.of(context).textTheme.titleLarge?.apply(
                            fontSizeDelta: 2,
                            color: Colors.white,
                          ),
                    ),
                    text: _fullBlogData!.blogInfo.blogNickName,
                    toastText: appLocalizations.haveCopiedNickName,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: ItemBuilder.buildCopyable(
                            context,
                            child: Text(
                              textAlign: TextAlign.center,
                              'ID: ${_fullBlogData!.blogInfo.blogName}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.apply(color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            text: _fullBlogData!.blogInfo.blogName,
                            toastText: appLocalizations.haveCopiedLofterID,
                          ),
                        ),
                        if (hasRemarkName)
                          WidgetSpan(
                            child: ItemBuilder.buildCopyable(
                              context,
                              child: Text(
                                textAlign: TextAlign.center,
                                appLocalizations.remarkSuffix(
                                    _fullBlogData!.blogInfo.remarkName),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.apply(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              text: _fullBlogData!.blogInfo.remarkName,
                              toastText: appLocalizations.haveCopiedRemark,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          textAlign: TextAlign.center,
                          '${appLocalizations.gender}: ${_fullBlogData!.blogInfo.gendar == 1 ? appLocalizations.male : _fullBlogData!.blogInfo.gendar == 2 ? appLocalizations.female : appLocalizations.confidential}${StringUtil.isNotEmpty(_fullBlogData!.blogInfo.ipLocation) ? "${appLocalizations.ipSuffix}${_fullBlogData!.blogInfo.ipLocation}" : ""}',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.apply(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      if (StringUtil.isNotEmpty(StringUtil.clearBlank(
                          _fullBlogData!.blogInfo.selfIntro)))
                        ClickableGestureDetector(
                          onTap: () {
                            DialogBuilder.showInfoDialog(
                              context,
                              title: appLocalizations.descriptionTitle(
                                  _fullBlogData!.blogInfo.blogNickName),
                              message: _fullBlogData!.blogInfo.selfIntro,
                              onTapDismiss: () {},
                              customDialogType: CustomDialogType.normal,
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: appLocalizations.moreInfo,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.apply(color: Colors.white),
                                ),
                                const WidgetSpan(
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (ResponsiveUtil.isLandscapeLayout()) ...[
                CircleIconButton(
                  onTap: () {
                    BottomSheetBuilder.showContextMenu(
                        context, _buildMoreButtons());
                  },
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ItemBuilder.buildStatisticItem(
                context,
                title: appLocalizations.following,
                count: _fullBlogData!.blogInfo.blogStat.followingCount,
                countColor: Colors.white,
                labelColor: Colors.white.withOpacity(0.9),
                onTap: () {
                  if (_fullBlogData!.showFollow == 1 ||
                      infoMode == InfoMode.me) {
                    RouteUtil.pushPanelCupertinoRoute(
                      context,
                      FollowingFollowerScreen(
                        infoMode: infoMode,
                        followingMode: infoMode == InfoMode.me
                            ? FollowingMode.following
                            : FollowingMode.timeline,
                        blogId: _fullBlogData!.blogInfo.blogId,
                        blogName: _fullBlogData!.blogInfo.blogName,
                        total: _fullBlogData!.blogInfo.blogStat.followingCount,
                      ),
                    );
                  } else {
                    IToast.showTop(appLocalizations.cannotViewFollowingList);
                  }
                },
              ),
              ItemBuilder.buildStatisticItem(
                context,
                title: appLocalizations.follower,
                count: _fullBlogData!.blogInfo.blogStat.followedCount,
                countColor: Colors.white,
                labelColor: Colors.white.withOpacity(0.9),
                onTap: () {
                  if (_fullBlogData!.showFans == 1 || infoMode == InfoMode.me) {
                    RouteUtil.pushPanelCupertinoRoute(
                      context,
                      FollowingFollowerScreen(
                        infoMode: infoMode,
                        followingMode: FollowingMode.follower,
                        blogId: _fullBlogData!.blogInfo.blogId,
                        blogName: _fullBlogData!.blogInfo.blogName,
                        total: _fullBlogData!.blogInfo.blogStat.followedCount,
                      ),
                    );
                  } else {
                    IToast.showTop(appLocalizations.cannotViewFollowerList);
                  }
                },
              ),
              ItemBuilder.buildStatisticItem(
                context,
                title: appLocalizations.hotCount,
                count: _fullBlogData!.blogInfo.hot.hotCount,
                countColor: Colors.white,
                labelColor: Colors.white.withOpacity(0.9),
                onTap: () {
                  DialogBuilder.showInfoDialog(
                    context,
                    title:
                        "${appLocalizations.totalHotCount}${_fullBlogData!.blogInfo.hot.hotCount}",
                    messageChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHotItem(
                          icon: Icons.favorite_rounded,
                          title: appLocalizations.postLikes,
                          count: _fullBlogData!.blogInfo.hot.favoriteCount,
                        ),
                        _buildHotItem(
                          icon: Icons.thumb_up_rounded,
                          title: appLocalizations.postRecommends,
                          count: _fullBlogData!.blogInfo.hot.shareCount,
                        ),
                        _buildHotItem(
                          icon: Icons.bookmark_rounded,
                          title: appLocalizations.postFavorites,
                          count: _fullBlogData!.blogInfo.hot.subscribeCount,
                        ),
                        _buildHotItem(
                          icon: Icons.mode_comment_rounded,
                          title: appLocalizations.commentLikes,
                          count:
                              _fullBlogData!.blogInfo.hot.tagChatFavoriteCount,
                        ),
                      ],
                    ),
                    buttonText: appLocalizations.comeOn,
                    onTapDismiss: () {},
                    customDialogType: CustomDialogType.custom,
                  );
                },
              ),
              ItemBuilder.buildStatisticItem(
                context,
                title: appLocalizations.supporter,
                count: _fullBlogData!.blogInfo.blogStat.supporterCount,
                countColor: Colors.white,
                labelColor: Colors.white.withOpacity(0.9),
                onTap: () {
                  if (_fullBlogData!.showSupport == 1 ||
                      infoMode == InfoMode.me) {
                    RouteUtil.pushPanelCupertinoRoute(
                      context,
                      SupporterScreen(
                        infoMode: infoMode,
                        blogId: _fullBlogData!.blogInfo.blogId,
                      ),
                    );
                  } else {
                    IToast.showTop(appLocalizations.cannotViewSupporterList);
                  }
                },
              ),
              if (infoMode == InfoMode.other)
                RoundIconTextButton(
                  onPressed: _processFollow,
                  text: _followButtonText,
                  background: _followButtonColor,
                  fontSizeDelta: 2,
                ),
              if (infoMode == InfoMode.me)
                RoundIconTextButton(
                  onPressed: () {},
                  text: appLocalizations.editProfile,
                  background: Colors.white.withOpacity(0.2),
                  fontSizeDelta: 2,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (showCases.isNotEmpty) _buildShowCases(),
        ],
      ),
    );
  }

  updateFollowStatus() {
    if (_fullBlogData!.following) {
      _followButtonText = _fullBlogData!.specialfollowing
          ? appLocalizations.specialFollowed
          : appLocalizations.followed;
      _followButtonColor = Colors.white.withOpacity(0.4);
    } else {
      _followButtonText = " ${appLocalizations.follow} ";
      _followButtonColor = Colors.white.withOpacity(0.2);
    }
    if (_fullBlogData!.isBlackBlog) {
      _followButtonText = appLocalizations.blacklisted;
      _followButtonColor = Colors.red.withOpacity(0.4);
    }
    setState(() {});
  }

  _buildHotItem({
    Color? color,
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.all(3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: color ?? ChewieColors.getHotTagTextColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  _doFollow({required bool isFollow}) {
    UserApi.followOrUnfollow(
      isFollow: isFollow,
      blogId: _fullBlogData!.blogInfo.blogId,
      blogName: _fullBlogData!.blogInfo.blogName,
    ).then((value) {
      if (value['meta']['status'] != 200) {
        IToast.showTop(value['meta']['desc'] ?? value['meta']['msg']);
      } else {
        _fullBlogData!.following = !_fullBlogData!.following;
        setState(() {});
        updateFollowStatus();
      }
    });
  }

  void _doBlockUser({
    required bool isBlock,
    Function()? onSuccess,
  }) {
    UserApi.blockOrUnBlock(
      isBlock: isBlock,
      blogId: _fullBlogData!.blogInfo.blogId,
    ).then((value) {
      if (value['meta']['status'] != 200) {
        IToast.showTop(value['meta']['desc'] ?? value['meta']['msg']);
      } else {
        _fullBlogData!.isBlackBlog = !_fullBlogData!.isBlackBlog;
        if (_fullBlogData!.isBlackBlog) {
          _fullBlogData!.following = false;
          _fullBlogData!.specialfollowing = false;
        }
        onSuccess?.call();
      }
    });
  }

  _doSpecialFollow({required bool isSpecialFollow}) {
    UserApi.specialFollowOrSpecialUnfollow(
      isSpecialFollow: isSpecialFollow,
      blogId: _fullBlogData!.blogInfo.blogId,
      blogName: _fullBlogData!.blogInfo.blogName,
    ).then((value) {
      if (value['meta']['status'] != 200) {
        IToast.showTop(value['meta']['desc'] ?? value['meta']['msg']);
      } else {
        _fullBlogData!.specialfollowing = !_fullBlogData!.specialfollowing;
        setState(() {});
        updateFollowStatus();
      }
    });
  }

  _processFollow() {
    if (_fullBlogData!.isBlackBlog) {
      DialogBuilder.showConfirmDialog(
        context,
        title: appLocalizations.unlockBlacklist,
        message: appLocalizations
            .unlockBlacklistMessage(_fullBlogData!.blogInfo.blogNickName),
        confirmButtonText: appLocalizations.confirm,
        cancelButtonText: appLocalizations.cancel,
        onTapConfirm: () async {
          _doBlockUser(
              isBlock: !_fullBlogData!.isBlackBlog,
              onSuccess: () {
                setState(() {});
                updateFollowStatus();
              });
        },
        onTapCancel: () {},
        customDialogType: CustomDialogType.custom,
      );
    } else {
      if (!_fullBlogData!.following) {
        HapticFeedback.mediumImpact();
        _doFollow(isFollow: !_fullBlogData!.following);
      } else {
        BottomSheetBuilder.showContextMenu(context, _buildFollowButtons());
      }
    }
  }

  _buildFollowButtons() {
    return FlutterContextMenu(entries: [
      FlutterContextMenuItem(
          _fullBlogData!.specialfollowing
              ? appLocalizations.unSpecialFollow
              : appLocalizations.specialFollow, onPressed: () {
        _doSpecialFollow(isSpecialFollow: !_fullBlogData!.specialfollowing);
      }),
      FlutterContextMenuItem(
        appLocalizations.unfollow,
        onPressed: () {
          _doFollow(isFollow: !_fullBlogData!.following);
        },
      ),
    ]);
  }

  _buildTabView() {
    List<Widget> children = [];
    children.add(
      PostScreen(
        infoMode: InfoMode.other,
        blogId: _fullBlogData!.blogInfo.blogId,
        blogName: _fullBlogData!.blogInfo.blogName,
        nested: true,
      ),
    );
    if (_fullBlogData!.showLike == 1) {
      children.add(
        LikeScreen(
          infoMode: InfoMode.other,
          blogId: _fullBlogData!.blogInfo.blogId,
          blogName: _fullBlogData!.blogInfo.blogName,
          nested: true,
        ),
      );
    }
    if (_fullBlogData!.showShare == 1) {
      children.add(
        ShareScreen(
          infoMode: InfoMode.other,
          blogId: _fullBlogData!.blogInfo.blogId,
          blogName: _fullBlogData!.blogInfo.blogName,
          nested: true,
        ),
      );
    }
    children.add(
      CollectionScreen(
        infoMode: InfoMode.other,
        blogId: _fullBlogData!.blogInfo.blogId,
        blogName: _fullBlogData!.blogInfo.blogName,
        collectionCount: _fullBlogData!.collectionCount,
        nested: true,
      ),
    );
    if (_fullBlogData!.showFoods == 1) {
      children.add(
        GrainScreen(
          infoMode: InfoMode.other,
          blogId: _fullBlogData!.blogInfo.blogId,
          blogName: _fullBlogData!.blogInfo.blogName,
          nested: true,
        ),
      );
    }
    return Container(
      color: ChewieTheme.getBackground(context),
      child: TabBarView(
        controller: _tabController,
        children: children,
      ),
    );
  }

  _buildShowCases() {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  appLocalizations.masterpiece,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.apply(fontSizeDelta: -1, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: showCases.length,
              itemBuilder: (context, index) {
                return _buildShowCaseItem(showCases[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildShowCaseItem(ShowCaseItem item) {
    late String title;
    late String backgroundUrl;
    late String hotCount;
    late Function() onTap;
    if (item.postSimpleData != null) {
      title = item.postSimpleData!.postView.title;
      backgroundUrl = item.postSimpleData!.postView.firstImage.orign;
      hotCount = item.postSimpleData!.postCountView.hotCount.toString();
      if (title.isEmpty) {
        title =
            HtmlUtil.extractTextFromHtml(item.postSimpleData!.postView.digest);
      }
      onTap = () {
        item.postSimpleData!.postView.blogName =
            _fullBlogData!.blogInfo.blogName;
        RouteUtil.pushPanelCupertinoRoute(
          context,
          PostDetailScreen(
            showCaseItem: item,
            isArticle: StringUtil.isEmpty(backgroundUrl),
          ),
        );
      };
    } else if (item.postCollection != null) {
      title = item.postCollection!.name;
      backgroundUrl = item.postCollection!.coverUrl;
      hotCount = item.postCollection!.postCollectionHot.toString();
      onTap = () {
        RouteUtil.pushPanelCupertinoRoute(
          context,
          CollectionDetailScreen(
            blogId: widget.blogId,
            blogName: widget.blogName,
            collectionId: item.postCollection!.id,
            postId: item.postCollection!.id,
          ),
        );
      };
    } else {
      ILogger.info("Loftify", item.toJson());
    }
    return ClickableGestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: StringUtil.isNotEmpty(backgroundUrl)
                  ? ChewieItemBuilder.buildCachedImage(
                      context: context,
                      imageUrl: backgroundUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      showLoading: false,
                      placeholderBackground: Colors.transparent,
                    )
                  : AssetUtil.loadDouble(
                      context,
                      AssetUtil.lofterDarkIllust,
                      AssetUtil.lofterDarkIllust,
                      size: 100,
                      fit: BoxFit.cover,
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Spacer(),
                  Center(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.apply(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          hotCount,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.apply(fontSizeDelta: -1, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -4,
              right: -6,
              child: ChewieItemBuilder.buildCachedImage(
                context: context,
                imageUrl: item.icon,
                width: 40,
                height: 40,
                showLoading: false,
                placeholderBackground: Colors.transparent,
              ),
            ),
            if (item.postCollection != null)
              Positioned(
                top: 6,
                left: 6,
                child: AssetUtil.load(
                  AssetUtil.collectionWhiteIcon,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get backgroudUrl =>
      _fullBlogData!.blogcover.customBlogCover ?? _fullBlogData!.blogcover.url;

  Widget _buildBackground({
    double blurRadius = 10,
    double? height,
  }) {
    return Blur(
      blur: blurRadius,
      blurColor: Colors.black12,
      child: ChewieItemBuilder.buildCachedImage(
        context: context,
        imageUrl: Utils.removeImageParam(backgroudUrl),
        fit: BoxFit.cover,
        width: MediaQuery.sizeOf(context).width * 2,
        height: height ?? 600,
        placeholderBackground: Theme.of(context).textTheme.labelSmall?.color,
        bottomPadding: 50,
        showLoading: false,
      ),
    );
  }
}
