import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:trappist_extra/models/navigation_screen.dart';
import 'package:trappist_extra/services/services.dart';
import 'package:trappist_extra/theme/custom_colors_theme.dart';

class HomePage extends StatefulWidget {
  final String title;
  final BlockchainService service;
  final KeyPair wallet;
  const HomePage(
      {super.key,
      required this.title,
      required this.service,
      required this.wallet});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final autoSizeGroup = AutoSizeGroup();
  var _bottomNavIndex = 0;

  late AnimationController _fabAnimationController;
  late AnimationController _hideBottomBarAnimationController;

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
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

  final List<String> titleList = ['Search', 'User', 'Status', 'Report', 'Vote'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColorsTheme>()!;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
          titleTextStyle: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.white, fontFamily: 'Syncopate-Bold')),
      body: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: NavigationScreen(
          titleList[_bottomNavIndex],
          wallet: widget.wallet,
          service: widget.service,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SpeedDial(
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
            onTap: () =>
                setState(() => _bottomNavIndex = titleList.indexOf('Report')),
          ),
          SpeedDialChild(
            child: const Icon(Icons.how_to_vote),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            label: 'Vote',
            onTap: () =>
                setState(() => _bottomNavIndex = titleList.indexOf('Vote')),
          ),
          SpeedDialChild(
            child: const Icon(Icons.hub),
            backgroundColor: Colors.lightGreen,
            foregroundColor: Colors.white,
            label: 'Sync Status',
            onTap: () => setState(
              () => _bottomNavIndex = titleList.indexOf('Status'),
            ),
          ),
        ],
      ),
    );
  }
}
