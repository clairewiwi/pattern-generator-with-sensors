#include "Sensor.h"

int windSensorPin = A5,
    lightSensorPin = A0;

int nbSensors = 2; 
Sensor* sensorVec[] = {new WindSensor(windSensorPin), 
                       new LightSensor(lightSensorPin)
                       };

int inByte = 0;
    
void setup() {
  // start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {  }
  establishContact();  // send a byte to establish contact until receiver responds
}

void loop() {
  if (Serial.available() > 0) {
    inByte = Serial.read();
    delay(10);
    for (int i=0;i<nbSensors;i++){
      Serial.write(sensorVec[i]->read());
    }
  }
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }
}
