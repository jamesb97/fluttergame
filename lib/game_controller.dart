import 'dart:math';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:game/components/enemy.dart';
import 'package:game/components/health_bar.dart';
import 'package:game/components/highscore_text.dart';
import 'dart:ui';

import 'package:game/components/player.dart';
import 'package:game/components/score_text.dart';
import 'package:game/components/start_text.dart';
import 'package:game/enemy_spawner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/state.dart';

class GameController extends Game {
  final SharedPreferences storage;
  Random rand;
  Size screenSize;
  double tileSize;
  Player player;
  EnemySpawner enemySpawner;
  List<Enemy> enemies;
  HealthBar healthBar;
  int score;
  ScoreText scoreText;
  State state;
  HighscoreText highscoreText;
  StartText startText;

  GameController(this.storage) {
    initialize();
  }
  void initialize() async {
    resize(await Flame.util.initialDimensions());
    state = State.menu;
    rand = Random();
    player = Player(this);
    enemies = List<Enemy>();
    enemySpawner = EnemySpawner(this);
    healthBar = HealthBar(this);
    score = 0;
    scoreText = ScoreText(this);
    highscoreText = HighscoreText(this);
    startText = StartText(this);
  }

  //Initialize a canvas for game component
  void render(Canvas c) {
    Rect background = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()..color = Color(0xFFFAFAFA);
    c.drawRect(background, backgroundPaint);
    //Render the player component
    player.render(c);
    if (state == State.menu) {
      //startText
      startText.render(c);
      //highscoreText
      highscoreText.render(c);
    } else if (state == State.playing) {
      enemies.forEach((Enemy enemy) => enemy.render(c));
      scoreText.render(c);
      healthBar.render(c);
    }
  }

  //Update game status
  void update(double t) {
    if (state == State.menu) {
      //startText
      startText.update(t);
      //highscoreText
      highscoreText.update(t);
    } else if (state == State.playing) {
      enemySpawner.update(t);
      enemies.forEach((Enemy enemy) => {enemy.update(t)});
      enemies.removeWhere((Enemy enemy) => enemy.isDead);
      player.update(t);
      scoreText.update(t);
      healthBar.update(t);
    }
  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 10;
  }

  void onTapDown(TapDownDetails d) {
    //print(d.globalPosition);
    if (state == State.menu) {
      state = State.playing;
    } else if (state == State.playing) {
      enemies.forEach((Enemy enemy) {
        if (enemy.enemyRect.contains(d.globalPosition)) {
          enemy.onTapDown();
        }
      });
    }
  }

  //Declare a function which spawns enemies at random
  void spawnEnemy() {
    double x, y;
    switch (rand.nextInt(4)) {
      case 0:
        //Top Side
        x = rand.nextDouble() * screenSize.width;
        y = -tileSize * 2.5;
        break;
      case 1:
        //Right side
        x = screenSize.width + tileSize * 2.5;
        y = rand.nextDouble() * screenSize.height;
        break;
      case 2:
        //Bottom side
        x = rand.nextDouble() * screenSize.width;
        y = screenSize.height + tileSize * 2.5;
        break;
      case 3:
        //Left Side
        x = -tileSize * 2.5;
        y = rand.nextDouble() * screenSize.height;
        break;
    }
    enemies.add(Enemy(this, x, y));
  }
}
