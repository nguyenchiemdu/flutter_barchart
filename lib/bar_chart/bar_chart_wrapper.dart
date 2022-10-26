import 'dart:async';
import 'dart:math';

import 'package:chart_animation/bar_chart/model/bar.dart';
import 'package:flutter/material.dart';

const kDefaultBarDecoration = BoxDecoration(
    color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(5)));
const kIndicatorTextStyle = TextStyle(fontSize: 10);
const kTitleTextStyle = TextStyle(fontSize: 12);

class BarChartWrapper extends StatefulWidget {
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
      required this.onBarTap,
      Key? key})
      : super(key: key);
  final List<Bar> listBar;
  final double paddingTop;
  final double paddingBottom;
  final double barWidth;
  final double barMargin;
  final String Function(double) indicatorBuilder;
  final TextStyle indicatorTextStyle;
  final TextStyle titleTextStyle;
  final BoxDecoration barDecoration;
  final void Function(Bar) onBarTap;
  final Color lineColor;
  final double barPaddingLeft;
  @override
  State<BarChartWrapper> createState() => _BarChartWrapperState();
}

class _BarChartWrapperState extends State<BarChartWrapper> {
  late double maxHeight;
  late double maxWidth;
  late int maxLine;
  late double maxRoundValue;
  late double spacer;
  late double spacerHeight;
  late List<Bar> listBar = widget.listBar;
  late double paddingBottom = widget.paddingBottom;
  late double paddingTop = widget.paddingTop;
  late double barMargin = widget.barMargin;
  late double indicatorTextWidth;
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
    double maxValue = 0;
    for (Bar bar in listBar) {
      if (bar.value > maxValue) {
        maxValue = bar.value;
      }
    }
    base = pow(10, (maxValue.toInt()).toString().length - 1) as int;
    maxLine = (maxValue ~/ base) + 1;
    maxRoundValue = maxValue - maxValue % base;
    spacer = base.toDouble();
    indicatorTextWidth = 0;
    // calculate indicator textWidth
    for (int i = 0; i < maxLine; i++) {
      indicatorTextWidth = max(
          indicatorTextWidth,
          _textWidth(widget.indicatorBuilder(spacer * (maxLine - i)),
              widget.indicatorTextStyle));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      maxHeight = constraints.maxHeight;
      maxWidth = constraints.maxWidth;
      spacerHeight = (maxHeight - paddingBottom - paddingTop) / maxLine;
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
        ...List.generate(
            maxLine, (index) => _line(spacer * (maxLine - index - 1))),
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
                widget.indicatorBuilder(value),
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
              widget.onBarTap(listBar[index]);
            },
            child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                    begin: 10,
                    end: (widget.listBar[index].value / base) * spacerHeight),
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
                listBar[index].title,
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
                  (widget.listBar[index].value / base) * spacerHeight,
              child: SizedBox(
                width: widget.barWidth,
                child: Text(
                  widget.indicatorBuilder(listBar[index].value),
                  textAlign: TextAlign.center,
                  style: widget.indicatorTextStyle,
                ),
              ));
        });
  }

  double _getLineWidth() {
    return (2 * barMargin + widget.barWidth) * listBar.length + 30;
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
