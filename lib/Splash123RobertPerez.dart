// Robert Perez
// Splash123 Lab

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

TextStyle ts = TextStyle(fontSize: 30);

class InfoState
{
  int count;
  InfoState( this.count );
}

class InfoCubit extends Cubit<InfoState>
{
  InfoCubit() : super( InfoState(0) );

  void increment() { emit( InfoState(state.count+1) ); }
  void decrement() { emit( InfoState(state.count-1) ); }
}

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfoCubit>(
      create: (context) => InfoCubit(),
      child: MaterialApp(
        title: 'Splash123',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Page1(title: 'Page 1'),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    InfoCubit cc = BlocProvider.of<InfoCubit>(context);


  return BlocProvider<InfoCubit>.value (value: cc,
    child: BlocBuilder<InfoCubit, InfoState>
    (builder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: Text(title, style: ts)),
        body: Center( child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children:
          [
            Text("${cc.state.count}", style: ts),
            ElevatedButton(onPressed: () {
              cc.increment(); },
              child: const Icon(Icons.add),
            ),
            ElevatedButton(onPressed: () {
              cc.decrement(); },
              child: const Icon(Icons.remove),
            ),
            ElevatedButton(onPressed: () {
              Navigator.of(context).push
                (MaterialPageRoute(builder: (context) => Page2(cc: cc)),);
            },
              child: Text("Go to Page 2", style: ts),
            ),
            ElevatedButton(onPressed: () {
              Navigator.of(context).push
                (MaterialPageRoute(builder: (context) => Page3(cc: cc)),);
            },
              child: Text("Go to Page 3", style: ts),
            ),
          ],
        ),
      ));
    }));
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key, required this.cc});
  final InfoCubit cc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfoCubit>.value (value: cc,
      child: BlocBuilder<InfoCubit, InfoState>
      (builder: (context, state) {
        return Scaffold(
          appBar: AppBar( title: Text( "Page 2", style: ts) ),
            body: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children:
            [
              Text("${cc.state.count}",style:ts),
              ElevatedButton(onPressed: () {
                cc.increment(); },
                child: const Icon(Icons.add),
              ),
              ElevatedButton(onPressed: () {
                cc.decrement(); },
                child: const Icon(Icons.remove),
              ),
              ElevatedButton(onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text("Go to Page 1", style: ts),
              ),
              ElevatedButton( onPressed: ()
              { Navigator.of(context).push
                ( MaterialPageRoute( builder: (context) => Page3( cc:cc) ), );
              },
                child: Text("Go to page 3", style:ts),
              ),
            ]),
            ));
    }));
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key, required this.cc});
  final InfoCubit cc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfoCubit>.value (value: cc,
        child: BlocBuilder<InfoCubit, InfoState>
          (builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text("Page 3", style: ts)),
            body: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children:
            [
              Text("${cc.state.count}", style: ts),
              ElevatedButton(onPressed: () {
                cc.increment(); },
                child: const Icon(Icons.add),
              ),
              ElevatedButton(onPressed: () {
                cc.decrement(); },
                child: const Icon(Icons.remove),
              ),
              ElevatedButton(onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
                child: Text("Go to Page 1", style: ts),
              ),
              ElevatedButton(onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).push
                  ( MaterialPageRoute( builder: (context) => Page2(cc:cc) ), );
              },
                child: Text("Go to Page 2", style: ts),
              ),
            ]),
            ));
    }));
  }
}