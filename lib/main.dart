import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:quiz/question.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Quizzical';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class QuizResponse {
  final String question;
  final String correct_answer;
  final List<String> incorrect_answers;

  const QuizResponse({
    required this.question,
    required this.correct_answer,
    required this.incorrect_answers,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      question: json['question'] ?? '',
      correct_answer: json['correct_answer'] ?? '',
      incorrect_answers: List<String>.from(json['incorrect_answers'] ?? []),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isGame = false;
  bool _endGame = false;
  List<int> questionStates = [];
  List<QuizResponse> questionSets = [];
  List<String> answers = [];
  List<List<int>> questionSetsIndexOrder = [];
  String cur_question = '';
  int cur_index = 0;
  int cur_selectedIndex = -1;
  int score = 0;

  @override
  void initState() {
    super.initState();
    questionStates = List.generate(5, (_) => -1);
  }

  void _startGame() {
    setState(() {
      _isGame = true;
    });
  }

  int getScore() {
    int score = 0;
    for (int i = 0; i < 5; i++) {
      if (questionSetsIndexOrder[i][questionStates[i]] == 3) {
        score++;
      }
    }
    return score;
  }

  List<String> getAnswers(index) {
    QuizResponse curQuestion = questionSets[index];
    String correctAns = curQuestion.correct_answer;
    List<String> ans = curQuestion.incorrect_answers;
    ans.add(correctAns);

    List<String> shuffedAns = [];
    for (int i = 0; i < 4; i++) {
      shuffedAns.add(ans[questionSetsIndexOrder[index][i]]);
    }
    return shuffedAns;
  }

  Future<List<QuizResponse>> fetchData(url) async {
    final finalUrl = Uri.parse(url);
    final response = await http.get(finalUrl);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body)['results'];
      final questionSets = (jsonData as List<dynamic>)
          .map((json) => QuizResponse.fromJson(json))
          .toList();
      return questionSets;
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<int> shuffleList(List<int> list) {
    final random = Random();
    for (var i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list;
  }

  void handleNextQuestion() {
    if (cur_index == questionSets.length - 1 && !_endGame) {
      setState(() {
        _endGame = true;
        score = getScore();
      });
    } else if (cur_index == questionSets.length - 1 && _endGame) {
      setState(() {
        _endGame = false;
      });
      luzi_test();
    }

    if (cur_index + 1 < questionSets.length) {
      setState(() {
        cur_index++;
        answers = getAnswers(cur_index);
        cur_question = questionSets[cur_index].question;
        cur_selectedIndex = questionStates[cur_index];
      });
    }
  }

  void handlePrevQuestion() {
    if (cur_index > 0) {
      setState(() {
        cur_index--;
        answers = getAnswers(cur_index);
        cur_question = questionSets[cur_index].question;
        cur_selectedIndex = questionStates[cur_index];
      });
    }
  }

  void luzi_test() async {
    const apiUrl = 'https://opentdb.com/api.php?amount=5&type=multiple';
    questionSets = await fetchData(apiUrl);
    final numbers = [0, 1, 2, 3];
    questionSetsIndexOrder = List.generate(5, (_) => shuffleList([...numbers]));
    questionStates = List.generate(5, (index) => -1);

    setState(() {
      answers = getAnswers(cur_index);
      cur_question = questionSets[cur_index].question;
      cur_index = 0;
      cur_selectedIndex = -1;
      score = 0;
    });
    _startGame();
  }

  void check_answer(int questionIndex, int selectedAnswerIndex) {
    setState(() {
      questionStates[questionIndex] = selectedAnswerIndex;
      cur_selectedIndex = selectedAnswerIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              width: double.infinity,
              child: Align(
                alignment: Alignment.topCenter,
                child: Visibility(
                  visible: _isGame,
                  child: QuestionWidget(
                    answers: answers,
                    question: cur_question,
                    index: cur_index,
                    onAnswerSelected: check_answer,
                    prevSeletectedIndex: cur_selectedIndex,
                  ),
                ),
              )),
          Expanded(
              child: Align(
            alignment: Alignment.center,
            child: Visibility(
              visible: !_isGame,
              child: ElevatedButton(
                  onPressed: () {
                    // Add your action here when the button is pressed
                    luzi_test();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Start Quizzical',
                      style: TextStyle(
                          fontSize:
                              18), // You can adjust the font size as needed
                    ),
                  )),
            ),
          )),
          Visibility(
            visible: _isGame,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: handlePrevQuestion,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Prev',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: handleNextQuestion,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Next',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  ],
                )),
          ),
          Visibility(
            visible: _isGame && _endGame,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Your score is ${score}/5',
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
