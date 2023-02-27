//
// This file adds to the Dino class only if DINO_SHIFT is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_SHIFT

// Define listeners for ShiftIn registers.
#define SHIFT_LISTENER_COUNT 4
struct shiftListener{
  byte     latchPin;
  byte     len;
  byte     dataPin;
  byte     clockPin;
  byte     settings;
  boolean  enabled;
};
shiftListener shiftListeners[SHIFT_LISTENER_COUNT];


//
// Request format for shift register API functions.
// pin        = latch pin (int)
// val        = length (int)
// auxMsg[0]  = data pin (byte)
// auxMsg[1]  = clock pin (byte)
// auxMsg[2]  = settings
//     bit 0  = transmission bit order, 1 = MSBFIRST, 0 = LSBFIRST (default)
//     bit 1  = clock state before reading (only), 1 = HIGH, 0 = LOW (default)
//     but 2+ = unused
// auxMsg[3]+ = data (bytes) (write func only)
//
// CMD = 21
// Write to a shift register.
void Dino::shiftWrite(int latchPin, int len, byte dataPin, byte clockPin, byte settings, byte *data) {
  // Set latch pin low to begin serial write.
  digitalWrite(latchPin, LOW);

  // Write one byte at a time.
  for (uint8_t i = 0;  i < len;  i++) {
    if (bitRead(settings, 0)) {
      shiftOut(dataPin, clockPin, MSBFIRST, data[i]);
    } else {
      shiftOut(dataPin, clockPin, LSBFIRST, data[i]);	
    }
  }

  // Set latch pin high so register writes to parallel output.
  digitalWrite(latchPin, HIGH);
}


// CMD = 22
// Read from a shift register.
void Dino::shiftRead(int latchPin, int len, byte dataPin, byte clockPin, byte settings) {
  // This matters on the ESP32 for some reason.
  pinMode(dataPin, INPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(latchPin, OUTPUT);
  
  // Some registers want the clock pin high at the start. If not, first bit won't be read,
  // and other bits will shift by 1 toward the new "first" bit.
  // Default is to start with clock low.
  if (bitRead(settings, 1)) {
    digitalWrite(clockPin, HIGH);
  } else {
    digitalWrite(clockPin, LOW);
  }

  // Latch high to read parallel state, then low again to stop.
  digitalWrite(latchPin, HIGH);
  digitalWrite(latchPin, LOW);

  // Send data as if coming from the latch pin so it's easy to identify.
  // Start with just pin number and : for now.
  stream->print(latchPin);
  stream->print(':');
  byte reading = 0;

  // Read a number of bytes from the register.
  for (int i = 1;  i <= len;  i++) {
    	
  	// Read a single byte from the register.
  	if (bitRead(settings, 0)) {
  	  reading = shiftIn(dataPin, clockPin, MSBFIRST);
  	} else {
      reading = shiftIn(dataPin, clockPin, LSBFIRST);
  	}
	
    // Print it, then a comma or \n if it's the last byte.
    stream->print(reading);
    stream->print((i==len) ? '\n' : ',');
  }

  // Leave latch pin high.
  digitalWrite(latchPin, HIGH);
}


// CMD = 23
// Start listening to a register using the Arduino shiftIn function.
void Dino::addShiftListener() {
  for (int i = 0;  i < SHIFT_LISTENER_COUNT;  i++) {
    // Overwrite the first disabled listener in the struct array.
    if (shiftListeners[i].enabled == false) {
      shiftListeners[i] = {
        pin,
        val,
        auxMsg[0],
        auxMsg[1],
        auxMsg[2],
        true
      };
      return;
    } else {
    // Should send some kind of error if all are in use.
    }
  }
}


// CMD = 24
// Send a number for a latch pin to remove a shift register listener.
void Dino::removeShiftListener() {
  for (int i = 0;  i < SHIFT_LISTENER_COUNT;  i++) {
    if (shiftListeners[i].latchPin == pin) {
      shiftListeners[i].enabled = false;
    }
  }
}


// Gets called by Dino::updateListeners to run listeners in the main loop.
void Dino::updateShiftListeners() {
  for (int i = 0; i < SHIFT_LISTENER_COUNT; i++) {
    if (shiftListeners[i].enabled) {
      shiftRead(shiftListeners[i].latchPin,
                shiftListeners[i].len,
                shiftListeners[i].dataPin,
                shiftListeners[i].clockPin,
                shiftListeners[i].settings);
    }
  }
}


// Gets called by Dino::reset to clear all listeners.
void Dino::clearShiftListeners() {
  for (int i = 0; i < SHIFT_LISTENER_COUNT; i++) shiftListeners[i].enabled = false;
}

#endif
