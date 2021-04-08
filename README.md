# yoda

Flutter effects widget: cut widgets in NxM tiles and animate them.

![Alt text](https://github.org/alnitak/blob/master/img/yoda.gif?raw=true "yoda Demo")

## Yoda Widget Properties

##### Yoda widget
* [**yodaEffect**] Animation effect to use (see below).
* [**controller**] Animation controller.
* [**duration**] Animation duration.
* [**startWhenTapped**] Enable tap gesture to start animation.
* [**animParameters**] Parameters used to animate tiles (see below).
* [**child**] Whatever widget to slice.

##### YodaEffect enum
* [**Explosion**]
* [**Vortex**]
* [**Flakes**]

##### AnimParameters properties
* [**yodaBarrier**] Define which edges are barraged (see below).
* [**hTiles**] Number of horizontal tiles to divide the child widget.
* [**vTiles**] Number of vertical tiles to divide the child widget.
* [**fractionalCenter**] Default center where force is given when not tapping on it.
* [**gravity**] Vertical force.
* [**power**] Strength of the effect.

##### YodaBarrier properties
* [**left**] Block tiles moving over the left edge.
* [**right**] Block tiles moving over the right edge.
* [**top**] Block tiles moving over the top edge.
* [**bottom**] Block tiles moving over the bottom edge.


## How to use

If you need to control the animation status:
```dart
  YodaController _yodaControllerExplode;
  
@override
  void initState() {
    super.initState();
    _yodaControllerExplode = YodaController()
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _yodaControllerExplode.reset();
      }
    });
  }
```
YodaController accept start() and reset() methods.


```dart
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
)
```

----
##### TODO
- Find a better way to capture the widget
- When changing Yoda widget parameters, 2 hot reloads are needed to make it to work!