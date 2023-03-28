import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void main() {
  return runApp(const MultiColorMultiRange());
}

class MultiColorMultiRange extends StatelessWidget {
  const MultiColorMultiRange({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final DateRangePickerSelectionMode _selectionMode =
      DateRangePickerSelectionMode.multiRange;
  final DateRangePickerController _controller = DateRangePickerController();

  @override
  void initState() {
    _controller.view = DateRangePickerView.month;
    _controller.selectedDate = DateTime(2021, 9, 5);
    _controller.selectedRange =
        PickerDateRange(DateTime(2021, 9, 7), DateTime(2021, 9, 11));
    _controller.selectedRanges = <PickerDateRange>[
      PickerDateRange(DateTime.now().subtract(const Duration(days: 4)),
          DateTime.now().add(const Duration(days: 4))),
      PickerDateRange(DateTime.now().add(const Duration(days: 11)),
          DateTime.now().add(const Duration(days: 16)))
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SfDateRangePicker(
              controller: _controller,
              selectionMode: _selectionMode,
              startRangeSelectionColor: Colors.transparent,
              endRangeSelectionColor: Colors.transparent,
              rangeSelectionColor: Colors.transparent,
              selectionColor: Colors.transparent,
              cellBuilder:
                  (BuildContext context, DateRangePickerCellDetails details) {
                if (_selectionMode == DateRangePickerSelectionMode.range) {
                  return Container(
                      child: CustomPaint(
                        painter: RangeSelection(details.date, _controller),
                        size: Size(details.bounds.width, details.bounds.height),
                      ));
                } else if (_selectionMode ==
                    DateRangePickerSelectionMode.multiRange) {
                  return Container(
                      child: CustomPaint(
                        painter: MultiRangeSelection(details.date, _controller),
                        size: Size(details.bounds.width, details.bounds.height),
                      ));
                }
                return Container(
                    child: CustomPaint(
                      painter: SingleSelection(details.date, _controller),
                      size: Size(details.bounds.width, details.bounds.height),
                    ));
              },
            )));
  }
}

class MultiRangeSelection  extends CustomPainter{
  MultiRangeSelection(this.date, this.controller);

  final DateTime date;
  final DateRangePickerController controller;
  final TextPainter _textPainter = TextPainter();

  bool isSameDate(DateTime start,DateTime end){
    return start.year==end.year &&start.month==end.month && start.day==end.day;
  }
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    List<Color> selectedColors=<Color>[Colors.red,Colors.blue,Colors.green,Colors.yellow,Colors.pink];
    List<PickerDateRange>? selectedRanges = controller.selectedRanges;

    bool isSelectedDate = false;
    for (int i = 0; i < selectedRanges!.length; i++) {
      Color selectedColor=selectedColors[i%selectedColors.length];
      PickerDateRange range=selectedRanges[i];
      DateTime startDate = range.startDate!;
      DateTime endDate = range.endDate ?? startDate;
      if (isSameDate(startDate,endDate)) {
        if (isSameDate(startDate,date)) {
          isSelectedDate = true;
          double x = size.width / 2;
          double y = size.height / 2;
          double radius = x > y ? y : x;
          radius = radius - 1;
          canvas.drawCircle(Offset(x, y), radius, Paint()
            ..color = selectedColor);
        }
        break;
      } else if (isSameDate(startDate,date)) {
        isSelectedDate = true;
        double x = size.width / 2;
        double y = size.height / 2;
        double radius = x > y ? y : x;
        radius = radius - 1;
        canvas.drawCircle(Offset(x, y), radius, Paint()..color = selectedColor);
        canvas.drawRect(Rect.fromLTRB(x, y - radius, size.width, y + radius),
            Paint()..color = selectedColor.withOpacity(0.25));
        break;
      } else if (isSameDate(endDate,date)) {
        isSelectedDate = true;
        double x = size.width / 2;
        double y = size.height / 2;
        double radius = x > y ? y : x;
        radius = radius - 1;
        canvas.drawCircle(Offset(x, y), radius, Paint()..color = selectedColor);
        canvas.drawRect(Rect.fromLTRB(x, y - radius, 0, y + radius),
            Paint()..color = selectedColor.withOpacity(0.25));
        break;
      } else if (startDate.isBefore(date) && endDate.isAfter(date)) {
        double x = size.width / 2;
        double y = size.height / 2;
        double radius = x > y ? y : x;
        radius = radius - 1;
        canvas.drawRect(
            Rect.fromLTRB(0, y - radius, size.width, y + radius),
            Paint()
              ..color = selectedColor.withOpacity(0.25));
        break;
      }

    }

    final TextSpan dayTextSpan = TextSpan(
        text: date.day.toString(),
        style: TextStyle(
            color: isSelectedDate ? Colors.white : Colors.black, fontSize: 12));

    _textPainter.text = dayTextSpan;
    _textPainter.textDirection = TextDirection.ltr;
    _textPainter.textAlign = TextAlign.center;
    _textPainter.maxLines = 1;
    _textPainter.layout(minWidth: size.width, maxWidth: size.width);
    double xPosition = (size.width - _textPainter.width) / 2;
    double yPosition = (size.height - _textPainter.height) / 2;

    _textPainter.paint(canvas, Offset(xPosition, yPosition));
  }

  @override
  bool shouldRepaint(MultiRangeSelection oldDelegate) {
    return true;
  }
}

class SingleSelection extends CustomPainter {
  SingleSelection(this.date, this.controller);

  final DateTime date;
  final DateRangePickerController controller;
  final TextPainter _textPainter = TextPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    DateTime selectedDate = controller.selectedDate!;
    bool isSelectedDate = false;
    if (controller.selectedDate != null) {
      if (selectedDate == date) {
        isSelectedDate = true;
        double x = size.width / 2;
        double y = size.height / 2;
        double radius = x > y ? y : x;
        radius = radius - 1;
        canvas.drawCircle(Offset(x, y), radius, Paint()..color = Colors.red);
      }
    }
    final TextSpan dayTextSpan = TextSpan(
        text: date.day.toString(),
        style: TextStyle(
            color: isSelectedDate ? Colors.white : Colors.black, fontSize: 12));
    _textPainter.text = dayTextSpan;
    _textPainter.textDirection = TextDirection.ltr;
    _textPainter.textAlign = TextAlign.center;
    _textPainter.maxLines = 1;
    _textPainter.layout(minWidth: size.width, maxWidth: size.width);
    double xPosition = (size.width - _textPainter.width) / 2;
    double yPosition = (size.height - _textPainter.height) / 2;
    _textPainter.paint(canvas, Offset(xPosition, yPosition));
  }

  @override
  bool shouldRepaint(SingleSelection oldDelegate) {
    return true;
  }
}

class RangeSelection extends CustomPainter {
  RangeSelection(this.date, this.controller);

  final DateTime date;
  final DateRangePickerController controller;
  final TextPainter _textPainter = TextPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    DateTime startDate = controller.selectedRange!.startDate!;
    DateTime endDate = controller.selectedRange!.endDate ?? startDate;
    bool isSelectedDate = false;

    if (controller.selectedRange != null) {
      if (startDate == endDate) {
        if (startDate == date) {
          isSelectedDate = true;
          double x = size.width / 2;
          double y = size.height / 2;
          double radius = x > y ? y : x;
          radius = radius - 1;
          canvas.drawCircle(Offset(x, y), radius, Paint()..color = Colors.red);
        }
      } else if (startDate == date) {
        isSelectedDate = true;
        double x = size.width / 2;
        double y = size.height / 2;
        double radius = x > y ? y : x;
        radius = radius - 1;
        canvas.drawCircle(Offset(x, y), radius, Paint()..color = Colors.red);
        canvas.drawRect(Rect.fromLTRB(x, y - radius, size.width, y + radius),
            Paint()..color = Colors.red.withOpacity(0.25));
      } else if (endDate == date) {
        isSelectedDate = true;
        double x = size.width / 2;
        double y = size.height / 2;
        double radius = x > y ? y : x;
        radius = radius - 1;
        canvas.drawCircle(Offset(x, y), radius, Paint()..color = Colors.red);
        canvas.drawRect(Rect.fromLTRB(x, y - radius, 0, y + radius),
            Paint()..color = Colors.red.withOpacity(0.25));
      } else if (startDate.isBefore(date) && endDate.isAfter(date)) {
        double x = size.width / 2;
        double y = size.height / 2;
        double radius = x > y ? y : x;
        radius = radius - 1;
        canvas.drawRect(Rect.fromLTRB(0, y - radius, size.width, y + radius),
            Paint()..color = Colors.red.withOpacity(0.25));
      }
    }

    final TextSpan dayTextSpan = TextSpan(
        text: date.day.toString(),
        style: TextStyle(
            color: isSelectedDate ? Colors.white : Colors.black, fontSize: 12));

    _textPainter.text = dayTextSpan;
    _textPainter.textDirection = TextDirection.ltr;
    _textPainter.textAlign = TextAlign.center;
    _textPainter.maxLines = 1;
    _textPainter.layout(minWidth: size.width, maxWidth: size.width);
    double xPosition = (size.width - _textPainter.width) / 2;
    double yPosition = (size.height - _textPainter.height) / 2;

    _textPainter.paint(canvas, Offset(xPosition, yPosition));
  }

  @override
  bool shouldRepaint(RangeSelection oldDelegate) {
    return true;
  }
}