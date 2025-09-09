import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loftify/Screens/Setting/filename_setting_screen.dart';
import 'package:loftify/Utils/enums.dart';
import 'package:loftify/Utils/route_util.dart';

import '../../Utils/cloud_control_provider.dart';
import '../../Utils/constant.dart';
import '../../Utils/hive_util.dart';
import '../../Utils/responsive_util.dart';
import '../../Widgets/BottomSheet/bottom_sheet_builder.dart';
import '../../Widgets/BottomSheet/list_bottom_sheet.dart';
import '../../Widgets/General/EasyRefresh/easy_refresh.dart';
import '../../Widgets/Item/item_builder.dart';
import '../../l10n/l10n.dart';

class ImageSettingScreen extends StatefulWidget {
  const ImageSettingScreen({super.key});

  static const String routeName = "/setting/image";

  @override
  State<ImageSettingScreen> createState() => _ImageSettingScreenState();
}

class _ImageSettingScreenState extends BaseDynamicState<ImageSettingScreen>
    with TickerProviderStateMixin {
  ImageQuality waterfallFlowImageQuality =
      HiveUtil.getImageQuality(HiveUtil.waterfallFlowImageQualityKey);
  ImageQuality postDetailImageQuality =
      HiveUtil.getImageQuality(HiveUtil.postDetailImageQualityKey);
  ImageQuality imageDetailImageQuality =
      HiveUtil.getImageQuality(HiveUtil.imageDetailImageQualityKey);
  ImageQuality tapLinkButtonImageQuality =
      HiveUtil.getImageQuality(HiveUtil.tapLinkButtonImageQualityKey);
  ImageQuality longPressLinkButtonImageQuality =
      HiveUtil.getImageQuality(HiveUtil.longPressLinkButtonImageQualityKey);
  bool followMainColor = ChewieHiveUtil.getBool(HiveUtil.followMainColorKey);
  String? savePath = ChewieHiveUtil.getString(HiveUtil.savePathKey);
  String _filenameFormat = ChewieHiveUtil.getString(HiveUtil.filenameFormatKey,
          defaultValue: defaultFilenameFormat) ??
      defaultFilenameFormat;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  showImageQualitySelect({
    Function(ImageQuality)? onSelected,
    dynamic selected,
    required String title,
  }) {
    BottomSheetBuilder.showListBottomSheet(
      context,
      (context) => TileList.fromOptions(
        EnumsLabelGetter.getImageQualityLabels(),
        (item2) {
          onSelected?.call(item2);
          Navigator.pop(context);
        },
        selected: selected,
        context: context,
        title: title,
        onCloseTap: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showImageQualitySettings =
        controlProvider.globalControl.showImageQualitySettings;
    bool showBigImageSettings =
        controlProvider.globalControl.showBigImageSettings;
    return Container(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: ResponsiveAppBar(
          showBack: true,
          title: appLocalizations.imageSetting,
          context: context,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: EasyRefresh(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              if (ResponsiveUtil.isLandscapeLayout()) const SizedBox(height: 10),
              if (showImageQualitySettings) ..._imageQualitySettings(),
              if (showImageQualitySettings) const SizedBox(height: 10),
              if (showBigImageSettings) ..._bigImageSettings(),
              if (showImageQualitySettings || showBigImageSettings)
                const SizedBox(height: 10),
              CaptionItem(
                  context: context, title: appLocalizations.downloadImageSetting),
              EntryItem(
                context: context,
                title: appLocalizations.downloadImagePath,
                description: savePath ?? "",
                tip: appLocalizations.edit,
                onTap: () async {
                  String? selectedDirectory =
                      await FilePicker.platform.getDirectoryPath(
                    dialogTitle: appLocalizations.chooseDownloadImagePath,
                    lockParentWindow: true,
                  );
                  if (selectedDirectory != null) {
                    setState(() {
                      savePath = selectedDirectory;
                      ChewieHiveUtil.put(HiveUtil.savePathKey, selectedDirectory);
                    });
                  }
                },
              ),
              EntryItem(
                context: context,
                title: appLocalizations.filenameFormat,
                description: _filenameFormat,
                tip: appLocalizations.edit,
                roundBottom: true,
                onTap: () {
                  var page = FilenameSettingScreen(
                    onSaved: (newFormat) {
                      setState(() {
                        _filenameFormat = newFormat;
                      });
                    },
                  );
                  RouteUtil.pushPanelCupertinoRoute(context, page);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  _imageQualitySettings() {
    return [
      CaptionItem(
          context: context, title: appLocalizations.imageQuality),
      EntryItem(
        context: context,
        title: appLocalizations.waterfallFlowImageQuality,
        tip: EnumsLabelGetter.getImageQualityLabel(waterfallFlowImageQuality),
        onTap: () {
          showImageQualitySelect(
            onSelected: (quality) {
              setState(() {
                waterfallFlowImageQuality = quality;
                ChewieHiveUtil.put(
                    HiveUtil.waterfallFlowImageQualityKey, quality.index);
              });
            },
            selected: waterfallFlowImageQuality,
            title: appLocalizations.chooseWaterfallFlowImageQuality,
          );
        },
      ),
      EntryItem(
        context: context,
        title: appLocalizations.postDetailImageQuality,
        tip: EnumsLabelGetter.getImageQualityLabel(postDetailImageQuality),
        onTap: () {
          showImageQualitySelect(
            onSelected: (quality) {
              setState(() {
                postDetailImageQuality = quality;
                ChewieHiveUtil.put(HiveUtil.postDetailImageQualityKey, quality.index);
              });
            },
            selected: postDetailImageQuality,
            title: appLocalizations.choosePostDetailImageQuality,
          );
        },
      ),
      EntryItem(
        context: context,
        title: appLocalizations.bigImageQuality,
        tip: EnumsLabelGetter.getImageQualityLabel(imageDetailImageQuality),
        roundBottom: true,
        onTap: () {
          showImageQualitySelect(
            onSelected: (quality) {
              setState(() {
                imageDetailImageQuality = quality;
                ChewieHiveUtil.put(
                    HiveUtil.imageDetailImageQualityKey, quality.index);
              });
            },
            selected: imageDetailImageQuality,
            title: appLocalizations.chooseBigImageQuality,
          );
        },
      ),
    ];
  }

  _bigImageSettings() {
    return [
      CaptionItem(
          context: context, title: appLocalizations.bigImageSetting),
      CheckboxItem(
        value: followMainColor,
        context: context,
        title: appLocalizations.backgroundColorFollowMainColor,
        onTap: () {
          setState(() {
            followMainColor = !followMainColor;
            ChewieHiveUtil.put(
              HiveUtil.followMainColorKey,
              followMainColor,
            );
          });
        },
      ),
      EntryItem(
        context: context,
        title: appLocalizations.tapLinkButton,
        tip: EnumsLabelGetter.getImageQualityLabel(tapLinkButtonImageQuality),
        description: appLocalizations.tapLinkButtonDescription,
        onTap: () {
          showImageQualitySelect(
            onSelected: (quality) {
              setState(() {
                tapLinkButtonImageQuality = quality;
                ChewieHiveUtil.put(
                    HiveUtil.tapLinkButtonImageQualityKey, quality.index);
              });
            },
            selected: tapLinkButtonImageQuality,
            title: appLocalizations.chooseTapLinkButton,
          );
        },
      ),
      EntryItem(
        context: context,
        title: appLocalizations.longPressLinkButton,
        tip: EnumsLabelGetter.getImageQualityLabel(
            longPressLinkButtonImageQuality),
        description: appLocalizations.longPressLinkButtonDescription,
        roundBottom: true,
        onTap: () {
          showImageQualitySelect(
            onSelected: (quality) {
              setState(() {
                longPressLinkButtonImageQuality = quality;
                ChewieHiveUtil.put(
                    HiveUtil.longPressLinkButtonImageQualityKey, quality.index);
              });
            },
            selected: longPressLinkButtonImageQuality,
            title: appLocalizations.chooseLongPressLinkButton,
          );
        },
      ),
    ];
  }
}
