import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/screens/app/app_index_provider.dart';
import 'package:focus_spot_finder/screens/app/favorite_list.dart';
import 'package:focus_spot_finder/screens/app/home.dart';
import 'package:focus_spot_finder/screens/app/profile/profile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'widget/bottom_nav.dart';
import 'widget/center_bottom_button.dart';

class AppPage extends HookConsumerWidget {
  final int initialPage;
  const AppPage({this.initialPage = 0, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller =
        usePageController(keepPage: false, initialPage: initialPage);
    ref.listen<int>(appIndexProvider, (p, c) {
      controller.jumpToPage(c);
    });

    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          Home(),
          FavList(
            onBackPress: () =>
                ref.read(appIndexProvider.notifier).changeIndex(0),
          ),
          Profile(
            onBackPress: () =>
                ref.read(appIndexProvider.notifier).changeIndex(0),
          )
        ],
      ),
      floatingActionButton: CenterBottomButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNav(
        onChange: (a) {},
      ),
    );
  }
}
