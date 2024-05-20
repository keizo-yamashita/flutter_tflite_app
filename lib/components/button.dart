////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:tflite_app/components/style.dart';

////////////////////////////////////////////////////////////////////////////////////////////
///  ページ上部のツールボタン作成に使用
////////////////////////////////////////////////////////////////////////////////////////////

class ToolButton extends StatelessWidget {
  final IconData icon;
  final bool pressEnable;
  final double width;
  final bool offEnable;
  final Function? onPressed;
  final Function? onLongPressed;

  const ToolButton({
    Key? key,
    required this.icon,
    required this.pressEnable,
    required this.width,
    this.offEnable = false,
    this.onPressed,
    this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    int invValue = (bgColor.value & 0xFF000000) | (~bgColor.value & 0x00FFFFFF);
    Color invBgColor = Color(invValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: SizedBox(
        width: width,
        height: 30,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            // elevation: 1.0,
            shadowColor: invBgColor,
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(
              color: pressEnable ? Styles.primaryColor : Styles.hiddenColor,
            ),
          ),
          onPressed: onPressed as void Function()?,
          onLongPress: onLongPressed as void Function()?,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: pressEnable ? Styles.primaryColor : Styles.hiddenColor,
                size: 20,
              ),
              offEnable
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CustomPaint(
                        painter: SlashPainter(
                          lineColor:
                              pressEnable ? Styles.primaryColor : Colors.grey,
                          backgroundColor: bgColor,
                          downRight: true,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////
///  Auto-Fill UI 作成に使用するテキストボタンを構築
/////////////////////////////////////////////////////////////////////////////////

class CustomTextButton extends StatelessWidget {
  final IconData? icon;
  final String    text;
  final Color     backgroundColor;
  final bool      enable;
  final double    width;
  final double    height;
  final Function  onPressed;

  const CustomTextButton({
    Key? key,
    this.icon,
    required this.text,
    required this.backgroundColor,
    required this.enable,
    required this.width,
    required this.height,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shadowColor: Styles.hiddenColor,
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                side: BorderSide(
                  color: enable ? Styles.primaryColor : Styles.hiddenColor,
                ),
                backgroundColor: enable ? backgroundColor : Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
              ),
              onPressed: onPressed as void Function()?,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                  SizedBox(width: width*0.05),
                  FittedBox(
                    fit: BoxFit.fill,
                    child: Text(text, style: enable ? Styles.defaultStyleGreen13 : Styles.defaultStyleGrey13),
                  ),
                ],
              ),
            ),
          ),
        if (icon != null)
          Positioned(
            left: 5,
            child: Icon(
              icon!,
              size: 20,
              color: enable ? Styles.primaryColor : Styles.hiddenColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Icon icon;
  final bool enable;
  final double width;
  final double height;
  final Function action;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.enable,
    required this.width,
    required this.height,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shadowColor: Styles.hiddenColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          side: BorderSide(
            color: enable ? Styles.primaryColor : Styles.hiddenColor,
          ),
        ),
        onPressed: action as void Function()?,
        child: icon,
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////
///  ページ下部の切り替えボタン作成に使用
/////////////////////////////////////////////////////////////////////////////////

class BottomButton extends StatelessWidget {
  final Widget content;
  final bool enable;
  final double width;
  final double height;
  final Function? onPressed;
  final Function? onLongPressed;

  const BottomButton({
    Key? key,
    required this.content,
    required this.enable,
    required this.width,
    required this.height,
    this.onPressed,
    this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    int invValue = (bgColor.value & 0xFF000000) | (~bgColor.value & 0x00FFFFFF);
    Color invBgColor = Color(invValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            // elevation: 2.0,          // enableがtrueの場合は影をつける
            shadowColor: invBgColor, // 影の色を設定
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(
              color: enable ? Styles.primaryColor : Styles.hiddenColor,
            ),
          ),
          onPressed: onPressed as void Function()?,
          onLongPress: onLongPressed as void Function()?,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: content,
          ),
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////
// DiagonalLinePainter Class
// ... 斜線を引くためのクラス
/////////////////////////////////////////////////////////////////////////////////

class SlashPainter extends CustomPainter {
  final Color lineColor;
  final Color backgroundColor;
  final bool downRight;

  const SlashPainter({
    this.lineColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.downRight = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = backgroundColor;
    paint.strokeWidth = 3.5;
    _drawLine(canvas, size, paint);

    paint.color = lineColor;
    paint.strokeWidth = 1.5;
    _drawLine(canvas, size, paint);
  }

  // 線を描画するヘルパーメソッド
  void _drawLine(Canvas canvas, Size size, Paint paint) {
    if (downRight) {
      canvas.drawLine(
          const Offset(0, 0), Offset(size.width, size.height), paint);
    } else {
      canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SlashPainter oldDelegate) {
    return false;
  }
}
