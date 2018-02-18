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
    void run();

  private:
    // Main loop functions.
    void acknowledge();
    void parse(byte c);
    void process();

    // See explanation at top of DinoBugWorkaround.cpp
    void bugWorkaround();

    // Functions with a cmd value can be called through the remote API.
    // Core IO Functions
    void setMode               ();         //cmd = 0
    void dWrite                ();         //cmd = 1
    void dRead                 (int pin);  //cmd = 2
    void aWrite                ();         //cmd = 3
    void aRead                 (int pin);  //cmd = 4

    // Core IO Listeners
    void setListener           ();         //cmd = 7
    void updateListeners       ();
    void updateCoreListeners   (byte tickCount);
    void digitalListenerUpdate (byte index);
    void clearCoreListeners    ();

    //
    // Store listeners as a 2 dimensional array where each gets 2 bytes, such that:
    //
    // byte 0, bit 7   : 1 for listener enabled, 0 for listener disabled.
    // byte 0, bit 6   : 1 for analog listener, 0 for digital listener.
    // byte 0, bit 5   : storage for digital listener state
    // byte 0, bits 4-3: unused
    // byte 0, bits 2-0: timing divider exponent specific to this pin, 2^0 through 2^8
    //
    // byte 1          : pin number
    //
    byte listeners [PIN_COUNT][2];

    // Track the highest number listener that's active.
    byte lastActiveListener;
    // Map 2's exponents for dividers to save time.
    const byte dividerMap[8] = {1, 2, 4, 8, 16, 32, 64, 128};

    // Storage and response func for features following the pin:rval pattern.
    int rval;
    void coreResponse(int p, int v);

    // Included Libraries
    void servoToggle           ();         //cmd = 8
    void servoWrite            ();         //cmd = 9
    void handleLCD             ();         //cmd = 10
    void pulseRead             ();         //cmd = 11
    void handleSerial          ();         //cmd = 12
    void irSend                ();         //cmd = 16
    void tone                  ();         //cmd = 17
    void noTone                ();         //cmd = 18

    // Shift Registers
    void shiftWrite            (int latchPin,  int len, byte dataPin, byte clockPin, byte *data);          //cmd = 21
    void shiftRead             (int latchPin,  int len, byte dataPin, byte clockPin, byte clockHighFirst); //cmd = 22
    void addShiftListener      ();                                                                         //cmd = 23
    void removeShiftListener   ();                                                                         //cmd = 24
    void updateShiftListeners  ();
    void clearShiftListeners   ();

    // SPI
    void spiBegin              (byte settings, uint32_t clockRate);
    void spiEnd                ();
    void spiTransfer           (int selectPin, byte settings, byte rLength, byte wLength, uint32_t clockRate, byte *data);  //cmd = 26
    void addSpiListener        ();                                                                                          //cmd = 27
    void removeSpiListener     ();                                                                                          //cmd = 28
    void updateSpiListeners    ();
    void clearSpiListeners     ();

    // I2C
    void i2cBegin              (); //cmd = 31
    void i2cSearch             (); //cmd = 33
    void i2cWrite              (); //cmd = 34
    void i2cRead               (); //cmd = 35

    // One Wire
    void owReset               (); //cmd = 41
    void owSearch              (); //cmd = 42
    void owWrite               (); //cmd = 43
    void owRead                (); //cmd = 44
    void owWriteBit            (byte b);
    byte owReadBit             ();

    // API access to timings, resolutions and reset.
    void reset                 ();  //cmd = 90
    void resetState            ();
    void setRegisterDivider    ();  //cmd = 97
    void setAnalogResolution   ();  //cmd = 96

    // Parser state storage and utility functions.
    byte *messageFragments[4];
    byte fragmentIndex;
    int charIndex;
    boolean escaping;
    void append(byte c);

    // Parsed message storage.
    byte cmdStr[4]; byte cmd;
    byte pinStr[4]; byte pin;
    byte valStr[4]; byte val;

    // Scale aux message allocation based on enabled features and chip.
    #if defined(DINO_IR_OUT) && !defined (__AVR_ATmega168__)
    #  define AUX_SIZE 528
    #elif defined(DINO_SHIFT) || defined(DINO_SPI) || defined (DINO_I2C)
    #  define AUX_SIZE 264
    #elif defined (DINO_LCD)
    #  define AUX_SIZE 136
    #else
    #  define AUX_SIZE 40
    #endif
    byte auxMsg[AUX_SIZE];

    // Save a pointer to any stream so we can call ->print and ->write on it.
    Stream* stream;

    // Internal timing variables and utility functions.
    unsigned long lastTick;
    byte tickCount;
    byte registerDivider;

    // Keep count of bytes as we receive them and send a dino message with how many.
    uint8_t rcvBytes  = 0;
    uint8_t rcvThreshold = 64;
    unsigned long lastRcv = micros();
    long long rcvWindow = 1000000;
};
#endif
