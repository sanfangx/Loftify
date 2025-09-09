
import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loftify/Api/dress_api.dart';
import 'package:loftify/Models/gift_response.dart';
import 'package:loftify/Screens/Info/nested_mixin.dart';
import 'package:loftify/Utils/hive_util.dart';

import '../../Utils/enums.dart';
import '../../Widgets/Item/item_builder.dart';
import '../../l10n/l10n.dart';

class DressDetailScreen extends StatefulWidgetForNested {
  const DressDetailScreen({
    super.key,
    required this.returnGiftDressId,
    super.nested = false,
  });

  final int returnGiftDressId;

  static const String routeName = "/info/dressDetail";

  @override
  State<DressDetailScreen> createState() => _DressDetailScreenState();
}

class _DressDetailScreenState extends BaseDynamicState<DressDetailScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  GiftDress? _giftDress;
  bool _loading = false;
  String? userAvatarImg;
  String? currentAvatarImg;
  final EasyRefreshController _refreshController = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    currentAvatarImg =
        ChewieHiveUtil.getString(HiveUtil.customAvatarBoxKey, defaultValue: null);
    setState(() {});
  }

  _fetchDetail({bool refresh = false}) async {
    if (_loading) return;
    _loading = true;
    userAvatarImg = (await HiveUtil.getUserInfo())?.bigAvaImg;
    await DressApi.getDressDetail(
      returnGiftDressId: widget.returnGiftDressId,
    ).then((value) {
      try {
        if (value['code'] != 200) {
          IToast.showTop(value['msg']);
          return IndicatorResult.fail;
        } else {
          _giftDress = GiftDress.fromJson(value['data']['returnGiftDress']);
          _giftDress!.partList.sort((a, b) => a.partType.compareTo(b.partType));
          if (mounted) setState(() {});
          return IndicatorResult.success;
        }
      } catch (e, t) {
        ILogger.error("Failed to load dress detail", e, t);
        if (mounted) IToast.showTop(appLocalizations.loadFailed);
        return IndicatorResult.fail;
      } finally {
        if (mounted) setState(() {});
        _loading = false;
      }
    });
  }

  _onRefresh() async {
    return await _fetchDetail(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ChewieTheme.getBackground(context),
      appBar: _buildAppBar(),
      body: EasyRefresh.builder(
          refreshOnStart: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          triggerAxis: Axis.vertical,
          childBuilder: (context, physics) {
            return _buildBody(physics);
          }),
    );
  }

  Widget _buildBody(ScrollPhysics physics) {
    return WaterfallFlow.builder(
      physics: physics,
      cacheExtent: 9999,
      padding: const EdgeInsets.all(10),
      itemCount: _giftDress?.partList.length ?? 0,
      gridDelegate: const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        maxCrossAxisExtent: 300,
      ),
      itemBuilder: (context, index) {
        return _buildItem(_giftDress!.partList[index]);
      },
    );
  }

  _dressOrUnDress(GiftPartItem item) async {
    HapticFeedback.mediumImpact();
    if (currentAvatarImg == item.partUrl) {
      await ChewieHiveUtil.put(HiveUtil.customAvatarBoxKey, "");
      currentAvatarImg = "";
      setState(() {});
      IToast.showTop(appLocalizations.unDressSuccess);
    } else {
      await ChewieHiveUtil.put(HiveUtil.customAvatarBoxKey, item.partUrl);
      currentAvatarImg = item.partUrl;
      setState(() {});
      IToast.showTop(appLocalizations.dressSuccess);
    }
  }

  _buildItem(GiftPartItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: ChewieTheme.canvasColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.partType == 1
                ? ItemBuilder.buildAvatar(
                    context: context,
                    size: 60,
                    showLoading: false,
                    imageUrl: userAvatarImg ?? "",
                    avatarBoxImageUrl: item.partUrl,
                    tagPrefix: "dressAvatarBox${item.partName}",
                    showDetailMode: ShowDetailMode.avatarBox,
                  )
                : GestureDetector(
                    onTap: () {
                      RouteUtil.pushDialogRoute(
                        context,
                        showClose: false,
                        fullScreen: true,
                        useFade: true,
                        HeroPhotoViewScreen(
                          imageUrls: [item.partUrl],
                          useMainColor: false,
                          title: item.partName,
                        ),
                      );
                    },
                    child: Hero(
                      tag: item.partUrl,
                      child: ChewieItemBuilder.buildCachedImage(
                        context: context,
                        width: 90,
                        height: 90,
                        showLoading: false,
                        placeholderBackground: Colors.transparent,
                        imageUrl: item.img,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            item.partName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            item.partType == 1 ? appLocalizations.avatarBox : appLocalizations.commentBubble,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (item.partType == 1) const SizedBox(width: 0),
              if (item.partType == 1)
                Center(
                  child: CircleIconButton(
                    icon: const Icon(Icons.download_done_rounded, size: 24),
                    onTap: () async {
                      CustomLoadingDialog.showLoading(
                          title: appLocalizations.downloading);
                      String url = item.partUrl;
                      await FileUtil.saveImage(context, url);
                      CustomLoadingDialog.dismissLoading();
                    },
                  ),
                ),
              if (item.partType != 1)
                Expanded(
                  flex: 2,
                  child: RoundIconTextButton(
                      text: appLocalizations.download, onPressed: () async {
                    CustomLoadingDialog.showLoading(
                        title: appLocalizations.downloading);
                    String url = item.partUrl;
                    await FileUtil.saveImage(context, url);
                    CustomLoadingDialog.dismissLoading();
                  }),
                ),
              if (item.partType == 1) const SizedBox(width: 5),
              if (item.partType == 1)
                Expanded(
                  flex: 3,
                  child: RoundIconTextButton(
                    text: currentAvatarImg == item.partUrl
                        ? appLocalizations.dressingCurrently
                        : appLocalizations.dressImmediately,
                    background: currentAvatarImg == item.partUrl
                        ? null
                        : Theme.of(context).primaryColor,
                    onPressed: () {
                      _dressOrUnDress(item);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return ResponsiveAppBar(
      showBack: true,
      title: appLocalizations.dressDetail,
    );
  }
}
