//////////////////////////////////////////////////////////////////////
/// import
//////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:tflite_app/components/style.dart';

//////////////////////////////////////////////////////////////////////
/// Show Modal Window
//////////////////////////////////////////////////////////////////////

Future<dynamic> showModalWindow(
  BuildContext context,
  double height,
  Widget child,
) {
  return showModalBottomSheet(
    useRootNavigator: true,
    //モーダルの背景の色、透過
    backgroundColor: Colors.transparent,
    //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
    isScrollControlled: true,
    context: context,
    constraints: const BoxConstraints(
      maxWidth: double.infinity,
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 100,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * height - 40,
                  width: MediaQuery.of(context).size.width,
                  child: child,
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

//////////////////////////////////////////////////////////////////////
/// Show Modal Window の中身の Widget を作るやつ
//////////////////////////////////////////////////////////////////////

Widget buildModalWindowContainer(
  BuildContext context,
  list,
  double height,
  Function(BuildContext, int) onTapped, [
  Text? title,
  bool? fadeout,
]) {
  return LayoutBuilder(
    builder: (context, constraint) {
      return Column(
        children: [
          (title != null)
              ? SizedBox(
                  height: 40,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: title,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                )
              : Container(),
          SizedBox(
            height: MediaQuery.of(context).size.height * height - 40,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    ListTile(
                      title: (list.runtimeType == List<String>)
                          ? Text(
                              list[index],
                              style: Styles.defaultStyle13,
                              textAlign: TextAlign.center,
                            )
                          : list[index],
                      onTap: () {
                        onTapped(context, index);
                        if (fadeout == null || fadeout == true) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const Divider(thickness: 2),
                  ],
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
