// DicePrep.dart
// Robert Perez

import "dart:math";

import "package:flutter/material.dart";

void main() // 23
{
  runApp(DiceRoller());
}

class DiceRoller extends StatelessWidget
{
  DiceRoller({super.key});

  @override
  Widget build( BuildContext context )
  { return MaterialApp
    ( title: "Dice Roller",
    home: DRHome(),
  );
  }
}

class DRHome extends StatefulWidget
{
  @override
  State<DRHome> createState() => DRHomeState();
}

class DRHomeState extends State<DRHome>
{
  final Random _random = Random();
  int rollDice()
  {
    return _random.nextInt(6) + 1;
  }

  @override
  Widget build( BuildContext context )
  { return Scaffold
    (
      appBar: AppBar(title: const Text("Dice Roller")),
      body: Center ( child:
      Column( children:
      [
        Container(
          decoration: BoxDecoration(
            color: Color(0xF6C8BACC),
            border: Border.all(
              width: 6,
              color: Colors.white,
            ),
          ),
          height: 500,
          width: 500,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rollDice().toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text("Roll Dice"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]
      ),
      ));
  }
}