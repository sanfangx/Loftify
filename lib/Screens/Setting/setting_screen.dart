import 'package:flutter/material.dart';
import 'package:loftify/Screens/Setting/apperance_setting_screen.dart';
import 'package:loftify/Screens/Setting/blacklist_setting_screen.dart';
import 'package:loftify/Screens/Setting/general_setting_screen.dart';
import 'package:loftify/Screens/Setting/image_setting_screen.dart';
import 'package:loftify/Screens/Setting/lofter_basic_setting_screen.dart';
import 'package:loftify/Screens/Setting/tagshield_setting_screen.dart';
import 'package:loftify/Screens/Setting/userdynamicshield_setting_screen.dart';
import 'package:loftify/Utils/app_provider.dart';

import '../../Utils/responsive_util.dart';
import '../../Utils/route_util.dart';
import '../../Widgets/General/EasyRefresh/easy_refresh.dart';
import '../../Widgets/Item/item_builder.dart';
import '../../l10n/l10n.dart';
import 'about_setting_screen.dart';
import 'experiment_setting_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  static const String routeName = "/setting";

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends BaseDynamicState<SettingScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Scaffold(
        appBar: ResponsiveAppBar(
          showBack: true,
          title: appLocalizations.setting,
          context: context,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: EasyRefresh(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              if (ResponsiveUtil.isLandscapeLayout()) const SizedBox(height: 10),
              CaptionItem(
                  context: context, title: appLocalizations.basicSetting),
              EntryItem(
                context: context,
                title: appLocalizations.generalSetting,
                showLeading: true,
                onTap: () {
                  RouteUtil.pushPanelCupertinoRoute(context,
                      GeneralSettingScreen(key: generalSettingScreenKey));
                },
                leading: Icons.settings_outlined,
              ),
              EntryItem(
                context: context,
                title: appLocalizations.appearanceSetting,
                showLeading: true,
                onTap: () {
                  RouteUtil.pushPanelCupertinoRoute(
                      context, const AppearanceSettingScreen());
                },
                leading: Icons.color_lens_outlined,
              ),
              EntryItem(
                context: context,
                title: appLocalizations.imageSetting,
                showLeading: true,
                onTap: () {
                  RouteUtil.pushPanelCupertinoRoute(
                      context, const ImageSettingScreen());
                },
                leading: Icons.image_outlined,
              ),
              // EntryItem(
              //   context: context,
              //   title: appLocalizations.operationSetting,
              //   showLeading: true,
              //   onTap: () {
              //     RouteUtil.pushPanelCupertinoRoute(
              //         context, const OperationSettingScreen());
              //   },
              //   leading: Icons.touch_app_outlined,
              // ),
              EntryItem(
                context: context,
                title: appLocalizations.experimentSetting,
                showLeading: true,
                roundBottom: true,
                onTap: () {
                  RouteUtil.pushPanelCupertinoRoute(
                      context, const ExperimentSettingScreen());
                },
                leading: Icons.flag_outlined,
              ),
              if (appProvider.token.isNotEmpty) ..._buildLofter(),
              const SizedBox(height: 10),
              _buildAbout(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  _buildAbout() {
    return EntryItem(
      context: context,
      title: appLocalizations.about,
      roundBottom: true,
      roundTop: true,
      showLeading: true,
      padding: 15,
      onTap: () {
        RouteUtil.pushPanelCupertinoRoute(context, const AboutSettingScreen());
      },
      leading: Icons.info_outline_rounded,
    );
  }

  List<Widget> _buildLofter() {
    return [
      const SizedBox(height: 10),
      CaptionItem(
          context: context, title: appLocalizations.lofterSetting),
      EntryItem(
        context: context,
        showLeading: true,
        title: appLocalizations.lofterBasicSetting,
        onTap: () {
          RouteUtil.pushPanelCupertinoRoute(
              context, const LofterBasicSettingScreen());
        },
        leading: Icons.copyright_rounded,
      ),
      EntryItem(
        context: context,
        showLeading: true,
        title: appLocalizations.blacklistSetting,
        onTap: () {
          RouteUtil.pushPanelCupertinoRoute(
              context, const BlacklistSettingScreen());
        },
        leading: Icons.block_rounded,
      ),
      EntryItem(
        context: context,
        showLeading: true,
        title: appLocalizations.tagShieldSetting,
        onTap: () {
          RouteUtil.pushPanelCupertinoRoute(
              context, const TagShieldSettingScreen());
        },
        leading: Icons.tag_rounded,
      ),
      EntryItem(
        context: context,
        showLeading: true,
        roundBottom: true,
        title: appLocalizations.userDynamicShieldSetting,
        onTap: () {
          RouteUtil.pushPanelCupertinoRoute(
              context, const UserDynamicShieldSettingScreen());
        },
        leading: Icons.shield_outlined,
      ),
    ];
  }
}
