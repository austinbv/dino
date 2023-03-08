//
// This file adds to the Dino class only if DINO_TONE is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_TONE

// CMD = 20
void Dino::tone() {
  uint16_t frequency = *reinterpret_cast<uint16_t*>(auxMsg);
  uint16_t duration = *reinterpret_cast<uint16_t*>(auxMsg + 2);
  
  // val is 1 if a duration was given, 0 if not.
  if (val !=0) {
    ::tone(pin, frequency, duration);
  } else {
	::tone(pin, frequency);
  }
}

// CMD = 21
void Dino::noTone() {
  ::noTone(pin);
}

#endif
