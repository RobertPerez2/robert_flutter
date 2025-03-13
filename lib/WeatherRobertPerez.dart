// Robert Perez
// Weather Lab

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// Base URL: http://api.weatherapi.com/v1/current.json
// API Key: a21bf56597c54d66b99232123251303

// EX: http://api.weatherapi.com/v1/current.json?key=<YOUR_API_KEY>&q=London
// ex: http://api.weatherapi.com/v1/current.json?key=a21bf56597c54d66b99232123251303&q=90001
// temp_f

class InfoState {
  int temperature;

  InfoState(this.temperature);
}

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(InfoState(0));

  void update(int temp) { emit(InfoState(temp)); }
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
      appBar: AppBar(title: Text("Weather")),
      body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                Text("Temperature: ${state.temperature}°F"),
                ElevatedButton( onPressed: () async
                {
                  int temp = await _networkCall();
                  await Future.delayed( Duration(milliseconds:200) );
                  myCubit.update(temp);
                },
                  child: Text("Get Weather at Zip Code: 90001"),
                ),
              ],
            ),
          ),
    );
  }

  Future<int> _networkCall() async
  {
    final url = Uri.parse('http://api.weatherapi.com/v1/current.json?key=a21bf56597c54d66b99232123251303&q=90001');
    final response = await http.get(url);
    Map<String,dynamic> dataAsMap = jsonDecode(response.body);
    // print(dataAsMap);
    Map<String,dynamic> dataFields = dataAsMap['current'];

    // print(dataFields);
    int temperature = dataFields['temp_f'];
    // print(temperature);
    return temperature;
  }
}