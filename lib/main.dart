import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyGame());
}

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mini Brawler")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Your Brawler", style: TextStyle(fontSize: 28)),
          const Icon(Icons.sports_esports, size: 80),

          const SizedBox(height: 30),

          ElevatedButton(
            child: const Text("START"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamePage()),
              );
            },
          ),

          ElevatedButton(
            child: const Text("SHOP"),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

class Player {
  double x;
  double y;
  int power = 0;
  bool alive = true;

  Player(this.x, this.y);
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  final Random rng = Random();

  late Player player;
  List<Player> bots = [];
  List<Offset> cubes = [];

  Timer? loop;

  @override
  void initState() {
    super.initState();

    player = Player(200, 400);

    for (int i = 0; i < 10; i++) {
      bots.add(Player(rng.nextDouble()*400, rng.nextDouble()*600));
    }

    for (int i = 0; i < 8; i++) {
      cubes.add(Offset(rng.nextDouble()*400, rng.nextDouble()*600));
    }

    loop = Timer.periodic(const Duration(milliseconds: 100), updateGame);
  }

  void updateGame(Timer t) {

    for (var bot in bots) {
      if (!bot.alive) continue;

      bot.x += rng.nextDouble()*20 - 10;
      bot.y += rng.nextDouble()*20 - 10;
    }

    checkCubePickup();

    setState(() {});
  }

  void checkCubePickup() {

    cubes.removeWhere((cube) {
      if ((cube.dx - player.x).abs() < 30 &&
          (cube.dy - player.y).abs() < 30) {

        player.power++;
        return true;
      }
      return false;
    });
  }

  void movePlayer(double dx, double dy) {
    setState(() {
      player.x += dx;
      player.y += dy;
    });
  }

  void die() {
    player.alive = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("You died"),
        actions: [

          TextButton(
            child: const Text("Leave"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),

          TextButton(
            child: const Text("Play Again"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GamePage()),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    loop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          Container(color: Colors.green.shade900),

          ...cubes.map((c) =>
            Positioned(
              left: c.dx,
              top: c.dy,
              child: Container(
                width: 20,
                height: 20,
                color: Colors.purple,
              ),
            )
          ),

          ...bots.map((b) =>
            Positioned(
              left: b.x,
              top: b.y,
              child: const Icon(Icons.android, size: 30),
            )
          ),

          Positioned(
            left: player.x,
            top: player.y,
            child: const Icon(Icons.person, size: 35),
          ),

          Positioned(
            bottom: 50,
            left: 30,
            child: Column(
              children: [
                ElevatedButton(onPressed: ()=>movePlayer(0,-20), child: const Text("↑")),
                Row(
                  children: [
                    ElevatedButton(onPressed: ()=>movePlayer(-20,0), child: const Text("←")),
                    ElevatedButton(onPressed: ()=>movePlayer(20,0), child: const Text("→")),
                  ],
                ),
                ElevatedButton(onPressed: ()=>movePlayer(0,20), child: const Text("↓")),
              ],
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: Text("Power: ${player.power}", style: const TextStyle(fontSize: 20)),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: ElevatedButton(
              child: const Text("Die"),
              onPressed: die,
            ),
          )

        ],
      ),
    );
  }
}
