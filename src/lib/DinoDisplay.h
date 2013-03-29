/*
  DinoDisplay.h - LCD Display handling for Dino.
  Created by Herman Moreno, March 24, 2013.
  Released into the public domain.
*/

#ifndef DinoDisplay_h
#define DinoDisplay_h

#include "Arduino.h"
#include <LiquidCrystal.h>
#include <string.h>

class DinoDisplay {
  public:
    DinoDisplay();
    void performOperation(LiquidCrystal &display, int cmd, char *aux);
    int *parse(char *pins);

  private:
    void beginLCD(LiquidCrystal &display, char *aux);
    void setLCDCursor(LiquidCrystal &display, char *aux);
};

#endif
