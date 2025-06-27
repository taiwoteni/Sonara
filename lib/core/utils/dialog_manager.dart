import 'package:flutter/material.dart';

class DialogManager {
  /// Shows a simple alert dialog with a title, content, and customizable actions.
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
    List<DialogAction> actions = const [],
    bool barrierDismissible = true,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          backgroundColor: Colors.grey[900],
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 16.0,
          ),
          actions: actions.isNotEmpty
              ? actions.map((action) {
                  return TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (action.onPressed != null) {
                        action.onPressed!();
                      }
                    },
                    child: Text(
                      action.label,
                      style: TextStyle(color: action.color ?? Colors.white),
                    ),
                  );
                }).toList()
              : [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
        );
      },
    );
  }

  /// Shows a custom dialog with a provided widget as content.
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// Pops the current dialog if one is showing.
  static void popDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// Represents an action button in a dialog.
class DialogAction {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const DialogAction({required this.label, this.onPressed, this.color});
}
