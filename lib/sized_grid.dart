// Sized Grid Lab
// Robert Perez 2025
// let user enter 2D grid size, make grid that size

import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoState {
  int width = 4;
  int height = 3;

  InfoState(this.width, this.height);
}

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(InfoState(4, 3));

  void incrementHeight() {
    emit(InfoState(state.width, state.height + 1));
  }

  void incrementWidth() {
    emit(InfoState(state.width + 1, state.height));
  }

  void decrementHeight() {
    if (state.height > 1) {
      emit(InfoState(state.width, state.height - 1));
    } else {
      emit(InfoState(state.width, 1));
    }
  }

  void decrementWidth() {
    if (state.width > 1) {
      emit(InfoState(state.width - 1, state.height));
    } else {
      emit(InfoState(1, state.height));
    }
  }
}

void main()
{ runApp(SG()); }

class SG extends StatelessWidget
{
  SG({super.key});

  Widget build( BuildContext context )
  {
    return BlocProvider<InfoCubit>(
      create: (context) => InfoCubit(),
      child: MaterialApp(
        title: "sized grid prep",
        home: SG1(),
      ),
    );
  }
}

class SG1 extends StatelessWidget
{
  SG1({super.key});

  Widget build( BuildContext context )
  {
    InfoCubit myCubit = BlocProvider.of<InfoCubit>(context);
    InfoState state = myCubit.state;

    return Scaffold
      ( appBar: AppBar( title: Text("Robert's Sized Grid Lab") ),
        body: BlocBuilder<InfoCubit, InfoState>(
        builder: (context, state) {

          Row theGrid = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[]
          );
          for ( int i=0; i<state.width; i++ )
          { Column c = Column(children:[]);
          for ( int j=0; j<state.height; j++ )
          { c.children.add( Boxy(40,40)  );
          }
          theGrid.children.add(c);
          }

          return Center (
            child: Column(
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () => myCubit.incrementHeight(),
                  tooltip: 'Increment Height',
                  child: const Text("Height+"),
                ),
                SizedBox.fromSize(size: Size(20, 20)),
                FloatingActionButton(
                  onPressed: () => myCubit.incrementWidth(),
                  tooltip: 'Increment Width',
                  child: const Text("Width+"),
                ),
                SizedBox.fromSize(size: Size(20, 20)),
                FloatingActionButton(
                  onPressed: () => myCubit.decrementHeight(),
                  tooltip: 'Decrement Height',
                  child: const Text("Height-"),
                ),
                SizedBox.fromSize(size: Size(20, 20)),
                FloatingActionButton(
                  onPressed: () => myCubit.decrementWidth(),
                  tooltip: 'Decrement Width',
                  child: const Text("Width-"),
                ),
              ],
            ),
            SizedBox.fromSize(size: Size(20, 20)),
            theGrid,
            ],
            ),);
        }),
    );
  }
}

class Boxy extends Padding {
  final double width;
  final double height;

  Boxy(this.width, this.height)
      : super
      (padding: EdgeInsets.all(4.0),
      child: Container
        (width: width, height: height,
        decoration: BoxDecoration
          (border: Border.all(),),
        child: Text("x"),
      ),
    );
}