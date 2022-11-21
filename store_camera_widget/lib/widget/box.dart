import 'package:flutter/widgets.dart';

class ColumnBox extends SizedBox {
  const ColumnBox(double height, {Key? key, Widget? child})
      : super(key: key, height: height, child: child);
}

const columnBox1 = ColumnBox(1);
const columnBox2 = ColumnBox(2);
const columnBox4 = ColumnBox(4);
const columnBox6 = ColumnBox(6);
const columnBox8 = ColumnBox(8);
const columnBox10 = ColumnBox(10);
const columnBox12 = ColumnBox(12);
const columnBox15 = ColumnBox(15);
const columnBox16 = ColumnBox(16);
const columnBox18 = ColumnBox(18);
const columnBox20 = ColumnBox(20);
const columnBox24 = ColumnBox(24);
const columnBox32 = ColumnBox(32);

class RowBox extends SizedBox {
  const RowBox(double width, {Key? key, Widget? child})
      : super(key: key, width: width, child: child);
}

const rowBox1 = RowBox(1);
const rowBox2 = RowBox(2);
const rowBox4 = RowBox(4);
const rowBox6 = RowBox(6);
const rowBox8 = RowBox(8);
const rowBox10 = RowBox(10);
const rowBox12 = RowBox(12);
const rowBox15 = RowBox(15);
const rowBox16 = RowBox(16);
const rowBox18 = RowBox(18);
const rowBox20 = RowBox(20);
const rowBox24 = RowBox(24);
const rowBox32 = RowBox(32);
