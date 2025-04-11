// player.dart
// Robert Perez 2025

import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "said_state.dart";
import "game_state.dart";
import "yak_state.dart";
import "dragger.dart";

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
    return BlocProvider<DragCubit>(
        create: (context) => DragCubit([Coords(550, 0), Coords(550, 50),
          Coords(550, 100), Coords(550, 150),
          Coords(550, 200), Coords(550, 250),
          Coords(550, 300),
        ]),
        child: BlocBuilder<DragCubit, DragState>(
        builder: (context, state) =>
        BlocProvider<GameCubit>
          ( create: (context) => GameCubit( iStart ),
          child: BlocBuilder<GameCubit,GameState>
            ( builder: (context,state) =>
              BlocProvider<SaidCubit>
                ( create: (context) => SaidCubit(),
                child: BlocBuilder<SaidCubit,SaidState>
                  ( builder: (context,state) => Scaffold
                  ( appBar: AppBar(title: Text("Scrabble")),
                  body: Player2(),
                ),
                ),
              ),
          ),
    )));
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


    List<String> displayLetters = List.from(gc.state.letters);
    displayLetters = displayLetters.where((letter) => letter != "").toList();

    if (displayLetters.isEmpty) {
      // if there are no letters, get some
      gc.getLetters();
      yc.say("GOT ${gc.state.letters}");
    }

    DragCubit dg = BlocProvider.of<DragCubit>(context);
    int i = 0;
    List<Tile> kids = [];
    for (Coords c in dg.state.zat) {
      kids.add(Tile(gc.state.letters[i], c));
      i++;
    }

    return GestureDetector(
        onTapDown: (td) => dg.down(td),
        onPanUpdate: (pdd) => dg.drag(pdd),
        onPanEnd: (de) {

          // After drop, try and get the coordinates and match them up
          // with the board to place the right letter at the right location
          int idx = dg.state.dragme;
          Coords finalCoords = dg.state.zat[idx];

          // indexing
          int col = ((finalCoords.x + TILE_SIZE / 2) ~/ TILE_SIZE);
          int row = ((finalCoords.y + TILE_SIZE / 2) ~/ TILE_SIZE);
          int sn = row * 15 + col;

          // Check if it's the players turn, if not don't let them play
          if(gc.state.myTurn && gc.state.letters[idx] != "") {
            String letter = gc.state.letters[idx];

            // Send message
            gc.update(sn, letter);
            gc.updateMyScore();
            yc.say("${sn} ${letter}");
            dg.up(de);

            // set the letter to empty
            gc.state.letters[idx] = "";

            // delete the letter from the list of letters
            // gc.state.letters.removeAt(idx);
            // remove the tile from the dragger
            // dg.state.zat.removeAt(idx);
          } else {
            dg.up(de);
          }
        },

        child: Container(
        child: Stack( children: [
          Column(
            children: [
              for (int i = 0; i < 15; i++)
                Row(
                  children: [
                    for (int j = 0; j < 15; j++) Sq(i * 15 + j),
                  ],
                ),
              SizedBox( height: 20),
              Row(
                spacing: 20,
                children: [
                  SizedBox(width: 40),
                  Column(
                    spacing: 10,
                    children: [
                      Text("My Score: ${gc.state.score}"),
                      Text("Opponent Score: ${gc.state.opponentScore}"),
                      Text("If you pick up a tile, you must play it!"),
                    ],
                  ),
                  Column(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: gc.state.myTurn ? () async {
                          yc.say("pass");
                          gc.pass();
                          // giving the program a second to process pass request
                          await Future.delayed( Duration(milliseconds:200) );
                          String letters = gc.getLetters();
                          yc.say("GOT ${letters}");
                        } : null,
                        child: Text("End Turn"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
        ),
        // Tiles!!!
        Stack(
            children:
            gc.state.letters.length > 0 ? kids : [Text("Get some letters first!")],
          ),
        ])));
  }
}

// the squares of the board are just buttons.  You press one
// to play it.  We should have control here over whether it
// is your turn or not (but this is not added yet).
class Sq extends StatelessWidget
{
  final int sn;
  Sq(this.sn,{super.key});

Widget build( BuildContext context )
{
  GameCubit gc = BlocProvider.of<GameCubit>(context);
  GameState gs = gc.state;
  YakCubit yc = BlocProvider.of<YakCubit>(context);
  SaidCubit sc = BlocProvider.of<SaidCubit>(context);

  // Check if it's the players turn, if not don't let them play
  if(!gc.state.myTurn) {
    print("not my turn");
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.white,
      )
      , child: Text(
      gs.board[sn],
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    ));
  }


  return Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      color: Colors.white,
    )
    , child: Text(
      gs.board[sn],
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    ),
  );
}
}