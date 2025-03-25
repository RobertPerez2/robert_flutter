// Robert Perez
// API Homework

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// Base URL: https://developer.nps.gov/api/v1/ extra: alerts?parkCode=acad,dena
// API Key: JZDRfikdel8eb6hMVWnBieorTUEovncTv1Rj1CQ6


class InfoState {
  List<String> parks;
  String selectedState;

  List<String> states = [
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
  ];

  InfoState(this.parks, this.selectedState);
}

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(InfoState([], "Select a State"));

  void update(List<String> parks, String selectedState) { emit(InfoState(parks, selectedState)); }
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

    return Scaffold(
      appBar: AppBar(title: Text("Get National Parks by State")),
      body: SingleChildScrollView(child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            DropdownButton(items:
            state.states.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
              onChanged: (String? value) async
            {
              List<String> parks = await _networkCall(value!);
              await Future.delayed( Duration(milliseconds:200) );
              myCubit.update(parks, value);
            },
              hint: Text(state.selectedState),
            ),
            for (String park in state.parks) Text(park),
          ],
        ),
      )),
    );
  }

  Future<List<String>> _networkCall(String stateCode) async
  {
    final url = Uri.parse('https://developer.nps.gov/api/v1/parks?stateCode=${stateCode}&api_key=JZDRfikdel8eb6hMVWnBieorTUEovncTv1Rj1CQ6');
    final response = await http.get(url);
    Map<String,dynamic> dataAsMap = jsonDecode(response.body);
    // print(dataAsMap);
    List<dynamic> dataFields = dataAsMap['data'];

    List<String> parkNames = [];
    for (int i = 0; i < dataFields.length; i++) {
      parkNames.add(dataFields[i]['fullName']);
    }

    return parkNames;
  }
}