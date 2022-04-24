import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/screens/app/setUp/bottom_nav.dart';
import 'package:focus_spot_finder/screens/app/setUp/center_bottom_button.dart';
import 'package:focus_spot_finder/screens/preAppLoad/app_index_provider.dart';
import 'package:focus_spot_finder/screens/app/favoriteList/favorite_list.dart';
import 'package:focus_spot_finder/screens/app/home/home.dart';
import 'package:focus_spot_finder/screens/app/profile/profile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppPage extends HookConsumerWidget {
  final int initialPage;
  const AppPage({this.initialPage = 0, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = usePageController(keepPage: false, initialPage: initialPage);
    ref.listen<int>(appIndexProvider, (p, c) {
      controller.jumpToPage(c);
    });

    //construct the page view for the user
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
        onChange: (a) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (c) => AppPage(initialPage: a,)),
                  (route) => false);
        },
      ),
    );
  }
}
