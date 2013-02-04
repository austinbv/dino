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
    void process(char* request, char* loopResponse);
    int updateListeners(char* responses);
    boolean updateReady();

  private:
    // Heartbeat timing.
    long lastUpdate;
    long heartRate;
    
    // Storage for enough analog and digital listeners for UNO or Nano board.
    // Analogs correspond to pins A0 through A7 by array index, and store raw pin number as int. 0 == disabled.
    // Digitals correspond to raw pin number by array index, and store boolean. false == disabled.
    // Analog pins can be listened to for a digital signal, hence 22.
    int analogListeners[8];
    boolean digitalListeners[22];
  
    // Storage for a single request after parsing.
    char cmd[3];
    char pinStr[3];
    int  pin;
    boolean analogPin;
    char val[4];
    
    // Storage for a single response.
    // process() and updateListeners() are responsible for passing this to the main loop as needed.
    char response[9];

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
    void convertPin     ();
};

#endif
