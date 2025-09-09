import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:loftify/Models/github_response.dart';
import 'package:loftify/Utils/cache_util.dart';
import 'package:loftify/Utils/itoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:window_manager/window_manager.dart';

import '../../Utils/app_provider.dart';
import '../../Utils/enums.dart';
import '../../Utils/file_util.dart';
import '../../Utils/hive_util.dart';
import '../../Utils/ilogger.dart';
import '../../Utils/locale_util.dart';
import '../../Utils/responsive_util.dart';
import '../../Utils/utils.dart';
import '../../Widgets/BottomSheet/bottom_sheet_builder.dart';
import '../../Widgets/BottomSheet/list_bottom_sheet.dart';
import '../../Widgets/Dialog/custom_dialog.dart';
import '../../Widgets/Dialog/dialog_builder.dart';
import '../../Widgets/General/EasyRefresh/easy_refresh.dart';
import '../../Widgets/Item/item_builder.dart';
import '../../l10n/l10n.dart';

class GeneralSettingScreen extends StatefulWidget {
  const GeneralSettingScreen({super.key});

  static const String routeName = "/setting/general";

  @override
  State<GeneralSettingScreen> createState() => GeneralSettingScreenState();
}

class GeneralSettingScreenState extends BaseDynamicState<GeneralSettingScreen>
    with TickerProviderStateMixin {
  String _cacheSize = "";
  List<Tuple2<String, Locale?>> _supportedLocaleTuples = [];
  bool inAppBrowser = ChewieHiveUtil.getBool(HiveUtil.inappWebviewKey);
  String currentVersion = "";
  String latestVersion = "";
  ReleaseItem? latestReleaseItem;
  bool autoCheckUpdate = ChewieHiveUtil.getBool(HiveUtil.autoCheckUpdateKey);
  bool enableMinimizeToTray = ChewieHiveUtil.getBool(HiveUtil.enableCloseToTrayKey);
  bool recordWindowState = ChewieHiveUtil.getBool(HiveUtil.recordWindowStateKey);
  bool enableCloseNotice = ChewieHiveUtil.getBool(HiveUtil.enableCloseNoticeKey);
  int doubleTapAction = Utils.patchEnum(
      ChewieHiveUtil.getInt(HiveUtil.doubleTapActionKey, defaultValue: 1),
      DoubleTapAction.values.length);
  int downloadSuccessAction = Utils.patchEnum(
      ChewieHiveUtil.getInt(HiveUtil.downloadSuccessActionKey),
      DownloadSuccessAction.values.length);
  String _logSize = "";
  bool launchAtStartup = ChewieHiveUtil.getBool(HiveUtil.launchAtStartupKey);
  bool showTray = ChewieHiveUtil.getBool(HiveUtil.showTrayKey);

  Future<void> getLogSize() async {
    double size = await FileOutput.getLogsSize();
    setState(() {
      _logSize = CacheUtil.renderSize(size);
    });
  }

  refreshLauchAtStartup() {
    setState(() {
      launchAtStartup = ChewieHiveUtil.getBool(HiveUtil.launchAtStartupKey);
    });
  }

  @override
  void initState() {
    super.initState();
    getLogSize();
    filterLocale();
    if (ResponsiveUtil.isMobile()) getCacheSize();
    fetchReleases(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void getCacheSize() {
    CacheUtil.loadCache().then((value) {
      setState(() {
        _cacheSize = value;
      });
    });
  }

  void filterLocale() {
    _supportedLocaleTuples = [];
    List<Locale> locales = S.delegate.supportedLocales;
    _supportedLocaleTuples.add(Tuple2(appLocalizations.followSystem, null));
    for (Locale locale in locales) {
      dynamic tuple = LocaleUtil.getTuple(locale);
      if (tuple != null) {
        _supportedLocaleTuples.add(tuple);
      }
    }
  }

  Future<void> fetchReleases(bool showTip) async {
    setState(() {});
    Utils.getReleases(
      context: context,
      showLoading: showTip,
      showUpdateDialog: showTip,
      showFailedToast: showTip,
      showLatestToast: showTip,
      onGetCurrentVersion: (currentVersion) {
        setState(() {
          this.currentVersion = currentVersion;
        });
      },
      onGetLatestRelease: (latestVersion, latestReleaseItem) {
        setState(() {
          this.latestVersion = latestVersion;
          this.latestReleaseItem = latestReleaseItem;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: ResponsiveAppBar(
          showBack: true,
          title: appLocalizations.generalSetting,
          context: context,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: EasyRefresh(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              if (ResponsiveUtil.isLandscapeLayout()) const SizedBox(height: 10),
              Selector<AppProvider, Locale?>(
                selector: (context, globalProvider) => globalProvider.locale,
                builder: (context, locale, child) => EntryItem(
                  context: context,
                  title: appLocalizations.language,
                  tip: LocaleUtil.getLabel(locale)!,
                  roundTop: true,
                  roundBottom: true,
                  onTap: () {
                    filterLocale();
                    BottomSheetBuilder.showListBottomSheet(
                      context,
                      (context) => TileList.fromOptions(
                        _supportedLocaleTuples,
                        (item2) {
                          appProvider.locale = item2;
                          Navigator.pop(context);
                        },
                        selected: locale,
                        context: context,
                        title: appLocalizations.chooseLanguage,
                        onCloseTap: () => Navigator.pop(context),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              CaptionItem(
                  context: context, title: appLocalizations.operationSetting),
              EntryItem(
                context: context,
                title: appLocalizations.doubleTapInDetailPage,
                tip: DoubleTapAction.values[doubleTapAction].label,
                onTap: () {
                  BottomSheetBuilder.showListBottomSheet(
                    context,
                    (sheetContext) => TileList.fromOptions(
                      DoubleTapAction.like.tuples,
                      (newAction) {
                        Navigator.pop(sheetContext);
                        setState(() {
                          doubleTapAction = newAction.index;
                          ChewieHiveUtil.put(
                              HiveUtil.doubleTapActionKey, doubleTapAction);
                        });
                      },
                      selected: DoubleTapAction.values[doubleTapAction],
                      title: appLocalizations.chooseDoubleTapInDetailPage,
                      context: context,
                      onCloseTap: () => Navigator.pop(sheetContext),
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  );
                },
              ),
              EntryItem(
                context: context,
                title: appLocalizations.afterDownloadSuccess,
                description: appLocalizations.afterDownloadSuccessDescription,
                roundBottom: true,
                tip: DownloadSuccessAction.values[downloadSuccessAction].label,
                onTap: () {
                  BottomSheetBuilder.showListBottomSheet(
                    context,
                    (sheetContext) => TileList.fromOptions(
                      DownloadSuccessAction.unlike.tuples,
                      (newAction) {
                        Navigator.pop(sheetContext);
                        setState(() {
                          downloadSuccessAction = newAction.index;
                          ChewieHiveUtil.put(HiveUtil.downloadSuccessActionKey,
                              downloadSuccessAction);
                        });
                      },
                      selected:
                          DownloadSuccessAction.values[downloadSuccessAction],
                      title: appLocalizations.chooseAfterDownloadSuccess,
                      context: context,
                      onCloseTap: () => Navigator.pop(sheetContext),
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  );
                },
              ),
              if (ResponsiveUtil.isDesktop()) ..._desktopSetting(),
              if (ResponsiveUtil.isMobile()) ..._mobileSetting(),
              const SizedBox(height: 10),
              CheckboxItem(
                value: autoCheckUpdate,
                roundTop: true,
                context: context,
                title: appLocalizations.autoCheckUpdates,
                onTap: () {
                  setState(() {
                    autoCheckUpdate = !autoCheckUpdate;
                    ChewieHiveUtil.put(HiveUtil.autoCheckUpdateKey, autoCheckUpdate);
                  });
                },
              ),
              EntryItem(
                context: context,
                title: appLocalizations.checkUpdates,
                roundBottom: true,
                description:
                    Utils.compareVersion(latestVersion, currentVersion) > 0
                        ? appLocalizations.newVersion(latestVersion)
                        : appLocalizations.alreadyLatestVersion,
                descriptionColor:
                    Utils.compareVersion(latestVersion, currentVersion) > 0
                        ? Colors.redAccent
                        : null,
                tip: currentVersion,
                onTap: () {
                  fetchReleases(true);
                },
              ),
              ..._logSetting(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  _mobileSetting() {
    return [
      const SizedBox(height: 10),
      CheckboxItem(
        value: inAppBrowser,
        context: context,
        title: appLocalizations.inAppBrowser,
        roundTop: true,
        onTap: () {
          setState(() {
            inAppBrowser = !inAppBrowser;
            ChewieHiveUtil.put(HiveUtil.inappWebviewKey, inAppBrowser);
          });
        },
      ),
      EntryItem(
        context: context,
        title: appLocalizations.clearCache,
        roundBottom: true,
        tip: _cacheSize,
        onTap: () {
          CustomLoadingDialog.showLoading(title: appLocalizations.clearingCache);
          getTemporaryDirectory().then((tempDir) {
            CacheUtil.delDir(tempDir).then((value) {
              CacheUtil.loadCache().then((value) {
                setState(() {
                  _cacheSize = value;
                  CustomLoadingDialog.dismissLoading();
                  IToast.showTop(appLocalizations.clearCacheSuccess);
                });
              });
            });
          });
        },
      ),
    ];
  }

  _logSetting() {
    return [
      const SizedBox(height: 10),
      EntryItem(
        context: context,
        title: appLocalizations.exportLog,
        description: appLocalizations.exportLogHint,
        roundTop: true,
        onTap: () {
          FileUtil.exportLogs();
        },
      ),
      EntryItem(
        context: context,
        title: appLocalizations.clearLog,
        roundBottom: true,
        tip: _logSize,
        onTap: () async {
          DialogBuilder.showConfirmDialog(
            context,
            title: appLocalizations.clearLogTitle,
            message: appLocalizations.clearLogHint,
            onTapConfirm: () async {
              CustomLoadingDialog.showLoading(title: appLocalizations.clearingLog);
              try {
                await FileOutput.clearLogs();
                await getLogSize();
                IToast.showTop(appLocalizations.clearLogSuccess);
              } catch (e, t) {
                ILogger.error("Failed to clear logs", e, t);
                IToast.showTop(appLocalizations.clearLogFailed);
              } finally {
                CustomLoadingDialog.dismissLoading();
              }
            },
          );
        },
      ),
    ];
  }

  _desktopSetting() {
    return [
      const SizedBox(height: 10),
      CaptionItem(
          context: context, title: appLocalizations.desktopSetting),
      CheckboxItem(
        context: context,
        title: appLocalizations.launchAtStartup,
        value: launchAtStartup,
        onTap: () async {
          setState(() {
            launchAtStartup = !launchAtStartup;
            ChewieHiveUtil.put(HiveUtil.launchAtStartupKey, launchAtStartup);
          });
          if (launchAtStartup) {
            await LaunchAtStartup.instance.enable();
          } else {
            await LaunchAtStartup.instance.disable();
          }
          Utils.initTray();
        },
      ),
      CheckboxItem(
        context: context,
        title: appLocalizations.showTray,
        value: showTray,
        onTap: () async {
          setState(() {
            showTray = !showTray;
            ChewieHiveUtil.put(HiveUtil.showTrayKey, showTray);
            if (showTray) {
              Utils.initTray();
            } else {
              Utils.removeTray();
            }
          });
        },
      ),
      Visibility(
        visible: showTray,
        child: EntryItem(
          context: context,
          title: appLocalizations.closeWindowOption,
          tip: enableMinimizeToTray
              ? appLocalizations.minimizeToTray
              : appLocalizations.exitApp,
          onTap: () {
            List<Tuple2<String, dynamic>> options = [
              Tuple2(appLocalizations.minimizeToTray, 0),
              Tuple2(appLocalizations.exitApp, 1),
            ];
            BottomSheetBuilder.showListBottomSheet(
              context,
              (sheetContext) => TileList.fromOptions(
                options,
                (idx) {
                  Navigator.pop(sheetContext);
                  if (idx == 0) {
                    setState(() {
                      enableMinimizeToTray = true;
                      ChewieHiveUtil.put(
                          HiveUtil.enableCloseToTrayKey, enableMinimizeToTray);
                    });
                  } else if (idx == 1) {
                    setState(() {
                      enableMinimizeToTray = false;
                      ChewieHiveUtil.put(
                          HiveUtil.enableCloseToTrayKey, enableMinimizeToTray);
                    });
                  }
                },
                selected: enableMinimizeToTray ? 0 : 1,
                title: appLocalizations.chooseCloseWindowOption,
                context: context,
                onCloseTap: () => Navigator.pop(sheetContext),
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            );
          },
        ),
      ),
      CheckboxItem(
        context: context,
        title: appLocalizations.autoMemoryWindowPositionAndSize,
        value: recordWindowState,
        description: appLocalizations.autoMemoryWindowPositionAndSizeTip,
        roundBottom: true,
        onTap: () async {
          setState(() {
            recordWindowState = !recordWindowState;
            ChewieHiveUtil.put(HiveUtil.recordWindowStateKey, recordWindowState);
          });
          HiveUtil.setWindowSize(await windowManager.getSize());
          HiveUtil.setWindowPosition(await windowManager.getPosition());
        },
      ),
    ];
  }
}
