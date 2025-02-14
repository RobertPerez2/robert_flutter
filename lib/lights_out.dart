// Robert Perez
// Lights Out Homework

import "dart:math";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

// Define the state (variables) of the app
class InfoState
{
  int lightCount;
  List<int> faces;
  int complete;

  // Constructor
  InfoState(this.lightCount, this.faces, this.complete);
}

/*
 * Send the State into the Cubit, which we will have our functions to update the
 * state variables. Must call emit in the update function, update reloads page
*/
class InfoCubit extends Cubit<InfoState>
{
  // Constructor
  InfoCubit() : super( InfoState(0, [], 0) );

  // resets the lights grid to the specified size + lights are randomly on/off
  void update(int n)
  {
    List<int> faces = [];
    Random rand = Random();
    for ( int i=0; i<n; i++ )
    { faces.add( rand.nextInt(2) ); }

    emit(InfoState(n, faces, 0));
  }

  void flip(int which)
  {
    // flip the selected light
    if ( state.faces[which] == 1 ) {
      state.faces[which] = 0;
    } else {
      state.faces[which] = 1;
    }

    // flip immediate neighbors
    if( which+1 < state.lightCount ) {
      if ( state.faces[which+1] == 1 ) {
        state.faces[which+1] = 0;
      } else {
        state.faces[which+1] = 1;
      }
    }

    if( which-1 >= 0 ) {
      if ( state.faces[which-1] == 1 ) {
        state.faces[which-1] = 0;
      } else {
        state.faces[which-1] = 1;
      }
    }

    int lightCheck = 1;
    for(int i = 0; i<state.lightCount; i++ )
    {
      if ( state.faces[i] == 1 ) { lightCheck = 0; }
    }

    emit(InfoState(state.lightCount, state.faces, lightCheck));
  }

  Widget createGrid(int n)
  {
    Row theGrid = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[]
    );

    for ( int i=0; i<state.lightCount; i++ )
    {
      Column c = Column(children:[]);
      c.children.add(
          Boxy(40,40, state.faces[i] == 1 ? Colors.yellow : Colors.brown));

      c.children.add(
          FloatingActionButton(
              onPressed: () => flip(i),
              child: Text("${state.faces[i]}", style: TextStyle(fontSize: 40)
              )
          ));
      theGrid.children.add(c);
    }

    return theGrid;
  }
}

void main()  {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build( BuildContext context )
  { return BlocProvider<InfoCubit>
    ( create: (context) => InfoCubit(),
    child:  MaterialApp
      ( title: "Lights Out",
      home: MyHomePage(),
    ),
  );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    InfoCubit myCubit = BlocProvider.of<InfoCubit>(context);
    InfoState state = myCubit.state;

    return Scaffold(
      appBar: AppBar(
          title: Text("Lights Out")),
      body: BlocBuilder<InfoCubit, InfoState>(
        builder: (context, state) {

          // Create the grid
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "Goal: Get all of the lights to go out!",
                    style: TextStyle(fontSize: 30)),
                SizedBox.fromSize(size: Size(20, 20)),
                myCubit.createGrid(state.lightCount),
                SizedBox.fromSize(size: Size(20, 20)),
                // Input Text Box
                Container(
                  width: 300,
                  margin: EdgeInsets.all(20),
                  height: 400,
                  child:
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter number of lights",
                    ),
                    onSubmitted: (String s) {
                      int n = int.parse(s);
                      myCubit.update(n);
                    },
                  ),
                ),
                SizedBox.fromSize(size: Size(20, 20)),
                // Completion Message
                Text(
                    state.complete == 1 ? "Congrats! You win!" : "",
                    style: TextStyle(fontSize: 30)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Boxy extends Padding
{
  final double width;
  final double height;
  final Color color;
  Boxy( this.width,this.height, this.color )
      : super
      ( padding: EdgeInsets.all(4.0),
      child: Container
        ( width: width, height: height,
        decoration: BoxDecoration
          (
          border: Border.all(),
          color: color,
        ),
      ),
    );
}