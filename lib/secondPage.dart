import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:test_1/main.dart';
import 'package:test_1/ThirdPage.dart';

class SecondPage extends StatefulWidget {
  final String breakfast;
  final String lunch;
  final String dinner;
  final String nickname;

  const SecondPage({
    Key? key,
    this.breakfast = '',
    this.lunch = '',
    this.dinner = '',
    this.nickname = '',
  }) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late String nickname = '';

  String breakfast = '';
  String lunch = '';
  String dinner = '';
  String? previousBreakfast;
  String? previousLunch;
  String? previousDinner;

  @override
  void initState() {
    super.initState();
    nickname = widget.nickname;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getSavedData();
  }

  @override
  void dispose() {
    saveData();
    super.dispose();
  }

  void getSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      breakfast = prefs.getString('breakfast') ?? '';
      lunch = prefs.getString('lunch') ?? '';
      dinner = prefs.getString('dinner') ?? '';
    });
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final formattedDateString = _getDateString(_selectedDay!, 'yyyy-MM-dd');

    await prefs.setString('breakfast', breakfast);
    await prefs.setString('lunch', lunch);
    await prefs.setString('dinner', dinner);
    await prefs.setString('${formattedDateString}_breakfast', breakfast);
    await prefs.setString('${formattedDateString}_lunch', lunch);
    await prefs.setString('${formattedDateString}_dinner', dinner);
  }

  @override
  void didUpdateWidget(SecondPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedDay != null) {
      getSavedDataForSelectedDay(_selectedDay!);
    }
  }

  void getSavedDataForSelectedDay(DateTime selectedDay) async {
    final prefs = await SharedPreferences.getInstance();
    final formattedDateString = _getDateString(selectedDay, 'yyyy-MM-dd');

    if (!isSameDay(selectedDay, DateTime.now())) {
      setState(() {
        breakfast = '';
        lunch = '';
        dinner = '';
      });
    } else {
      final hasData = prefs.containsKey('${formattedDateString}_breakfast') ||
          prefs.containsKey('${formattedDateString}_lunch') ||
          prefs.containsKey('${formattedDateString}_dinner');

      if (hasData) {
        setState(() {
          breakfast = prefs.getString('${formattedDateString}_breakfast') ?? '';
          lunch = prefs.getString('${formattedDateString}_lunch') ?? '';
          dinner = prefs.getString('${formattedDateString}_dinner') ?? '';
        });
      } else {
        // Restore previously recommended diet if available
        setState(() {
          breakfast = previousBreakfast ?? '';
          lunch = previousLunch ?? '';
          dinner = previousDinner ?? '';
        });
      }
    }

    _selectedDay = selectedDay; // Update the selected date
  }

  String _getDateString(DateTime dateTime, String format) {
    final formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.orange[800],
        backgroundColor: Colors.teal[900],
        onTap: (index) async {
          if (index == 1) return;
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FirstPage()),
              );
              break;
            case 1:
              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondPage(
                    breakfast: breakfast,
                    lunch: lunch,
                    dinner: dinner,
                  ),
                ),
              );
              if (result != null) {
                setState(() {
                  breakfast = result['breakfast'] ?? '';
                  lunch = result['lunch'] ?? '';
                  dinner = result['dinner'] ?? '';
                });
              }
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThirdPage()),
              );
              break;
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: const Text('Calendar'),
      ),
      body: Center(
        child: Column(
          children: [
            TableCalendar(
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              firstDay: DateTime(2021),
              lastDay: DateTime(2025),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                if (isSameDay(selectedDay, DateTime.now())) {
                  getSavedDataForSelectedDay(selectedDay);
                } else {
                  setState(() {
                    // Store the previously recommended die
                    previousBreakfast = breakfast;
                    previousLunch = lunch;
                    previousDinner = dinner;
                    breakfast = '';
                    lunch = '';
                    dinner = '';
                  });
                }
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
            ),
            Column(
              children: [
                Text(
                  '${widget.nickname}님의 식단', // 저장된 닉네임을 출력
                  style: const TextStyle(fontSize: 18),
                ),
                breakfast.isNotEmpty || lunch.isNotEmpty || dinner.isNotEmpty
                    ? Column(
                        children: [
                          Text(
                            breakfast,
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            lunch,
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            dinner,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      )
                    : const Text(
                        '추천받은 식단이 없습니다',
                        style: TextStyle(fontSize: 18),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
