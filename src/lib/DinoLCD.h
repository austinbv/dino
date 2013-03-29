#ifndef DinoLCD_h
#define DinoLCD_h

#include "Arduino.h"
#include <LiquidCrystal.h>

class DinoLCD {
  public:
    DinoLCD();
    void process(int cmd, char *message);
};

#endif
