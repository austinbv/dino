/*
  Library for dino ruby gem.
*/

#ifndef Dino_h
#define Dino_h
#include "Arduino.h"

class Dino {
  public:
    Dino();
    void process(char *request, String *loopResponse);
    bool debug;
  private:
    char cmd[3];
    char pin[3];
    int intPin;       // Pins expressed as 'A0' etc. must be converted to integers.
    char val[4];
    String response;
    
    void convertPin   ();
    void toggleDebug  ();
    void setMode      ();
    void dWrite       ();
    void dRead        ();
    void aWrite       ();
    void aRead        (); 
};

#endif
