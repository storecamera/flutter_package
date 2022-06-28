import 'package:flutter/widgets.dart';

class ColumnBox extends SizedBox {
  const ColumnBox(double height, {Key? key, Widget? child})
      : super(key: key, height: height, child: child);
}

const columnBox32 = ColumnBox(32);

const columnBox16 = ColumnBox(16);

const columnBox8 = ColumnBox(8);

const columnBox4 = ColumnBox(4);

class RowBox extends SizedBox {
  const RowBox(double width, {Key? key, Widget? child})
      : super(key: key, width: width, child: child);
}

const rowBox32 = RowBox(32);

const rowBox16 = RowBox(16);

const rowBox8 = RowBox(8);

const rowBox4 = RowBox(4);
