import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/models/call_state_controller.dart';
import 'package:sentinel_call/models/navigation_screen.dart';
import 'package:sentinel_call/services/blockchain.dart';
import 'package:sentinel_call/theme/custom_colors_theme.dart';

class MainWrapper extends StatefulWidget {
  final String title;

  const MainWrapper({
    super.key,
    required this.title,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper>
    with TickerProviderStateMixin {
  final autoSizeGroup = AutoSizeGroup();
  var _bottomNavIndex = 0;
  late bool granted = false;
  late AnimationController _fabAnimationController;
  late AnimationController _hideBottomBarAnimationController;

  final service = Get.find<BlockchainService>();
  final wallet = Get.find<KeyPair>();

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _hideBottomBarAnimationController.dispose();
    service.disconnect();
    super.dispose();
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _hideBottomBarAnimationController.reverse();
          _fabAnimationController.forward(from: 0);
          break;
        case ScrollDirection.reverse:
          _hideBottomBarAnimationController.forward();
          _fabAnimationController.reverse(from: 1);
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  final List<IconData> iconList = [
    Icons.search,
    Icons.person,
  ];

  final List<String> titleList = [
    'Search',
    'User',
    'Status',
    'Report',
    'Vote',
    'Test'
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColorsTheme>()!;

    return GetBuilder<CallStateController>(
        builder: (s) => Scaffold(
              appBar: AppBar(
                  title: Text(widget.title),
                  titleTextStyle: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(
                          color: Colors.white, fontFamily: 'Syncopate-Bold')),
              body: NotificationListener<ScrollNotification>(
                onNotification: onScrollNotification,
                child: NavigationScreen(
                  titleList[_bottomNavIndex],
                  wallet: wallet,
                  service: service,
                ),
              ),
              bottomNavigationBar: AnimatedBottomNavigationBar.builder(
                itemCount: iconList.length,
                activeIndex: _bottomNavIndex,
                gapLocation: GapLocation.center,
                notchSmoothness: NotchSmoothness.defaultEdge,
                onTap: (index) => setState(() => _bottomNavIndex = index),
                tabBuilder: (index, isActive) {
                  final color = isActive
                      ? colors.activeNavigationBarColor
                      : colors.notActiveNavigationBarColor;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        iconList[index],
                        size: 24,
                        color: color,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: AutoSizeText(
                          titleList[index],
                          maxLines: 1,
                          style: TextStyle(
                            color: color,
                          ),
                          group: autoSizeGroup,
                        ),
                      )
                    ],
                  );
                },
                leftCornerRadius: 32,
                rightCornerRadius: 32,
                backgroundColor: colors.bottomNavigationBarBackgroundColor,
                hideAnimationController: _hideBottomBarAnimationController,
                shadow: const BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 12,
                  spreadRadius: 0.5,
                  // color: colors.activeNavigationBarColor,
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: SpeedDial(
                foregroundColor: colors.notActiveNavigationBarColor,
                renderOverlay: true,
                icon: Icons.api,
                activeIcon: Icons.close,
                useRotationAnimation: true,
                elevation: 8.0,
                animationCurve: Curves.elasticInOut,
                isOpenOnStart: false,
                shape: const StadiumBorder(),
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.report),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    label: 'Report Spam',
                    onTap: () => setState(
                        () => _bottomNavIndex = titleList.indexOf('Report')),
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.how_to_vote),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    label: 'Vote',
                    onTap: () => setState(
                        () => _bottomNavIndex = titleList.indexOf('Vote')),
                  ),
                  // SpeedDialChild(
                  //   child: const Icon(Icons.hub),
                  //   backgroundColor: Colors.lightGreen,
                  //   foregroundColor: Colors.white,
                  //   label: 'Sync Status',
                  //   onTap: () => setState(
                  //     () => _bottomNavIndex = titleList.indexOf('Status'),
                  //   ),
                  // ),
                  SpeedDialChild(
                    child: const Icon(Icons.call),
                    backgroundColor: Colors.lightGreen,
                    foregroundColor: Colors.white,
                    label: 'Test Phone',
                    // onTap: () => Get.toNamed('/test'),
                    onTap: () => setState(
                      () => _bottomNavIndex = titleList.indexOf('Test'),
                    ),
                  ),
                ],
              ),
            ));
  }
}
