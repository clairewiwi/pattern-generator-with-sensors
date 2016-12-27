/* KEYS
 * q/Q    : Quit
 * r/R    : reset nodes
 * s/S    : save png
 * +      : increase blackness
 * -      : decrease blackness
 
 * WIRING arduino: 5.5v AND pin A0
 */

import processing.serial.*;

/////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// USER CONFIGURATION VARIABLES  //////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

final int kinttingWidth  = 80,  // number of needles,
          knittingHeight = 95,  // number of rows to knit
          screenScale    = 5;  // mutliplier for display 

final int startupDelay      = 5000, // time in milliseconds to wait before using the serial input
          saveMessageDelay  = 3000, // time to show save message
          blacknessMsgDelay = 1500; // time to show blackness Threshold Value (range is 0 to 1, steps of 0.01)

final String outputDir               = "Output",
             separator               = "/",           // this may need to be changed on Windows!
             tempFile                = "temp.png",
             outputFilePrefix        = "Knit_This",
             outputfileNameExtension = ".png",
             startupMsg              = "Starting up ...",
             savedMsg                = "\nSaved!!",
             blacknessMsg            = "Blackness Value: ";

final String [] instructions = { "q: Quit",
                                 "r: Reset",
                                 "s: Save",
                                 //"+: +Blackness",  // comment these 2 lines 
                                 //"-: -Blackness"   // to inhibit users from changing blackness
                               };

// This is the BLACKNESS VALUE
float filterThreshold = 0.75;

final boolean useSerial = true;
/////////////////////////////////////////////////////////////////////////////////////////////
////////////////////// NO USER CONFIGURATION BEYOND THIS POINT  /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

final int fontSize = max( 18,round(24*screenScale/10.0));

boolean blacknessChanged = true;
int blacknessChangedTime = 0;

PFont tFont;

final color black = #000000,
            white = #FFFFFF,
            green  = #00FF00;

Serial myPort;         // The serial port
int serialInVal = 0;    // Where we'll put what we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller

final int numMov = 3000; //number of billes
Mover[] movers = new Mover[numMov];


final String tempFileName         = outputDir + separator + tempFile,
             outputfileNamePrefix = outputDir + separator + outputFilePrefix;


String outputting = "";
int outputTime=0;

void settings(){
  size(kinttingWidth*screenScale,knittingHeight*screenScale);
}

void setup() {
  println(round(24*screenScale/10.0));
  tFont = loadFont("FreeMono-24.vlw");
  textFont(tFont);
  strokeWeight(1);
  if(useSerial){
    // setup usb port 
    println(Serial.list());
    String portName = "/dev/ttyACM0";
    myPort = new Serial(this, portName, 9600);
  }
  for (int i=0; i<movers.length; i++) {
    movers[i] = new Mover();
  }
}

void draw() {
  // wait for the startup delay to pass
  if (millis()<startupDelay){
    startupMessage();
  }
  // if writing a saved imgage, inform user
  else if (outputting != ""){
    outputMessage();
  }
  else if (blacknessChanged){
    blacknessMessage();
  }
  // otherwise run the movers
  else{
    background(white);
    for (int i=0; i<movers.length; i++) {
      movers[i].run();
    }
  }
}

class Mover {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float topSpeed, sz, d=0;
  int startTime;
  boolean init;

  Mover() {
    sz = 4; //taille des billes
    location = new PVector(random(sz, width-sz), random(sz, height-sz));
    velocity = new PVector(0, 0);
    acceleration = new PVector(random(-0.01, 0.01), random(-0.02, 0.02));
    topSpeed = 3;
    init = false;
  }

  void run() {
    if (!init){
      init = true;
      startTime = millis();
    }
    if(millis()-startTime> startupDelay){
      update();
      checkEdges();
    }
    display();
  }

  void update() {
    PVector mouse;
    // use the serial read value as input
    if (useSerial){
      mouse = new PVector(serialInVal, serialInVal);
    }
    // use the mouse as input
    else{
      mouse = new PVector(mouseX, mouseY);
    }
    PVector dir = PVector.sub(mouse, location);

    dir.normalize();
    float distance = mouse.dist(location);
    if (distance<150) {
      d = map(distance, 0, 50, 0.2, 0.01);
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
    fill(black);
    stroke(white);
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

void keyPressed() {
  switch(key){
    // increase or decrfease blackness
    case '+':
    case '-':
      if(instructions.length>3){
        filterThreshold = (key == '+') ? min(1.0,filterThreshold+0.01) : max(0,filterThreshold-0.01);
        blacknessChanged = true;
        blacknessChangedTime = millis();
      }
      break;
    // QUIT
    case 'q':
    case 'Q':
      exit();
      break;
    // RESET
    case 'r':
    case 'R':
      for (int i=0; i<movers.length; i++) {
        movers[i] = new Mover();
      }
      break;
    // SAVE
    case 's':
    case 'S':
      // first save the current frame as tempfile
      saveFrame(tempFileName);  
      // then conform it
      outputting = conformFrame(tempFileName);
      // note the outpit time for messaging
      outputTime = millis();
      break;
  }
}

String conformFrame(String frameFileName){
  // take the saved frame tempfile
  //pushStyle();
  //colorMode(RGB, 100);
  PImage img = loadImage(frameFileName);
  // resize it to the knitting parameters
  img.resize(kinttingWidth,0);
  // make it black and white
  img.filter(THRESHOLD,filterThreshold);
  // calculate time-stamp and output file name
  int y = year(),
      m = month(),
      d = day(),
      h = hour(),
      mi = minute(),
      s = second();
  int [] tVec = {y,m,d,h,mi,s};
  String outFileName = outputfileNamePrefix;
  for(int i=0;i<tVec.length;i++){
    outFileName += "-" + String.valueOf(tVec[i]);
  }
  outFileName += outputfileNameExtension;
  // save the image file
  img.save(outFileName);
  // return the name of the file for user information
  return outFileName;
}

void startupMessage(){
  // informs user that system is starting 
  // and gives instructions
  //final int tSize = round(fontSize*1.5);;
  pushStyle();
  background(black);
  fill(green);
  textAlign(CENTER,CENTER);
  textSize(fontSize); //tSize);
  textFont(tFont);
  text(startupMsg,width/2.0,height/2.0);
  textAlign(LEFT);
  for (int i=0;i<instructions.length;i++){
    text(instructions[i],width/2.0-textWidth(startupMsg)/2.0,height/2.0 +fontSize*1.5*(i+2));
  }
  popStyle();
  blacknessChangedTime = millis();
}

void outputMessage(){
  // informs user of what image file was saved and where
  pushStyle();
  background(black);
  fill(green);
  textAlign(CENTER,CENTER);
  textFont(tFont);
  textSize(fontSize);
  String [] mVec = outputting.split(separator);
  //text(outputting + savedMsg,width/2.0,height/2.0);
  text(mVec[0] + separator + '\n' + mVec[1] + savedMsg,width/2.0,height/2.0);
  
  outputting = (millis()-outputTime < saveMessageDelay) ? outputting : "";
  popStyle();
}

void blacknessMessage(){
  // informs user of new blackness value
  pushStyle();
  background(black);
  fill(green);
  textAlign(CENTER,CENTER);
  textFont(tFont);
  textSize(fontSize);
  text(blacknessMsg + nf(filterThreshold,1,2),width/2.0,height/2.0);
  blacknessChanged = (millis()-blacknessChangedTime < blacknessMsgDelay);
  popStyle();
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
    print("read: ");
    println(serialInVal);
    myPort.write('A');  
  }
}