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
  late YodaController _yodaControllerVortex;
  late YodaController _yodaControllerFlocks;
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
    _yodaControllerFlocks = YodaController()
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _yodaControllerFlocks.reset();
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
                    hTiles: 20,
                    vTiles: 20,
                    power: 0.3,
                    gravity: 1.0
                  ),
                  startWhenTapped: true,
                  child: SizedBox(
                    width: 250,
                    height: 180,
                    child: Image.asset('assets/dash.png', fit: BoxFit.fill)
                  )
              ),

              SizedBox(height: 12),

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
                      width: 250,
                      height: 180,
                      child: Image.asset('assets/dash2.png', fit: BoxFit.fill)
                  )
              ),

              SizedBox(height: 12),

              Yoda(
                  yodaEffect: YodaEffect.Flakes,
                  controller: _yodaControllerFlocks,
                  duration: Duration(milliseconds: 2500),
                  animParameters: AnimParameters(
                    yodaBarrier: YodaBarrier(),
                    // fractionalCenter: Offset(0.5, 1.0), // not used in the Flocks effect
                    hTiles: 20,
                    vTiles: 20,
                    power: 10,
                    gravity: 30
                  ),
                  startWhenTapped: true,
                  child: SizedBox(
                    width: 250,
                    height: 180,
                    child: Image.asset('assets/dash3.png', fit: BoxFit.fill)
                  )
              ),

            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _yodaControllerExplode.start();
            _yodaControllerVortex.start();
            _yodaControllerFlocks.start();
          },
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
