# Supported Microcontrollers

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet

### Microchip/Atmel Chips in Arduino Products (and Compatibles)
[![AVR Build Status](https://github.com/austinbv/dino/actions/workflows/build_avr.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_avr.yml) [![MegaAVR Build Status](https://github.com/austinbv/dino/actions/workflows/build_megaavr.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_megaavr.yml) [![SAM3X Build Satus](https://github.com/austinbv/dino/actions/workflows/build_sam3x.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_sam3x.yml) [![SAMD Build Satus](https://github.com/austinbv/dino/actions/workflows/build_samd.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_samd.yml) 

|    Chip        | Status          | Boards           | Notes |
| :--------      | :------:        | :--------------- |------ |
| ATmega168      | :green_heart:   | Duemilanove, Diecimila, Pro | (Configurable) features omitted to save memory. Run `dino targets` for more info.
| ATmega328      | :green_heart:   | Uno, Nano, Fio, Pro  | 
| ATmega32u4     | :green_heart:   | Leonardo, Micro, Leonardo ETH, Esplora, LilyPad USB | **v0.11.1** for Leonardo ETH
| ATmega1280     | :green_heart:   | Mega | 
| ATmega2560     | :green_heart:   | Mega2560, Arduino Mega ADK | 
| ATmega4809     | :man_shrugging: | Nano Every, Uno WiFi Rev2 | No hardware to test, but should work
| ATSAM3X8E      | :yellow_heart:  | Due | Uses native USB port. Tone, and IR Out don't work.
| ATSAMD21       | :green_heart:   | Zero, M0, M0 Pro | Uses native USB port.

**Note:** Only USB boards listed. Any board with a supported chip should work, once you can flash it and connect to serial.

### Arduino Accessories

|    Chip               | Status          | Product          | Notes |
| :--------             | :------:        | :--------------- |------ |
| Wiznet W5100/5500     | :green_heart:   | Ethernet Shield  | Wired Ethernet for Uno/Mega pin-compatibles
| HDG204 + AT32UC3      | :man_shrugging: | WiFi Shield      | WiFi for Uno. No hardware to test, but compiles
| ATWINC1500            | :man_shrugging: | WiFi Shield 101  | Same as above, high memory use, Mega only

### Espressif Chips with Built-In WiFi
[![ESP8266 Build Status](https://github.com/austinbv/dino/actions/workflows/build_esp8266.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_esp8266.yml) [![ESP32 Build Status](https://github.com/austinbv/dino/actions/workflows/build_esp32.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_esp32.yml)

|    Chip        | Status          | Boards               | Notes |
| :--------      | :------:        | :---------------     |------ |
| ESP8266        | :green_heart:   | NodeMCU |
| ESP8285        | :man_shrugging: | DOIT ESP-Mx DevKit   | Should be identical to 8266. Not tested in hardware.
| ESP32          | :green_heart:   | DOIT ESP32 DevKit V1 |
| ESP32-S2       | :green_heart:   | LOLIN S2 Pico        | Native USB port. Make sure to enable CDC on boot.
| ESP32-S3       | :green_heart:   | LOLIN S3 V1.0.0      | Native USB port. Make sure to enable CDC on boot.
| ESP32-C3       | :green_heart:   | LOLIN C3 Mini V2.1.0 | Hold button (GPIO9) while connecting USB to flash.

### Raspberry Pi Microcontrollers
[![RP2040 Build Status](https://github.com/austinbv/dino/actions/workflows/build_rp2040.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_rp2040.yml)

|    Chip        | Status          | Boards           | Notes |
| :--------      | :------:        | :--------------- |------ |
| RP2040         | :green_heart:   | Raspberry Pi Pico (W) | WiFi only on W version. No WS1812 LED support.

# Supported Components

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet

### Basic GPIO Interface

| Name                  | Status          | Component Class     | Notes |
| :---------------      | :------:        | :------             | :---- |
| Digital Out           | :green_heart:   | `DigitalIO::Output` | -     |
| Digital In            | :green_heart:   | `DigitalIO::Input`  | 1ms - 128ms (4ms default) listen, poll, or read
| PWM Out               | :green_heart:   | `PulseIO::PWMOut`   |
| Analog Out (DAC)      | :green_heart:   | `AnalogIO::Output`  | On SAM3X, SAMD21 and ESP32
| Analog In (ADC)       | :green_heart:   | `AnalogIO::Input`   | 1ms - 128ms (16ms default) listen, poll, or read
| Tone Out (Square Wave)| :green_heart:   | `PulseIO::Buzzer`   | Doesn't work on Due (SAM3X)

**Note:** When listening, the board checks the pin's value every **_2^n_** ms (**_n_** from **_0_** to **_7_**), without further prompting. Polling and reading follow a call and response pattern.

### Advanced Interfaces

| Name             | Status         | SW/HW     | Component Class          | Notes |
| :--------------- | :------:       | :-------- | :---------------         |------ |
| I2C              | :green_heart:  | Hardware  | `I2C::Bus`               |
| SPI              | :green_heart:  | Hardware  | `SPI::Bus`               | Hardware SPI
| SPI Bit Bang     | :green_heart:  | Software  | `SPI::BitBang`           | Bit Bang SPI
| UART             | :heart:        | Hardware  | -                        | Most boards have extra hardware UARTs
| UART Bit Bang    | :yellow_heart: | Software  | `UART::BitBang`          | Only on boards with 1 hardware UART. Write only
| Maxim OneWire    | :green_heart:  | Software  | `OneWire::Bus`           | No overdrive support
| Infrared Emitter | :green_heart:  | Software  | `PulseIO::IRTransmitter` | Library on Board
| Infrared Receiver| :heart:        | Software  | -                        | Doable with existing library

### Generic Components

| Name             | Status         | Interface    | Component Class            | Notes |
| :--------------- | :------:       | :--------    | :---------------           |------ |
| Board EEPROM     | :green_heart:  | Built-In     | `EEPROM::BuiltIn`          | Not all boards have EEPROM
| Led              | :green_heart:  | Digi/Ana Out | `LED::Base`                |
| RGBLed           | :green_heart:  | Digi/Ana Out | `LED::RGB`                 |
| Relay            | :green_heart:  | Digital Out  | `DigitalIO::Relay`         |
| 7 Segment Display| :yellow_heart: | Digital Out  | `LED::SevenSegment`        | No decimal point
| Button           | :green_heart:  | Digital In   | `DigitalIO::Button`        |
| Rotary Encoder   | :green_heart:  | Digital In   | `DigitalIO::RotaryEncoder` | Listens every 1ms
| PIR Sensor       | :yellow_heart: | Digital In   | `DigitalIO::Input`         | Needs class. HC-SR501 
| Analog Sensor    | :green_heart:  | Analog In    | `AnalogIO::Sensor`         |
| Potentiometer    | :green_heart:  | Analog In    | `AnalogIO::Potentiometer`  | Smoothing on by default
| Piezo Buzzer     | :green_heart:  | Tone Out     | `PulseIO::Buzzer`          | Frequency > 30Hz
| Input Register   | :green_heart:  | SPI          | `SPI::InputRegister`       | Tested on CD4021B
| Output Register  | :green_heart:  | SPI          | `SPI::OutputRegister`      | Tested on 74HC595

**Note:** Most Digital In and Out components can be used seamlessley through Input and Output Registers respectively.

### Motors / Motor Drivers

| Name                 | Status         | Interface      | Component Class  | Notes |
| :---------------     | :------:       | :--------      | :--------------- |------ |
| Servo                | :green_heart:  | PWM + Library  | `Motor::Servo`   | Maximum of 6 on ATmega168, 16 on ESP32 and 12 otherwise
| L298N                | :green_heart:  | Digi + PWM Out | `Motor::L298`    | H-Bridge DC motor driver
| A3967                | :green_heart:  | Digital Out    | `Motor::Stepper` | 1ch microstepper (EasyDriver)
| PCA9685              | :heart:        | I2C            | -                | 16ch 12-bit PWM for servo or LED

### Displays

| Name                     | Status         | Interface                    | Component Class     | Notes |
| :---------------         | :------:       | :--------                    | :---------------    |------ |
| HD44780 LCD              | :green_heart:  | Digital Out, Output Register | `Display::HD44780`  | 
| SSD1306 OLED             | :yellow_heart: | I2C                          | `Display::SSD1306`  | 1 font, some graphics

### Addressable LEDs

| Name               | Status             | Interface         | Component Class    | Notes |
| :---------------   | :------:           | :--------         | :---------------   |------ |
| Neopixel / WS2812B | :yellow_heart:     | Adafruit Library  | `LED::WS2812`      | Not working on RP2040 |
| Dotstar / APA102   | :yellow_heart:     | SPI               | `LED::APA102`      | No current control yet and max 64 pixels.

### I/O Expansion

| Name             | Status         | Interface  | Component Class      | Notes |
| :--------------- | :------:       | :--------  | :---------------     |------ |
| PCF8574 Expander | :heart:        | I2C        | -  | 8ch bi-directional digital I/O
| ADS1115 ADC      | :heart:        | I2C        | -  | 16-bit, 4ch analog to digital converter
| ADS1118 ADC      | :heart:        | SPI        | -  | 16-bit, 4ch analog to digital converter
| PCF8591 ADC/DAC  | :heart:        | I2C        | -  | 4ch ADC + 1ch DAC, 8-bit resolution

### Environmental Sensors

| Name             | Status         | Interface   | Component Class    | Notes |
| :--------------- | :------:       | :--------   | :---------------   |------ |
| DHT 11/21/22     | :green_heart:  | Digi In/Out | `Sensor::DHT`      | Temperature, Humidity
| DS18B20          | :green_heart:  | OneWire     | `Sensor::DS18B20`  | Temperature
| MAX31850         | :heart:        | OneWire     | - | Thermocouple
| BME280           | :green_heart:  | I2C         | `Sensor::BME280`   | Temperature, Pressure, Humidity
| BMP280           | :green_heart:  | I2C         | `Sensor::BMP280`   | Temperature, Pressure
| HTU21D           | :heart:        | I2C         | - | Temperature, Humidity
| HTU31D           | :heart:        | I2C         | - | Temperature, Humidity
| AHT10            | :heart:        | I2C         | - | Temperature, Humidity
| AHT21            | :heart:        | I2C         | - | Temperature, Humidity
| ENS160           | :heart:        | I2C         | - | CO2e, TVOC, AQI
| AGS02MA          | :heart:        | I2C         | - | TVOC

### Light Sensors

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| APDS9960         | :heart:        | I2C       | - | Proximity, RGB, Gesture

### Distance Sensors

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| HC-SR04          | :heart:        | Direct    | - | Ultrasonic, 20-4000mm
| VL53L0X          | :heart:        | I2C       | - | Laser, 30 - 1000mm
| GP2Y0E03         | :heart:        | I2C       | - | Infrared, 40 - 500mm

### Motion Sensors

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| ADXL345          | :heart:        | I2C       | - | 3-axis Accelerometer
| IT3205           | :heart:        | I2C       | - | 3-axis Gyroscope
| HMC5883L         | :heart:        | I2C       | - | 3-axis Compass

### Real Time Clock

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| DS3221           | :yellow_heart: | I2C       | `RTC::DS3231`     | Only set and get time implemented

### Miscellaneous

| Name             | Status         | Interface  | Component Class   | Notes |
| :--------------- | :------:       | :--------  | :---------------  |------ |
| MFRC522          | :heart:        | SPI / I2C  | -                 | RFID tag reader / writer
