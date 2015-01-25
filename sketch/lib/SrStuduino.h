/*
  Library for smalrubot ruby gem.
*/

#ifndef SrStuduino_h
#define SrStuduino_h

#include "Smalrubot.h"
#include "Studuino.h"

class SrStuduino : public Smalrubot {
  public:
    SrStuduino();

  protected:
    Studuino studuino;

    virtual void processCommand();

    void setDcMotorCalibration();
    void initDcMotorPort();
    void initSensorPort();
    void dcMotorPower();
    void dcMotorControl();
    void getTouchSensorValue();
    void getLightSensorValue();
    void getIrPhotoreflectorValue();
};


#endif
