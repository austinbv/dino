// If using Wi-Fi or Ethernet shield, uncomment this to let the SPI library know.
// #define TXRX_SPI

// Uncomment this line to enable debugging mode.
// #define debug

// Uncomment these to include features beyond core features.
// #define DINO_ONE_WIRE
// #define DINO_TONE
// #define DINO_SHIFT
// #define DINO_I2C
// #define DINO_SPI
// #define DINO_SERVO
// #define DINO_SERIAL
// #define DINO_IR_OUT
// #define DINO_LED_ARRAY

// Include libraries for specific LED array protocols.
#ifdef DINO_LED_ARRAY
# define DINO_LED_WS2812
#endif

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

// If no high usage features (core sketch), 32 + 16.
#if !defined(DINO_SHIFT) && !defined (DINO_I2C) && !defined(DINO_SPI) && !defined(DINO_SERIAL) && !defined(DINO_IR_OUT) && !defined(DINO_LED_ARRAY)
#  define AUX_SIZE 48
// If using IR_OUT or LED_ARRAY, and not on the ATmega168, 512 + 16.
#elif (defined(DINO_IR_OUT) || defined(DINO_LED_ARRAY)) && !defined(__AVR_ATmega168__)
# define AUX_SIZE 528
// Default aux message size to 256 + 16 bytes.
#else
# define AUX_SIZE 272
#endif

// No EEPROM on the Due or Zero.
#if !defined(__SAM3X8E__) && !defined(__SAMD21G18A__)
  #define EEPROM_PRESENT
  #include <EEPROM.h>
#endif

// Emulate 512 bytes of EEPROM on ESP chips and the RP2040.
#if defined(ESP8266) || defined(ESP32) || defined(ARDUINO_ARCH_RP2040)
#  define EEPROM_EMULATED
#  define EMULATED_EEPROM_LENGTH 512
#endif

// Figure out how many LEDC channels are available on ESP32 boards.
#ifdef ESP32
  #define LEDC_CHANNEL_COUNT 16
#endif
