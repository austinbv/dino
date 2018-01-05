//
// This file adds to the Dino class only if DINO_IR_OUT is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_IR_OUT

#include "IRremote.h"
IRsend infraredOut;

// CMD = 16
// Send an infrared signal.
void Dino::irSend(){
  infraredOut.sendRaw((uint16_t)&auxMsg[1], (uint8_t)auxMsg[0], val);
}

#endif
