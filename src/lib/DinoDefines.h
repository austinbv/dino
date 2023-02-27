// If using Wi-Fi or Ethernet shield, uncomment this to let the SPI library know.
// #define TXRX_SPI

// Uncomment this line to enable debugging mode.
// #define debug

// Uncomment these to include features beyond core features.
// #define DINO_SERVO
// #define DINO_LCD
// #define DINO_SERIAL
// #define DINO_ONE_WIRE
// #define DINO_IR_OUT
// #define DINO_TONE
// #define DINO_SHIFT
// #define DINO_SPI
// #define DINO_I2C

// No EEPROM on the Due.
#ifndef __SAM3X8E__
  #define EEPROM_PRESENT
  #include <EEPROM.h>
#endif