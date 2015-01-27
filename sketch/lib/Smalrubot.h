/*
  Library for smalrubot ruby gem.
*/

#ifndef Smalrubot_h
#define Smalrubot_h

#include "Arduino.h"
#include <Servo.h>

// Allocate listener storage based on what board we're running.
#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
#  define PIN_COUNT 70
#  define SERVO_OFFSET 22
#else
#  define PIN_COUNT 22
#  define SERVO_OFFSET 2
#endif

// Uncomment this line to enable debugging mode.
// #define debug true

class Smalrubot {
  public:
    Smalrubot();
    void setupWrite(void (*writeCallback)(char *str));
    void parse(char c);
    void process();

  protected:
    // Request storage.
    char request[8];
    int index;
    char cmdStr[3];
    byte cmd;
    char pinStr[3];
    byte pin;
    char valStr[4];
    int val;

    // Value and response storage.
    int rval;
    char response[8];
    void (*_writeCallback)(char *str);
    void writeResponse();

    Servo servos[12];

    virtual void processCommand();

    // API-accessible functions.
    void setMode               ();
    void dWrite                ();
    void dRead                 ();
    void aWrite                ();
    void aRead                 ();
    void servoToggle           ();
    void servoWrite            ();
    void reset                 ();
};

#endif
