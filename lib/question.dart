import 'package:flutter/material.dart';

class QuestionWidget extends StatefulWidget {
  final String question;
  final List<String> answers;
  final int index;
  final int prevSeletectedIndex;
  final Function(int, int) onAnswerSelected;

  QuestionWidget(
      {required this.question,
      required this.answers,
      required this.index,
      required this.onAnswerSelected,
      required this.prevSeletectedIndex});

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  int selectedAnswerIndex = -1; // Index to keep track of selected answer

  @override
  void didUpdateWidget(covariant QuestionWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    selectedAnswerIndex = widget.prevSeletectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${widget.index}: ${widget.question}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.answers.asMap().entries.map((entry) {
                final index = entry.key;
                final answer = entry.value;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedAnswerIndex = index;
                    });
                    widget.onAnswerSelected(widget.index, selectedAnswerIndex);
                  },
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: selectedAnswerIndex,
                        onChanged: (value) {
                          setState(() {
                            selectedAnswerIndex = value!;
                          });
                          widget.onAnswerSelected(
                              widget.index, selectedAnswerIndex);
                        },
                      ),
                      Text(
                        '$answer',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
