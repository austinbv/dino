/*
  Library for dino ruby gem.
*/

#ifndef Dino_h
#define Dino_h

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

class Dino {
  public:
    Dino();
    void setupWrite(void (*writeCallback)(char *str));
    void parse(char c);
    void process();
    void updateListeners();
    
  private:
    // Manage heartbeat and listeners.
    long heartRate;
    long lastUpdate;
    unsigned int loopCount;
    unsigned int analogDivider;
    
    // Storage for enough analog and digital listeners for UNO or Nano board.
    // Correspond to raw pin number by array index, and store boolean. false == disabled.
    boolean analogListeners[PIN_COUNT];
    boolean digitalListeners[PIN_COUNT];
    
    // Keep track of the last read values for digital listeners. Only write responses when changed.
    byte digitalListenerValues[PIN_COUNT];
    
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

    // API-accessible functions.
    void setMode               ();
    void dWrite                (); 
    void dRead                 ();
    void aWrite                ();
    void aRead                 ();
    void addDigitalListener    ();
    void addAnalogListener     ();
    void removeListener        ();
    void servoToggle           ();
    void servoWrite            ();
    void reset                 ();
    void setAnalogDivider      ();
    void setHeartRate          ();

    // Internal functions.
    long timeSince              (long event);
    void updateDigitalListeners ();
    void updateAnalogListeners  ();
};

#endif
