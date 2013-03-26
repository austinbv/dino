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
#else
#  define PIN_COUNT 22
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
    
    // Listeners correspond to raw pin number by array index, and store boolean. false == disabled.
    boolean analogListeners[PIN_COUNT];
    boolean digitalListeners[PIN_COUNT];
    
    // Keep track of the last read values for digital listeners. Only write responses when changed.
    byte digitalListenerValues[PIN_COUNT];

    // Parsed message storage.
    char cmdStr[5]; int cmd;
    char pinStr[5]; int pin;
    char valStr[5]; int val;
    char auxMsg[256];
    
    // Parser state storage.
    char *messageFragments[4];
    byte fragmentIndex;
    int charIndex;
    boolean backslash;

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
    void append                 (char c);
    long timeSince              (long event);
    void updateDigitalListeners ();
    void updateAnalogListeners  ();
};

#endif
