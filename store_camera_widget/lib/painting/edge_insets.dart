import 'package:flutter/widgets.dart' show EdgeInsetsDirectional;

class EdgeInsetsDynamic extends EdgeInsetsDirectional {
  const EdgeInsetsDynamic(
      {double? all,
      double? vertical,
      double? horizontal,
      double? start,
      double? top,
      double? end,
      double? bottom})
      : super.only(
          start: start ?? (horizontal ?? (all ?? 0)),
          end: end ?? (horizontal ?? (all ?? 0)),
          top: top ?? (vertical ?? (all ?? 0)),
          bottom: bottom ?? (vertical ?? (all ?? 0)),
        );
}

const EdgeInsetsDynamic pagePadding = EdgeInsetsDynamic(horizontal: 16, vertical: 8);

const EdgeInsetsDynamic contentPadding = EdgeInsetsDynamic(horizontal: 8, vertical: 4);
