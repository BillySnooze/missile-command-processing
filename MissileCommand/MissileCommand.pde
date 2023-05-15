int score = 0;
int round_num = 0;
int canvasWidth = 1200, canvasHeight = 900;
ArrayList<GameObj> bases = new ArrayList<GameObj>();
ArrayList<GameObj> explosions = new ArrayList<GameObj>();
ArrayList<GameObj> missiles = new ArrayList<GameObj>();
ArrayList<Integer> missilesToRemove = new ArrayList<Integer>();
PFont scorefont;
PFont titlefont;
PImage backgroundImage;
int endFrame = 0;
int currentFrame = 0;
boolean roundStarted = false;
boolean gameOver = false;

class GameObj {
  boolean isEnemy;
  PVector pos;
  PVector v;
  color col;
  int tail;
  boolean alive;
  int armedIn;
  PVector dest;

  GameObj(PVector pos, PVector v, color col, int tail, boolean alive, int armedIn, PVector dest, boolean isEnemy) {
    this.pos = pos;
    this.v = v;
    this.col = col;
    this.tail = tail;
    this.alive = alive;
    this.armedIn = armedIn;
    this.dest = dest;
    this.isEnemy = isEnemy;
  }
}

// Set up canvas and initialize game objects
void setup() {
  size(1200, 900);
  scorefont = createFont("Comic Sans MS", 15);
  titlefont = createFont("Comic Sans MS", 100);
  backgroundImage = loadImage("background.png");
  for (int x = 0; x < 5; x++) {
    bases.add(new GameObj(new PVector(250 + 100 * x, canvasHeight-20), null, color(0, 102, 255), 0, true, 0, null, false));
  }
}

// Main game draw loop
void draw() {
  image(backgroundImage, 0, 0, canvasWidth, canvasHeight);

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
  explosions.add(new GameObj(missile.pos.copy(), null, color(200, 0, 0), 0, true, 0, null, true));
  missilesToRemove.add(i);
  for (GameObj base : bases) {
    if (dist(missile.pos.x, missile.pos.y, base.pos.x, base.pos.y) <= 80) {
      base.alive = false;
    }
  }
  if (bases.stream().noneMatch(b -> b.alive)) {
    gameOver = true;
  }
} else {
  stroke(missile.col);
  strokeWeight(8);
  line(missile.pos.x, missile.pos.y, missile.pos.x - missile.v.x * missile.tail, missile.pos.y - missile.v.y * missile.tail);
}
    
    // Draw missile projectiles and explosions
    if(missile.tail > 0){
      stroke(missile.col);
      line(missile.pos.x, missile.pos.y, missile.pos.x - missile.tail*missile.v.x, missile.pos.y - missile.tail*missile.v.y);
      noStroke();
    }

  for (int j = 0; j < missiles.size(); j++) {
    GameObj missile2 = missiles.get(j);

    if (missile != missile2 && missile.isEnemy != missile2.isEnemy) {
      if (dist(missile.pos.x, missile.pos.y, missile2.pos.x, missile2.pos.y) <= 100) {
        explosions.add(new GameObj(missile.pos.copy(), null, color(200, 0, 0), 0, true, 0, null, true));
        explosions.add(new GameObj(missile2.pos.copy(), null, color(200, 0, 0), 0, true, 0, null, true));

        missile.alive = false;
        missile2.alive = false;
        missilesToRemove.add(i);
        missilesToRemove.add(j);

        score++;
          
      }
    }
  }
}

for (int i = missilesToRemove.size() - 1; i >= 0; i--) {
  missiles.remove((int) missilesToRemove.get(i));
}
missilesToRemove.clear();

if (gameOver) {
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(titlefont);
  text("GAME OVER", canvasWidth/2, canvasHeight/2);
  textFont(scorefont);
  text("Final Score: " + score, canvasWidth/2, canvasHeight/2 + 50);
  return;
}

if (!roundStarted) {
  round_num += 1;
  endFrame = 300 + round_num * 50;
  for (int x = 0; x < 5 + round_num * 2 + int(pow(1.13, round_num)); x++) {
    PVector dest = new PVector(random(200, canvasWidth - 200), canvasHeight);
    PVector v = new PVector(random(-3, 3), random(3,6));
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
for (GameObj explosion : explosions) {
  fill(explosion.col);
  ellipse(explosion.pos.x, explosion.pos.y, 40, 40);
}

currentFrame = (currentFrame + 1) % endFrame;

// Draw scoreboard and round number
fill(color(255, 255, 255));
textFont(scorefont);
text("Score: " + score, 10, 20);
text("Round: " + round_num, 10, 40);
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

// Function for calculating missile aim
PVector aimAt(PVector s, PVector t, float time) {
  return new PVector((t.x - s.x) / time, (t.y - s.y) / time);
}
