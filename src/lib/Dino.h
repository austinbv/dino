/*
  Library for dino ruby gem.
*/
#ifndef Dino_h
#define Dino_h
#include <Arduino.h>
#include "DinoDefines.h"

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
    void pwmWrite    (byte p, int v,  boolean echo=true);  //cmd = 3
    void dacWrite    (byte p, int v,  boolean echo=true);  //cmd = 4
    int  aRead       (byte p);                             //cmd = 5
    void setListener (byte p, boolean enabled, byte analog, byte exponent, boolean local=true); //cmd = 6
    
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
    // Track which pin is assigned to each LEDC channel.
    // Byte 0 = enabled or disabled
    // Byte 1 = pin number attached to that channel
    //
    #ifdef ESP32
    byte ledcPins[LEDC_CHANNEL_COUNT][2];
    byte ledcChannel(byte p);
    byte assignLEDC(byte channel, byte pin);
    void releaseLEDC(byte p);
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
    // byte 0, bits 2-0: timing divider exponent (2^0 through 2^7)
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
    void eepromRead            ();   //cmd = 7
    void eepromWrite           ();   //cmd = 8

    // Included Libraries
    void pulseRead             ();   //cmd = 9
    void servoToggle           ();   //cmd = 10
    void servoWrite            ();   //cmd = 11
    void handleSerial          ();   //cmd = 12
    void irSend                ();   //cmd = 16
    void tone                  ();   //cmd = 17
    void noTone                ();   //cmd = 18
    void showLEDArray          ();   //cmd = 19

    // Bit Bang SPI
    void spiBBtransfer         (uint8_t clock, uint8_t input, uint8_t output, uint8_t select, uint8_t settings, 
                                uint8_t rLength, uint8_t wLength, byte *data);                                                          //cmd = 21
    byte spiBBtransferByte     (uint8_t clock, uint8_t input, uint8_t output, uint8_t select,
                                uint8_t mode, uint8_t bitOrder, byte data);
    void spiBBaddListener      ();                                                                                                      //cmd = 22
    void spiBBreadListener     (uint8_t i);

    // Hardware SPI
    void spiBegin              (byte settings, uint32_t clockRate);
    void spiEnd                ();
    void spiTransfer           (uint32_t clockRate, uint8_t selectPin, uint8_t settings, uint8_t rLength, uint8_t wLength, byte *data); //cmd = 26
    void spiAddListener        ();                                                                                                      //cmd = 27
    void spiReadListener       (uint8_t i);
 
    // SPI Listeners (both hardware and bit bang)
    void spiRemoveListener     ();                                                                                                      //cmd = 28
    void spiUpdateListeners    ();
    void spiClearListeners     ();

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
    void handshake                      ();  //cmd = 90
    void resetState                     ();  //cmd = 91
    void setRegisterDivider             ();  //cmd = 97
    void setAnalogWriteResolution       ();  //cmd = 96
    void setAnalogReadResolution        ();  //cmd = 97
    void microDelay(uint32_t microseconds);  //cmd = 99, Platform specific microsecond delay
    unsigned long lastTime;
    unsigned long timeDiff;
    byte registerDivider;

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
    byte auxMsg[AUX_SIZE];

    //
    // Flow control stuff.
    //
    // Notify the computer when the board has received half a serial buffer of bytes.
    //
    void rxNotify();
    uint8_t rxBytes  = 0;
    uint8_t rxNotifyLimit = 32;
    //
    // Tell the computer to halt or resume sending data to the board.
    //
    // Only use these if running a function on the board that disables interrupts for
    // longer than a single serial character (~85us at 115,200 baud).
    //
    // If the function was initiated by the computer (eg. writing to a WS2812 strip), do
    // not call sendHalt(). The computer should have halted transmission itself after sending
    // the WS2812 command. Only call sendReady() after data is written out to the strip.
    //
    // If the function was initiated on the board (eg. New IR input triggered by an interrupt),
    // call sendHalt() as soon as possible, then call sendReady() when done.
    //
    // sendReady() is also exposed through the API for diagnostics and testing.
    //
    void sendHalt();
    void sendReady(); // cmd = 92

    //
    // Shared SPI listeners that can be used by either hardware or bit bang SPI.
    // 
    #if defined(DINO_SPI) || defined(DINO_SPI_BB)
      // How many SPI lsiteners.
      #define SPI_LISTENER_COUNT 4

      // How to store a SPI listener.
      struct SpiListener{
        uint32_t clock;     // Clock rate if hardware SPI. If bit bang: bits[0..7] = clock pin, bits [8..15] = input pin.
        uint8_t  select;    // Select pin.
        uint8_t  settings;  // Settings mask as given in request.
        uint8_t  length;    // Read length as given in request.
        uint8_t  enabled;   // 0 = disabled, 1 = hardware, 2 = bit bang.
      };
      SpiListener spiListeners[SPI_LISTENER_COUNT];
    #endif
};
#endif
