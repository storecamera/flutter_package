import 'package:flutter/material.dart';

typedef TextFieldFocusCompleteCallback = void Function(String value);
typedef TextFieldFocusCompleteWidgetBuilder = Widget Function(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode);

class TextFieldFocusCompleteBuilder extends StatefulWidget {
  final String text;
  final TextFieldFocusCompleteCallback onFocusComplete;
  final TextFieldFocusCompleteWidgetBuilder builder;

  const TextFieldFocusCompleteBuilder({
    super.key,
    required this.text,
    required this.onFocusComplete,
    required this.builder,
  });

  @override
  State<TextFieldFocusCompleteBuilder> createState() =>
      _TextFieldFocusCompleteBuilderState();
}

class _TextFieldFocusCompleteBuilderState
    extends State<TextFieldFocusCompleteBuilder> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _controller.text = widget.text;
    _controller.addListener(_setState);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.text != _controller.text) {
        widget.onFocusComplete(_controller.text);
      }
      _setState();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TextFieldFocusCompleteBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != oldWidget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller, _focusNode);
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}
