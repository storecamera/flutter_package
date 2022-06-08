import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:store_camera_widget/painting/edge_insets.dart';

typedef DatePickerChanged = void Function(DateTime value);
typedef DatePickerDeleted = void Function();
typedef DatePickerToString = String Function(DateTime? value);

class DatePickerWidget extends StatefulWidget {
  final DateTime? value;
  final String? labelText;
  final String? errorText;
  final String? dateSeparator;
  final double? maxWidth;
  final bool enabled;

  final DateTime? firstDate;
  final DateTime? lastDate;
  final DatePickerChanged onChanged;
  final DatePickerDeleted? onDeleted;
  final DatePickerToString? onDateToString;

  const DatePickerWidget({
    super.key,
    this.value,
    this.labelText,
    this.errorText,
    this.dateSeparator,
    this.maxWidth,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.onDateToString,
    required this.onChanged,
    this.onDeleted,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePickerWidget> {
  final TextEditingController _controller = TextEditingController();

  void _setDateTimeToController(DateTime? dateTime) {
    _controller.text =
        widget.onDateToString?.call(dateTime) ?? dateTime?.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();
    _setDateTimeToController(widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DatePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _setDateTimeToController(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enabled: widget.enabled,
      decoration: InputDecoration(
          constraints: widget.maxWidth != null
              ? BoxConstraints(maxWidth: widget.maxWidth!)
              : null,
          contentPadding: EdgeInsetsDynamic(
              start: 8, end: widget.onDeleted != null ? 0 : 8, vertical: 4),
          labelText: widget.labelText,
          errorText: widget.errorText,
          suffix: widget.onDeleted != null
              ? IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: const EdgeInsetsDynamic(start: 4, vertical: 4),
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: widget.onDeleted,
                )
              : null),
      controller: _controller,
      textAlign: TextAlign.center,
      onTap: () async {
        if (widget.enabled) {
          try {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: widget.value ?? DateTime.now(),
              firstDate: widget.firstDate ?? DateTime(1900),
              lastDate: widget.lastDate ?? DateTime(2100),
              fieldHintText: '',
              fieldLabelText: widget.labelText,
            );

            if (picked != null) {
              widget.onChanged(picked.toUtc());
            }
          } catch (e) {
            if (kDebugMode) {
              print('DateTimePickerWidget error: $e');
            }
          }
        }
      },
    );
  }
}
