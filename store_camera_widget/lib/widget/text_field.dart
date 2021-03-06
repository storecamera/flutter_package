import 'package:flutter/material.dart';
import 'package:store_camera_widget/painting/edge_insets.dart';

Color textFieldIconColor(BuildContext context) {
  switch (Theme.of(context).brightness) {
    case Brightness.dark:
      return Colors.white70;
    case Brightness.light:
      return Colors.black45;
  }
}

class InputDecorationBorderNone extends InputDecoration {
  const InputDecorationBorderNone({
    super.icon,
    super.iconColor,
    super.label,
    super.labelText,
    super.labelStyle,
    super.floatingLabelStyle,
    super.helperText,
    super.helperStyle,
    super.helperMaxLines,
    super.hintText,
    super.hintStyle,
    super.hintTextDirection,
    super.hintMaxLines,
    super.errorText,
    super.errorStyle,
    super.errorMaxLines,
    super.floatingLabelBehavior,
    super.floatingLabelAlignment,
    super.isCollapsed = false,
    super.isDense,
    super.contentPadding,
    super.prefixIcon,
    super.prefixIconConstraints,
    super.prefix,
    super.prefixText,
    super.prefixStyle,
    super.prefixIconColor,
    super.suffixIcon,
    super.suffix,
    super.suffixText,
    super.suffixStyle,
    super.suffixIconColor,
    super.suffixIconConstraints,
    super.counter,
    super.counterText,
    super.counterStyle,
    super.filled,
    super.fillColor,
    super.focusColor,
    super.hoverColor,
    super.enabled = true,
    super.semanticCounterText,
    super.alignLabelWithHint,
    super.constraints,
  }) : super(
          border: InputBorder.none,
          enabledBorder: null,
          focusedBorder: null,
          disabledBorder: null,
          errorBorder: null,
          focusedErrorBorder: null,
        );
}

class InputDecorationOutlineInputBorder extends InputDecoration {
  const InputDecorationOutlineInputBorder({
    super.icon,
    super.iconColor,
    super.label,
    super.labelText,
    super.labelStyle,
    super.floatingLabelStyle,
    super.helperText,
    super.helperStyle,
    super.helperMaxLines,
    super.hintText,
    super.hintStyle,
    super.hintTextDirection,
    super.hintMaxLines,
    super.errorText,
    super.errorStyle,
    super.errorMaxLines,
    super.floatingLabelBehavior,
    super.floatingLabelAlignment,
    super.isCollapsed = false,
    super.isDense,
    super.contentPadding = const EdgeInsetsDynamic(horizontal: 8, vertical: 16),
    super.prefixIcon,
    super.prefixIconConstraints,
    super.prefix,
    super.prefixText,
    super.prefixStyle,
    super.prefixIconColor,
    super.suffixIcon,
    super.suffix,
    super.suffixText,
    super.suffixStyle,
    super.suffixIconColor,
    super.suffixIconConstraints,
    super.counter,
    super.counterText,
    super.counterStyle,
    super.filled,
    super.fillColor,
    super.focusColor,
    super.hoverColor,
    super.enabled = true,
    super.semanticCounterText,
    super.alignLabelWithHint,
    super.constraints,
  }) : super(
    border: const OutlineInputBorder(),
    enabledBorder: null,
    focusedBorder: null,
    disabledBorder: null,
    errorBorder: null,
    focusedErrorBorder: null,
  );
}

class ReadOnlyTextField extends StatefulWidget {
  final String text;
  final InputDecoration? decoration;
  final bool enabled;
  final TextAlign textAlign;
  final int minLines;
  final int maxLines;
  final TextAlignVertical? textAlignVertical;
  final GestureTapCallback? onTap;

  const ReadOnlyTextField({
    super.key,
    required this.text,
    this.decoration,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.minLines = 1,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  State<ReadOnlyTextField> createState() => _ReadOnlyTextFieldState();
}

class _ReadOnlyTextFieldState extends State<ReadOnlyTextField> {
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.text;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReadOnlyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != oldWidget.text) {
      textEditingController.text = widget.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      enabled: widget.enabled,
      decoration: widget.decoration ?? const InputDecoration(),
      controller: textEditingController,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onTap: widget.onTap,
    );
  }
}
