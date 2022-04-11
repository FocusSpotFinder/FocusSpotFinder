import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/screens/admin/home/admin_home.dart';
import 'package:focus_spot_finder/screens/admin/issue/issues_list.dart';
import 'package:focus_spot_finder/screens/admin/profile/admin_profile.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_bottom_nav.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_center_bottom_button.dart';
import 'package:focus_spot_finder/screens/preAppLoad/app_index_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AdminAppPage extends HookConsumerWidget {
  final int initialPage;
  const AdminAppPage({this.initialPage = 0, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = usePageController(keepPage: false, initialPage: initialPage);
    ref.listen<int>(appIndexProvider, (p, c) {
      controller.jumpToPage(c);
    });

    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          AdminHome(),
          issuesList(
            onBackPress: () =>
                ref.read(appIndexProvider.notifier).changeIndex(0),
          ),
          AdminProfile(
            onBackPress: () =>
                ref.read(appIndexProvider.notifier).changeIndex(0),
          )
        ],
      ),
      floatingActionButton: AdminCenterBottomButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AdminBottomNav(
        onChange: (a) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (c) => AdminAppPage(initialPage: a,)),
                  (route) => false);
        },
      ),
    );
  }
}
