library scrollable_list_tabview;

import 'dart:io';

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
      this.selectedDecoration = const BoxDecoration(color: Colors.black),
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
  final ItemPositionsListener _tabPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController _tabScrollController = ItemScrollController();
  @override
  void initState() {
    super.initState();
    _bodyPositionsListener.itemPositions.addListener(_onInnerViewScrolled);
  }

  int getFirstIndex() {
    return _bodyPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge > 0)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;
  }

  @override
  Widget build(BuildContext context) {
    Shader shaderCallback(rect) {
      return LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white,
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(0),
          Colors.white,
        ],
        stops: [0.015, 0.06, 0.94, 0.9850],
      ).createShader(rect);
    }

    return Column(
      children: [
        if (widget.tabs.length > 1)
          Container(
            height: widget.tabHeight,
            color: Theme.of(context).cardColor,
            child: ShaderMask(
              shaderCallback: shaderCallback,
              blendMode: BlendMode.exclusion,
              child: ScrollablePositionedList.builder(
                itemPositionsListener: _tabPositionsListener,
                itemCount: widget.tabs.length,
                scrollDirection: Axis.horizontal,
                physics: Platform.isAndroid
                    ? ClampingScrollPhysics()
                    : BouncingScrollPhysics(),
                itemScrollController: _tabScrollController,
                padding: widget.padding,
                itemBuilder: (context, index) {
                  return ValueListenableBuilder<int>(
                      valueListenable: _index,
                      builder: (_, i, __) {
                        var selected = index == i;
                        return Container(
                          margin: EdgeInsets.only(
                              left: index == 0 ? 12 : 0,
                              right: index == widget.tabs.length - 1 ? 12 : 0),
                          child: GestureDetector(
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
                          ),
                        );
                      });
                },
              ),
            ),
          ),
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: _bodyScrollController,
            itemPositionsListener: _bodyPositionsListener,
            physics: Platform.isAndroid
                ? ClampingScrollPhysics()
                : BouncingScrollPhysics(),
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

    // Custom fix https://github.com/google/flutter.widgets/issues/124#issuecomment-633248979
    var firstIndex = getFirstIndex();
    if (_index.value == firstIndex) return;

    /// A new index has been detected.
    await _handleTabScroll(firstIndex);
  }

  Future<void> _handleTabScroll(int index) async {
    _index.value = index;

    final itemPositions = _tabPositionsListener.itemPositions.value;
    ItemPosition currentItem;
    try {
      currentItem =
          itemPositions.firstWhere((element) => element.index == index);
    } catch (e) {}
    if (widget.isJump) {
      if (currentItem != null) {
        final centerAlignment = 0.5 -
            (currentItem.itemTrailingEdge - currentItem.itemLeadingEdge) / 2;
        final endAlignment =
            1 - (currentItem.itemTrailingEdge - currentItem.itemLeadingEdge);
        final haveFirst = itemPositions.first.index == 0;
        final haveLast = itemPositions.last.index == widget.tabs.length - 1;
        double alignment;
        if (haveFirst) {
          bool isFullSeen = itemPositions.first.itemLeadingEdge >= 0 &&
              itemPositions.first.itemTrailingEdge <= 1;
          if (isFullSeen) {
            if (currentItem.itemTrailingEdge > 1) {
              alignment = centerAlignment;
            } else {
              return;
            }
          }
          alignment = centerAlignment;
        } else if (haveLast) {
          bool isFullSeen = itemPositions.last.itemLeadingEdge >= 0 &&
              itemPositions.last.itemTrailingEdge <= 1;
          if (isFullSeen) {
            if (currentItem.itemLeadingEdge < 0) {
              alignment = centerAlignment;
            } else {
              return;
            }
          }
          alignment = centerAlignment;
        } else {
          if (itemPositions.first.index == widget.tabs.length - 1) {
            alignment = endAlignment;
          } else if (itemPositions.last.index == 0) {
            if (index == 0 && currentItem.index == 0) {
              alignment = 0;
            } else {
              alignment = centerAlignment;
            }
          } else {
            alignment = centerAlignment;
          }
        }
        _tabScrollController.jumpTo(index: _index.value, alignment: alignment);
      } else {
        _tabScrollController.jumpTo(
            index: _index.value,
            alignment: index <= widget.tabs.length / 2
                ? 0
                : 1 -
                    (itemPositions.last.itemTrailingEdge -
                        itemPositions.last.itemLeadingEdge));
      }
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
    final itemPositions = _tabPositionsListener.itemPositions.value;
    final currentItem =
        itemPositions.firstWhere((element) => element.index == index);
    final centerAlignment =
        0.5 - (currentItem.itemTrailingEdge - currentItem.itemLeadingEdge) / 2;
    final endAlignment =
        1 - (currentItem.itemTrailingEdge - currentItem.itemLeadingEdge);
    final haveFirst = itemPositions.first.index == 0;
    final isFirst = currentItem.index == 0;
    final haveLast = itemPositions.last.index == widget.tabs.length - 1;
    final isLast = currentItem.index == itemPositions.last.index;
    double alignment;
    if (widget.isJump) {
      if (haveFirst) {
        bool isFullSeen = itemPositions.first.itemLeadingEdge >= 0 &&
            itemPositions.first.itemTrailingEdge <= 1;
        if (isFullSeen) {
          if (currentItem.itemTrailingEdge > 1) {
            alignment = centerAlignment;
          } else {
            _bodyScrollController.jumpTo(index: index);
            return;
          }
        }
        if (isFirst) {
          alignment = 0;
        } else {
          alignment = centerAlignment;
        }
      } else if (haveLast) {
        bool isFullSeen = itemPositions.last.itemLeadingEdge >= 0 &&
            itemPositions.last.itemTrailingEdge <= 1;
        if (isFullSeen) {
          if (currentItem.itemLeadingEdge < 0) {
            alignment = centerAlignment;
          } else {
            _bodyScrollController.jumpTo(index: index);
            return;
          }
        }
        if (isLast) {
          alignment =
              1 - (currentItem.itemTrailingEdge - currentItem.itemLeadingEdge);
        } else {
          alignment = centerAlignment;
        }
      } else {
        if (itemPositions.first.index == widget.tabs.length - 1) {
          alignment = endAlignment;
        } else if (itemPositions.last.index == 0) {
          if (index == 0 && currentItem.index == 0) {
            alignment = 0;
          } else {
            alignment = centerAlignment;
          }
        } else {
          alignment = centerAlignment;
        }
      }
      _tabScrollController.jumpTo(index: index, alignment: alignment);
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
