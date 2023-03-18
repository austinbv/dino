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

// No EEPROM on the Due or Zero.
#if !defined(__SAM3X8E__) && !defined(ARDUINO_SAMD_ZERO)
  #define EEPROM_PRESENT
  #include <EEPROM.h>
#endif