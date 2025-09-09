import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../Utils/app_provider.dart';
import '../../Utils/hive_util.dart';
import '../../Widgets/Item/item_builder.dart';
import '../../l10n/l10n.dart';
import '../Lock/pin_change_screen.dart';
import '../Lock/pin_verify_screen.dart';
import 'base_setting_screen.dart';

class ExperimentSettingScreen extends BaseSettingScreen {
  const ExperimentSettingScreen({
    super.key,
    super.padding,
    super.showTitleBar,
    super.searchConfig,
    super.searchText,
  });

  static const String routeName = "/setting/experiment";

  @override
  State<ExperimentSettingScreen> createState() =>
      _ExperimentSettingScreenState();
}

class _ExperimentSettingScreenState
    extends BaseDynamicState<ExperimentSettingScreen>
    with TickerProviderStateMixin {
  bool _enableGuesturePasswd =
      ChewieHiveUtil.getBool(HiveUtil.enableGuesturePasswdKey);
  bool _autoLock = ChewieHiveUtil.getBool(HiveUtil.autoLockKey);
  bool _enableSafeMode =
      ChewieHiveUtil.getBool(HiveUtil.enableSafeModeKey, defaultValue: false);
  bool _enableBiometric = ChewieHiveUtil.getBool(HiveUtil.enableBiometricKey);
  bool _biometricAvailable = false;
  int _refreshRate = ChewieHiveUtil.getInt(HiveUtil.refreshRateKey);
  List<DisplayMode> _modes = [];
  DisplayMode? _activeMode;
  DisplayMode? _preferredMode;

  List<Tuple2<String, DisplayMode>> get _supportedModeTuples =>
      _modes.map((e) => Tuple2(e.toString(), e)).toList();

  @override
  void initState() {
    super.initState();
    initBiometricAuthentication();
    if (ResponsiveUtil.isAndroid()) getRefreshRate();
  }

  getRefreshRate() async {
    _modes = await FlutterDisplayMode.supported;
    _activeMode = await FlutterDisplayMode.active;
    _preferredMode = await FlutterDisplayMode.preferred;
    ILogger.info(
        "Current active display mode: $_activeMode\nCurrent preferred display mode: $_preferredMode");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChewieItemBuilder.buildSettingScreen(
      context: context,
      title: appLocalizations.experimentSetting,
      showTitleBar: widget.showTitleBar,
      showBack: !ResponsiveUtil.isLandscapeLayout(),
      padding: widget.padding,
      children: [
        Selector<AppProvider, bool>(
          selector: (context, globalProvider) => globalProvider.pinSettled,
          builder: (context, pinSettled, child) => _privacySettings(pinSettled),
        ),
        if (ResponsiveUtil.isAndroid()) _fpsSettings(),
      ],
    );
  }

  _fpsSettings() {
    return [
      const SizedBox(height: 10),
      EntryItem(
        title: appLocalizations.refreshRate,
        description: appLocalizations.refreshRateDescription(
          _modes.isNotEmpty
              ? _modes[_refreshRate.clamp(0, _modes.length - 1)].toString()
              : "",
          _preferredMode?.toString() ?? "Unknown",
          _activeMode?.toString() ?? "Unknown",
        ),
        roundTop: true,
        roundBottom: true,
        onTap: () {
          getRefreshRate();
          BottomSheetBuilder.showListBottomSheet(
            context,
            (context) => TileList.fromOptions(
              _supportedModeTuples,
              (item2) async {
                try {
                  ILogger.info("Try to set display mode: ${item2.toString()}");
                  ILogger.info(
                      "Active display mode before set: ${_activeMode.toString()}\nPreferred display mode before set: ${_preferredMode.toString()}");
                  await FlutterDisplayMode.setPreferredMode(item2);
                  _activeMode = await FlutterDisplayMode.active;
                  _preferredMode = await FlutterDisplayMode.preferred;
                  ILogger.info(
                      "Active display mode after set: ${_activeMode.toString()}\nPreferred display mode after set: ${_preferredMode.toString()}");
                  if (_preferredMode?.toString() != item2.toString()) {
                    IToast.showTop(appLocalizations.setRefreshRateFailed);
                  } else {
                    if (_activeMode?.toString() != item2.toString()) {
                      IToast.showTop(S.current
                          .setRefreshRateSuccessWithDisplayModeNotChanged);
                    } else {
                      IToast.showTop(appLocalizations.setRefreshRateSuccess);
                    }
                  }
                } catch (e, t) {
                  IToast.showTop(appLocalizations
                      .setRefreshRateFailedWithError(e.toString()));
                  ILogger.error("Failed to set display mode", e, t);
                }
                _refreshRate = _modes.indexOf(item2);
                getRefreshRate();
                ChewieHiveUtil.put(HiveUtil.refreshRateKey, _refreshRate);
                Navigator.pop(context);
              },
              selected: _modes[_refreshRate.clamp(0, _modes.length - 1)],
              context: context,
              title: appLocalizations.chooseRefreshRate,
              onCloseTap: () => Navigator.pop(context),
            ),
          );
        },
      ),
    ];
  }

  _privacySettings(bool pinSettled) {
    return CaptionItem(
      title: appLocalizations.privacySetting,
      children: [
        CheckboxItem(
          value: _enableGuesturePasswd,
          title: appLocalizations.enableGestureLock,
          onTap: onEnablePinTapped,
        ),
        Visibility(
          visible: _enableGuesturePasswd,
          child: EntryItem(
            title: pinSettled
                ? appLocalizations.changeGestureLock
                : appLocalizations.setGestureLock,
            description:
                pinSettled ? "" : appLocalizations.haveToSetGestureLockTip,
            onTap: onChangePinTapped,
          ),
        ),
        Visibility(
          visible: _enableGuesturePasswd && pinSettled && _biometricAvailable,
          child: CheckboxItem(
            value: _enableBiometric,
            disabled: ResponsiveUtil.isMacOS() || ResponsiveUtil.isLinux(),
            title: appLocalizations.biometric,
            description: appLocalizations.biometricUnlockTip,
            onTap: onBiometricTapped,
          ),
        ),
        Visibility(
          visible: _enableGuesturePasswd && pinSettled,
          child: CheckboxItem(
            value: _autoLock,
            title: appLocalizations.autoLock,
            description: appLocalizations.autoLockTip,
            onTap: onEnableAutoLockTapped,
          ),
        ),
        Visibility(
          visible: _enableGuesturePasswd && pinSettled && _autoLock,
          child: Selector<AppProvider, int>(
            selector: (context, globalProvider) =>
                globalProvider.autoLockSeconds,
            builder: (context, autoLockTime, child) => InlineSelectionItem<SelectionItemModel<(
              title: appLocalizations.autoLockDelay,
              tip: AppProvider.getAutoLockOptionLabel(autoLockTime),
              onTap: () {
                BottomSheetBuilder.showListBottomSheet(
                  context,
                  (context) => TileList.fromOptions(
                    AppProvider.getAutoLockOptions(),
                    (item2) {
                      appProvider.autoLockSeconds = item2;
                      Navigator.pop(context);
                    },
                    selected: autoLockTime,
                    context: context,
                    title: appLocalizations.chooseAutoLockDelay,
                    onCloseTap: () => Navigator.pop(context),
                  ),
                );
              },
            ),
          ),
        ),
        CheckboxItem(
          value: _enableSafeMode,
          title: appLocalizations.safeMode,
          disabled: ResponsiveUtil.isDesktop(),
          roundBottom: true,
          description: appLocalizations.safeModeTip,
          onTap: onSafeModeTapped,
        ),
      ],
    );
  }

  initBiometricAuthentication() async {
    LocalAuthentication localAuth = LocalAuthentication();
    bool available = await localAuth.canCheckBiometrics;
    setState(() {
      _biometricAvailable = available;
    });
  }

  onEnablePinTapped() {
    setState(() {
      RouteUtil.pushPanelCupertinoRoute(
        context,
        PinVerifyScreen(
          onSuccess: () {
            setState(() {
              _enableGuesturePasswd = !_enableGuesturePasswd;
              IToast.showTop(_enableGuesturePasswd
                  ? appLocalizations.enableGestureLockSuccess
                  : appLocalizations.disableGestureLockSuccess);
              ChewieHiveUtil.put(
                  HiveUtil.enableGuesturePasswdKey, _enableGuesturePasswd);
            });
          },
          isModal: false,
        ),
      );
    });
  }

  onBiometricTapped() {
    if (!_enableBiometric) {
      RouteUtil.pushPanelCupertinoRoute(
        context,
        PinVerifyScreen(
          onSuccess: () {
            IToast.showTop(appLocalizations.enableBiometricSuccess);
            setState(() {
              _enableBiometric = !_enableBiometric;
              ChewieHiveUtil.put(HiveUtil.enableBiometricKey, _enableBiometric);
            });
          },
          isModal: false,
        ),
      );
    } else {
      setState(() {
        _enableBiometric = !_enableBiometric;
        ChewieHiveUtil.put(HiveUtil.enableBiometricKey, _enableBiometric);
      });
    }
  }

  onChangePinTapped() {
    setState(() {
      RouteUtil.pushPanelCupertinoRoute(context, const PinChangeScreen());
      //     .then((value) {
      //   setState(() {
      //     _hasGuesturePasswd =
      //         ChewieHiveUtil.getString(HiveUtil.guesturePasswdKey) != null &&
      //             ChewieHiveUtil.getString(HiveUtil.guesturePasswdKey)!.isNotEmpty;
      //   });
      // });
    });
  }

  onEnableAutoLockTapped() {
    setState(() {
      _autoLock = !_autoLock;
      ChewieHiveUtil.put(HiveUtil.autoLockKey, _autoLock);
    });
  }

  onSafeModeTapped() {
    setState(() {
      _enableSafeMode = !_enableSafeMode;
      if (ResponsiveUtil.isMobile()) {
        if (_enableSafeMode) {
          FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        } else {
          FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
        }
      }
      ChewieHiveUtil.put(HiveUtil.enableSafeModeKey, _enableSafeMode);
    });
  }
}
