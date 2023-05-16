import processing.core.*;
import java.util.Set;
import java.util.HashSet;
import java.util.Collections;
import java.util.List;
import processing.sound.*;

SoundFile pew1, pew2, boom1, boom2, boom3, music;
int score = 0;
int roundNum = 0;
int canvasWidth = 1200, canvasHeight = 900;
ArrayList<GameObj> citys = new ArrayList<GameObj>();
ArrayList<GameObj> bases = new ArrayList<GameObj>();
ArrayList<GameObj> explosions = new ArrayList<GameObj>();
ArrayList<GameObj> missiles = new ArrayList<GameObj>();
Set<Integer> missilesToRemove = new HashSet<Integer>();
PFont scorefont;
PFont titlefont;
PImage backgroundImage;
int endFrame = 0;
int currentFrame = 0;
boolean roundStarted = false;
boolean gameOver = false;
int lives = 6;



class GameObj {
  boolean isEnemy;
  PVector pos;
  PVector v;
  color col;
  int tail;
  boolean alive;
  int armedIn;
  PVector dest;
  long birthTime;

  GameObj(PVector pos, PVector v, color col, int tail, boolean alive, int armedIn, PVector dest, boolean isEnemy) {
    this.pos = pos;
    this.v = v;
    this.col = col;
    this.tail = tail;
    this.alive = alive;
    this.armedIn = armedIn;
    this.dest = dest;
    this.isEnemy = isEnemy;
    this.birthTime = System.currentTimeMillis();
  }
}

void createCity() {
    for (int i = 0; i < 6; i++) {
    citys.add(new GameObj(new PVector(267 + 133 * i, canvasHeight - 20), null, color(0, 255, 0), 0, true, 0, null, false));
  }
}

void mousePressed() {
    if (gameOver) {
    createCity();
    roundNum = 1;
    score = 0;
    lives = 3;
    currentFrame = 0;
    endFrame = 300;
    gameOver = false;
  }
}

// Set up canvas and initialize game objects
void setup() {
  size(1200, 900);
  scorefont = createFont("Comic Sans MS", 15);
  titlefont = createFont("Comic Sans MS", 100);
  backgroundImage = loadImage("background.png");
  pew1 = new SoundFile(this, "pew1.mp3");
  pew2 = new SoundFile(this, "pew2.mp3");
  boom1 = new SoundFile(this, "boom1.mp3");
  boom2 = new SoundFile(this, "boom2.mp3");
  boom3 = new SoundFile(this, "boom3.mp3");
  music = new SoundFile(this, "music.mp3");
  music.loop();
  createCity();
  for (int x = 0; x < 5; x++) {
    bases.add(new GameObj(new PVector(333 + 133 * x, canvasHeight - 20), null, color(100, 255, 50), 0, true, 0, null, false));
  }
}



// Main game draw loop
void draw() {
  image(backgroundImage, 0, 0, canvasWidth, canvasHeight);

  for (GameObj city : citys) {
    cityGradient(city.pos.x, city.pos.y, 50, 50, city.col, color(0, 125, 125));
  }

  for (GameObj base : bases) {
    baseGradient(base.pos.x, base.pos.y, 20, 20, base.col, color(0, 51, 204));
    base.armedIn = max(0, base.armedIn - 1);
    baseGradient(base.pos.x, base.pos.y - 20 + base.armedIn, 5, 5, color(0, 255, 99), color(0, 153, 51));
  }

// Draw base and missile gradients
for (int i = 0; i < missiles.size(); i++) {
  GameObj missile = missiles.get(i);

  missile.pos.add(missile.v);
  missileGradient(missile.pos.x, missile.pos.y, 5, 5, missile.col, color(255, 51, 51));

    if (missile.pos.y >= canvasHeight - 20) {
      missile.alive = false;
      if (!missile.alive) {
        explosions.add(new GameObj(missile.pos.copy(), null, color(200, 0, 0), 0, true, 0, null, true));

        // Check collisions with cities
        for (int j = 0; j < citys.size(); j++) {
          GameObj city = citys.get(j);
          float distance = PVector.dist(missile.pos, city.pos);

          if (distance <= 80) {
            lives -= 1;
            citys.remove(j);
            break;
          }
        }
        missiles.remove(i);
    if (frameCount % 4 == 0) {
    boom1.play();
    }
    if  (frameCount % 2 == 0) {
      boom2.play();
    }
    if (frameCount % 4 != 0) {
      if (frameCount % 2 != 0) {
      boom3.play();
    }
    }
    }

    if (lives <= 0) {
    gameOver = true;
}
  } else {
    stroke(missile.col);
    strokeWeight(5);
    line(missile.pos.x, missile.pos.y, missile.pos.x - missile.v.x * missile.tail, missile.pos.y - missile.v.y * missile.tail);
  }

  for (int j = 0; j < missiles.size(); j++) {
    GameObj missile2 = missiles.get(j);

    if (missile != missile2 && missile.isEnemy != missile2.isEnemy) {
      if (dist(missile.pos.x, missile.pos.y, missile2.pos.x, missile2.pos.y) <= 100) {
        explosions.add(new GameObj(missile.pos.copy(), null, color(200, 0, 0), 0, true, 0, null, true));
        explosions.add(new GameObj(missile2.pos.copy(), null, color(200, 0, 0), 0, true, 0, null, true));
      if (frameCount % 4 == 0) {
    boom1.play();
    }
    if  (frameCount % 2 == 0) {
      boom2.play();
    }
    if (frameCount % 4 != 0) {
      if (frameCount % 2 != 0) {
      boom3.play();
    }
    }

        missile.alive = false;
        missile2.alive = false;
        missilesToRemove.add(i);
        missilesToRemove.add(j);

        score++;

      }
    }
  }
}


// Convert the Set to a List and sort it in descending order
List<Integer> sortedIndicesToRemove = new ArrayList<>(missilesToRemove);
Collections.sort(sortedIndicesToRemove, Collections.reverseOrder());

// Remove elements from missiles using the sorted list
for (Integer index : sortedIndicesToRemove) {
  missiles.remove((int) index);
}
missilesToRemove.clear();

if (gameOver) {
  fill(255, 0, 0);
  textAlign(CENTER, CENTER);
  textFont(titlefont);
  text("GAME OVER", canvasWidth / 2, canvasHeight / 2);
  fill(255);
  textFont(scorefont);
  text("Final Score: " + score, canvasWidth / 2, canvasHeight / 4);
  text("Click to continue", canvasWidth / 2, canvasHeight - 200);
}

if (!roundStarted) {
    roundNum += 1;
    endFrame = 300 * (roundNum);
    for (int x = 0; x < 10 + roundNum * 2 + PApplet.round(pow(1.13f, roundNum)); x++) {
        PVector dest = new PVector(random(200, canvasWidth - 200), canvasHeight);
        PVector v = new PVector(random(-3, 9), random(6, 12));
        PVector start = PVector.add(dest, PVector.mult(v, -1 * random(170, endFrame - 5)));
        missiles.add(new GameObj(start, v, color(250, 0, 0), 25, true, 0, dest, true));
    }
    roundStarted = true;
}


if (missiles.size() > 0) {
  if (mousePressed) {
    ArrayList<GameObj> armed = new ArrayList<GameObj>();
    for (GameObj base : bases) {
      if (base.armedIn == 0) {
        armed.add(base);
      }
    }
    if (armed.size() > 0) {
      GameObj closestBase = null;
      float minDist = Float.MAX_VALUE;
      for (GameObj base : armed) {
        if (frameCount % 2 == 0) {
          pew1.play();
        } else {
          pew2.play();
        }
        float currentDist = dist(base.pos.x, base.pos.y, mouseX, mouseY);
        if (currentDist < minDist) {
          closestBase = base;
          minDist = currentDist;
        }
      }
      if (closestBase != null) {
        PVector pos = new PVector(closestBase.pos.x, closestBase.pos.y);
        closestBase.armedIn = 25;
        PVector dest = new PVector(mouseX, mouseY);
        missiles.add(new GameObj(pos.copy(), aimAt(pos, dest, 5).copy(), color(160, 255, 220), 1, true, 0, dest.copy(), false));
      }
    }
  }
}

// Draw explosions
long fadeDuration = 500;

for (GameObj explosion : explosions) {
    long elapsedTime = System.currentTimeMillis() - explosion.birthTime;
    if (elapsedTime < fadeDuration) {
        int alpha = (int) map(elapsedTime, 0, fadeDuration, 255, 0);
        int fadingColor = color(
            red(explosion.col),
            green(explosion.col),
            blue(explosion.col),
            alpha
        );
        fill(fadingColor);
        ellipse(explosion.pos.x, explosion.pos.y, 40, 40);
    } else {
        explosion.alive = false;
    }

if (currentFrame == endFrame - 5) {
  roundStarted = false;

}
}

currentFrame = (currentFrame + 1) % endFrame;

// Draw scoreboard and round number
fill(color(255, 255, 255));
textFont(scorefont);
textAlign(LEFT, LEFT);
text("Score: " + score, 10, 20);
text("Round: " + roundNum, 10, 40);
text("Lives: " + lives, 10, 60);

}

// Functions for drawing gradients of bases and missiles
void baseGradient(float x, float y, float w, float h, color c1, color c2) {
  noStroke();
  for (float i = y; i <= y + h; i++) {
    float inter = map(i, y, y + h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    fill(c);
    ellipse(x, i, w, h);
  }
}

void missileGradient(float x, float y, float w, float h, color c1, color c2) {
  noStroke();
  for (float i = y; i <= y + h; i++) {
    float inter = map(i, y, y + h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    fill(c);
    ellipse(x, i, w, h);
  }
}

void cityGradient(float x, float y, float w, float h, color c1, color c2) {
  noStroke();
  for (float i = y; i <= y + h; i++) {
    float inter = map(i, y, y + h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    fill(c);
    ellipse(x, i, w, h);
  }
}

// Function for calculating missile aim
PVector aimAt(PVector s, PVector t, float time) {
  return new PVector((t.x - s.x) / time, (t.y - s.y) / time);
}
