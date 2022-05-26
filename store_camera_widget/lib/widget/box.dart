import 'package:flutter/widgets.dart';

class ColumnBox extends SizedBox {
  const ColumnBox(double height, {Key? key, Widget? child})
      : super(key: key, height: height, child: child);
}

class RowBox extends SizedBox {
  const RowBox(double width, {Key? key, Widget? child})
      : super(key: key, width: width, child: child);
}
