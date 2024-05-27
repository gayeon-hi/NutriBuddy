import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_1/main.dart';
import 'package:test_1/secondPage.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({Key? key}) : super(key: key);

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  TextEditingController nickController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  String gender = '';

  @override
  void initState() {
    super.initState();
    getSavedData();
  }

  void getSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final nick = prefs.getString('nick');
    final weight = prefs.getString('weight');
    final height = prefs.getString('height');
    final age = prefs.getString('age');
    final savedGender = prefs.getString('gender');

    setState(() {
      nickController.text = nick ?? '';
      weightController.text = weight ?? '';
      heightController.text = height ?? '';
      ageController.text = age ?? '';
      gender = savedGender ?? '';
    });
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('nick', nickController.text);
    prefs.setString('weight', weightController.text);
    prefs.setString('height', heightController.text);
    prefs.setString('age', ageController.text);
    prefs.setString('gender', gender);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        currentIndex: 2,
        selectedItemColor: Colors.orange[800],
        backgroundColor: Colors.teal[900],
        onTap: (index) {
          if (index == 2) return;
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FirstPage()),
              );
              break;
            case 1:
              final nickname = nickController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SecondPage(nickname: nickname)),
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
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nickController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: ' 닉네임 ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '몸무게 (kg)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '키 (cm)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '나이',
              ),
            ),
            const SizedBox(height: 16),
            Text('성별'),
            RadioListTile<String>(
              title: const Text('남성'),
              value: '남성',
              groupValue: gender,
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('여성'),
              value: '여성',
              groupValue: gender,
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 데이터 저장 또는 처리 로직을 여기에 추가
                String nick = nickController.text;
                String weight = weightController.text;
                String height = heightController.text;
                String age = ageController.text;
                saveData();

                // 데이터 처리 예시: 출력
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Information'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('닉네임: $nick '),
                        Text('몸무게: $weight kg'),
                        Text('키: $height cm'),
                        Text('나이: $age'),
                        Text('성별: $gender'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
