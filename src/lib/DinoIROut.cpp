//
// This file adds to the Dino class only if DINO_IR_OUT is defined in Dino.h.
//
#include "Dino.h"
#if defined(DINO_IR_OUT) && !defined(ESP8266) && !defined(ESP32)

// Save memory by disabling receiver.
#undef RAW_BUFFER_LENGTH
#define RAW_BUFFER_LENGTH 0
#define DISABLE_CODE_FOR_RECEIVER

// Save more memory.
#define IR_REMOTE_DISABLE_RECEIVE_COMPLETE_CALLBACK true
#define EXCLUDE_UNIVERSAL_PROTOCOLS
#define EXCLUDE_EXOTIC_PROTOCOLS
#define NO_LED_FEEDBACK_CODE

#include <IRremote.hpp>

// CMD = 16
// Send an infrared signal.
void Dino::irSend(){
  // Byte 1+ of auxMsg is already little-endian uint16 pulses.
  uint16_t *pulseArray = reinterpret_cast<uint16_t *>(auxMsg + 1);
  
  // Dynamically set the sending pin. Needs to be PWM capable.
  IrSender.setSendPin(pin);

  // auxMsg[0] contains number of uint16_t
  // Val contains frequency
  IrSender.sendRaw(pulseArray, auxMsg[0], val);
}
#endif
