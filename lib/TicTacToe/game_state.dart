// game_state.dart
// Barrett Koster 2025

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

// This is where you put whatever the game is about.

class GameState
{
  bool iStart;
  bool myTurn;
  List<String> board;

  GameState( this.iStart, this.myTurn, this.board );
}

class GameCubit extends Cubit<GameState>
{
  static final String d = ".";
  GameCubit( bool myt ): super( GameState( myt, myt, [d,d,d,d,d,d,d,d,d] )); 

  update( int where, String what )
  {
    state.board[where] = what;
    state.myTurn = !state.myTurn;
    emit( GameState(state.iStart,state.myTurn,state.board) ) ;
  }

  clear()
  {
    state.board = [d,d,d,d,d,d,d,d,d];
    state.myTurn = state.iStart;
    emit( GameState(state.iStart,state.myTurn,state.board) ) ;
  }

  pass()
  {
    // pass the turn to the other player.
    state.myTurn = !state.myTurn;
    emit( GameState(state.iStart,state.myTurn,state.board) ) ;
  }

  // Someone played x or o in this square.  (numbered from
  // upper left 0,1,2, next row 3,4,5 ... 
  // Update the board and emit.
  bool play( int where )
  {
    if(where == -1) {
      // opponent passed their turn
      state.myTurn = !state.myTurn;
      return false;
    }
    String mark = state.myTurn==state.iStart? "x":"o";
    state.board[where] = mark;
    state.myTurn = !state.myTurn;

    emit( GameState(state.iStart,state.myTurn,state.board) ) ;

    // Win condition check
    bool gameOver = false;
    for(int i=0; i < 3; i++)
    {
      if ( state.board[i*3] == mark && state.board[i*3+1] == mark && state.board[i*3+2] == mark )
      { gameOver = true; }
      if ( state.board[i] == mark && state.board[i+3] == mark && state.board[i+6] == mark )
      { gameOver = true; }
    }

    if(gameOver) {
      // Reset the game
      state.board = [d,d,d,d,d,d,d,d,d];
      state.myTurn = state.iStart;
      emit( GameState(state.iStart,state.myTurn,state.board) );
      return true;
    }

    return false;
  }

  void handle( String msg )
  {
    // yc.say("Player $playerMark played square: $sn");
    // sc.update("Player $playerMark played square: $sn");
    List<String> parts = msg.split(" ");
    print("parts: $parts");
    print("parts.length: ${parts.length}");
    if(parts.length == 5) {

      // "Player $playerMark passed their turn"
      if(parts[2] == "passed") {
        // opponent passed their turn
        pass();
      } else {
        // "Player $playerMark played square: $sn"
        if(parts[2] == "played") {
          // opponent played in square
          int sq = int.parse(parts[4]);
          play(sq);
        }
      }



    } else if (parts.length == 4) { // "Game Over, $playerMark wins!"
      if(parts[0] == "Game") {
        // Reset the game
        state.board = [d,d,d,d,d,d,d,d,d];
        state.myTurn = state.iStart;
        emit( GameState(state.iStart,state.myTurn,state.board) );
      }
    }
  }
}