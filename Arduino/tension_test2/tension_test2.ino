#include "Sensor.h"

int windSensorPin = A5,
    lightSensorPin = A0;

WindSensor  ws = WindSensor(windSensorPin);
LightSensor ls = LightSensor(lightSensorPin);


int inByte = 0;         // incoming serial byte

void setup() {
  // start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {  }
  establishContact();  // send a byte to establish contact until receiver responds
}

void loop() {
  // if we get a valid byte, read analog ins:
  if (Serial.available() > 0) {
    // get incoming byte:
    inByte = Serial.read();
    delay(10);
    Serial.write(ws.read());
    Serial.write(ls.read());
 
  }
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }
}
