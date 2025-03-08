// Deal or No Deal HW
// Robert Perez 2025
// ONLY FOR ANDROID AND MAC DUE TO FILE FUNCTIONS

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

class InfoState {
  int holdCase; // Our selected hold case
  List<int> money; // The list of money, saved for building the cases
  List<int> selectedCases; // List of selected cases so far
  Widget cases; // Case Grid For Game
  Widget presentation; // Presentation Grid for Values Left

  InfoState(this.holdCase, this.money, this.selectedCases, this.cases, this.presentation);
}

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(InfoState(
      -1,
      [1, 5, 10, 100, 1000, 5000, 10000, 100000, 500000, 1000000],
      [],
      Column(),
      Column())) {

    // Shuffling the money list
    state.money..shuffle();
    update(); // Updating the grid and presentation
  }

  // Serves the purpose of updating the grid and presentation
  void update() {
    emit(InfoState(state.holdCase, state.money, state.selectedCases, Builder(builder: (context) => createCases(context)), createPresentation()));
  }

  // Add a case to the selected cases
  void addCase(int myCase) {
    List<int> updatedCases = List.from(state.selectedCases);


    int myHoldCase = state.holdCase;
    int idx = state.money.indexOf(myCase);
    // if we have not selected a hold case yet, set it to the current case
    // for first selection of the game
    if(myHoldCase == -1) { myHoldCase = idx; }
    updatedCases.add(myCase);

    // update the hold case, selected cases, save game state, and update UI
    emit(InfoState(myHoldCase, state.money, updatedCases, state.cases, state.presentation));
    saveGameState();
    update();
  }

  // Reset the game
  void resetCases() {
    List<int> shuffled = List.from(state.money)..shuffle();

    emit(InfoState(-1, shuffled, [], state.cases, state.presentation));
    saveGameState();
    update();
  }

  // Calcualte dealer's offer
  int getDealerOffer() {
    int sum = 0;

    for (int i = 0; i < state.money.length; i++) {
      // Only add the cases that are not selected but include the hold case
      if (!state.selectedCases.contains(state.money[i]) || i == state.holdCase) {
        sum += state.money[i];
      }
    }

    double average = sum / (state.money.length - state.selectedCases.length + 1);
    return (average * 0.9).toInt();
  }

  Future<String> whereAmI() async
  {
    Directory mainDir = await getApplicationDocumentsDirectory();
    String mainDirPath = mainDir.path;

    return mainDirPath;
  }

  Future<void> saveGameState() async
  {
    String myStuff = await whereAmI();
    String filePath = "$myStuff/cases.txt";

    File fodder = File(filePath);
    if (!fodder.existsSync()) {
      fodder.createSync();
    }

    // Save the order of the boxes, which have been selected, and which is the hold case
    // value,1 = Selected and not the hold case
    // value,2 = Hold
    // value,3 = Unselected

    String fileString = "";
    for (int i = 0; i < state.money.length; i++) {
      if (state.selectedCases.contains(state.money[i])) {
        if (i == state.holdCase) {
          fileString += "${state.money[i]},2\n";
        } else {
          fileString += "${state.money[i]},1\n";
        }
      } else {
        fileString += "${state.money[i]},3\n";
      }
    }

    fodder.writeAsStringSync(fileString);
  }

  // Load the game state from the saved file
  Future<void> loadGameState() async
  {
    String myStuff = await whereAmI();
    String filePath = "$myStuff/cases.txt";

    File fodder = File(filePath);
    if (!fodder.existsSync()) {
      return;
    }

    List<String> contents = fodder.readAsStringSync().split("\n");
    List<int> newMoney = [];
    List<int> newSelectedCases = [];
    int newHoldCase = -1;

    // Go through each line, following format provided in saveGameState
    for (String line in contents) {
      if(line.isEmpty) { continue; }
      List<String> parts = line.split(",");
      if(parts.length != 2) { continue; }
      int value = int.parse(parts[0]);
      int status = int.parse(parts[1]);

      newMoney.add(value);
      if (status == 1) {
        newSelectedCases.add(value);
      } else if (status == 2) {
        newSelectedCases.add(value);
        newHoldCase = newMoney.length - 1;
      }
    }

    emit(InfoState(newHoldCase, newMoney, newSelectedCases, state.cases, state.presentation));
    update();
  }

  // Create a grid of buttons, each button representing a case.
  Widget createCases(BuildContext context) {
    Row row1 = Row(mainAxisAlignment: MainAxisAlignment.center, spacing:20, children: [] );
    Row row2 = Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 20, children: [] );

    for(int i = 0; i < state.money.length; i++) {
      ElevatedButton button;
      // If the case has been selected, disable the button
      if (state.selectedCases.contains(state.money[i])) {
        button = ElevatedButton(
          onPressed: null,
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(Size(115.0, 50.0)),
          ),
          child: Text("${i}", style: TextStyle(fontSize: 12)),
        );
      } else {
        // If it's not the hold case, provide the deal or no deal page
        // Otherwise, just add the case and update UI to normal game play
        button = ElevatedButton(
          onPressed: () {
            if (state.holdCase != -1 && state.money.length - state.selectedCases.length != 1) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DealPage(cc: this)));
            }
            addCase(state.money[i]);
            if (state.money.length - state.selectedCases.length == 0) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => GameOverPage(cc: this, winningCase: state.money[state.holdCase])));
            }
          },
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(Size(115.0, 50.0)),
          ),
          child: Text((i).toString(), style: TextStyle(fontSize: 12)),
        );
      }

      // Just splitting up the grid into two rows
      if (i < 5) {
        row1.children.add(button);
      } else {
        row2.children.add(button);
      }
    }

    return Column(spacing: 20, children: [row1, row2] );
  }

  // Side Preview for the values the player still has left in the game
  Widget createPresentation() {
    Column c1 = Column(
        spacing: 2,
        children: []
    );

    Column c2 = Column(
        spacing: 2,
        children: []
    );

    List<int> sorted = List.from(state.money)..sort();
    for (int i = 0; i < sorted.length; i++) {
      String text = "${sorted[i]}";

      Column c;
      if(i < 5) {
        c = c1;
      } else {
        c = c2;
      }

      // Display whether it's been selected yet, still hide if selected hold case
      bool displayRed = (state.selectedCases.contains(sorted[i])
          && state.holdCase != -1 && sorted[i] != state.money[state.holdCase]);

      c.children.add(
        Container(
          width: 100,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: displayRed ? Colors.red : Colors.green,
            border: Border.all(color: Colors.black, width: 3),),
          child: Text(text)
        )
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [c1, c2]
    );
  }
}


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<InfoCubit>(
          create: (context) => InfoCubit(),
          child: BlocBuilder<InfoCubit, InfoState>(
            builder: (context, state) => MyHomePage(),
          )
    ));
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    InfoCubit myCubit = BlocProvider.of<InfoCubit>(context);
    InfoState state = myCubit.state;

    myCubit.loadGameState();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deal or No Deal"),
      ),

      body: Focus(
        // FOR KEYBOARD INPUT
        autofocus: true,
        onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          String key = event.logicalKey.keyLabel.toLowerCase();
          // If the key pressed is a number, try to select that case
          // might be 'r' to reset game
          if (key == 'r') {
            myCubit.resetCases();
          }

          int? selectedNum = int.tryParse(key);
          if (selectedNum != null) {
            int idx = selectedNum;
            if (idx >= 0 && idx < state.money.length && !state.selectedCases.contains(state.money[idx])) {
              // If the hold case is already set and we are not down at last case, navigate to the deal page
              if (state.holdCase != -1 && state.money.length - state.selectedCases.length != 1) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => DealPage(cc: myCubit)));
              }
              myCubit.addCase(state.money[idx]);
              if (myCubit.state.money.length - myCubit.state.selectedCases.length == 0) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GameOverPage(cc: myCubit, winningCase: state.money[state.holdCase])));
              }
            }
          }
        }
      return KeyEventResult.ignored;
    },

    // UI OF THE GAME, Presents the different states the game could be in when u have the hold case yet or not
    child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 35,
        children: [
          Text("Welcome to Deal or No Deal!", style: TextStyle(fontSize: 35)),
          if(state.holdCase != -1) ...[
            Text("Your hold case: ${state.holdCase}", style: TextStyle(fontSize: 25)),
          ] else ...[
            Text("Select your hold case:", style: TextStyle(fontSize: 25)),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 50,
            children: [
              state.cases,
              if(state.holdCase != -1) ...[
                state.presentation,
              ],
          ]),
          ElevatedButton(
              onPressed: myCubit.resetCases,
              child: const Text("Reset Game")
          ),
          SizedBox.fromSize(size: Size(20, 20)),
          Text("Select cases by clicking the case, or press the number of the case.", style: TextStyle(fontSize: 15)),
          Text("You can also press 'R' to reset game.", style: TextStyle(fontSize: 15)),
        ],
      )),
    ));
  }
}

// Provide the deal or no deal page
class DealPage extends StatelessWidget {
  final InfoCubit cc;
  const DealPage({required this.cc, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deal or No Deal"),
      ),
    body: Focus(
      // FOR KEYBOARD INPUT
      autofocus: true,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          String key = event.logicalKey.keyLabel.toLowerCase();
          if (key == 'd') {
            Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => GameOverPage(cc: cc, winningCase: cc.getDealerOffer())));
          } else if (key == 'n') {
            Navigator.of(context).pop();
          }
        }
        return KeyEventResult.ignored;
      },

      // NORMAL UI
      child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          Text("The dealer offers you: \$${cc.getDealerOffer()}", style: TextStyle(fontSize: 35)),
          SizedBox.fromSize(size: Size(20, 20)),
          Text("Cases Left:", style: TextStyle(fontSize: 20)),
          cc.state.presentation,
          SizedBox.fromSize(size: Size(20, 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 50,
            children: [
              ElevatedButton(
                  onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => GameOverPage(cc: cc, winningCase: cc.getDealerOffer())));
                  },
                  child: const Text("Deal")
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("No Deal")
              ),
            ]
          ),
          Text("You can also press 'D' for Deal or 'N' for No Deal.", style: TextStyle(fontSize: 15)),
        ],
      )),
    ));
  }
}

// VICTORY PAGE
class GameOverPage extends StatelessWidget {
  final InfoCubit cc;
  final int winningCase;
  const GameOverPage({required this.cc, required this.winningCase, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Over"),
      ),
      // listen for 'p' to play again
      body: Focus( // FOR KEYBOARD INPUT
        autofocus: true,
        onKey: (FocusNode node, RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            String key = event.logicalKey.keyLabel.toLowerCase();
            if (key == 'p') {
              Navigator.of(context).popUntil((route) => route.isFirst);
              cc.resetCases();
            }
          }
          return KeyEventResult.ignored;
        },
      child: Center(child: Column( // NORMAL GAME UI
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 15,
        children: [
          Text("You won \$${winningCase}!", style: TextStyle(fontSize: 35)),
          SizedBox.fromSize(size: Size(20, 20)),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                cc.resetCases();
              },
              child: const Text("Play Again")
          ),
          Text("You can also press 'P' to Play Again."),
        ],
      )),
    ));
  }
}