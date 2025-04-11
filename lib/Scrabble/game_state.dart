// game_state.dart
// Robert Perez 2025

import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "said_state.dart";
import "yak_state.dart";
import "dragger.dart";

// This is where you put whatever the game is about.

class GameState
{
  bool iStart;
  bool myTurn;
  List<String> board;
  List<String> letters;
  List<String> available;
  int score;
  int opponentScore;

  GameState( this.iStart, this.myTurn, this.board, this.letters, this.available, this.score, this.opponentScore);
}

class GameCubit extends Cubit<GameState> {
  static final String d = ".";

  GameCubit(bool myt) : super(
      GameState(myt, myt, [], ["", "", "", "", "", "", ""], "abcdefghijklmnopqrstuvwxyz".split(""), 0, 0)) {
    // initialize the board
    state.board = [];
    for (int i = 0; i < 225; i++) {
      state.board.add(d);
    }
  }

  update(int where, String what) {
    state.board[where] = what;
    emit(GameState(state.iStart, state.myTurn, state.board, state.letters,
        state.available, state.score, state.opponentScore));
  }

  updateMyScore() {
    state.score += 1;
    emit(GameState(state.iStart, state.myTurn, state.board, state.letters,
        state.available, state.score, state.opponentScore));
  }

  updateOpponentScore() {
    state.opponentScore += 1;
    emit(GameState(state.iStart, state.myTurn, state.board, state.letters,
        state.available, state.score, state.opponentScore));
  }

  String getLetters() {
    int need = 0;
    for(String c in state.letters) {
      if(c == "") need++;
    }
    List<String> letters = [];

    for (int i = 0; i < need && state.available.isNotEmpty; i++) {
      int index = Random().nextInt(state.available.length);
      letters.add(state.available[index]);
      state.available.removeAt(index);
    }

    // update the letters
    for (int i = 0; i < state.letters.length; i++) {
      if (state.letters[i] == "") {
        state.letters[i] = letters[0];
        letters.removeAt(0);
      }
    }

    emit(GameState(state.iStart, state.myTurn, state.board, state.letters,
        state.available, state.score, state.opponentScore));

    return letters.join("");
  }

  updateAvailable(List<String> letters) {
    // update the available letters
    state.available = letters;
    emit(GameState(state.iStart, state.myTurn, state.board, state.letters,
        state.available, state.score, state.opponentScore));
  }

  pass() {
    // pass the turn to the other player.
    state.myTurn = !state.myTurn;
    emit(GameState(state.iStart, state.myTurn, state.board, state.letters,
        state.available, state.score, state.opponentScore));
  }

  // Someone played x or o in this square.  (numbered from
  // upper left 0,1,2, next row 3,4,5 ...
  // Update the board and emit.
  play(int where, String what) {
    state.board[where] = what;

    emit(GameState(state.iStart, state.myTurn, state.board, state.letters,
        state.available, state.score, state.opponentScore));
  }

  void handle(String msg) {
    // yc.say("$square $what");
    List<String> parts = msg.split(" ");
    print("parts: $parts");
    print("parts.length: ${parts.length}");
    if (parts.length == 2) {
      if(parts[0] == "GOT") {
        // opponent got these letters, remove from available
        List<String> letters = parts[1].split("");
        for(String c in letters) {
          state.available.remove(c);
        }
        emit(GameState(state.iStart, state.myTurn, state.board, state.letters,
            state.available, state.score, state.opponentScore));
      } else {
        // process the move/letter
        int sn = int.parse(parts[0]);
        String what = parts[1];
        play(sn, what);
        // update the score
        updateOpponentScore();
      }
    } else if (parts.length == 1) {
      // turn over
      if(parts[0] == "pass") {
        pass();
      }
    }
  }
}