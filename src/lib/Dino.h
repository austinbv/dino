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
#elif defined(ESP8266)
#  define PIN_COUNT 17
#elif defined(ESP32)
#  define PIN_COUNT 40
#else
#  define PIN_COUNT 22
#endif

// Use the maximum length for the ESP8266 EEPROM.
#if defined(ESP8266) || defined(ESP32)
#  define ESP_EEPROM_LENGTH 512
#endif

class Dino {
  public:
    Dino();
    void run();

    // Expect main sketch to pass a reference to a Stream-like object for IO.
    // Store it and call ->print, ->write, ->available, ->read etc. on it.
    Stream* stream;

    // Callback hooks for local logic (defined in main sketch) based on listeners.
    // These should be used if:
    //   1) a round-trip to the remote client is too slow, or
    //   2) something needs to happen regardless of remote client connection.
    // Eg. Instant feedback from a smart light switch.
    void (*digitalListenCallback)(byte p, byte v);
    void (*analogListenCallback)(byte p, int v);

    // Core IO API Functions
    // Functions with a cmd value can be called through the remote API.
    //
    // This subset is made public to allow use by local listener callbacks.
    // Reading and writing through the dino library can help maintain
    // consistency and notify the remote client of local actions automatically.
    //
    void setMode     (byte p, byte m);                     //cmd = 0
    void dWrite      (byte p, byte v, boolean echo=true);  //cmd = 1
    byte dRead       (byte p);                             //cmd = 2
    void aWrite      (byte p, int v,  boolean echo=true);  //cmd = 3
    int  aRead       (byte p);                             //cmd = 4
    void setListener (byte p, boolean enabled, byte analog, byte exponent, boolean local=true); //cmd = 5
    
    // Read value of micros() every loop.
    unsigned long currentTime;
    
    // Counts 1ms ticks based on currentTime. Rolls over every 256ms.
    byte tickCount;

  private:
    //
    // Main loop listen functions.
    //
    void updateListeners       ();
    void updateCoreListeners   ();
    void analogListenerUpdate  (byte index);
    void digitalListenerUpdate (byte index);
    void clearCoreListeners    ();
    void findLastActiveListener();

    //
    // Tanslating aWrite to ledcWrite for PWM out on the ESP32.
    //
    #ifdef ESP32
    //
    // Track which pin is assigned to each LEDC channel.
    // Byte 0 = enabled or disabled
    // Byte 1 = pin number attached to that channel
    #define LEDC_CHANNEL_COUNT 16
    byte ledcPins[LEDC_CHANNEL_COUNT][2];

    byte ledcChannel(byte p);
    byte attachLEDC(byte channel, byte pin);
    void detachLEDC(byte p);
    void clearLedcChannels();
    #endif

    //
    // Store listeners as a 2 dimensional array where each gets 2 bytes:
    //
    // byte 0, bit 7   : 1 = enabled, 0  = disabled
    // byte 0, bit 6   : 1 = analog, 0 = digital
    // byte 0, bit 5   : digital listener state storage
    // byte 0, bit 4   : local flag (remote client cannot modify listener if set)
    // byte 0, bit 3   : unused
    // byte 0, bits 2-0: timing divider exponent (2^0 through 2^8)
    //
    // byte 1          : pin number
    //
    byte listeners [PIN_COUNT][2];

    // Track the highest number listener that's active.
    byte lastActiveListener;
    // Map 2's exponents for dividers to save time.
    const byte dividerMap[8] = {1, 2, 4, 8, 16, 32, 64, 128};

    // Response func for features following the pin:value pattern.
    void coreResponse(int p, int v);

    // Functions with a cmd value can be called through the remote API.
    // EEPROM Access
    void eepromRead            ();         //cmd = 6
    void eepromWrite           ();         //cmd = 7

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
    void shiftWrite            (int latchPin,  int len, byte dataPin, byte clockPin, byte settings, byte *data); //cmd = 21
    void shiftRead             (int latchPin,  int len, byte dataPin, byte clockPin, byte settings);             //cmd = 22
    void addShiftListener      ();                                                                               //cmd = 23
    void removeShiftListener   ();                                                                               //cmd = 24
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
    void i2cBegin              ();
    void i2cSearch             (); //cmd = 33
    void i2cWrite              (); //cmd = 34
    void i2cRead               (); //cmd = 35
    void i2cTransfer           (); //cmd = 36

    // One Wire
    void owReset               (); //cmd = 41
    void owSearch              (); //cmd = 42
    void owWrite               (); //cmd = 43
    void owRead                (); //cmd = 44
    void owWriteBit            (byte b);
    byte owReadBit             ();

    //
    // Board level timings, resolutions and reset.
    //
    void handshake             ();  //cmd = 90
    void resetState            ();  //cmd = 91
    void setRegisterDivider    ();  //cmd = 97
    void setAnalogResolution   ();  //cmd = 96
    unsigned long lastTime;
    unsigned long timeDiff;
    byte registerDivider;
    
    // Wrapper for different delay implementations by platform.
    void microDelay(uint32_t microseconds);

    //
    // Main loop input functions.
    //
    void parse(byte c);
    void process();

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
    # if defined(ESP8266) || defined(ESP32)
    #  define AUX_SIZE 528
    #elif defined(DINO_IR_OUT) && !defined(__AVR_ATmega168__)
    #  define AUX_SIZE 528
    #elif defined(DINO_SHIFT) || defined(DINO_SPI) || defined (DINO_I2C)
    #  define AUX_SIZE 264
    #elif defined (DINO_LCD)
    #  define AUX_SIZE 136
    #else
    #  define AUX_SIZE 40
    #endif
    byte auxMsg[AUX_SIZE];

    // Flow control stuff. Notify when we've received half a serial buffer worth of bytes.
    void rxNotify();
    uint8_t rxBytes  = 0;
    uint8_t rxNotifyLimit = 32;
};
#endif
