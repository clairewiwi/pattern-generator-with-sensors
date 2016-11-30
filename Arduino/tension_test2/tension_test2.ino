int sensorPin = A5;

void setup() {
  // put your setup code here, to run once:
// start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

}
int maxRead=0,
    cutoff = 14,
    count=0;
void loop (){
  int valueRead=analogRead(sensorPin);
  while (valueRead>cutoff){
    maxRead = max(maxRead,valueRead);
    valueRead=analogRead(sensorPin); 
  }
  if (maxRead>cutoff){
    Serial.print("Max Analog: ");
    Serial.print(min(255,maxRead*7)); //multiply the sensor data
   
    Serial.print(" end: ");
    Serial.println(count++);
  }
  maxRead=0; 
  /*
  Serial.print(valueRead);off)
  Serial.print("\tMax Analog: ");
  Serial.print(maxRead);
  Serial.print("\tMax Volts: ");
  Serial.println(maxRead/1023.0);
  */
 
}

