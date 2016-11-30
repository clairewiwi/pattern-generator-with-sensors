// M_1_5_01.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * how to transform noise values into directions (angles) and brightness levels
 * 
 * MOUSE
 * position x/y        : specify noise input range
 * 
 * KEYS
 * d                   : toogle display brightness circles on/off
 * arrow up            : noise falloff +
 * arrow down          : noise falloff -
 * arrow left          : noise octaves -
 * arrow right         : noise octaves +
 * space               : new noise seed
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;
import processing.serial.*;

Serial myPort;         // The serial port
int serialInVal = 0;    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller

boolean savePDF = false;

int octaves = 4;
float falloff = 0.5;

//color arcColor = color(0,130,164,100);

float tileSize = 20;
int gridResolutionX, gridResolutionY;
boolean debugMode = true;
PShape arrow;

void setup() {
  size(600,600); 
  cursor(CROSS);
  gridResolutionX = round(width/tileSize);
  gridResolutionY = round(height/tileSize);
  smooth();
  arrow = loadShape("arroww.svg");
 
   println(Serial.list());
  String portName = "/dev/ttyUSB0";
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  background(255);
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

//noiseSeed((int) random(100000));
//noiseSeed((int) 2*(serialInVal-500));



//ici le pourcentage de "noise" par rapport aux valeurs du capteur
  noiseDetail(octaves,falloff);
  float noiseXRange = serialInVal/50.0;
  float noiseYRange = serialInVal/50.0;      //mouseY/100.0;       //2*(serialInVal-100); 
  //pour quoi *2?

  for (int gY=0; gY<= gridResolutionY; gY++) {  
    for (int gX=0; gX<= gridResolutionX; gX++) {
      float posX = tileSize*gX;
      float posY = tileSize*gY;

      // get noise value
      float noiseX = map(gX, 0,gridResolutionX, 0,noiseXRange);
      float noiseY = map(gY, 0,gridResolutionY, 0,noiseYRange);
      float noiseValue = noise(noiseX,noiseY);
      float angle = noiseValue*TWO_PI;

      pushMatrix();
      translate(posX,posY);

      // debug heatmap
      if (debugMode) {
        noStroke();
        ellipseMode(CENTER);
   //     fill(noiseValue*255);
        ellipse(0,0,tileSize*0.25,tileSize*0.25);
    
    //here you can set no of range of data from sensor that changes parameters of patterns in this case noise of the lines  
     //     if (serialInVal == 200) falloff += 0.5; //plus la valeur est haute plus il faut de temps pour arrievr au chaos
       //   if (serialInVal == 140) falloff -= 0.5;
  
   // if (falloff > 1.0) falloff = 1.0;
  // if (falloff < 0.0) falloff = 0.0;

  if (serialInVal > 1.0) falloff = 1.0;
  if (serialInVal < 0.0) falloff = 0.0;
      }

      // arc
 //     noFill();
   //   strokeCap(SQUARE);
     // strokeWeight(1);
    //  stroke(arcColor);
    //  arc(0,0,tileSize*0.75,tileSize*0.75,0,angle);

      // arrow
      stroke(0);
      strokeWeight(0.75);
      rotate(angle);
      shape(arrow,0,0,tileSize*0.75,tileSize*0.75);
      popMatrix();
    }
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
  println("octaves: "+octaves+" falloff: "+falloff+" noiseXRange: 0-"+noiseXRange+" noiseYRange: 0-"+noiseYRange); 
}

void keyReleased() {  
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_####.png");
  if (key == 'p' || key == 'P') savePDF = true;
  if (key == 'd' || key == 'D') debugMode = !debugMode;
  if (key == ' ') noiseSeed((int) random(100000));
}

void keyPressed() {
  if (keyCode == UP) falloff += 0.05;
  if (keyCode == DOWN) falloff -= 0.05;
  if (falloff > 1.0) falloff = 1.0;
  if (falloff < 0.0) falloff = 0.0;

  if (keyCode == LEFT) octaves--;
  if (keyCode == RIGHT) octaves++;
  if (octaves < 0) octaves = 0;
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
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