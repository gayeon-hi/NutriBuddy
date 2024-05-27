import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test_1/ThirdPage.dart';
import 'package:test_1/secondPage.dart';

const apiKey = '/*api key*/';
const apiUrl = 'https://api.openai.com/v1/completions';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FirstPageData(),
      child: const MyApp(),
    ),
  );
}

class FirstPageData extends ChangeNotifier {
  String breakfast = '';
  String lunch = '';
  String dinner = '';

  void setBreakfast(String value) {
    breakfast = value;
    notifyListeners();
  }

  void setLunch(String value) {
    lunch = value;
    notifyListeners();
  }

  void setDinner(String value) {
    dinner = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final TextEditingController _controller = TextEditingController();

  void getResult(String prompt) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      body: jsonEncode({
        "model": "text-davinci-003",
        'prompt': prompt,
        'max_tokens': 1000,
        'temperature': 0.3,
        'top_p': 1,
        'frequency_penalty': 0.5,
        'presence_penalty': 2
      }),
    );

    Map<String, dynamic> newResponse =
        jsonDecode(utf8.decode(response.bodyBytes));

    String text = newResponse['choices'][0]['text'];
    List<String> lines = text.split('\n');
    String breakfast = '아침 ';
    String lunch = '점심 ';
    String dinner = '저녁 ';
    for (String line in lines) {
      if (line.contains('아침')) {
        int startIndex = line.indexOf('아침') + '아침'.length;
        breakfast = '아침 ${line.substring(startIndex).trim()}';
      } else if (line.contains('점심')) {
        int startIndex = line.indexOf('점심') + '점심'.length;
        lunch = '점심 ${line.substring(startIndex).trim()}';
      } else if (line.contains('저녁')) {
        int startIndex = line.indexOf('저녁') + '저녁'.length;
        dinner = '저녁 ${line.substring(startIndex).trim()}';
      }
    }

    final firstPageData = Provider.of<FirstPageData>(context, listen: false);
    firstPageData.setBreakfast(breakfast);
    firstPageData.setLunch(lunch);
    firstPageData.setDinner(dinner);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('breakfast', breakfast);
    prefs.setString('lunch', lunch);
    prefs.setString('dinner', dinner);
  }

  void showCaloriePopup(BuildContext context) {
    final calorieController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('칼로리 입력'),
          content: TextField(
            controller: calorieController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly // 숫자만 입력되도록 설정
            ],
            decoration: const InputDecoration(
              labelText: '원하는 칼로리를 입력하세요.',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                String prompt =
                    '아침, 점심, 저녁 식단을 총 칼로리${calorieController.text}미만으로 추천해주고 칼로리 알려줘';
                getResult(prompt);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstPageData = Provider.of<FirstPageData>(context);
    final breakfast = firstPageData.breakfast;
    final lunch = firstPageData.lunch;
    final dinner = firstPageData.dinner;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.teal[900],
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        automaticallyImplyLeading: false, // 뒤로가기 화살표 숨김
      ),
      body: Center(
        child: Container(
          color: Colors.teal[900],
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xffe76f00),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 280,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffd9d9d8),
                      ),
                      child: Center(
                        child: Text(
                          breakfast,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 280,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffd9d9d8),
                      ),
                      child: Center(
                        child: Text(
                          lunch,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 280,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffd9d9d8),
                      ),
                      child: Center(
                        child: Text(
                          dinner,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30.30),
              OutlinedButton(
                onPressed: () => showCaloriePopup(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange[800],
                ),
                child: const Text('식단 추천 받기'),
              ),
            ],
          ),
        ),
      ),
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
        currentIndex: 0,
        selectedItemColor: Colors.orange[800],
        backgroundColor: Colors.teal[900],
        onTap: (index) {
          if (index == 0) return;
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FirstPage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecondPage()),
              );
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
    );
  }
}
