import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:yoda/yoda.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late YodaController _yodaControllerExplode;
  late YodaController _yodaControllerCard;
  late YodaController _yodaControllerVortex;
  @override
  void initState() {
    super.initState();
    _yodaControllerExplode = YodaController()
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _yodaControllerExplode.reset();
      }
    });
    _yodaControllerVortex = YodaController()
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _yodaControllerVortex.reset();
      }
    });
    _yodaControllerCard = YodaController()
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _yodaControllerCard.reset();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Yoda example'),
        ),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Yoda(
                  yodaEffect: YodaEffect.Explosion,
                  controller: _yodaControllerExplode,
                  duration: Duration(milliseconds: 2500),
                  animParameters: AnimParameters(
                    yodaBarrier: YodaBarrier(bottom: true, left: true, right: true),
                    fractionalCenter: Offset(0.5, 1.0),
                    hTiles: 12,
                    vTiles: 12,
                    power: 0.3,
                    gravity: 1.0
                  ),
                  startWhenTapped: true,
                  child: SizedBox(
                    width: 300,
                    height: 200,
                    child: Image.asset('assets/forest.jpg', fit: BoxFit.fill)
                    // child: Container(color: Colors.green)
                  )
              ),

              SizedBox(height: 20),

              Yoda(
                  yodaEffect: YodaEffect.Explosion,
                  controller: _yodaControllerCard,
                  duration: Duration(milliseconds: 2500),
                  animParameters: AnimParameters(
                      yodaBarrier: YodaBarrier(top: true, bottom: true, left: true, right: true),
                      fractionalCenter: Offset(0.5, 0.5),
                      hTiles: 40,
                      vTiles: 20,
                      power: 0.1,
                      gravity: 0
                  ),
                  startWhenTapped: true,
                  child: SizedBox(
                    height: 100,
                    child: Card(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset('assets/dash.png', fit: BoxFit.fill, height: 60),
                              Image.asset('assets/forest.jpg', fit: BoxFit.fill, height: 60)
                            ],
                          ),
                          Text('YODA example'),
                        ],
                      ),
                    ),
                  )
              ),

              SizedBox(height: 20),

              Yoda(
                  yodaEffect: YodaEffect.Vortex,
                  controller: _yodaControllerVortex,
                  duration: Duration(milliseconds: 2500),
                  animParameters: AnimParameters(
                    yodaBarrier: YodaBarrier(top: true, bottom: true, left: true, right: true),
                    fractionalCenter: Offset(0.5, 1.0),
                    hTiles: 20,
                    vTiles: 20,
                    power: 10,
                    gravity: 0
                  ),
                  startWhenTapped: true,
                  child: SizedBox(
                    width: 300,
                    height: 200,
                    child: Image.asset('assets/dash.png', fit: BoxFit.fill)
                    // child: Container(color: Colors.green)
                  )
              ),

            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _yodaControllerExplode.start();
            _yodaControllerCard.start();
            _yodaControllerVortex.start();
          },
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
