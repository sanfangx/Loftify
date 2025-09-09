import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';
import 'package:loftify/Api/login_api.dart';
import 'package:loftify/Screens/Login/login_by_captcha_screen.dart';
import 'package:loftify/Screens/Login/login_by_password_screen.dart';
import 'package:loftify/Utils/enums.dart';
import 'package:loftify/Utils/hive_util.dart';

import '../../Models/login_lofterid_response.dart';
import '../../Utils/app_provider.dart';
import '../../Utils/constant.dart';
import '../../Utils/request_util.dart';
import '../../Widgets/Item/item_builder.dart';
import '../../l10n/l10n.dart';

class LoginByLofterIDScreen extends StatefulWidget {
  const LoginByLofterIDScreen({super.key, this.initPassword});

  static const String routeName = "/login/lofterID";

  final String? initPassword;

  @override
  State<LoginByLofterIDScreen> createState() => _LoginByLofterIDScreenState();
}

class _LoginByLofterIDScreenState
    extends BaseDynamicState<LoginByLofterIDScreen>
    with TickerProviderStateMixin {
  late TextEditingController _lofterIDController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _lofterIDController = TextEditingController();
    _passwordController = TextEditingController();
    _lofterIDController.text = defaultLofterID;
    _passwordController.text = widget.initPassword ?? defaultPassword;
  }

  void _login() {
    String lofterID = _lofterIDController.text;
    String password = _passwordController.text;
    if (lofterID.isEmpty || password.isEmpty) {
      IToast.showTop(appLocalizations.lofterIDOrPasswordCannotBeEmpty);
      return;
    }
    LoginApi.loginByLofterID(lofterID, password).then((value) async {
      try {
        LoginLofterIDResponse loginResponse =
            LoginLofterIDResponse.fromJson(value);
        if (loginResponse.status != 200) {
          IToast.showTop(loginResponse.desc);
        } else {
          IToast.showTop(appLocalizations.loginSuccess);
          appProvider.token = loginResponse.token ?? "";
          await RequestUtil.clearCookie();
          await ChewieHiveUtil.put(HiveUtil.userIdKey, loginResponse.userId);
          await ChewieHiveUtil.put(HiveUtil.tokenKey, loginResponse.token);
          await ChewieHiveUtil.put(
              HiveUtil.tokenTypeKey, TokenType.lofterID.index);
          mainScreenState?.login();
        }
      } catch (e, t) {
        ILogger.error("Failed to login by LofterID", e, t);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: ResponsiveAppBar(
          title: appLocalizations.loginByLofterID,
          titleLeftMargin: ResponsiveUtil.isLandscapeLayout() ? 15 : 5,
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: NoShadowScrollBehavior(),
                child: ListView(
                  children: [
                    const SizedBox(height: 50),
                    InputItem(
                      hint: appLocalizations.inputLofterID,
                      textInputAction: TextInputAction.next,
                      controller: _lofterIDController,
                      leadingConfig: InputItemLeadingTailingConfig(
                        type: InputItemLeadingTailingType.icon,
                        icon: Icons.card_membership_rounded,
                      ),
                      tailingConfig: InputItemLeadingTailingConfig(
                        type: InputItemLeadingTailingType.clear,
                      ),
                    ),
                    InputItem(
                      hint: appLocalizations.inputPassword,
                      textInputAction: TextInputAction.next,
                      leadingConfig: InputItemLeadingTailingConfig(
                        type: InputItemLeadingTailingType.icon,
                        icon: Icons.verified_outlined,
                      ),
                      controller: _passwordController,
                      tailingConfig: InputItemLeadingTailingConfig(
                        type: InputItemLeadingTailingType.password,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 50),
                      child: RoundIconTextButton(
                        text: appLocalizations.login,
                        onPressed: _login,
                        background: Theme.of(context).primaryColor,
                        color: Colors.white,
                        fontSizeDelta: 2,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 50,
                child: Column(
                  children: [
                    ItemBuilder.buildTextDivider(
                      context: context,
                      text: appLocalizations.otherLoginMethods,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ToolButton(
                            context: context,
                            icon: Icons.phone_android_rounded,
                            onPressed: () {
                              RouteUtil.pushCupertinoRoute(
                                context,
                                const LoginByCaptchaScreen(),
                              );
                            }),
                        const SizedBox(width: 30),
                        ToolButton(
                            context: context,
                            icon: Icons.password_rounded,
                            onPressed: () {
                              RouteUtil.pushCupertinoRoute(
                                context,
                                LoginByPasswordScreen(
                                  initPassword: _passwordController.text,
                                ),
                              );
                            }),
                        // const SizedBox(width: 30),
                        // ToolButton(
                        //     context: context,
                        //     icon: Icons.mail_outline_rounded,
                        //     onTap: () {
                        //       RouteUtil.pushCupertinoRoute(
                        //         context,
                        //         LoginByMailScreen(
                        //           initPassword: _passwordController.text,
                        //         ),
                        //       );
                        //     }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
