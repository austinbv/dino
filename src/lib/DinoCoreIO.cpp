#include "Dino.h"

// CMD = 00
// Set a pin to output (0), or input (1).
void Dino::setMode() {
  if (val == 0) {
    removeListener();
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
  sprintf(response, "%d:%d", pin, rval);

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
  sprintf(response, "%d:%d", pin, rval);

  #ifdef debug
    Serial.print("Called Dino::aRead()\n");
  #endif
}

// CMD = 05
// Set a flag to periodically read a digital pin without further requests.
// Runs around other requests in the main loop. Only sends value when changed.
void Dino::addDigitalListener() {
  removeListener();
  digitalListeners[pin] = true;
  digitalListenerValues[pin] = 2;

  #ifdef debug
    Serial.print("Called Dino::addDigitalListener()\n");
  #endif
}

// CMD = 06
// Set a flag to periodically read an analog pin without further requests.
// Runs around other requests in the main loop. Sends value on every read.
void Dino::addAnalogListener() {
  removeListener();
  analogListeners[pin] = true;

  #ifdef debug
    Serial.print("Called Dino::addAnalogListener()\n");
  #endif
}

// CMD = 07
// Remove analog and digital listen flags on the pin.
void Dino::removeListener() {
  analogListeners[pin] = false;
  digitalListeners[pin] = false;

  #ifdef debug
    Serial.print("Called Dino::removeListener()\n");
  #endif
}

// Gets called by Dino::updateListeners to run listeners in the main loop.
// Reads each digital listen pin and sends value if changed from last read.
void Dino::updateDigitalListeners() {
  for (int i = 0; i < PIN_COUNT; i++) {
    if (digitalListeners[i]) {
      dRead(i);
      if (rval != digitalListenerValues[i]) {
        digitalListenerValues[i] = rval;
        writeResponse();
      }
    }
  }
}

// Gets called by Dino::updateListeners to run listeners in the main loop.
// Reads each analog listen pin and sends value always. Does not store last value.
void Dino::updateAnalogListeners() {
  for (int i = 0; i < PIN_COUNT; i++) {
    if (analogListeners[i]) {
      aRead(i);
      writeResponse();
    }
  }
}

// Gets called by Dino::reset to clear all digital listeners.
void Dino::clearDigitalListeners(){
  for (int i = 0; i < PIN_COUNT; i++) digitalListeners[i] = false;
  for (int i = 0; i < PIN_COUNT; i++) digitalListenerValues[i] = 2;
}

// Gets called by Dino::reset to clear all analog listeners.
void Dino::clearAnalogListeners(){
  for (int i = 0; i < PIN_COUNT; i++) analogListeners[i] = false;
}
