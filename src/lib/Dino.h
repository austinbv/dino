/*
  Library for dino ruby gem.
*/

#ifndef Dino_h
#define Dino_h
#include "Arduino.h"

class Dino {
  public:
    Dino();
    bool debug;
    void setupWrite(void (*writeCallback)(char *str));
    void parse(char c);
    void process();
    void updateListeners();
    
  private:
    // Manage heartbeat and listeners.
    long heartRate;
    long lastUpdate;
    
    // Storage for enough analog and digital listeners for UNO or Nano board.
    // Analogs correspond to pins A0 through A7 by array index, and store raw pin number as byte. 0 == disabled.
    // Digitals correspond to raw pin number by array index, and store boolean. false == disabled.
    // Analog pins can be listened to for a digital signal, hence 22.
    byte analogListeners[8];
    boolean digitalListeners[22];
    
    // Keep track of the last read values for digital listeners. Only write responses when changed.
    byte digitalListenerValues[22];
    
    // Request storage.
    char request[8];
    int index;
    char cmd[3];
    char pinStr[3];
    byte pin;
    boolean analogPin;
    char val[4];
    
    // Value and response storage.
    int rval;
    char response[9];
    void (*_writeCallback)(char *str);
    void writeResponse();

    // API-accessible functions.
    void setMode               ();
    void dWrite                (); 
    void dRead                 ();
    void aWrite                ();
    void aRead                 ();
    void toggleDebug           ();
    void setHeartRate          ();
    void reset                 ();
    void addDigitalListener    ();
    void addAnalogListener     ();
    void removeListener        ();
    
    // Internal functions.
    void convertPin             ();
    void countListeners         ();
    long timeSince              (long event);
    void updateDigitalListeners ();
    void updateAnalogListeners  ();
};

#endif
