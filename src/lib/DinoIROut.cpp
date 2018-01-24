//
// This file adds to the Dino class only if DINO_IR_OUT is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_IR_OUT

#ifdef ESP8266
  #include "IRremoteESP8266.h"
  #include "Irsend.h"
  IRsend infraredOut(2);
#else
  #include "IRremote.h"
  IRsend infraredOut;
#endif

// CMD = 16
// Send an infrared signal.
void Dino::irSend(){
  infraredOut.enableIROut(val);

  for (int i=0; i<(uint8_t)auxMsg[0]; i++){
    uint16_t pulse = ((uint16_t)auxMsg[(i*2)+2] << 8) | auxMsg[(i*2)+1];
    if ((i % 2) == 0) {
      infraredOut.mark(pulse);
    } else {
      infraredOut.space(pulse);
    }
  }
  infraredOut.space(0);
}
#endif
