#ifndef SENSOR_H
#define SENSOR_H

#include <Arduino.h>


class Sensor{
  protected:
    int pinID,
        value;
  public:
    Sensor(int pi);
    virtual int read() = 0;
    void reset();
};

class WindSensor : public Sensor{
  private:
    static const int cutoff = 20;   
  public:
    WindSensor(int pi);
    virtual int read();
};

class LightSensor : public Sensor{
    
  public:
    LightSensor(int pi);
    virtual int read();
};

class FluxSensor : public Sensor{
    
  public:
    FluxSensor(int pi);
    virtual int read();
};

class MicampSensor : public Sensor{
  public:
   MicampSensor(int pi);
    virtual int read();
};


#endif

