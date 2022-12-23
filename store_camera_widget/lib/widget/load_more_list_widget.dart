import 'package:flutter/widgets.dart';

class LoadMoreListWidget<T> extends StatefulWidget {
  final LoadMoreController<T> controller;
  final Widget Function(BuildContext context, List<T>? list) sliverListBuilder;

  final Widget? more;
  final Widget? bottom;

  const LoadMoreListWidget({
    super.key,
    required this.controller,
    required this.sliverListBuilder,
    this.more,
    this.bottom,
  });

  @override
  State<LoadMoreListWidget> createState() => _LoadMoreListWidgetState();
}

class _LoadMoreListWidgetState extends State<LoadMoreListWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_setState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_setState);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LoadMoreListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_setState);
      widget.controller.addListener(_setState);
      _setState();
    }
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller.controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        widget.sliverListBuilder(context, widget.controller.list),
        if (widget.controller.loadMore && widget.more != null)
          SliverToBoxAdapter(
            child: widget.more,
          ),
        if (widget.bottom != null)
          SliverToBoxAdapter(
            child: widget.bottom,
          ),
      ],
    );
  }
}

typedef LoadMoreScrollControllerCallback<T> = Future<List<T>> Function();

class LoadMoreController<T> extends ChangeNotifier {
  final ScrollController controller = ScrollController();

  LoadMoreController() {
    controller.addListener(_scrollScrollControllerListener);
  }

  List<T>? get list => _list;
  List<T>? _list;
  set list(List<T>? value) {
    _list = value;
    notifyListeners();
  }

  bool get loadMore => _loadMore;
  bool _loadMore = false;

  LoadMoreScrollControllerCallback<T>? _onLoadMoreCallback;

  void setOnLoadMoreListener(LoadMoreScrollControllerCallback<T>? callback) {
    _onLoadMoreCallback = callback;
  }

  double? _maxScrollExtent;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _onLoadMoreCallback = null;
  }

  void resetState() {
    _maxScrollExtent = null;
    enableLoadMore = true;
    _loadMore = false;
    if (controller.hasClients) {
      controller.jumpTo(0);
    }
  }

  bool enableLoadMore = true;

  void _scrollScrollControllerListener() {
    if (enableLoadMore && !loadMore) {
      double maxScrollExtent = controller.position.maxScrollExtent;
      if (_maxScrollExtent != maxScrollExtent &&
          controller.position.maxScrollExtent - controller.offset < 100) {
        _maxScrollExtent = controller.position.maxScrollExtent;
        _loadMoreState();
      }
    }
  }

  Future<void> _loadMoreState() async {
    if (loadMore) {
      return;
    }

    final callback = _onLoadMoreCallback;
    if (callback != null) {
      _loadMore = true;
      notifyListeners();
      try {
        final list = await callback();
        _loadMore = false;

        if (list.isEmpty) {
          enableLoadMore = false;
          notifyListeners();
        } else {
          enableLoadMore = true;
          this.list = [...this.list ?? [], ...list];
        }
      } catch(_) {
        _loadMore = false;
        enableLoadMore = false;
        notifyListeners();
      }
    } else {
      enableLoadMore = false;
    }
  }
}