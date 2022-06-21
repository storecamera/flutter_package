import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

extension BehaviorSubjectExtension<T> on BehaviorSubject<T> {
  StreamBuilder<T> builder(
    AsyncWidgetBuilder<T> builder, {
    Key? key,
  }) =>
      StreamBuilder<T>(
        key: key,
        initialData: valueOrNull,
        stream: this,
        builder: builder,
      );

  StreamBuilder<T> builderNotnull(
    Widget Function(BuildContext context, T data) builder, {
    Widget Function(BuildContext context)? builderNullable,
    Key? key,
  }) =>
      StreamBuilder<T>(
        key: key,
        initialData: valueOrNull,
        stream: this,
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          final data = snapshot.data;
          if (data != null) {
            return builder(context, data);
          }
          return builderNullable?.call(context) ?? Container();
        },
      );

  SliverToBoxAdapter sliverToBoxAdapter(
    AsyncWidgetBuilder<T> builder, {
    Key? key,
  }) {
    return SliverToBoxAdapter(
      key: key,
      child: StreamBuilder<T>(
        key: key,
        initialData: valueOrNull,
        stream: this,
        builder: builder,
      ),
    );
  }
}
