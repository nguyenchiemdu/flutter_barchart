import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

const kDefaultBarDecoration = BoxDecoration(
    color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(5)));
const kIndicatorTextStyle = TextStyle(fontSize: 10);
const kTitleTextStyle = TextStyle(fontSize: 12);
typedef ValueFunc<T> = double Function(T);
typedef TitleFunc<T> = String Function(T);
typedef LineTextFormat<T> = String Function(double);
typedef OnBarTapFunc<T> = void Function(T)?;

class BarChartWrapper<T> extends StatefulWidget {
  const BarChartWrapper(
      {required this.listBar,
      this.paddingBottom = 0,
      this.paddingTop = 0,
      this.barWidth = 20,
      this.barMargin = 20,
      this.barPaddingLeft = 30,
      this.indicatorTextStyle = kIndicatorTextStyle,
      this.titleTextStyle = kTitleTextStyle,
      this.barDecoration = kDefaultBarDecoration,
      this.lineColor = Colors.grey,
      required this.indicatorBuilder,
      required this.getTitle,
      required this.getValue,
      required this.lineTextFormat,
      this.onBarTap,
      Key? key})
      : super(key: key);
  final List<T> listBar;
  final double paddingTop;
  final double paddingBottom;
  final double barWidth;
  final double barMargin;
  final double barPaddingLeft;

  /// Builder for value on the top of Barchart when tapped
  final TitleFunc<T> indicatorBuilder;

  /// Function for format indicator line in the background of
  final LineTextFormat lineTextFormat;

  /// Text style of indicator
  final TextStyle indicatorTextStyle;

  /// Text style of title
  final TextStyle titleTextStyle;

  /// Style of bar chart
  final BoxDecoration barDecoration;
  final OnBarTapFunc<T> onBarTap;

  /// Function to get Value of Bar Chart
  final ValueFunc<T> getValue;

  /// Function to get Title of Bar Chart
  final TitleFunc<T> getTitle;

  /// Indicator line Color
  final Color lineColor;

  @override
  State<BarChartWrapper<T>> createState() => _BarChartWrapperState();
}

class _BarChartWrapperState<T> extends State<BarChartWrapper<T>> {
  // max height of widget
  late double maxHeight;
  // max width of widget
  late double maxWidth;
  // the number of indicator line
  late int maxLine;
  // the round value of the max values among of bars
  late double maxRoundValue;
  // the value between two indicator
  late double spacer;
  // the actually height of spacer in screen
  late double spacerHeight;

  /// list of bar
  late List<T> listBar = widget.listBar;
  late double paddingBottom = widget.paddingBottom;
  late double paddingTop = widget.paddingTop;
  // space between two bars
  late double barMargin = widget.barMargin;
  // the minimun width of text indicator
  late double indicatorTextWidth;
  // the value between two indicator but rounded
  late int base;
  final StreamController<int> _tappedIndexController = StreamController<int>();
  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    _tappedIndexController.close();
    super.dispose();
  }

  void initData() {
    // get max value among of list Bar
    double maxValue = 0;
    for (T bar in listBar) {
      if (widget.getValue(bar) > maxValue) {
        maxValue = widget.getValue(bar);
      }
    }
    // calculate Base
    base = pow(10, (maxValue.toInt()).toString().length - 1) as int;
    maxLine = (maxValue ~/ base) + 1;
    maxRoundValue = maxValue - maxValue % base;
    spacer = base.toDouble();
    indicatorTextWidth = 0;
    // calculate indicator textWidth
    for (int i = 0; i < maxLine; i++) {
      indicatorTextWidth = max(
          indicatorTextWidth,
          _textWidth(widget.lineTextFormat(spacer * (maxLine - i)),
              widget.indicatorTextStyle));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      maxHeight = constraints.maxHeight;
      maxWidth = constraints.maxWidth;
      spacerHeight = _spacerHeight;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _lineDrawer(),
            _barDrawer(),
            _titleDrawer(),
            _tappedDrawer()
          ],
        ),
      );
    }));
  }

  Widget _lineDrawer() {
    return Column(
      children: [
        Container(
          height: paddingTop,
        ),
        ...List.generate(maxLine, (index) => _line(getLineValue(index))),
        Container(
          height: paddingBottom,
        )
      ],
    );
  }

  Widget _line(double value) {
    return SizedBox(
      height: spacerHeight,
      width: max(maxWidth, _getLineWidth()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: indicatorTextWidth,
              child: Text(
                widget.lineTextFormat(value),
                style: widget.indicatorTextStyle,
              )),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: widget.lineColor, width: 1))),
            ),
          )
        ],
      ),
    );
  }

  Widget _barDrawer() {
    return Positioned(
      bottom: spacerHeight / 2 + paddingBottom,
      left: widget.barPaddingLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          listBar.length,
          (index) => GestureDetector(
            onTap: () {
              _tappedIndexController.add(index);
              if (widget.onBarTap != null) {
                widget.onBarTap!(listBar[index]);
              }
            },
            child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                    begin: 10,
                    end: (widget.getValue(widget.listBar[index]) / base) *
                        spacerHeight),
                duration: const Duration(milliseconds: 500),
                curve: Curves.bounceOut,
                builder: (context, height, child) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: barMargin),
                    width: widget.barWidth,
                    height: height,
                    decoration: widget.barDecoration,
                  );
                }),
          ),
        ),
      ),
    );
  }

  Widget _titleDrawer() {
    return Positioned(
        top: (maxLine - 0.5) * spacerHeight + paddingTop,
        left: widget.barPaddingLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            listBar.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: barMargin),
              width: widget.barWidth,
              child: Text(
                widget.getTitle(listBar[index]),
                textAlign: TextAlign.center,
                style: widget.titleTextStyle,
              ),
            ),
          ),
        ));
  }

  Widget _tappedDrawer() {
    return StreamBuilder<int>(
        stream: _tappedIndexController.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }
          int index = snapshot.data!;
          return Positioned(
              left: widget.barPaddingLeft +
                  2 * widget.barMargin * (index + 0.5) +
                  (widget.barWidth) * (index),
              bottom: spacerHeight / 2 +
                  paddingBottom +
                  (widget.getValue(widget.listBar[index]) / base) *
                      spacerHeight,
              child: SizedBox(
                width: widget.barWidth,
                child: Text(
                  widget.indicatorBuilder(listBar[index]),
                  textAlign: TextAlign.center,
                  style: widget.indicatorTextStyle,
                ),
              ));
        });
  }

  double _getLineWidth() {
    return (2 * barMargin + widget.barWidth) * listBar.length + 30;
  }

  double get _spacerHeight =>
      (maxHeight - paddingBottom - paddingTop) / maxLine;
  double getLineValue(int index) {
    return spacer * (maxLine - index - 1);
  }

  double _textWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }
}
