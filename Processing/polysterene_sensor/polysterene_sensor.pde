
import processing.serial.*;

Serial myPort;         // The serial port
int serialInVal = 0;    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller



int numMov = 3000; //number of billes
Mover[] movers = new Mover[numMov];

void setup() {
  size(500, 400);
  //smooth(8);
  background(255);
  strokeWeight(1);
  

  // setup usb port 
 println(Serial.list());
  String portName = "/dev/ttyACM0";
  myPort = new Serial(this, portName, 9600);
  
     for (int i=0; i<numMov; i++) {
    movers[i] = new Mover();
   }
}

void draw() {
  background(255);
  
  //use sensor data for coordinate position
mouseY = (serialInVal); //mouseY;
mouseX= (serialInVal); //mouseX;

//mouseX= 2*(serialInVal-100); //mouseX;
//mouseY = 2*(serialInVal-100); //mouseY;

 //mouseX = serialInVal/50;
 //mouseY = serialInVal/50;
  
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
    sz = 5;
    location = new PVector(random(sz, width-sz), random(sz, height-sz));
    velocity = new PVector(0, 0);
    //acceleration = new PVector(random(-0.01, 0.01), random(-0.02, 0.02));
    topSpeed = 3;
  }

  void run() {
    update();
    checkEdges();
    display();
  }

  void update() {
//    if(mousePressed){
  PVector mouse = new PVector(serialInVal, serialInVal);
 //  PVector mouse = new PVector(mouseX, mouseY);
  // PVector mouse = new PVector(2*(serialInVal/100), 2*(serialInVal/100));
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
  //added

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
void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  int inByte = myPort.read();
  // if this is the first byte received, and it's an A,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller.
  // Otherwise, add the incoming byte to the array:
  if (firstContact == false) {
    if (inByte == 'A') {
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      println("hello");
      myPort.write('A');       // ask for more
    }
  }
  else {
    // Add the latest byte from the serial port to array:
    serialInVal = inByte;
    //serialCount++;
    print("read: ");
    println(serialInVal);
    myPort.write('A');
    //serialCount = 0;
  
  }
 }
  }