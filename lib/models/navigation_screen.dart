import 'package:flutter/material.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:trappist_extra/pages/calling.dart';
import 'package:trappist_extra/pages/report.dart';
import 'package:trappist_extra/pages/search.dart';
import 'package:trappist_extra/pages/status.dart';
import 'package:trappist_extra/pages/user.dart';
import 'package:trappist_extra/pages/vote.dart';
import 'package:trappist_extra/services/blockchain.dart';

class NavigationScreen extends StatefulWidget {
  final String titleList;
  final KeyPair wallet;
  final BlockchainService service;

  const NavigationScreen(this.titleList,
      {super.key, required this.wallet, required this.service});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void didUpdateWidget(NavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.titleList != widget.titleList) {
      _startAnimation();
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    super.initState();
  }

  _startAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: ListView(
        children: [
          switch (widget.titleList) {
            'Status' => const StatusPage().build(context),
            'User' => UserPage(
                wallet: widget.wallet,
                service: widget.service,
              ),
            'Search' => const SearchPage(),
            'Report' =>
              ReportPage(service: widget.service, wallet: widget.wallet),
            'Vote' => VotePage(),
            'Test' =>
              CallingPage(wallet: widget.wallet, service: widget.service),
            String() => Container(),
          }
        ],
      ),
    );
  }
}
