# Supported Microcontrollers

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet

### Microchip/Atmel Chips in Arduino Products (and Compatibles)
[![AVR Build Status](https://github.com/austinbv/dino/actions/workflows/build_avr.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_avr.yml) [![MegaAVR Build Status](https://github.com/austinbv/dino/actions/workflows/build_megaavr.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_megaavr.yml) [![SAM3X Build Satus](https://github.com/austinbv/dino/actions/workflows/build_sam3x.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_sam3x.yml) [![SAMD Build Satus](https://github.com/austinbv/dino/actions/workflows/build_samd.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_samd.yml) 

|    Chip        | Status          | Version| Boards           | Notes |
| :--------      | :------:        | :----- | :--------------- |------ |
| ATmega168      | :green_heart:  | 0.12.0 | Duemilanove, Diecimila, Pro | IR Out, Serial left out to save memory. Configurable features. Run `dino targets` for more info.
| ATmega328      | :green_heart:   | 0.11.0 | Uno, Nano, Fio, Pro  | 
| ATmega32u4     | :green_heart:   | 0.11.0 | Leonardo, Micro, Leonardo ETH, Esplora, LilyPad USB | **v0.11.1** for Leonardo ETH
| ATmega1280     | :green_heart:   | 0.11.1 | Mega | 
| ATmega2560     | :green_heart:   | 0.11.1 | Mega2560, Arduino Mega ADK | 
| ATmega4809     | :man_shrugging: | 0.12.0 | Nano Every, Uno WiFi Rev2 | No hardware to test, but should work
| ATSAM3X8E      | :yellow_heart:  | 0.12.0 | Due | Uses native USB. SoftSerial, Tone, IR Out, and I2C don't work yet
| ATSAMD21       | :green_heart:   | 0.13.0 | Zero, M0, M0 Pro |

**Note:** Only USB boards listed. Any supported chip should work, once you can flash it and connect to serial.

### Arduino Accessories

|    Chip               | Status          | Version| Product          | Notes |
| :--------             | :------:        | :----- | :--------------- |------ |
| Wiznet W5100/5500     | :green_heart:   | 0.11.1 | Ethernet Shield  | Wired Ethernet for Uno/Mega pin-compatibles
| HDG204 + AT32UC3      | :man_shrugging: | 0.12.0 | WiFi Shield      | WiFi for Uno. No hardware to test, but compiles
| ATWINC1500            | :man_shrugging: | 0.12.0 | WiFi Shield 101  | Same as above, high memory use, Mega only

### Espressif Chips with Built-In WiFi
[![ESP8266 Build Status](https://github.com/austinbv/dino/actions/workflows/build_esp8266.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_esp8266.yml) [![ESP32 Build Status](https://github.com/austinbv/dino/actions/workflows/build_esp32.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_esp32.yml)

|    Chip        | Status          | Version| Boards           | Notes |
| :--------      | :------:        | :----- | :--------------- |------ |
| ESP8266        | :yellow_heart:  | 0.12.0 | NodeMCU | No Software Serial
| ESP8285        | :man_shrugging: | 0.12.0 | DOIT ESP-Mx DevKit | Should be identical to 8266. Not tested in hardware.
| ESP32          | :yellow_heart:  | 0.12.0 | DOIT ESP32 DevKit V1 | No SoftSerial or DAC Out. SPI mode bug (see changelog).
| ESP32-S2       | :test_tube:     | 0.12.0 | LOLIN S2 Pico | Should work, hardware limits will be wrong
| ESP32-S3       | :test_tube:     | 0.12.0 | LOLIN S3 V1.0.0 | Should work, hardware limits will be wrong

**Note:** There are too many boards using these chips to be comprehensive. Most should work. These are the exact ones used for testing, chosen based on popularity.

**Note:** For these boards, "pin" numbers are always based on GPIO numbers defined by the CHIP, not the pin numbers labeled on the BOARD. They might coincide, but not always. Keep a mapping reference handy for your particular board.

### Raspberry Pi Microcontrollers
[![RP2040 Build Status](https://github.com/austinbv/dino/actions/workflows/build_rp2040.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_rp2040.yml)

|    Chip        | Status          | Version| Boards           | Notes |
| :--------      | :------:        | :----- | :--------------- |------ |
| RP2040         | :test_tube:     | -      | Raspberry Pi Pico (W) | Sofware Serial disabled. WiFi only on W version.

**Note:** There are many boards built around the RP2040. Check your board's GPIO pin map, and use GPIO numbers in dino.

# Supported Components

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet

### Basic GPIO Interface

| Name                  | Status          | Version  | Component Class | Notes |
| :---------------      | :------:        | :-----   | :------         | :---- |
| Digital Out           | :green_heart:   | 0.11.0   | `DigitalOutput` | -     |
| Digital In            | :green_heart:   | 0.11.0   | `DigitalInput`  | 1ms - 128ms (4ms default) listen, poll, or read
| Analog (PWM) Out      | :green_heart:   | 0.11.0   | `AnalogOutput`  |
| Analog (ADC) In       | :green_heart:   | 0.11.0   | `AnalogInput`   | 1ms - 128ms (16ms default) listen, poll, or read
| Analog (DAC) Out      | :green_heart:   | 0.12.0   | `AnalogOutput`  | On Due, Zero and ESP32
| Tone Out (Square Wave)| :green_heart:   | 0.12.0   | -               | Not working on Due yet

**Note:** When listening, the board checks the pin's value every **_2^n_** ms (**_n_** from **_0_** to **_7_**), without further prompting. Polling and reading follow a call and response pattern.

### Advanced Interfaces

| Name             | Status         | SW/HW     | Version  | Component Class | Notes |
| :--------------- | :------:       | :-------- | :-----   | :---------------  |------ |
| I2C              | :green_heart:  | Hardware  | 0.12.0   | `I2C::Bus` | Only default clocks
| SPI              | :green_heart:  | Hardware  | 0.12.0   | `Register::Select` | Hardware register I/O
| Shift In/Out     | :green_heart:  | Software  | 0.12.0   | `Register::Select` | Bit bang register I/O
| Software Serial  | :yellow_heart: | Software  | 0.12.0   | `SoftwareSerial` | Library on Board. Write only
| Hardware Serial  | :heart:        | Hardware  | -        | - | For boards with native USB and UARTs
| Maxim OneWire    | :green_heart:  | Software  | 0.12.0   | `OneWire::Bus` | No overdrive support
| Infrared Emitter | :green_heart:  | Software  | 0.12.0   | `IREmitter` | Library on Board
| Infrared Receiver| :heart:        | Software  | -        | -           | Doable with existing library

### Generic Components

| Name             | Status         | Interface   | Version  | Component Class   | Notes |
| :--------------- | :------:       | :--------   | :-----   | :---------------  |------ |
| Board EEPROM     | :green_heart:  | Built-In    | 0.12.0   | `BoardEEPROM` | Not all boards have EEPROM
| Led              | :green_heart:  | Digi/Ana Out| 0.11.0   | `Led` |
| RGBLed           | :green_heart:  | Digi/Ana Out| 0.11.0   | `RGBLed` |
| Relay            | :green_heart:  | Digital Out | 0.11.0   | `Relay` |
| 7 Segment Display| :yellow_heart: | Digital Out | 0.12.0   | `SSD` | No decimal point
| Button           | :green_heart:  | Digital In  | 0.11.0   | `Button` | 
| Rotary Encoder   | :green_heart:  | Digital In  | 0.12.0   | `RotaryEncoder` | Listens every 1ms
| PIR Sensor       | :yellow_heart: | Digital In  | 0.11.0   | `DigitalInput` | Needs class. HC-SR501 
| Analog Sensor    | :green_heart:  | Analog In   | 0.11.0   | `Sensor` |
| Potentiometer    | :green_heart:  | Analog In   | 0.12.0   | `Potentiometer` | Smoothing on by default
| Piezo Buzzer     | :green_heart:  | Tone Out    | 0.12.0   | `Piezo` | Frequency > 30Hz
| Input Register   | :green_heart:  | Shift In    | 0.12.0   | `Register::ShiftIn` | Tested on CD4021B
| Input Register   | :green_heart:  | SPI         | 0.12.0   | `Register::SPIIn` | Tested on CD4021B
| Output Register  | :green_heart:  | Shift Out   | 0.12.0   | `Register::ShiftOut` | Tested on 74HC595
| Output Register  | :green_heart:  | SPI         | 0.12.0   | `Register::SPIOut` | Tested on 74HC595

**Note:** Most Digital In and Out components can be used seamlessley through Input and Output Registers respectively.

### Motors / Motor Drivers

| Name                 | Status         | Interface           | Version  | Component Class   | Notes |
| :---------------     | :------:       | :--------           | :-----   | :---------------  |------ |
| Servo                | :green_heart:  | PWM + Library       | 0.11.2   | `Servo`  | Maximum of 6 on ATmega168, 16 on ESP32 and 12 otherwise
| L298N                | :green_heart:  | Digi + PWM Out      | 0.13.0   | `L298`   | H-Bridge DC motor driver
| A3967                | :green_heart:  | Digital Out         | 0.12.0   | `Stepper`| 1ch microstepper (EasyDriver)
| PCA9685              | :heart:        | I2C                 | -        | -        | 16ch 12-bit PWM for servo or LED

### Displays

| Name                     | Status         | Interface                    | Version  | Component Class   | Notes |
| :---------------         | :------:       | :--------                    | :-----   | :---------------  |------ |
| HD44780 LCD              | :green_heart:  | Digital Out, Output Register | 0.13.0   | `HD44780` | 
| SSD1306 OLED             | :yellow_heart: | I2C                          | 0.13.0   | `I2C::SSD1306` | Only basic character support

### Addressable LEDs

| Name               | Status             | Interface             | Version  | Component Class   | Notes |
| :---------------   | :------:           | :--------             | :-----   | :---------------  |------ |
| Neopixel / WS2812B | :heart:            | -                     | -        | - |
| Dotstar / APA102   | :grey_exclamation: | SPI                   | -        | - |

### I/O Expansion

| Name             | Status         | Interface     | Version  | Component Class      | Notes |
| :--------------- | :------:       | :--------     | :-----   | :---------------     |------ 
| PCF8574 Expander | :heart:        | I2C           | -        | -  | 8ch bi-directional digital I/O
| ADS1115 ADC      | :heart:        | I2C           | -        | -  | 16-bit, 4ch analog to digital converter
| ADS1118 ADC      | :heart:        | SPI           | -        | -  | 16-bit, 4ch analog to digital converter
| PCF8591 ADC/DAC  | :heart:        | I2C           | -        | -  | 4ch ADC + 1ch DAC, 8-bit resolution

### Environmental Sensors

| Name             | Status         | Interface | Version  | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :-----   | :---------------  |------ |
| DHT 11/21/22     | :green_heart:  | Digi In/Out| 0.12.0  | `DHT`             | Temperature, Humidity
| DS18B20          | :green_heart:  | OneWire   | 0.12.0   | `OneWire::DS18B20`| Temperature
| MAX31850         | :grey_exclamation: | OneWire   | -        | - | Thermocouple
| BME280           | :green_heart:  | I2C       | 0.13.0   | `I2C::BME280` | Temperature, Pressure, Humidity
| BMP280           | :green_heart:  | I2C       | 0.13.0   | `I2C::BMP280` | Temperature, Pressure
| HTU21D           | :heart:        | I2C       | -        | - | Temperature, Humidity
| HTU31D           | :heart:        | I2C       | -        | - | Temperature, Humidity
| AHT10            | :heart:        | I2C       | -        | - | Temperature, Humidity
| AHT21            | :heart:        | I2C       | -        | - | Temperature, Humidity
| ENS160           | :heart:        | I2C       | -        | - | CO2e, TVOC, AQI
| AGS02MA          | :heart:        | I2C       | -        | - | TVOC


### Light Sensors

| Name             | Status         | Interface | Version  | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :-----   | :---------------  |------ |
| APDS9960         | :heart:        | I2C       | -        | - | Proximity, RGB, Gesture


### Distance Sensors

| Name             | Status         | Interface | Version  | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :-----   | :---------------  |------ |
| HC-SR04          | :heart:        | Direct    | -        | - | Ultrasonic, 20-4000mm
| VL53L0X          | :heart:        | I2C       | -        | - | Laser, 30 - 1000mm
| GP2Y0E03         | :heart:        | I2C       | -        | - | Infrared, 40 - 500mm

### Motion Sensors

| Name             | Status         | Interface | Version  | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :-----   | :---------------  |------ |
| ADXL345          | :heart:        | I2C       | -        | - | 3-axis Accelerometer
| IT3205           | :heart:        | I2C       | -        | - | 3-axis Gyroscope
| HMC5883L         | :heart:        | I2C       | -        | - | 3-axis Compass

### Real Time Clock

| Name             | Status         | Interface | Version  | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :-----   | :---------------  |------ |
| DS3221           | :yellow_heart: | I2C       | 0.12.0   | `I2C::DS3231`     | Only set and get time implemented

### Miscellaneous

| Name             | Status         | Interface   | Version  | Component Class   | Notes |
| :--------------- | :------:       | :--------   | :-----   | :---------------  |------ |
| MFRC522          | :heart:        | SPI / I2C   | -        | -                 | RFID tag reader / writer
