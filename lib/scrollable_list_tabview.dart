library scrollable_list_tabview;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'model/scrollable_list_tab.dart';

export 'model/list_tab.dart';
export 'model/scrollable_list_tab.dart';

const Duration _kScrollDuration = const Duration(milliseconds: 150);

const SizedBox _kSizedBoxW8 = const SizedBox(width: 8.0);

class ScrollableListTabView extends StatefulWidget {
  /// Create a new [ScrollableListTabView]
  const ScrollableListTabView(
      {Key key,
      this.tabs,
      this.tabHeight = kToolbarHeight,
      this.withLabel = false,
      this.selectedDecoration = const BoxDecoration(color: Colors.black12),
      this.unselectedDecoration = const BoxDecoration(),
      this.padding = const EdgeInsets.all(0),
      this.tabAnimationDuration = _kScrollDuration,
      this.bodyAnimationDuration = _kScrollDuration,
      this.tabAnimationCurve = Curves.decelerate,
      this.bodyAnimationCurve = Curves.decelerate,
      this.isJump = true,
      this.tabMargin =
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      this.tabOpacityAnimationWeights = const [20, 20, 60],
      this.bodyOpacityAnimationWeights = const [20, 20, 60]})
      : assert(tabAnimationDuration != null, bodyAnimationDuration != null),
        assert(tabAnimationCurve != null, bodyAnimationCurve != null),
        assert(tabHeight != null),
        assert(tabs != null),
        super(key: key);

  /// List of tabs to be rendered.
  final List<ScrollableListTab> tabs;

  /// Height of the tab at the top of the view.
  final double tabHeight;

  final bool withLabel;

  final bool isJump;

  final EdgeInsetsGeometry tabMargin;

  /// Duration of tab change animation.
  final Duration tabAnimationDuration;

  /// Duration of inner scroll view animation.
  final Duration bodyAnimationDuration;

  /// Animation curve used when animating tab change.
  final Curve tabAnimationCurve;

  final EdgeInsets padding;

  final BoxDecoration selectedDecoration;

  final BoxDecoration unselectedDecoration;

  /// Animation curve used when changing index of inner [ScrollView]s.
  final Curve bodyAnimationCurve;

  /// See more information in [ItemScrollController.scrollTo(opacityAnimationWeights)]
  final List<double> tabOpacityAnimationWeights;

  final List<double> bodyOpacityAnimationWeights;

  @override
  _ScrollableListTabViewState createState() => _ScrollableListTabViewState();
}

class _ScrollableListTabViewState extends State<ScrollableListTabView> {
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  final ItemScrollController _bodyScrollController = ItemScrollController();
  final ItemPositionsListener _bodyPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController _tabScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _bodyPositionsListener.itemPositions.addListener(_onInnerViewScrolled);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.tabs.length > 1)
          Container(
            height: widget.tabHeight,
            color: Theme.of(context).cardColor,
            child: ScrollablePositionedList.builder(
              itemCount: widget.tabs.length,
              scrollDirection: Axis.horizontal,
              physics: ClampingScrollPhysics(),
              itemScrollController: _tabScrollController,
              padding: widget.padding,
              itemBuilder: (context, index) {
                return ValueListenableBuilder<int>(
                    valueListenable: _index,
                    builder: (_, i, __) {
                      var selected = index == i;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final lastIndexOnScreen = _bodyPositionsListener
                                  .itemPositions.value.last.index ==
                              _index.value;
                          _onTabPressed(
                              index: index,
                              lastIndexOnScreen: lastIndexOnScreen);
                        },
                        child: Container(
                          height: 32,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          margin: widget.tabMargin,
                          decoration: selected
                              ? widget.selectedDecoration
                              : widget.unselectedDecoration,
                          child: _buildTab(index, selected),
                        ),
                      );
                    });
              },
            ),
          ),
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: _bodyScrollController,
            itemPositionsListener: _bodyPositionsListener,
            physics: ClampingScrollPhysics(),
            itemCount: widget.tabs.length,
            itemBuilder: (_, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.withLabel)
                  Padding(
                    padding: widget.tabMargin.add(const EdgeInsets.all(5.0)),
                    child: _buildInnerTab(index),
                  ),
                Flexible(
                  child: widget.tabs[index].body,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInnerTab(int index) {
    var tab = widget.tabs[index].tab;
    var textStyle = Theme.of(context)
        .textTheme
        .bodyText1
        .copyWith(fontWeight: FontWeight.w500);
    return Builder(
      builder: (_) {
        if (tab.icon == null) return tab.label;
        if (!tab.showIconOnList)
          return DefaultTextStyle(style: textStyle, child: tab.label);
        return DefaultTextStyle(
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.w500),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [tab.icon, _kSizedBoxW8, tab.label],
          ),
        );
      },
    );
  }

  Widget _buildTab(int index, bool selected) {
    var tab = widget.tabs[index].tab;
    if (tab.icon == null) return selected ? tab.label : tab.inactiveLabel;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        tab.icon,
        _kSizedBoxW8,
        selected ? tab.label : tab.inactiveLabel
      ],
    );
  }

  void _onInnerViewScrolled() async {
    var positions = _bodyPositionsListener.itemPositions.value;

    /// Target [ScrollView] is not attached to any views and/or has no listeners.
    if (positions == null || positions.isEmpty) return;

    /// Capture the index of the first [ItemPosition]. If the saved index is same
    /// with the current one do nothing and return.
    var firstIndex =
        _bodyPositionsListener.itemPositions.value.elementAt(0).index;
    if (_index.value == firstIndex) return;

    /// A new index has been detected.
    await _handleTabScroll(firstIndex);

    // final firstIndex = _bodyPositionsListener.itemPositions.value.first.index;
    // final lastIndex = _bodyPositionsListener.itemPositions.value.last.index;
    // final lastIndexOnScreen =
    //     _bodyPositionsListener.itemPositions.value.last.index == _index.value;
    // if ((_index.value == firstIndex) ||
    //     lastIndexOnScreen && (_index.value == lastIndex)) return;
    //
    // /// A new index has been detected.
    // await _handleTabScroll(lastIndex);
  }

  Future<void> _handleTabScroll(int index) async {
    _index.value = index;
    if (widget.isJump) {
      _tabScrollController.jumpTo(
          index: _index.value,
          alignment: index < widget.tabs.length / 2 ? 0 : 0.75);
    } else {
      await _tabScrollController.scrollTo(
          index: _index.value,
          duration: widget.tabAnimationDuration,
          curve: widget.tabAnimationCurve);
      //opacityAnimationWeights: widget.tabOpacityAnimationWeights);
    }
    return;
  }

  /// When a new tab has been pressed both [_tabScrollController] and
  /// [_bodyScrollController] should notify their views.
  void _onTabPressed(
      {@required int index, @required bool lastIndexOnScreen}) async {
    if (widget.isJump) {
      _tabScrollController.jumpTo(
          index: index, alignment: index < widget.tabs.length / 2 ? 0 : 0.75);
      _bodyScrollController.jumpTo(index: index);
    } else {
      await _tabScrollController.scrollTo(
          index: index,
          duration: widget.tabAnimationDuration,
          curve: widget.tabAnimationCurve);
      //opacityAnimationWeights: widget.tabOpacityAnimationWeights);
      await _bodyScrollController.scrollTo(
          index: index,
          //alignment: !lastIndexOnScreen ? 0 : -0.2,
          duration: widget.bodyAnimationDuration,
          curve: widget.bodyAnimationCurve);
      //opacityAnimationWeights: widget.bodyOpacityAnimationWeights);
    }
    _index.value = index;
    return;
  }

  @override
  void dispose() {
    _bodyPositionsListener.itemPositions.removeListener(_onInnerViewScrolled);
    return super.dispose();
  }
}
