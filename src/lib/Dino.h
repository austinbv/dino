/*
  Library for dino ruby gem.
*/
#ifndef Dino_h
#define Dino_h
#include <Arduino.h>
#include "DinoDefines.h"

// Figure out how many pins our hardware has.
#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
#  define PIN_COUNT 70
#elif defined(__SAM3X8E__)
#  define PIN_COUNT 66
#else
#  define PIN_COUNT 22
#endif

class Dino {
  public:
    Dino();
    void setOutputStream(Stream* callback);
    void parse(byte c);
    void updateListeners();

  private:
    // Functions with a cmd value can be called through the remote API.

    // See explanation at top of DinoBugWorkaround.cpp
    void bugWorkaround();

    // Core IO Functions
    void setMode               ();         //cmd = 0
    void dWrite                ();         //cmd = 1
    void dRead                 (int pin);  //cmd = 2
    void aWrite                ();         //cmd = 3
    void aRead                 (int pin);  //cmd = 4

    // Core IO Listeners
    void addDigitalListener    ();         //cmd = 5
    void addAnalogListener     ();         //cmd = 6
    void removeListener        ();         //cmd = 7
    void updateDigitalListeners();
    void updateAnalogListeners ();
    void clearDigitalListeners ();
    void clearAnalogListeners  ();
    // Listener State and Storage
    // Array indices mapped to board pins. true = listener enabled on that pin.
    // Cache last value for digital listeners and only send on change.
    boolean analogListeners[PIN_COUNT];
    boolean digitalListeners[PIN_COUNT];
    byte digitalListenerValues[PIN_COUNT];

    // Included Libraries
    void servoToggle           ();         //cmd = 8
    void servoWrite            ();         //cmd = 9
    void handleLCD             ();         //cmd = 10
    void handleSerial          ();         //cmd = 12
    void dhtRead               ();         //cmd = 13
    void ds18Read              ();         //cmd = 15
    void irSend                ();         //cmd = 16
    void tone                  ();         //cmd = 17
    void noTone                ();         //cmd = 18

    // Shift Registers
    void shiftWrite            (int latchPin,  int len, byte dataPin, byte clockPin, byte *data);          //cmd = 21
    void shiftRead             (int latchPin,  int len, byte dataPin, byte clockPin, byte clockHighFirst); //cmd = 22
    void addShiftListener      (int latchPin,  int len, byte dataPin, byte clockPin, byte clockHighFirst); //cmd = 23
    void removeShiftListener   ();                                                                         //cmd = 24
    void updateShiftListeners  ();
    void clearShiftListeners   ();

    // SPI
    void spiBegin              (byte spiMode, uint32_t clockRate);
    void spiEnd                ();
    void spiWrite              (int selectPin, int len, byte spiMode, uint32_t clockRate, byte *data);     //cmd = 26
    void spiRead               (int selectPin, int len, byte spiMode, uint32_t clockRate);                 //cmd = 27
    void addSpiListener        (int selectPin, int len, byte spiMode, uint32_t clockRate);                 //cmd = 28
    void removeSpiListener     ();                                                                         //cmd = 29
    void updateSpiListeners    ();
    void clearSpiListeners     ();

    // I2C
    void i2cBegin              (); //cmd = 31
    void i2cEnd                (); //cmd = 32
    void i2cScan               (); //cmd = 33
    void i2cWrite              (); //cmd = 34
    void i2cRead               (); //cmd = 35

    // API access to timings, resolutions and reset.
    void reset                 ();  //cmd = 90
    void resetState            ();
    void setRegisterDivider    ();  //cmd = 97
    void setAnalogResolution   ();  //cmd = 96
    void setAnalogDivider      ();  //cmd = 97
    void setHeartRate          ();  //cmd = 98

    // Parser state storage and utility functions.
    byte *messageFragments[4];
    byte fragmentIndex;
    int charIndex;
    boolean escaping;
    void append(byte c);

    // Mostly a switch statement that decides what to run.
    void process();

    // Parsed message storage.
    byte cmdStr[5]; int cmd;
    byte pinStr[5]; int pin;
    byte valStr[5]; int val;

    // Scale aux message allocation based on enabled features and chip.
    #if !defined (__AVR_ATmega168__)
      #if defined(DINO_IR_OUT)
        byte auxMsg[528];
      #elif defined(DINO_SHIFT) || defined(DINO_SPI) || defined (DINO_I2C)
        byte auxMsg[272];
      #elif defined (DINO_LCD)
        byte auxMsg[144];
      #else
        byte auxMsg[48];
      #endif
    #else
      byte auxMsg[40];
    #endif

    // Save a pointer to any stream so we can call ->print and ->write on it.
    Stream* stream;

    // Storage and response func for features following the pin:rval pattern.
    int rval;
    void coreResponse();

    // Internal timing variables and utility functions.
    long heartRate;
    long lastUpdate;
    unsigned int loopCount;
    unsigned int analogDivider;
    unsigned int registerDivider;
    long timeSince (long event);
};
#endif
