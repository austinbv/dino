//
// This file adds to the Dino class only if DINO_TONE is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_TONE

// CMD = 20
void Dino::tone() {
  unsigned int duration = atoi((char*)auxMsg);
  ::tone(pin, val, duration);
}

// CMD = 21
void Dino::noTone() {
  ::noTone(pin);
}

#endif
