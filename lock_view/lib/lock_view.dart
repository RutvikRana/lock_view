///Importing Libraries
import 'dart:math';
import 'package:flutter/material.dart';

///lock_view library

///LockView Widget - To Create 9x9 LockScreen
class LockView extends StatefulWidget {
  ///Height,Width
  final double height, width;

  ///gridNumber
  final int gridNumber;

  ///lineWidth,CircleRadius
  final double lineWidth, circleRadius;

  ///Password
  final List<int> password;

  ///Colors
  final Color passColor, correctColor, incorrectColor, normalColor, borderColor;

  ///Decorations
  final BoxDecoration background, lineDecoration;

  ///Want To Take Pattern Instead?
  final bool takePattern;
  //Callbak onEndPattern
  final Function(bool didUnlocked) onEndPattern;

  ///Callback onEndTakePattern
  final Function(List<int> pattern) onEndTakePattern;

  ///Constructor
  LockView(
      {this.width,
      this.height,
      this.password,
      this.gridNumber = 3,
      this.lineWidth = 5,
      this.circleRadius = 0.15,
      this.borderColor = Colors.black,
      this.normalColor = Colors.white,
      this.correctColor = Colors.green,
      this.incorrectColor = Colors.red,
      this.passColor = Colors.blue,
      this.background = const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 10)],
          borderRadius: BorderRadius.all(Radius.circular(20))),
      this.lineDecoration = const BoxDecoration(
          color: Colors.grey, boxShadow: [BoxShadow(blurRadius: 10)]),
      this.onEndPattern,
      this.takePattern = false,
      this.onEndTakePattern});
  @override
  _LockViewState createState() => _LockViewState();
}

///State Of LockView
class _LockViewState extends State<LockView> {
  double _width, _height;
  List<int> passedPoints = [];
  List<Widget> lines = new List<Widget>();
  Offset _touch;
  bool _win = false;
  bool _end = false;

  ///Calls When Parent Updates
  @override
  void didUpdateWidget(oldWidget) {
    if (widget.takePattern) {
      lines.clear();
      passedPoints.clear();
      _end = false;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  ///Get Index From _touch Offset
  int getTouchIndex() {
    if (_touch == null) {
      return -2;
    }

    for (int i = 0; i < widget.gridNumber * widget.gridNumber; i++) {
      Offset position = Offset(
          (i % widget.gridNumber) * (_width / widget.gridNumber),
          ((i / widget.gridNumber).floor()) * (_height / widget.gridNumber));
      position += Offset((_width / widget.gridNumber) * 0.5,
          (_height / widget.gridNumber) * 0.5);
      if ((position - _touch).distance <
          (_width / widget.gridNumber) * (widget.circleRadius * 2)) {
        return i;
      }
    }
    return -1;
  }

  ///Create All Lines
  List<Widget> createLines() {
    int ind = getTouchIndex();
    if (ind >= 0) {
      if (!passedPoints.contains(ind)) {
        passedPoints.add(ind);
        if (passedPoints.length > 1) {
          int ind2 = passedPoints[passedPoints.length - 2];
          Offset position1 = Offset(
              (ind % widget.gridNumber) * (_width / widget.gridNumber),
              ((ind / widget.gridNumber).floor()) *
                  (_height / widget.gridNumber));
          Offset position2 = Offset(
              (ind2 % widget.gridNumber) * (_width / widget.gridNumber),
              ((ind2 / widget.gridNumber).floor()) *
                  (_height / widget.gridNumber));
          Offset position = (position2 - position1);
          List<int> addedPoints = new List<int>();
          for (int i = 0; i < widget.gridNumber * widget.gridNumber; i++) {
            if (i == ind || i == ind2) {
              continue;
            }
            Offset p = Offset(
                    (i % widget.gridNumber) * (_width / widget.gridNumber),
                    ((i / widget.gridNumber).floor()) *
                        (_height / widget.gridNumber)) -
                position1;
            double theta = acos(((p.dx * position.dx) + (p.dy * position.dy)) /
                (p.distance * position.distance));
            if ((p).distance * sin(theta) <
                (_width / widget.gridNumber) * (widget.circleRadius * 2)) {
              if (ind > ind2 && i < ind && i > ind2) {
                addedPoints.add(i);
              } else if (ind < ind2 && i > ind && i < ind2) {
                addedPoints.add(i);
              }
            }
          }
          addedPoints..add(ind);
          if (ind > ind2) {
            addedPoints.sort((a, b) => a.compareTo(b));
          } else {
            addedPoints.sort((a, b) => b.compareTo(a));
          }
          passedPoints.removeLast();
          for (int i in addedPoints) {
            if (!passedPoints.contains(i)) {
              passedPoints.add(i);
              lines.add(getLine(passedPoints[passedPoints.length - 1],
                  passedPoints[passedPoints.length - 2]));
            }
          }
        }
      }
    } else if (ind == -1 && passedPoints.length > 0) {
      List<Widget> myList = new List<Widget>();
      myList
        ..addAll(lines)
        ..add(getTempLine(passedPoints[passedPoints.length - 1]));
      return myList;
    }

    return lines;
  }

  ///Create Line From Index1 to Index2
  Widget getLine(int index1, int index2) {
    Offset position1 = Offset(
        (index1 % widget.gridNumber) * (_width / widget.gridNumber),
        ((index1 / widget.gridNumber).floor()) * (_height / widget.gridNumber));
    Offset position2 = Offset(
        (index2 % widget.gridNumber) * (_width / widget.gridNumber),
        ((index2 / widget.gridNumber).floor()) * (_height / widget.gridNumber));
    Offset position = (position1 + position2) / 2 +
        Offset((_width / widget.gridNumber) * 0.5,
            (_height / widget.gridNumber) * 0.5);
    double angle =
        atan((position2.dy - position1.dy) / (position2.dx - position1.dx));
    double w = (position1 - position2).distance + 5;

    return Transform.rotate(
        alignment: Alignment.center,
        angle: angle,
        origin: Offset(position.dx - w / 2, position.dy - widget.lineWidth / 2),
        child: Container(
          width: w,
          height: widget.lineWidth,
          decoration: widget.lineDecoration,
          transform: Matrix4.translationValues(
              position.dx - w / 2, position.dy - widget.lineWidth / 2, 0),
        ));
  }

  ///Create Line From Index1 to _touch Offset
  Widget getTempLine(int index) {
    Offset position1 = Offset(
            (index % widget.gridNumber) * (_width / widget.gridNumber),
            ((index / widget.gridNumber).floor()) *
                (_height / widget.gridNumber)) +
        Offset((_width / widget.gridNumber) * 0.5,
            (_height / widget.gridNumber) * 0.5);
    Offset position2 =
        Offset(_touch.dx.clamp(0.0, _width), _touch.dy.clamp(0.0, _height));
    Offset position = (position1 + position2) / 2;
    double angle =
        atan((position2.dy - position1.dy) / (position2.dx - position1.dx));
    double w = (position1 - position2).distance + 5;

    return Transform.rotate(
        alignment: Alignment.center,
        angle: angle,
        origin: Offset(position.dx - w / 2, position.dy - widget.lineWidth / 2),
        child: Container(
          width: w,
          height: widget.lineWidth,
          decoration: widget.lineDecoration,
          transform: Matrix4.translationValues(
              position.dx - w / 2, position.dy - widget.lineWidth / 2, 0),
        ));
  }

  ///Unlock Status
  bool didUnlocked() {
    if (widget.password == null) {
      return false;
    }
    if (widget.password.length != passedPoints.length) {
      return false;
    }
    for (int i = 0; i < widget.password.length; i++) {
      if (widget.password[i] != passedPoints[i]) {
        return false;
      }
    }
    return true;
  }

  ///PanEnd - Check For UnlockStatus
  void _panEnd() {
    _touch = null;
    if (widget.takePattern) {
      if (widget.onEndTakePattern != null) {
        widget.onEndTakePattern(passedPoints.toList());
      }
      return;
    }

    if (didUnlocked()) {
      setState(() {
        _win = true;
        _end = true;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        lines.clear();
        passedPoints.clear();
        _end = false;
        if (widget.onEndPattern != null) {
          widget.onEndPattern(true);
        }
        setState(() {});
      });
    } else {
      setState(() {
        _win = false;
        _end = true;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        lines.clear();
        passedPoints.clear();
        _end = false;
        if (widget.onEndPattern != null) {
          widget.onEndPattern(false);
        }
        setState(() {});
      });
    }
  }

  ///Main Build Method
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c, size) {
        double w = widget.width ?? size.biggest.width;
        double h = widget.height ?? size.biggest.height;
        _width = w;
        _height = h;
        double _radius = (w / widget.gridNumber) * (widget.circleRadius * 2);
        return GestureDetector(
          onPanStart: (details) {
            setState(() {
              _touch = details.localPosition;
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _touch = details.localPosition;
            });
          },
          onPanEnd: (details) {
            _panEnd();
          },
          child: Container(
            height: h,
            width: w,
            decoration: widget.background,
            child: Stack(
              children: [
                Stack(children: createLines()),
                GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: widget.gridNumber,
                  children: List.generate(widget.gridNumber * widget.gridNumber,
                      (index) {
                    bool _passed = passedPoints.contains(index);
                    return Center(
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: _end
                                        ? (_win
                                            ? widget.correctColor
                                            : widget.incorrectColor)
                                        : (_passed
                                            ? widget.passColor
                                            : widget.borderColor),
                                    width: _radius *
                                        (_end
                                            ? (_win ? 0.5 : 0.5)
                                            : (_passed ? 0.5 : 0.2))),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(blurRadius: 5)],
                                color: widget.normalColor),
                            width: _radius,
                            height: _radius));
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
