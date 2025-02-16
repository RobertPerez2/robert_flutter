// Converter Homework
// Robert Perez 2025

import "dart:io";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoState {
  String preConversion = "";
  double convertedValue = 0;

  // 0 = C to F, 1 F to C,
  // 2 = Kg to Lb, 3 = Lb to Kg
  int conversionType = 0;

  InfoState(this.preConversion, this.convertedValue, this.conversionType);
}

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(InfoState("0", 0, 0));

  void update(String preConversion, double newConversion, int conversionType) {
    emit(InfoState(preConversion, newConversion, conversionType));
  }

  void convert(int conversionType) {
    double convertedValue = 0.0;

    double value = double.parse(state.preConversion);
    if(conversionType == 0) {
      // Celsius to Fahrenheit
      convertedValue = (value * 9/5) + 32;
    } else if(conversionType == 1) {
      // Fahrenheit to Celsius
      convertedValue = (value - 32) * 5/9;
    } else if(conversionType == 2) {
      // Kilograms to Pounds
      convertedValue = value * 2.20462;
    } else if(conversionType == 3) {
      // Pounds to Kilograms
      convertedValue = value / 2.20462;
    } else if(conversionType == 4) {
      emit(InfoState("0", 0, 0));
      return;
    }

    return update(state.preConversion, convertedValue, conversionType);
  }

  void updatePreConversion(String character) {
    String updatedValue;
    String storedValue = state.preConversion;

    if(character == "-") {
      if(storedValue[0] == "-") {
        updatedValue = storedValue.substring(1);
      } else {
        updatedValue = "-" + storedValue;
      }
    } else {
      if (storedValue == "0") {
        updatedValue = character;
      } else if (storedValue == "-0") {
        updatedValue = "-" + character;
      } else {
        updatedValue = storedValue + character;
      }
    }

    emit(InfoState(updatedValue, state.convertedValue, state.conversionType));
  }


}

void main()
{ runApp(Converter()); }

class Converter extends StatelessWidget
{
  Converter({super.key});

  Widget build( BuildContext context )
  {
    return BlocProvider<InfoCubit>(
      create: (context) => InfoCubit(),
      child: MaterialApp(
        title: "Converter",
        home: ConverterHomePage(),
      ),
    );
  }
}

class ConverterHomePage extends StatelessWidget
{
  const ConverterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    InfoCubit myCubit = BlocProvider.of<InfoCubit>(context);
    InfoState state = myCubit.state;

    List<String> gridContents = [
        "7", "8", "9",
        "4", "5", "6",
        "1", "2", "3",
        ".", "0", "-"
    ];

    // Building the Numerical Buttons
    Row theGrid = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children:[]
    );
    for ( int i=0; i<3; i++ ) {
      Column c = Column(
          spacing: 10,
          children:[]
      );
      for ( int j=0; j<4; j++ ) {
        c.children.add(

            ElevatedButton(
                style: ButtonStyle(
                //Make it clear
                fixedSize: MaterialStateProperty.all(Size(75, 75)),

            ),
            onPressed: () {
                myCubit.updatePreConversion(gridContents[(j * 3) + i]);
            },
            child: Text(
              gridContents[(j * 3) + i],
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center
            )
            ),

        );
      }
      theGrid.children.add(c);
    }


    // Building the Conversion Selection Buttons
    List<String> conversionOptions = [
      "C-F",
      "F-C",
      "Kg-Lb",
      "Lb-Kg",
      "Clear"
    ];

    Column conversionOptionsColumn = Column(
      spacing: 20,
      children: []
    );
    for (int i = 0; i < conversionOptions.length; i++) {
      conversionOptionsColumn.children.add(
          ElevatedButton(
          style: ButtonStyle(
            //Make it clear
            fixedSize: MaterialStateProperty.all(Size(100, 50)),

          ),
          onPressed: () {
            myCubit.convert(i);
          },
          child: Text(conversionOptions[i]),
        )
      );
    }


    // Putting Together the Calculator UI / Look
    return Scaffold(
      appBar: AppBar(
        title: Text("Converter Calculator"),
      ),
      body: BlocBuilder<InfoCubit, InfoState>(
        builder: (context, state) {
          return Center(
            child: Column(
              children: <Widget>[
                Container(
                  width: 400,
                  // padding: EdgeInsets.all(20),
                  height: 500,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing : 40,
                      children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 25,
                              children: [
                                Container(
                                width: 170,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 3),
                                ),
                                height: 70,
                                child: Text(
                                    state.preConversion,
                                    style: TextStyle(fontSize: 20))),

                              Container(
                                width: 170,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 3),
                                ),
                                height: 70,
                                child:
                                Text(
                                    state.convertedValue.toString(),
                                    style: TextStyle(fontSize: 20))),
                        ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              theGrid,
                              conversionOptionsColumn,
                            ])
                      ]
                  ),
                ),
              ],
            ),
          );
        }));
  }
}