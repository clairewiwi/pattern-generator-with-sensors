#include "Sensor.h"

int windSensorPin = A1,
    lightSensorPin = A3,
    luxSensorPin = A5,
    micampSensorPin= A0;
    
int nbSensors = 4; 
Sensor* sensorVec[] = {new WindSensor(windSensorPin),
                       new LightSensor(lightSensorPin),
                       new LightSensor(luxSensorPin),
                       new MicampSensor(micampSensorPin)
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
  //  delay(300);
   delay(500); //changed for luxSensor
  }
}
