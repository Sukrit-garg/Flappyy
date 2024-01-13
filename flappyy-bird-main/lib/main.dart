import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Bird',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(), // Set the GameScreen as the home screen of the app
    );
  }
}
class Pipe {
  double x;
  double y;
  double width;
  double height;

  Pipe({required this.x, required this.y, required this.width, required this.height});
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  double birdYPosition = 0.0;
  double birdYVelocity = 0.0;
  final double gravity = 0.5;
  late Ticker _ticker;
  List<Pipe> pipes = [];
  double pipeGap = 200.0;
  double pipeWidth = 80.0;
  double pipeSpeed = 2.0;
  Random random = Random();
  int score = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initializePipes();
      _ticker = createTicker((elapsed) => updateGame(elapsed));
      _ticker.start();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void initializePipes() {
    double screenWidth = MediaQuery.of(context).size.width;
    double initialX = screenWidth;
    while (initialX > -pipeWidth) {
      double randomHeight = random.nextDouble() * 300;
      pipes.add(Pipe(
        x: initialX,
        y: 0.0,
        width: pipeWidth,
        height: randomHeight,
      ));
      pipes.add(Pipe(
        x: initialX,
        y: randomHeight + pipeGap - 100,
        width: pipeWidth,
        height: MediaQuery.of(context).size.height - randomHeight - pipeGap,
      ));
      initialX -= pipeWidth + 200.0;
    }
  }

  void updateGame(Duration elapsed) {
    updateBirdPosition();
    updatePipes();
    checkCollision();
  }

  void updateBirdPosition() {
    setState(() {
      birdYVelocity += gravity;
      birdYPosition += birdYVelocity;
    });
  }

  void updatePipes() {
    setState(() {
      for (int i = 0; i < pipes.length; i++) {
        pipes[i].x -= pipeSpeed;
        if (pipes[i].x + pipeWidth < 0) {
          pipes.removeAt(i);
          i--;
          continue;
        }
      }
      if (pipes.length < 4) {
        double screenWidth = MediaQuery.of(context).size.width;
        double randomHeight = random.nextDouble() * 300 + 100;
        pipes.add(Pipe(
          x: screenWidth,
          y: 0.0,
          width: pipeWidth,
          height: randomHeight,
        ));
        pipes.add(Pipe(
          x: screenWidth,
          y: randomHeight + pipeGap,
          width: pipeWidth,
          height: MediaQuery.of(context).size.height - randomHeight - pipeGap,
        ));
      }
    });
  }

  void checkCollision() {
    // TODO: Add collision detection logic
    // Update score if bird crosses the gap in the pipes
    double birdMidX = MediaQuery.of(context).size.width / 2;
    for (Pipe pipe in pipes) {
      if (pipe.x <= birdMidX && pipe.x + pipeWidth > birdMidX) {
        setState(() {
          score += 1;
        });
      }
    }
  }

  void onTapScreen() {
    setState(() {
      birdYVelocity = -10.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
        onTap: onTapScreen,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
    alignment: Alignment.center,
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage('assets/background.jpeg'),
    fit: BoxFit.cover,
    ),
    ),
          child: Stack(
            children: [
              ...pipes.map((pipe) {
                return Positioned(
                  top: pipe.y,
                  left: pipe.x,
                  child: Image.asset(
                    pipe.y == 0 ? 'assets/pipe_top.png' : 'assets/pipe_bottom.png',
                    width: pipe.width,
                    height: pipe.height,
                  ),
                );
              }).toList(),
              Positioned(
                top: 20,
                right: 20,
                child: Text(
                  'Score: ${score ~/ 80}',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                alignment: Alignment(0, birdYPosition / MediaQuery.of(context).size.height),
                child: Image.asset(
                  'assets/bird.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ],
          ),

        ),
        ),
    );
  }
}
