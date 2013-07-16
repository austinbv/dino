/*
  Library for dino ruby gem.
*/

#ifndef Dino_h
#define Dino_h

#include "Arduino.h"
#include <Servo.h>
#include "DinoLCD.h"
#include "DinoSerial.h"

// Allocate listener storage based on what board we're running.
#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
#  define PIN_COUNT 70
#  define SERVO_OFFSET 22
#elif defined(__SAM3X8E__)
#  define PIN_COUNT 66
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
    void updateListeners();
    
  private:
    // API-accessible functions.
    void setMode               ();  //cmd = 0
    void dWrite                ();  //cmd = 1
    void dRead                 ();  //cmd = 2
    void aWrite                ();  //cmd = 3
    void aRead                 ();  //cmd = 4
    void addDigitalListener    ();  //cmd = 5
    void addAnalogListener     ();  //cmd = 6
    void removeListener        ();  //cmd = 7
    void servoToggle           ();  //cmd = 8
    void servoWrite            ();  //cmd = 9
    void handleLCD             ();  //cmd = 10
    void shiftWrite            ();  //cmd = 11
    void handleSerial          ();  //cmd = 12
    void reset                 ();  //cmd = 90
    void setAnalogResolution   ();  //cmd = 96
    void setAnalogDivider      ();  //cmd = 97
    void setHeartRate          ();  //cmd = 98
  
    // Parser state storage and utility functions.
    char *messageFragments[4];
    byte fragmentIndex;
    int charIndex;
    boolean backslash;
    void append(char c);
    void process();
    
    // Parsed message storage.
    char cmdStr[5]; int cmd;
    char pinStr[5]; int pin;
    char valStr[5]; int val;
    char auxMsg[256];

    // Value and response storage.
    int rval;
    char response[16];
    
    // Use a write callback from the main sketch to respond.
    void (*_writeCallback)(char *str);
    void writeResponse();

    // Arduino native library variables.
    Servo servos[12];

    // Internal timing variables and utility functions.
    long heartRate;
    long lastUpdate;
    unsigned int loopCount;
    unsigned int analogDivider;
    long timeSince (long event);
    
    // Listeners correspond to raw pin number by array index, and store boolean. false == disabled.
    boolean analogListeners[PIN_COUNT];
    boolean digitalListeners[PIN_COUNT];
    
    // Keep track of the last read values for digital listeners. Only write responses when changed.
    byte digitalListenerValues[PIN_COUNT];

    // Listener update functions.
    void updateDigitalListeners ();
    void updateAnalogListeners  ();
};
#endif
