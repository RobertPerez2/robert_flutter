// Robert Perez
// Quizzle Homework


import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
// Assets code from https://docs.flutter.dev/ui/assets/assets-and-images#asset-bundling
import 'package:flutter/services.dart' show rootBundle;

class InfoState {
  Map<String, String> questions = {};

  // Count for correct answers
  int correct = 0;
  // Lets us know which question we are on
  int current_question = 0;
  // 0 = false, 1 = true, 2 = not answered, helps present correct/incorrect message
  int last_question_correct = 2;

  InfoState(this.questions, this.correct, this.current_question, this.last_question_correct);
}

class InfoCubit extends Cubit<InfoState> {

  // Try to load the questions from the file at the start
  InfoCubit() : super(InfoState({}, 0, 0, 2)) {
    loadQuestions();
  }

  void update(Map<String, String> new_questions, int new_correct, int new_current_question, int new_last_question_correct) {
    emit(InfoState(new_questions, new_correct, new_current_question, new_last_question_correct));
  }

  void loadQuestions() async {
    // Load the questions from the file
    String contents = await loadAsset();
    print(contents);

    List<String> questions_answers = contents.split("\n");

    Map<String, String> questions = {};
    for (String line in questions_answers) {
      if(line.isEmpty) { continue; }
      List<String> parts = line.split(",");
      if(parts.length != 2) { continue; }
      if(parts[0].trim() == "state") { continue; }
      questions[parts[0].trim()] = parts[1].trim();
    }

    emit(InfoState(questions, 0, 0, 2));
  }

  // Check if the answer is correct
  void answerQuestion(String question, String answer) {
    if (state.questions[question] == answer.trim()) {
      // Correct
      emit(InfoState(state.questions, state.correct + 1, state.current_question, 1));
    } else {
      // Incorrect
      emit(InfoState(state.questions, state.correct, state.current_question, 0));
    }
  }

  // Move to the next question, also resets the correct/incorrect message
  void nextQuestion() {
    if (state.current_question < state.questions.length - 1) {
      emit(InfoState(state.questions, state.correct, state.current_question + 1, 2));
    }
  }

  void previousQuestion() {
    if (state.current_question > 0) {
      emit(InfoState(state.questions, state.correct, state.current_question - 1, 2));
    }
  }

  // Load the quiz content file
  Future<String> loadAsset() async {
    return await rootBundle.loadString('lib/assets/StateCapitols.txt');
  }

}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfoCubit>(
      create: (context) => InfoCubit(),
      child: MaterialApp(
        title: "Quizzle",
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    InfoCubit myCubit = BlocProvider.of<InfoCubit>(context);
    InfoState state = myCubit.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizzle"),
      ),
      body: BlocBuilder<InfoCubit, InfoState>(
          builder: (context, state) {

            // Prevents the app from loading/crashing if questions are not loaded yet
            if (state.questions.isEmpty) {
              myCubit.loadQuestions();
              return Container();
            }

            return Column(
              children: [
                // Current question
                Text(
                "Question ${state.current_question + 1} of ${state.questions.length}",
                style: TextStyle(fontSize: 15)
                ),

                // # of correct answers
                Text("Correct: ${state.correct}",
                  style: TextStyle(fontSize: 15)
                ),
                SizedBox.fromSize(size: Size(20, 20)),

                // correct/incorrect message
                Text(state.last_question_correct == 0 ? "Incorrect" : state.last_question_correct == 1 ? "Correct" : "",
                  style: TextStyle(
                      fontSize: 15,
                      color: state.last_question_correct == 0 ? Colors.red : state.last_question_correct == 1 ? Colors.green : Colors.black
                  )
                ),
                Text("What is the capitol of ${state.questions.keys.elementAt(state.current_question)}?",
                style: TextStyle(fontSize: 20)
                ),
                Container(
                width: 300,
                margin: EdgeInsets.all(20),
                height: 50,
                child: TextField(
                    onSubmitted: (String answer) {
                      myCubit.answerQuestion(
                          state.questions.keys.elementAt(state.current_question),
                          answer);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        myCubit.previousQuestion();
                      },
                      child: const Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        myCubit.nextQuestion();
                      },
                      child: const Text("Next"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        myCubit.loadQuestions();
                      },
                      child: const Text("Restart"),
                    ),
                  ],
                ),
              ],
            );
          }
      ),
    );
  }
}

