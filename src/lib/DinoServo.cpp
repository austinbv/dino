//
// This file adds to the Dino class only if DINO_SERVO is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_SERVO

#ifdef ESP32
  #include <ESP32Servo.h>
#else if
  #include <Servo.h>
#endif

// 12 servos on most boards. 6 on the ATmega168.
// Could be up to 48 on Arduino Mega.
#if defined (__AVR_ATmega168__)
  #define SERVO_COUNT 6
#elif defined(ESP32)
  #define SERVO_COUNT 16
#else
  #define SERVO_COUNT 12
#endif

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
    uint16_t min = (auxMsg[1] << 8) | auxMsg[0];
    uint16_t max = (auxMsg[3] << 8) | auxMsg[2];

    for (int i = 0;  i < SERVO_COUNT;  i++) {
      if (servos[i].pin == pin) {
        found = true;
        servos[i].servo.attach(pin, min, max);
        servos[i].active = true;
        break;
      }
    }
    // If it doesn't exist, use the first inactive object.
    if (found == false) {
      for (int i = 0;  i < SERVO_COUNT;  i++) {
        if (servos[i].active == false) {
          servos[i].servo.attach(pin, min, max);
          servos[i].active = true;
          servos[i].pin = pin;
          break;
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
      uint16_t us = (auxMsg[1] << 8) | auxMsg[0];
      servos[i].servo.writeMicroseconds(us);
    }
  }

  #ifdef debug
    Serial.print("Called Dino::servoWrite()\n");
  #endif
}

#endif
