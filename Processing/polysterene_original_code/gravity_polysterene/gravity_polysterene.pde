int numMov = 1000;
Mover[] movers = new Mover[numMov];

void setup() {
  size(500, 300);
  //smooth(8);
  background(255);
  strokeWeight(1);
  for (int i=0; i<numMov; i++) {
   movers[i] = new Mover();
  }
}

void draw() {
  background(255);
  for (int i=0; i<numMov; i++) {
    movers[i].run();
  }
}

class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float topSpeed, sz, d=0;

  Mover() {
    sz = 5;  //size billes
  location = new PVector(random(sz, width-sz), random(sz, height-sz));
    velocity = new PVector(0, 0);
    acceleration = new PVector(random(-0.01, 0.01), random(-0.02, 0.02));
    topSpeed = 3;
  }

  void run() {
    update();
    checkEdges();
    display();
  }

  void update() {

    PVector mouse = new PVector(mouseX, mouseY);
    PVector dir = PVector.sub(mouse, location);
    dir.normalize();
    float distance = mouse.dist(location);
    if (distance<150) {
      d = map(distance, 0, 150, 0.2, 0.01);
    }
    if (distance>100) {
      d = 0;
      velocity.mult(.99);
    }
    dir.mult(d);
    acceleration = dir;

    velocity.add(acceleration);
    velocity.limit(topSpeed);
    location.add(velocity);
  }

  void display() {
    fill(0);
    stroke(255);
    ellipse(location.x, location.y, sz, sz);
  }

  void checkEdges() {
    if (location.x<sz/2 || location.x > width-sz/2) {
      velocity.x *= -1;
      acceleration.x *= -1;
    }
    if (location.y<sz/2 || location.y>height-sz/2) {
      velocity.y *= -1;
      acceleration.y *= -1;
    }
  }
}