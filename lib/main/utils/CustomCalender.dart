import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main/model/DateModel.dart';
import 'package:kivicare_flutter/main/utils/AppColors.dart';
import 'package:kivicare_flutter/main/utils/AppCommon.dart';
import 'package:kivicare_flutter/main/utils/date_utils.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class CustomCalender extends StatefulWidget {
  void Function(DateTime?) onDayChanged;
  DateTime? selectedDate;

  CustomCalender({required this.onDayChanged, this.selectedDate});

  @override
  _CustomCalenderState createState() => _CustomCalenderState();
}

class _CustomCalenderState extends State<CustomCalender> {
  List<String> monthNameList = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  List<DateModel> monthList = [];
  List<DateModel> dayList = [];
  List<int> yearList = [];
  int? selectedDate;
  DateTime today = DateTime.now();
  int? currentYear;
  int? currentMonth;
  int? selectedDay;
  int? selected;
  int index = -1;
  ScrollController scrollController = ScrollController();

  void getNumberOfDays() {
    dayList.clear();
    DateTime current = DateTime(currentYear!, currentMonth! + 1);
    var days = Utils.daysInRange(Utils.firstDayOfMonth(current), Utils.lastDayOfMonth(current).add(Duration(days: 1)));
    days.forEach((element) {
      DateModel dateModel = DateModel(id: element.day, monthName: element.weekday.getWeekDay(), dateTime: element);
      dayList.add(dateModel);
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    monthNameList.forEach((element) {
      monthList.add(DateModel(id: monthNameList.indexOf(element), monthName: element));
    });
    yearList.add(today.year);
    currentYear = today.year;
    if (widget.selectedDate != null) {
      yearList.add(widget.selectedDate!.year - 1);
      currentMonth = widget.selectedDate!.month - 1;
      selectedDay = widget.selectedDate!.day - 1;
    } else {
      yearList.add(today.year - 1);
      currentMonth = today.month - 1;
      selectedDay = today.day - 1;
    }
    getNumberOfDays();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void _onAfterBuild(BuildContext context) {
    double finalValue = (selectedDay! * 50) + (selectedDay! * 8).toDouble();
    scrollController.animateTo(finalValue, curve: Curves.linear, duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));

    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<int>(
              icon: Icon(Icons.keyboard_arrow_down_sharp, size: 20, color: context.iconColor),
              underline: 1.height,
              value: currentMonth,
              dropdownColor: Theme.of(context).cardColor,
              items: monthList.map((e) => DropdownMenuItem<int>(child: Text(e.monthName!, style: primaryTextStyle()), value: e.id)).toList(),
              onChanged: (month) {
                currentMonth = month;
                getNumberOfDays();
                setState(() {});
              },
            ),
            20.width,
            DropdownButton<int>(
              icon: Icon(Icons.keyboard_arrow_down_sharp, size: 20, color: context.iconColor),
              underline: 0.height,
              value: currentYear,
              dropdownColor: Theme.of(context).cardColor,
              items: yearList.map((e) => DropdownMenuItem<int>(child: Text(e.toString(), style: primaryTextStyle()), value: e)).toList(),
              onChanged: (year) {
                currentYear = year;
                getNumberOfDays();
                setState(() {});
              },
            ),
            // ignore: deprecated_member_use
            AppButton(
              padding: EdgeInsets.zero,
              color: context.cardColor,
              onTap: () {
                currentMonth = today.month - 1;
                currentYear = today.year;
                getNumberOfDays();
                selectedDay = today.day - 1;
                widget.onDayChanged.call(today);
                setState(() {});
              },
              child: Text('Today', style: boldTextStyle(color: appPrimaryColor)),
            ),
          ],
        ).paddingOnly(left: 16, right: 16),
        Container(
          height: 80,
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: dayList.length,
            padding: EdgeInsets.only(left: 8, right: 8),
            itemBuilder: (BuildContext context, int index) {
              DateModel data = dayList[index];
              return GestureDetector(
                onTap: () {
                  if (data.dateTime!.add(Duration(days: 1)).isBefore(DateTime.now())) {
                    errorToast("Invalid Date");
                  } else {
                    selectedDay = index;
                    widget.onDayChanged.call(data.dateTime);
                    setState(() {});
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  width: 50,
                  height: 80,
                  decoration: boxDecorationWithShadow(
                    backgroundColor: selectedDay == index ? primaryColor : Theme.of(context).cardColor,
                    border: Border.all(width: 0.5, color: selectedDay == index ? Colors.transparent : Colors.black12),
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                  child: Column(
                    children: [
                      FittedBox(child: Text(data.monthName!, style: boldTextStyle(size: 16, color: selectedDay == index ? Colors.white : primaryColor))),
                      6.height,
                      Text(data.id.toString(), style: boldTextStyle(size: 14, color: selectedDay == index ? Colors.white : primaryColor)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
