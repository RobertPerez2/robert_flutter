// Groceries Lab
// Robert Perez 2025
// Allow users to add to a list (Grocery list), be able to save it to a file,
// and load it from a saved file

import "dart:io";
import "package:path_provider/path_provider.dart";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoState {
  List<String> groceries = [];
  String filename = "groceries.txt";

  InfoState(this.groceries);
}

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(InfoState([]));

  void update(List<String> new_groceries) {
    emit(InfoState(new_groceries));
  }

  void addGrocery(String grocery) {
    List<String> updated_groceries = List.from(state.groceries);
    updated_groceries.add(grocery);

    emit(InfoState(updated_groceries));
  }

  Future<String> whereAmI() async
  {
    // getApplicationDocumentsDirectory isn't supported by chrome(web)
    Directory mainDir = await getApplicationDocumentsDirectory();
    String mainDirPath = mainDir.path;
    // String mainDirPath = "Users/robertperez/Documents/GitHub/robert_flutter/lib";

    return mainDirPath;
  }

  Future<List<String>> loadGroceries() async
  {
    String myStuff = await whereAmI();
    String filePath = "$myStuff/groceries.txt";

    File fodder = File(filePath);
    String contents = fodder.readAsStringSync();

    List<String> groceries = contents.split("\n");
    return groceries;
  }

  Future<void> saveGroceries() async
  {
    String myStuff = await whereAmI();
    String filePath = "$myStuff/groceries.txt";
    print("filePath is $filePath");

    File fodder = File(filePath);
    if (!fodder.existsSync()) {
      fodder.createSync();
    }

    String groceries_string = state.groceries.join("\n");
    fodder.writeAsStringSync( groceries_string );
  }

}

void main() {
  runApp(Groceries());
}

class Groceries extends StatelessWidget {
  Groceries({super.key});

  Widget build(BuildContext context) {
    return BlocProvider<InfoCubit>(
      create: (context) => InfoCubit(),
      child: MaterialApp(
        title: "Groceries List",
        home: GroceriesHomePage(),
      ),
    );
  }
}

class GroceriesHomePage extends StatelessWidget {
  const GroceriesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    InfoCubit myCubit = BlocProvider.of<InfoCubit>(context);
    InfoState state = myCubit.state;

    return Scaffold(
      appBar: AppBar(
        title: Text("Groceries List"),
      ),
      body: BlocBuilder<InfoCubit, InfoState>(
        builder: (context, state) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: <Widget>[
                Text("Groceries:", style: TextStyle(fontSize: 25)),
                Column(
                  children:
                    state.groceries.map(
                      (grocery) => Text(grocery, style:TextStyle(fontSize: 15))
                    ).toList(),
                ),
                Container(
                  width: 300,
                  margin: EdgeInsets.all(20),
                  height: 50,
                  child: TextField(
                    onSubmitted: (String value) {
                      myCubit.addGrocery(value);
                    },
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20,
                    children: [
                  ElevatedButton(
                    onPressed: () async{
                      List<String> contents = await myCubit.loadGroceries();
                      myCubit.update(contents);
                    },
                    child: Text("Load Groceries"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      myCubit.saveGroceries();
                    },
                    child: Text("Save Groceries"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        myCubit.update([]);
                      },
                      child: Text("Clear Groceries"),
                  ),
                ])
              ],
          );
        }
      )
    );
  }

}
