// player.dart
// Barrett Koster 2025

import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "said_state.dart";
import "game_state.dart";
import "yak_state.dart";

/*
  A Player gets called for each of the ServerBase and the ClientBase.
  We establish the game state, usually different depending on 
  whether you are the starting player or not.  
  This establishes the Game and Said BLoC layers. 
*/
class Player extends StatelessWidget
{
  final bool iStart;
  Player( this.iStart, {super.key} );

  @override
  Widget build( BuildContext context )
  { 
    return BlocProvider<GameCubit>
    ( create: (context) => GameCubit( iStart ),
      child: BlocBuilder<GameCubit,GameState>
      ( builder: (context,state) => 
        BlocProvider<SaidCubit>
        ( create: (context) => SaidCubit(),
          child: BlocBuilder<SaidCubit,SaidState>
          ( builder: (context,state) => Scaffold
            ( appBar: AppBar(title: Text("player")),
              body: Player2(),
            ),
          ),
        ),
      ),
    );
  }
}

// this layer initializes the communication.
// By this point, the socets exist in the YakState, but
// they have not yet been told to listen for messages.
class Player2 extends StatelessWidget
{ Widget build( BuildContext context )
  {
    YakCubit yc = BlocProvider.of<YakCubit>(context);
    YakState ys = yc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);

    if ( ys.socket != null && !ys.listened )
    {
      sc.listen(context);
      yc.updateListen();
    } 
    return Player3();
  }
}

// This is the actual presentation of the game.

class Player3 extends StatelessWidget
{
  Player3( {super.key} );
  final TextEditingController tec = TextEditingController();

  Widget build( BuildContext context )
  {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);
    SaidState ss = sc.state;
    YakCubit yc = BlocProvider.of<YakCubit>(context);

    String playerMark = gc.state.myTurn == gc.state.iStart? "x":"o";
    String opponentMark = gc.state.myTurn == gc.state.iStart? "o":"x";

    return Row
    (
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children:
      [
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Row(children: [ Sq(0), Sq(1), Sq(2)]),
            Row(children: [ Sq(3), Sq(4), Sq(5)]),
            Row(children: [ Sq(6), Sq(7), Sq(8)]),
            SizedBox( height: 20),
            ElevatedButton(
                  onPressed: () {
                    yc.say("Game Over, $opponentMark wins!");
                    sc.update("Game Over, $opponentMark wins!");
                    gc.clear();
                  },
                  child: Text("Resign"),
            ),
            SizedBox( height: 20),
            ElevatedButton(
                  onPressed: gc.state.myTurn ? () {
                    gc.pass();
                    yc.say("Player $playerMark passed their turn");
                    sc.update("Player $playerMark passed their turn");
                  } : null,
                  child: Text("Pass"),
            ),
          ]),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            verticalDirection: VerticalDirection.up,
            children: [
            ElevatedButton(
              onPressed: () {
                yc.say(tec.text);
                sc.update(tec.text);
              },
              child: Text("Send Message"),
            ),
            SizedBox.fromSize(size: Size(20, 20)),
            SizedBox( width: 300, height: 50, child: TextField(controller: tec) ),
            // last 10 messages
            for(int i=0; i < min(ss.said.length, 11) ; i++)
              Text(ss.said[ss.said.length - 1 - i]),
          ]),
      ]);
  }
}

// the squares of the board are just buttons.  You press one 
// to play it.  We should have control here over whether it
// is your turn or not (but this is not added yet).
class Sq extends StatelessWidget
{ final int sn;
  Sq(this.sn,{super.key});

  Widget build( BuildContext context )
  {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    YakCubit yc = BlocProvider.of<YakCubit>(context);

    SaidCubit sc = BlocProvider.of<SaidCubit>(context);

    // state.myTurn==state.iStart? "x":"o";
    String playerMark = gc.state.myTurn == gc.state.iStart? "x":"o";

    if(!gc.state.myTurn) {
      print("not my turn");
      return ElevatedButton
      (
        onPressed: () { print("not my turn"); },
        child: Text(gs.board[sn]),
      );
    }

    
    return ElevatedButton
    ( onPressed: ()
      {
        bool gameOver = gc.play(sn);
        if(gameOver) {
          yc.say("Game Over, $playerMark wins!");
          sc.update("Game Over, $playerMark wins!");
          gc.clear();
        }
        else {
          yc.say("Player $playerMark played square: $sn");
          sc.update("Player $playerMark played square: $sn");
        }
      },
      child: Text(gs.board[sn]),
    );

  }
}