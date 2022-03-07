import 'package:hooks_riverpod/hooks_riverpod.dart';

final appIndexProvider = StateNotifierProvider<AppIndexNotifier, int>((ref) {
  return AppIndexNotifier();
});

class AppIndexNotifier extends StateNotifier<int> {
  AppIndexNotifier() : super(0);

  void changeIndex(int index) {
    state = index;
  }
}
