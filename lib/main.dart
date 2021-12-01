import 'package:dart_chess/common/constants.dart';
import 'package:dart_chess/figures/figure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dart_chess/room.dart';


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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Шахматки'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Room room = Room(1, 1, 2);

  void _reset() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      room = Room(1, 1, 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: room.game.winPlayer == null ? board() : endGame(),
      floatingActionButton: FloatingActionButton(
        onPressed: _reset,
        tooltip: 'Reset game',
        child: Icon(Icons.cached),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget endGame() {
    var textColor =
        room.game.winPlayer == room.player1 ? Colors.green : Colors.red;
    String text =
        room.game.winPlayer == room.player1 ? 'Вы выиграли!' : 'Вы проиграли!';
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 50,
        ),
      ),
    );
  }

  Widget board() {
    List<Widget> board = [];
    int index = 0;
    for (int i = 0; i < room.game.gameBoard.keys.length; i += 8) {
      List<Widget> column = [];
      for (int j = i; j < i + 8; j++) {
        column.add(space(room.game.gameBoard.keys.toList()[j], index + j));
      }
      index++;
      board.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: column,
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: board,
    );
  }

  Widget space(SpaceName point, int index) {
    Figure nullFigure = NullFigure();
    List<SpaceName> possibilityPoints = [];
    if (room.game.activeFigure != nullFigure) {
      possibilityPoints =
          room.game.getPossibilityPoints(room.game.activeFigure);
    }
    Widget value = _getIcon(point, possibilityPoints);
    return GestureDetector(
      onTap: () {
        setState(() {
          Figure figure = room.game.chooseFigure(point);
          if (room.game.activeFigure == nullFigure) {
            if (figure != nullFigure && !room.game.canMove(figure)) {
              print('Эта фигура сейчас не может двигаться');
            } else {
              room.game.activeFigure = figure;
            }
          } else {
            bool canMove =
                room.game.checkPossibilityToMove(room.game.activeFigure, point);
            if (canMove) {
              room.game.move(room.game.activeFigure, point);
              room.computerStep();
            }
          }
        });
      },
      child: Container(
        width: 42,
        height: 42,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: index % 2 == 0 ? Colors.yellow[100] : Colors.brown[400],
        ),
        child: Center(
          // child: Text(
          //   value,
          //   style: TextStyle(
          //     color: colorText,
          //     fontWeight: FontWeight.w900,
          //   ),
          // ),
          child: value,
        ),
      ),
    );
  }

  Widget _getIcon(SpaceName point, List<SpaceName> possibilityPoints) {
    Figure figure = room.game.gameBoard[point]!;

    if (figure == NullFigure()) {
      if (possibilityPoints.contains(point)) {
        return Icon(
          Icons.adjust,
          color: Colors.grey,
        );
      } else {
        return Text(' ');
      }
    }
    var figureColor = figure.color.index == 1 ? Colors.green[200] : Colors.black;
    if (figure == room.game.activeFigure) {
      figureColor = Colors.green;
    }
    String assetPath = "assets/icons/pawn.png";
    switch (figure.runtimeType) {
      case Pawn:
        assetPath = "assets/icons/pawn.png";
        break;
      case Queen:
        assetPath = "assets/icons/queen.png";
        break;
      case Castle:
        assetPath = "assets/icons/castle.png";
        break;
      case King:
        assetPath = "assets/icons/king.png";
        break;
      case Horse:
        assetPath = "assets/icons/horse.png";
        break;
      case Bishop:
        assetPath = "assets/icons/bishop.png";
        break;
    }
    var figureIcon = Image.asset(assetPath, color: figureColor);
    if (possibilityPoints.contains(point)) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Icon(
            Icons.my_location,
            size: 35,
            color: Colors.red,
          ),
          figureIcon
        ],
      );
    }
    return figureIcon;
  }
}
