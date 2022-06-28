import 'package:flutter/material.dart';

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

class ReadOnlyTextField extends StatefulWidget {
  final String text;
  final InputDecoration? decoration;
  final bool enabled;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;

  const ReadOnlyTextField({
    super.key,
    required this.text,
    this.decoration,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.textAlignVertical
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
    );
  }
}
