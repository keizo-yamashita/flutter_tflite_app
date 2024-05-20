////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// my package
import 'package:tflite_app/main.dart';
import 'package:tflite_app/components/snackbar.dart';
import 'package:tflite_app/components/style.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 登録の確認ダイアログ (確認機能付き)
/// title : タイトルの文章
/// message1 : 確認メッセージ
/// message2 : OK選択時に表示するメッセージ
/// onAccept : OK選択時に実行する関数
////////////////////////////////////////////////////////////////////////////////////////////

Future<bool> showConfirmDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required String message1,
  required String message2,
  required Function onAccept,
  bool confirm = false,
  bool error = false,
}) async {
  ref.read(settingProvider).loadPreferences();
  bool isDark = ref.read(settingProvider).enableDarkTheme;

  bool accepted = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return Theme(
        data: isDark ? ThemeData.dark() : ThemeData.light(),
        child: CupertinoAlertDialog(
          title: Text(
            '$title\n',
            style:
                error ? Styles.defaultStyleRed15 : Styles.defaultStyleGreen15,
          ),
          content: Text(
            message1,
            style: Styles.defaultStyle13
          ),
          actions: <Widget>[
            // Apply Button
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: Styles.defaultStyleGreen15,
              ),
              onPressed: () {
                onAccept();
                Navigator.pop(dialogContext);
                accepted = true;
                if (confirm) {
                  showSnackBar(context: context, message: message2, type: SnackBarType.info);
                }
              },
            ),
            // Canncel Button
            CupertinoDialogAction(
              child: Text('Cancel', style: Styles.defaultStyleRed15),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      );
    },
  );

  return accepted;
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 確認ボタン押すだけのダイアログ (OKボタンのみ)
/// title : タイトルの文章 message : 確認メッセージ
////////////////////////////////////////////////////////////////////////////////////////////

void showAlertDialog(
  BuildContext context,
  WidgetRef ref,
  String title,
  String message,
  bool error,
) {
  ref.read(settingProvider).loadPreferences();

  bool isDark = ref.read(settingProvider).enableDarkTheme;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: isDark ? ThemeData.dark() : ThemeData.light(),
        child: CupertinoAlertDialog(
          title: Text(
            '$title\n',
            style: (!error)
                ? Styles.defaultStyleGreen15
                : Styles.defaultStyleRed15,
          ),
          content: Text(
            message,
            style: Styles.defaultStyle13,
          ),
          actions: <Widget>[
            // Apply Button
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: (!error)
                    ? Styles.defaultStyleGreen15
                    : Styles.defaultStyleRed15,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
    },
  );
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 選択ダイアログ (Futureで押された値を返す)
/// title : タイトルの文章 message : 選択のためのヒント
////////////////////////////////////////////////////////////////////////////////////////////

Future<int?> showSelectDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String message,
    required List<String> options,
    required List<bool> error,
  }) async {
  int? selectedOption;

  ref.read(settingProvider).loadPreferences();
  bool isDark = ref.read(settingProvider).enableDarkTheme;

  await showDialog(
    context: context,
    barrierColor:
        isDark ? Colors.grey.withOpacity(0.1) : Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return Theme(
        data: isDark ? ThemeData.dark() : ThemeData.light(),
        child: CupertinoAlertDialog(
          title: Text(
            '$title\n',
            style: Styles.defaultStyleGreen15,
          ),
          content: Column(
            children: [
              for (int i = 0; i < options.length; i++)
                CupertinoDialogAction(
                  child: Text(
                    options[i],
                    style: error[i] ? Styles.defaultStyleRed13 : isDark ? Styles.defaultStyleWhite13 : Styles.defaultStyleBlack13,
                  ),
                  onPressed: () {
                    selectedOption = i;
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );

  return selectedOption;
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 選択ダイアログ (Futureで値押された値を返す)
/// title : タイトルの文章 message : 選択のためのヒント
////////////////////////////////////////////////////////////////////////////////////////////

Future<int?> showInfoDialog(
  BuildContext context,
  WidgetRef ref,
  String title,
  Widget description,
) async {
  int? selectedOption;
  ref.read(settingProvider).loadPreferences();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, _) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            title: Text(
              title,
              style: Styles.defaultStyleGreen20,
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.90,
              child: SingleChildScrollView(
                child: description,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('閉じる'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );

  return selectedOption;
}
