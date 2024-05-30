import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({required String message}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Color(0xFFFFEB3B),
    textColor: Colors.black,
    fontSize: 16,
    webBgColor: "yellow",
    webPosition: "center",
  );
}
