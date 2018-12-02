#include "Dino.h"

// CMD = 00
// Set a pin to output (0), or input (1).
void Dino::setMode() {
  if (val == 0) {
    pinMode(pin, OUTPUT);
  }
  else {
    pinMode(pin, INPUT);
  }

  #ifdef debug
    Serial.print("Called Dino::setMode()\n");
  #endif
}

// CMD = 01
// Write a digital output pin. 0 for LOW, 1 or >0 for HIGH.
void Dino::dWrite() {
  if (val == 0) {
    digitalWrite(pin, LOW);
  }
  else {
    digitalWrite(pin, HIGH);
  }

  #ifdef debug
    Serial.print("Called Dino::dWrite()\n");
  #endif
}

// CMD = 02
// Read a digital input pin. 0 for LOW, 1 for HIGH.
void Dino::dRead(int pin) {
  rval = digitalRead(pin);
  coreResponse(pin, rval);

  #ifdef debug
    Serial.print("Called Dino::dRead()\n");
  #endif
}

// CMD = 03
// Write an analog output pin. 0 for LOW, up to 255 for HIGH @ 8-bit resolution.
void Dino::aWrite() {
  analogWrite(pin,val);

  #ifdef debug
    Serial.print("Called Dino::aWrite()\n");
  #endif
}

// CMD = 04
// Read an analog input pin. 0 for LOW, up to 1023 for HIGH @ 10-bit resolution.
void Dino::aRead(int pin) {
  rval = analogRead(pin);
  coreResponse(pin, rval);

  #ifdef debug
    Serial.print("Called Dino::aRead()\n");
  #endif
}


// Send current value of pin and reading value (rval), following the protocol.
// This is for core reads and listeners, but can be used for any function
// following the pin:rval pattern. Set those variables correctly before calling.
void Dino::coreResponse(int p, int v){
  stream->print(p);
  stream->print(':');
  stream->print(v);
  stream->print('\n');
}

// CMD = 05
// Set a listener ON or OFF, or change its type, or divider.
// Takes settings as mask stored in val and applies to existing listener
// if pin was already used, or first inactive. See Dino.h for mask structure.
void Dino::setListener(){
  boolean found = false;
  // Check if previously assigned a listener to this pin and re-use.
  for(byte i=0; i<PIN_COUNT; i++){
    if (listeners[i][1] == pin){
      listeners[i][0] = val;
      found = true;
      break;
    }
  }

  // If this pin wasn't used before, take the fist inactive one.
  if (!found){
    for(byte i=0; i<PIN_COUNT; i++){
      if (bitRead(listeners[i][0], 7) == 0){
        listeners[i][0] = val;
        listeners[i][1] = pin;
        break;
      }
    }
  }

  // Update the last active listener whenever we make a change.
  for(byte i=0; i<PIN_COUNT; i++){
    if (bitRead(listeners[i][0], 7) == 1){
      lastActiveListener = i;
    }
  }
}

void Dino::updateCoreListeners(byte tickCount){
  for (byte i = 0; i <= lastActiveListener; i++){
    // Check if active.
    if (bitRead(listeners[i][0], 7) == 1){
      // Check if to update it on this tick.
      byte exponent = 0b111 & listeners[i][0];
      byte divider = dividerMap[exponent];
      if(tickCount % divider == 0){
        // Check if digital or analog.
        if (bitRead(listeners[i][0], 6) == 1){
          aRead(listeners[i][1]);
        } else {
          digitalListenerUpdate(i);
        }
      }
    }
  }
}

void Dino::digitalListenerUpdate(byte i){
  rval = digitalRead(listeners[i][1]);
  // Previous state is stored in the 5th bit of the first byte.
  // If changed, update it and send the message.
  if (rval != bitRead(listeners[i][0], 5)){
    bitWrite(listeners[i][0], 5, rval);
    coreResponse(listeners[i][1], rval);
  }
}

// Gets called by Dino::reset to clear all core listeners.
void Dino::clearCoreListeners(){
  for (int i = 0; i < PIN_COUNT; i++){
    listeners[i][0] = 0;
    listeners[i][1] = 0;
  }
}

//
// Rapidly polls a digital input looking for rising or falling edges,
// recording the time in microseconds between consecutive edges.
// There is an optional reset at the beginning if the pin must be held opposite
// to its idle state to trigger a reading.
//
// Max 65535 microseconds reset time.
// Max 255 microseconds per pulse (between 2 consecutive edges).
// Max 255 pulses counted.
//
// val bit 0   : whether to reset the line first or not (0 = no, 1 = yes)
// val bit 1   : direction to pull the line (0 = low, 1 = high)
// auxMsg[0-1] : unsigned 16-bit reset duration
// auxMsg[2-3] : unsigned 16-bit pulse read timeout (in milliseconds)
// auxMsg[4]   : unsigned 8-bit pulse count limit
// auxMsg[8] + : reserved as output buffer, will be overwritten
//
void Dino::pulseRead(){
  // Reset
  if (bitRead(val, 0)) {
    uint16_t resetTime = (auxMsg[1] << 8) | auxMsg[0];
    pinMode(pin, OUTPUT);
    digitalWrite(pin, bitRead(val, 1));
    delayMicroseconds(resetTime);
  }
  pinMode(pin, INPUT);
  byte state = digitalRead(pin);

  uint16_t timeout = (auxMsg[3] << 8) | auxMsg[2];
  byte pulseCount = 0;

  uint32_t start = millis();
  uint32_t lastWrite = micros();

  while ((millis() - start < timeout) && (pulseCount < auxMsg[4])) {
    if (digitalRead(pin) != state){
      uint32_t now = micros();
      pulseCount++;
      auxMsg[pulseCount+8] = now - lastWrite;
      lastWrite = now;
      state = state ^ 1;
    }
  }

  stream->print(pin); stream->print(':');
  for (byte i=1; i<=pulseCount; i++){
    stream->print(auxMsg[i+8]);
    stream->print((i == pulseCount) ? '\n' : ',');
  }
  if (pulseCount == 0) stream->print('\n');
}


// CMD = 6
// Read from the microcontroller's EEPROM.
//
// pin         = empty
// val         = number of bytes to read
// auxMsg[0-1] = start address
//
void Dino::eepromRead(){
  if (val > 0) {
    uint16_t startAddress = (uint16_t)auxMsg[1] << 8 | auxMsg[0];

    // Stream read bytes as if coming from a pin named 'EE'.
    stream->print("EE");
    stream->print(':');
    stream->print(startAddress);
    stream->print('-');

    for (byte i = 0;  (i < val);  i++) {
      stream->print(EEPROM.read(startAddress + i));
      stream->print((i+1 == val) ? '\n' : ',');
    }
  }
}

// CMD = 7
// Write to the microcontroller's EEPROM.
//
// pin         = empty
// val         = number of bytes to write
// auxMsg[0-1] = start address
// auxMsg[2+]  = bytes to write
//
void Dino::eepromWrite(){
  if (val > 0) {
    uint16_t startAddress = (uint16_t)auxMsg[1] << 8 | auxMsg[0];

    for (byte i = 0;  (i < val);  i++) {
      if(EEPROM.read(startAddress + i) != auxMsg[2+i]) {
        EEPROM.write(startAddress + i, auxMsg[2+i]);
      }
    }
  }
}
