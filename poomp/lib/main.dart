import 'dart:async';
import 'dart:convert';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:poomp/poomp_bloc.dart';

// var uri = "http://isharm.pythonanywhere.com/";
var uri = "http://192.168.1.74:8000/";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final audioCache = AudioCache();
  ConfettiController confettiController;
  Timer timer;

  // ignore: non_constant_identifier_names
  bool _poomp_enabled = true;
  PoompBloc _poompBloc = PoompBloc();

  @override
  void initState() {
    super.initState();
    _poompBloc.eventSink.add(PoompAction.Fetch);
    confettiController = ConfettiController(duration: Duration(seconds: 8));
    timer = Timer.periodic(
      Duration(seconds: 10),
      (Timer t) {
        _poompBloc.eventSink.add(PoompAction.Fetch);
      },
    );
    // fetchCount();
  }

  @override
  void dispose() {
    timer.cancel();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Stack(children: [
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StreamBuilder(
                    stream: _poompBloc.poompStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                      }
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          break;
                        case ConnectionState.waiting:
                          break;
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.hasData) {
                            if (snapshot.data["celebrate"] == "yes") {
                              print("Celebreations!!!");
                              confettiController.play();
                            } else {
                              print("UGHHH");
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${snapshot.data['count']}",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                                Text("Target: ${snapshot.data['target']}"),
                              ],
                            );
                          } else {
                            print(snapshot.error);
                          }
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  IconButton(
                    icon: Image.asset('horn.jpeg'),
                    iconSize: 150,
                    onPressed: !_poomp_enabled
                        ? null
                        : () {
                            _poompBloc.eventSink.add(PoompAction.Play);
                            audioCache.play("horn.wav");

                            setState(() {
                              _poomp_enabled = false;
                              // _fetchPoompCount = fetchPoompCount();
                            });
                            Timer(
                                Duration(milliseconds: 800),
                                () => setState(() {
                                      _poomp_enabled = true;
                                    }));
                          },
                  ),
                ],
              ),
            ),
            Align(
              child: ConfettiWidget(
                confettiController: this.confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                // blastDirection: 1,
                emissionFrequency: 0.2,
                numberOfParticles: 10,
              ),
              alignment: Alignment.topCenter,
            ),
          ]),
        ),
      ),
    );
  }
}
