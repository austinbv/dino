#include "Dino.h"

// CMD = 00
// Set a pin to output (0), or input (1).
void Dino::setMode(byte p, byte m) {
  #ifdef debug
    Serial.print("setmode, pin:");
    Serial.print(p);
    Serial.print(", mode:");
    Serial.println(m);
  #endif

  if (m == 0) {
    pinMode(p, OUTPUT);
  }
  else {
    pinMode(p, INPUT);
  }
}

// CMD = 01
// Write a digital output pin. 0 for LOW, 1 or >0 for HIGH.
void Dino::dWrite(byte p, byte v, boolean echo) {
  #ifdef debug
    Serial.print("dwrite, pin:");
    Serial.print(p);
    Serial.print(", value:");
    Serial.print(v);
    Serial.print(", echo:");
    Serial.println(echo);
  #endif

  if (v == 0) {
    digitalWrite(p, LOW);
  }
  else {
    digitalWrite(p, HIGH);
  }
  if (echo) coreResponse(p, v);
}

// CMD = 02
// Read a digital input pin. 0 for LOW, 1 for HIGH.
byte Dino::dRead(byte p) {
  #ifdef debug
    Serial.print("dread, pin:");
    Serial.println(p);
  #endif

  byte rval = digitalRead(p);
  coreResponse(p, rval);
  return rval;
}

// CMD = 03
// Write an analog output pin. 0 for LOW, up to 255 for HIGH @ 8-bit resolution.
void Dino::aWrite(byte p, int v, boolean echo) {
  #ifdef debug
    Serial.print("awrite, pin:");
    Serial.print(p);
    Serial.print(", value:");
    Serial.print(v);
    Serial.print(", echo:");
    Serial.println(echo);
  #endif

  analogWrite(p,v);
  if (echo) coreResponse(p, v);
}

// CMD = 04
// Read an analog input pin. 0 for LOW, up to 1023 for HIGH @ 10-bit resolution.
int Dino::aRead(byte p) {
  #ifdef debug
    Serial.print("aread, pin:");
    Serial.println(p);
  #endif

  int rval = analogRead(p);
  coreResponse(p, rval);
  return rval;
}

// Simple response for core listeners, or any response with the pin:value pattern.
void Dino::coreResponse(int p, int v){
  stream->print(p);
  stream->print(':');
  stream->print(v);
  stream->print('\n');
}

// CMD = 05
// Enable, disable and change settings for core (digital/analog) listeners.
// See Dino.h for settings and mask layout.
void Dino::setListener(byte p, boolean enabled, byte analog, byte exponent, boolean local){
  // Pre-format the settings into a mask byte.
  byte settingMask = 0;
  if (enabled)  settingMask = settingMask | B10000000;
  if (analog)   settingMask = settingMask | B01000000;
  if (local)    settingMask = settingMask | B00010000;
  settingMask = settingMask | exponent;

  #ifdef debug
    Serial.print("setlistener, pin:");
    Serial.print(p);
    Serial.print(", enabled:");
    Serial.print(enabled);
    Serial.print(", analog:");
    Serial.print(analog);
    Serial.print(", exponent:");
    Serial.print(exponent);
    Serial.print(", local:");
    Serial.print(local);
    Serial.print(", settingMask:");
    Serial.println(settingMask);
  #endif

  // If an existing listener was already using this pin, just update settings.
  boolean found = false;
  for(byte i=0; i<PIN_COUNT; i++){
    if (listeners[i][1] == p){
      found = true;
      if (bitRead(listeners[i][0], 4) == 0) {
        listeners[i][0] = settingMask;
      } else if(local) {
        // Only allow local code to update local listeners.
        listeners[i][0] = settingMask;
      }
      break;
    }
  }

  // If this pin wasn't used before, take the lowest index inactive listener.
  if (!found){
    for(byte i=0; i<PIN_COUNT; i++){
      if (bitRead(listeners[i][0], 7) == 0){
        listeners[i][0] = settingMask;
        listeners[i][1] = p;
        break;
      }
    }
  }

  // Keep track of how far into the listener array to go when updating.
  findLastActiveListener();
}

// Runs once on every loop to update necessary listeners.
void Dino::updateCoreListeners(byte tickCount){
  for (byte i = 0; i <= lastActiveListener; i++){
    // Check if active.
    if (bitRead(listeners[i][0], 7) == 1){
      // Check if to update it on this tick.
      byte exponent = (listeners[i][0] << 5) >> 5;
      byte divider = dividerMap[exponent];
      if(tickCount % divider == 0){
        // Check if digital or analog.
        if (bitRead(listeners[i][0], 6) == 1){
          analogListenerUpdate(i);
        } else {
          digitalListenerUpdate(i);
        }
      }
    }
  }
}

// Handle a single analog listener when it needs to read.
void Dino::analogListenerUpdate(byte i){
  int rval = analogRead(listeners[i][1]);
  analogListenCallback(listeners[i][1], rval);
  coreResponse(listeners[i][1], rval);
}

// Handle a single digital listener when it needs to read.
void Dino::digitalListenerUpdate(byte i){
  byte rval = digitalRead(listeners[i][1]);

  if (rval != bitRead(listeners[i][0], 5)){
    // State for digital listeners is stored in byte 5 of the listener itself.
    bitWrite(listeners[i][0], 5, rval);
    digitalListenCallback(listeners[i][1], rval);
    coreResponse(listeners[i][1], rval);
  }
}

// Gets called by Dino::reset to clear all listeners set by the remote client.
void Dino::clearCoreListeners(){
  for (int i = 0; i < PIN_COUNT; i++){
    // Only clear listeners if they were started by the remote client.
    // Leaves listeners started by local code running.
    if (bitRead(listeners[i][0], 4) == 0) {
      listeners[i][0] = 0;
      listeners[i][1] = 0;
    }
  }
  findLastActiveListener();
}

// Track the last active listener whenever changes are made.
// Call this after setting or clearing any listeners.
void Dino::findLastActiveListener(){
  for(byte i=0; i<PIN_COUNT; i++){
    if (bitRead(listeners[i][0], 7) == 1){
      lastActiveListener = i;
    }
  }
}
