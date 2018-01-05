//
// This file adds to the Dino class only if DINO_SERVO is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_SERVO

#include <Servo.h>

// Maximum 12 servos on most boards. Could be up to 48 on Arduino Mega.
#define SERVO_COUNT 12

// Create an array of wrapper structs that link pins to servo objects.
struct ServoWrapper{
  byte     pin;
  boolean  active;
  Servo    servo;
};
ServoWrapper servos[SERVO_COUNT];

// CMD = 08
// Attach a free servo object to the specified pin.
void Dino::servoToggle() {
  // Search by pin for in use servo object, detatch and set inactive.
  if (val == 0) {
    for (int i = 0;  i < SERVO_COUNT;  i++) {
      if (servos[i].pin == pin) {
        servos[i].servo.detach();
        servos[i].active = false;
      }
    }
  }
  // Search by pin for in use servo object, attach and set active.
  else {
    boolean found = false;
    for (int i = 0;  i < SERVO_COUNT;  i++) {
      if (servos[i].pin == pin) {
        found = true;
        servos[i].servo.attach(pin);
        servos[i].active = true;
      }
    }
    // If it doesn't exist, use the first inactive object.
    if (found == false) {
      for (int i = 0;  i < SERVO_COUNT;  i++) {
        if (servos[i].active == false) {
          servos[i].servo.attach(pin);
          servos[i].active = true;
        }
      }
    }
  }

  #ifdef debug
    Serial.print("Called Dino::servoToggle()\n");
  #endif
}

// CMD = 09
// Write a value to the servo object.
void Dino::servoWrite() {
  // Find servo by pin and write value to it.
  for (int i = 0;  i < SERVO_COUNT;  i++) {
    if (servos[i].pin == pin) {
      servos[i].servo.write(val);
    }
  }

  #ifdef debug
    Serial.print("Called Dino::servoWrite()\n");
  #endif
}

#endif
