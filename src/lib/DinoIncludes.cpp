//
// This file should implement features where Dino simply passes input to classes
// that require a static instance to be defined in Dino's scope.
//
#include "Dino.h"

#ifdef DINO_LCD
  #include "DinoLCD.h"
  DinoLCD dinoLCD;

  // CMD = 10
  // Pass aux message to the LCD library for processing.
  void Dino::handleLCD() {
    dinoLCD.process(val, (char *)auxMsg);
    #ifdef debug
      Serial.print("Called Dino::handleLCD()\n");
    #endif
  }
#endif


#ifdef DINO_SERIAL
  #include "DinoSerial.h"
  DinoSerial dinoSerial;

  // CMD = 12
  // Pass aux message to the software serial library for processing.
  void Dino::handleSerial() {
    dinoSerial.process(val, auxMsg);
    #ifdef debug
      Serial.print("Called Dino::handleSerial()\n");
    #endif
  }
#endif
