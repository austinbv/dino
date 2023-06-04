// If using Wi-Fi or Ethernet shield, uncomment this to let the SPI library know.
// #define TXRX_SPI

// Uncomment this line to enable debugging mode.
// #define debug

// Define the version of Dino the board was flashed with so we can verify in Ruby.
#define DINO_VERSION __VERSION__

// Uncomment these to include features beyond core features.
// #define DINO_ONE_WIRE
// #define DINO_TONE
// #define DINO_SPI_BB
// #define DINO_I2C
// #define DINO_SPI
// #define DINO_SERVO
// #define DINO_UART
// #define DINO_UART_BB
// #define DINO_IR_OUT
// #define DINO_LED_ARRAY

// Include libraries for specific LED array protocols.
#ifdef DINO_LED_ARRAY
  #define DINO_LED_WS2812
#endif

// Define number of pins to set up listener storage.
#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
  #define PIN_COUNT 70
#elif defined(__SAM3X8E__)
  #define PIN_COUNT 72
#elif defined(ESP8266)
  #define PIN_COUNT 18
#elif defined(ESP32)
  #define PIN_COUNT 40
#elif defined(ARDUINO_ARCH_RP2040)
  #define PIN_COUNT 26
#else
  #define PIN_COUNT 22
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

// Filter for boards that can set their analog write resolution.
#if defined(__SAM3X8E__) || defined(__SAMD21G18A__) || defined(ESP32) || defined(ARDUINO_ARCH_RP2040) || defined(ESP8266)
  #define WRITE_RESOLUTION_SETTER
#endif

// Filter for boards that can set their analog read resolution.
#if defined(__SAM3X8E__) || defined(__SAMD21G18A__) || defined(ESP32) || defined(ARDUINO_ARCH_RP2040)
  #define READ_RESOLUTION_SETTER
#endif

// Figure out how many open (not connected to a USB port) hardware UARTS there are on the board.
#ifdef DINO_UART
  // Look for TX pin definitions on RP2040.
  #if defined(RP2040)
    #if   defined(PIN_SERIAL2_TX)
      #define DINO_UARTS 2
    #elif defined(PIN_SERIAL_1_TX)
      #define DINO_UARTS 1
    #endif
  
  // ESP32 has either 1 or 2 extra UARTS enabled, depending on chip and board.
  #elif defined(ESP32)
    #if SOC_UART_NUM == 3
      #define DINO_UARTS 2
    #elif SOC_UART_NUM == 2
      #define DINO_UARTS 1
    #endif  

  // ESP8266 has a single open transmit-only UART.
  #elif defined(ESP8266) && defined(SERIAL_PORT_HARDWARE_OPEN)
    #define DINO_UARTS 1

  // This works for all the Atmel cores.
  #else
    #if defined(SERIAL_PORT_HARDWARE3)
      #define DINO_UARTS 3
    #elif defined(SERIAL_PORT_HARDWARE2)
      #define DINO_UARTS 2
    #elif defined(SERIAL_PORT_HARDWARE1)
      #define DINO_UARTS 1
    #endif
  #endif
#endif

#ifdef DINO_UART_BB
  #include <SoftwareSerial.h>
#endif

// If no high usage features (core sketch), 32 + 16.
#if !defined(DINO_SHIFT) && !defined (DINO_I2C) && !defined(DINO_SPI) && !defined(DINO_UARTS) && !defined(DINO_UART_BB) && !defined(DINO_IR_OUT) && !defined(DINO_LED_ARRAY)
  #define AUX_SIZE 48
// If using IR_OUT or LED_ARRAY, and not on the ATmega168, 512 + 16.
#elif (defined(DINO_IR_OUT) || defined(DINO_LED_ARRAY)) && !defined(__AVR_ATmega168__)
  #define AUX_SIZE 528
// Default aux message size to 256 + 16 bytes.
#else
  #define AUX_SIZE 272
#endif
