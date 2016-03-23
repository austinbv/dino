#ifndef DinoLCD_h
#define DinoLCD_h

#include "Arduino.h"
#include <LiquidCrystal.h>
#include <string.h>

class DinoLCD {
  public:
    DinoLCD();
    void process(int cmd, char *message);
  private:
    int *parse(char *aux);
    void setPins(char *aux);
    void beginLCD(char *aux);
    void setLCDCursor(char *aux);
    int parseSize;
};

#endif
