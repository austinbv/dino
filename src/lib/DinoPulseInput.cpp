//
// Read chains of input pulses. Only used for DHT sensors right now.
//
#include "Dino.h"

// CMD = 11
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
// auxMsg[8+]  : reserved as output buffer, will be overwritten
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
