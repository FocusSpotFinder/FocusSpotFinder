import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/screens/app/addPlace/add_place.dart';


class CenterBottomButton extends HookWidget {
  const CenterBottomButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isClicked = useState(false);

    return FloatingActionButton(
      onPressed: () {},
      child: Theme(
        data: Theme.of(context).copyWith(
          cardColor: Colors.white60,
        ),
        child: PopupMenuButton(
            offset: const Offset(-35, -100),
            icon: Image.asset('assets/logo.png', fit: BoxFit.cover, height: 40),
            onCanceled: () {
              isClicked.value = false;
            },
            onSelected: (value) {
              isClicked.value = false;

              if (value == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPlace()),
                );
              }

              print('pop up clicked');
            },
            itemBuilder: (context) {
              isClicked.value = false;
              return [
                PopupMenuItem(
                  child: Center(
                    child: Text(
                      'Add Place',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  value: 0,
                ),
              ];
            }),
      ),
      backgroundColor: Colors.white,
    );
  }
}
