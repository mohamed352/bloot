import 'package:flutter/material.dart';
import 'package:bloot/core/components/app_snack_bar.dart';
import 'package:bloot/core/components/dialogs/loading_dialog.dart';

extension DialogOnContext on BuildContext {
  Future<void> showLoadingDialog({String? message}) async {
    return LoadingDialog.show(this, message: message);
  }

  void dismissDialog() {
    if (Navigator.canPop(this)) {
      Navigator.pop(this);
    }
  }

  void showSnackbar(String message, {bool isError = false}) {
    AppSnackBar.show(
      this,
      message: message,
      type: isError ? AppSnackBarType.error : AppSnackBarType.success,
    );
  }
}
