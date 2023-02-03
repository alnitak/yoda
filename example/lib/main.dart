import 'package:flutter/material.dart';
import 'package:yoda/yoda.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YodaExample(),
    );
  }
}

class YodaExample extends StatefulWidget {
  @override
  _YodaExampleState createState() => _YodaExampleState();
}

class _YodaExampleState extends State<YodaExample> {
  List<Yoda> items = [];

  @override
  void initState() {
    super.initState();
    buildItems();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Yoda example'),
      ),
      body: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (final item in items)
              SizedBox(width: width / 2, height: width / 2 * 0.9, child: item)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            buildItems();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  buildItems() {
    items.add(
      Yoda(
        yodaEffect: YodaEffect.Explosion,
        controller: YodaController()
          ..addStatusListener((status, context) {
            if (status == AnimationStatus.completed) {
              items.removeWhere((element) {
                bool isEqual =
                    element.controller!.getKey() == context.widget.key;
                if (isEqual) setState(() {});
                return isEqual;
              });
            }
          }),
        duration: Duration(milliseconds: 2000),
        animParameters: AnimParameters(
            yodaBarrier: YodaBarrier(bottom: true),
            fractionalCenter: Offset(0.5, 1.0),
            hTiles: 20,
            vTiles: 20,
            effectPower: 0.2,
            gravity: 0.1,
            blurPower: 5,
            randomness: 30),
        startWhenTapped: true,
        child: YodaCard(assetName: 'assets/dash.png'),
      ),
    );

    items.add(
      Yoda(
          yodaEffect: YodaEffect.Vortex,
          controller: YodaController()
            ..addStatusListener((status, context) {
              if (status == AnimationStatus.completed) {
                items.removeWhere((element) {
                  bool isEqual =
                      element.controller!.getKey() == context.widget.key;
                  if (isEqual) setState(() {});
                  return isEqual;
                });
              }
            }),
          duration: Duration(milliseconds: 2500),
          animParameters: AnimParameters(
              yodaBarrier:
                  YodaBarrier(top: true, bottom: true, left: true, right: true),
              fractionalCenter: Offset(0.5, 1.0),
              hTiles: 20,
              vTiles: 20,
              effectPower: 10,
              gravity: 0,
              blurPower: 5,
              randomness: 20),
          startWhenTapped: true,
          child: YodaCard(assetName: 'assets/dash2.png')),
    );

    items.add(
      Yoda(
          yodaEffect: YodaEffect.Flakes,
          controller: YodaController()
            ..addStatusListener((status, context) {
              if (status == AnimationStatus.completed) {
                items.removeWhere((element) {
                  bool isEqual =
                      element.controller!.getKey() == context.widget.key;
                  if (isEqual) setState(() {});
                  return isEqual;
                });
              }
            }),
          duration: Duration(milliseconds: 2500),
          animParameters: AnimParameters(
              yodaBarrier: YodaBarrier(),
              // fractionalCenter: Offset(0.5, 1.0), // not used in the Flocks effect
              hTiles: 20,
              vTiles: 20,
              effectPower: 10,
              gravity: 30,
              blurPower: 30,
              randomness: 30),
          startWhenTapped: true,
          child: YodaCard(
            assetName: 'assets/dash3.png',
          )),
    );

    items.add(
      Yoda(
        yodaEffect: YodaEffect.Explosion,
        controller: YodaController()
          ..addStatusListener((status, context) {
            if (status == AnimationStatus.completed) {
              items.indexWhere((element) {
                bool isEqual =
                    element.controller!.getKey() == context.widget.key;
                if (isEqual) element.controller!.reset();
                return isEqual;
              });
            }
          }),
        duration: Duration(milliseconds: 1000),
        animParameters: AnimParameters(
            yodaBarrier: YodaBarrier(bottom: true),
            fractionalCenter: Offset(0.5, 1.0),
            hTiles: 20,
            vTiles: 20,
            effectPower: 0.1,
            gravity: 0.5,
            blurPower: 0,
            randomness: 0),
        startWhenTapped: true,
        child: YodaCard(assetName: 'assets/dash.png'),
      ),
    );

    items.add(
      Yoda(
        yodaEffect: YodaEffect.Flakes,
        controller: YodaController()
          ..addStatusListener((status, context) {
            if (status == AnimationStatus.completed) {
              items.indexWhere((element) {
                bool isEqual =
                    element.controller!.getKey() == context.widget.key;
                if (isEqual) element.controller!.reset();
                return isEqual;
              });
            }
          }),
        duration: Duration(milliseconds: 1000),
        animParameters: AnimParameters(
            yodaBarrier: YodaBarrier(),
            fractionalCenter: Offset(0.5, 1.0),
            hTiles: 20,
            vTiles: 20,
            effectPower: 0,
            gravity: 2,
            blurPower: 0,
            randomness: 80),
        startWhenTapped: true,
        child: YodaCard(assetName: 'assets/dash.png'),
      ),
    );

    items.add(
      Yoda(
          yodaEffect: YodaEffect.Vortex,
          controller: YodaController()
            ..addStatusListener((status, context) {
              if (status == AnimationStatus.completed) {
                items.indexWhere((element) {
                  bool isEqual =
                      element.controller!.getKey() == context.widget.key;
                  if (isEqual) element.controller!.reset();
                  return isEqual;
                });
              }
            }),
          duration: Duration(milliseconds: 2500),
          animParameters: AnimParameters(
              yodaBarrier:
                  YodaBarrier(top: true, bottom: true, left: true, right: true),
              fractionalCenter: Offset(0.5, 1.0),
              hTiles: 30,
              vTiles: 30,
              effectPower: 5,
              gravity: 0,
              blurPower: 0,
              randomness: 10),
          startWhenTapped: true,
          child: YodaCard(assetName: 'assets/dash.png')),
    );
  }
}

class YodaCard extends StatelessWidget {
  final String assetName;

  YodaCard({
    required this.assetName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Text(
            'Flutter is awesome',
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaleFactor: 1.2,
          ),
          Image.asset(assetName, fit: BoxFit.fitHeight),
        ],
      ),
    );
  }
}
