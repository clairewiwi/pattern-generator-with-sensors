/****************************************
Example Sound Level Sketch for the 
Adafruit Microphone Amplifier
****************************************/
//We can connect this sketch to send data to a processing sketch
// wiring//
//GND -> GND//
//VCC -> 3.3V//
//OUT -> AIN0//

int sensorPin = A0;
int firstSensor = 0;    // first analog sensor
int inByte = 0;         // incoming serial byte
const int sampleWindow = 50; // Sample window width in mS (50 mS = 20Hz)
unsigned int sample;


void setup() 
{
   Serial.begin(9600);
    while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
 establishContact();  // send a byte to establish contact until receiver responds
}



void loop() 
{
   unsigned long startMillis= millis();  // Start of sample window
   unsigned int peakToPeak = 0;   // peak-to-peak level

   unsigned int signalMax = 0;
   unsigned int signalMin = 1024;

   // collect data for 50 mS
   while (millis() - startMillis < sampleWindow)
   {
      sample = analogRead(0);
      if (sample < 1024)  // toss out spurious readings
      {
         if (sample > signalMax)
         {
            signalMax = sample;  // save just the max levels
         }
         else if (sample < signalMin)
         {
            signalMin = sample;  // save just the min levels
         }
      }
   }
   peakToPeak = signalMax - signalMin;  // max - min = peak-peak amplitude
   double volts = (peakToPeak * 5.0) / 1024;  // convert to volts

 //  Serial.println(volts);

     // if we get a valid byte, read analog ins:
 if (Serial.available() > 0) {
    // get incoming byte:
    inByte = Serial.read();
    // read first analog input, divide by 4 to make the range 0-255:
    firstSensor = analogRead(sensorPin) / 5;
    // delay 10ms to let the ADC recover:
    delay(10);
    // send sensor values:
    Serial.write(255-firstSensor);
 
  }
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }

}
