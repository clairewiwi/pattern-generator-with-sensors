#include "Sensor.h"

Sensor::Sensor(int pi): pinID(pi),value(0){
  //pinID =pi;
  //value =0;
}

void Sensor::reset(){
  value = 0;
}

WindSensor::WindSensor(int p) : Sensor(p){
}

int WindSensor::read(){
  bool newVal = false;
  int valueRead = analogRead(pinID),
      maxRead = valueRead;
  while (valueRead>cutoff){
    maxRead = max(maxRead,valueRead);
    valueRead=analogRead(pinID); 
  }
  if (maxRead>WindSensor::cutoff){
    value = min(255,maxRead*7);
    newVal=true;
  }
  return newVal ? value : 0; 
}



LightSensor::LightSensor(int p) : Sensor(p){
}

int LightSensor::read(){
 return(255-(analogRead(pinID) / 4));
}
