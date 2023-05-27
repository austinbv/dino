# Microcontrollers

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet :question: Works in theory. Untested in real hardware.

### Microchip/Atmel Chips in Arduino Products (and Compatibles)
[![AVR Build Status](https://github.com/austinbv/dino/actions/workflows/build_avr.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_avr.yml) [![MegaAVR Build Status](https://github.com/austinbv/dino/actions/workflows/build_megaavr.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_megaavr.yml) [![SAM3X Build Satus](https://github.com/austinbv/dino/actions/workflows/build_sam3x.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_sam3x.yml) [![SAMD Build Satus](https://github.com/austinbv/dino/actions/workflows/build_samd.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_samd.yml)

|    Chip        | Status          | Products         | Notes |
| :--------      | :------:        | :--------------- |------ |
| ATmega168      | :green_heart:   | Duemilanove, Diecimila, Pro | Features omitted to save memory. `dino targets` for more info.
| ATmega328      | :green_heart:   | Uno, Nano, Fio, Pro  |
| ATmega32u4     | :green_heart:   | Leonardo, Micro, Leonardo ETH, Esplora, LilyPad USB |
| ATmega1280     | :green_heart:   | Mega |
| ATmega2560     | :green_heart:   | Mega2560, Arduino Mega ADK |
| ATmega4809     | :question:      | Nano Every, Uno WiFi Rev2 | No hardware to test, but should work
| ATSAM3X8E      | :yellow_heart:  | Due | Native USB port. Tone, and IR Out don't work.
| ATSAMD21       | :green_heart:   | Zero, M0, M0 Pro | Native USB port. I2C seems stuck on 100 kHz.

**Note:** Only USB boards listed. Any board with a supported chip should work, once you can flash it and connect to serial.

### Arduino Accessories

|    Chip               | Status          | Product          | Notes |
| :--------             | :------:        | :--------------- |------ |
| Wiznet W5100/5500     | :green_heart:   | Ethernet Shield  | Wired Ethernet for Uno/Mega pin-compatibles
| HDG204 + AT32UC3      | :question:      | WiFi Shield      | WiFi for Uno. No hardware to test, but compiles
| ATWINC1500            | :question:      | WiFi Shield 101  | Same as above, high memory use, Mega only

### Espressif Chips with Built-In WiFi
[![ESP8266 Build Status](https://github.com/austinbv/dino/actions/workflows/build_esp8266.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_esp8266.yml) [![ESP32 Build Status](https://github.com/austinbv/dino/actions/workflows/build_esp32.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_esp32.yml)

|    Chip        | Status          | Board Tested         | Notes |
| :--------      | :------:        | :---------------     |------ |
| ESP8266        | :green_heart:   | NodeMCU              |
| ESP8285        | :question:      | DOIT ESP-Mx DevKit   | Should be identical to 8266. Not tested in hardware.
| ESP32          | :green_heart:   | DOIT ESP32 DevKit V1 |
| ESP32-S2       | :green_heart:   | LOLIN S2 Pico        | Native USB
| ESP32-S3       | :green_heart:   | LOLIN S3 V1.0.0      | Native USB
| ESP32-C3       | :green_heart:   | LOLIN C3 Mini V2.1.0 | Native USB

**Note:** For ESP32 chips using native USB, make sure `USB CDC On Boot` is `Enabled` in the IDE's `Tools` menu. Flashing from the CLI doesn't automatically enable this, so the IDE is recommended for now.

### Raspberry Pi Microcontrollers
[![RP2040 Build Status](https://github.com/austinbv/dino/actions/workflows/build_rp2040.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/build_rp2040.yml)

|    Chip        | Status          | Board Tested          | Notes |
| :--------      | :------:        | :---------------      |------ |
| RO2040         | :green_heart:   | Raspberry Pi Pico (W) | WiFi only on W version. No WS1812 LED support.

# Single Board Computers

### Raspberry Pi Single Board Computers
**Note:** See the [dino-piboard](https://github.com/dino-rb/dino-piboard) extension to this gem. It uses the Component classes from this gem, but swaps out the low-level microcontroller interface with the Raspberry Pi's built-in GPIPO interface. This is still a very early work-in-progress.

|    Chip        | Status          | Products              | Notes |
| :--------      | :------:        | :---------------      |------ |
| BCM2835        | :yellow_heart:  | Pi 1, Pi Zero (W)     |
| BCM2836/7      | :question:      | Pi 2                  |
| BCM2837A0/B0   | :question:      | Pi 3                  |
| BCM2711        | :question:      | Pi 4, Pi 400          |
| BCM2710A1      | :question:      | Pi Zero 2W            |

# Peripherals

:green_heart: Full support :yellow_heart: Partial support :heart: Planned. No support yet

### Basic GPIO Interface

| Name                  | Status          | Component Class      | Notes |
| :---------------      | :------:        | :------              | :---- |
| Digital Out           | :green_heart:   | `DigitalIO::Output`  | -     |
| Digital In            | :green_heart:   | `DigitalIO::Input`   | 1ms - 128ms (4ms default) listen, poll, or read
| PWM Out               | :green_heart:   | `PulseIO::PWMOutput` |
| Analog Out (DAC)      | :green_heart:   | `AnalogIO::Output`   | On SAM3X, SAMD21 and some ESP32
| Analog In (ADC)       | :green_heart:   | `AnalogIO::Input`    | 1ms - 128ms (16ms default) listen, poll, or read
| Tone Out (Square Wave)| :green_heart:   | `PulseIO::Buzzer`    | Doesn't work on Due (SAM3X)

**Note:** When listening, the board checks the pin's value every **_2^n_** milliseconds (**_n_** from **_0_** to **_7_**), without further commands.
Polling and reading follow a call and response pattern.

### Advanced Interfaces

| Name             | Status         | SW/HW     | Component Class          | Notes |
| :--------------- | :------:       | :-------- | :---------------         |------ |
| I2C              | :green_heart:  | Hardware  | `I2C::Bus`               | Hardware I2C on predefined pins
| SPI              | :green_heart:  | Hardware  | `SPI::Bus`               | Hardware SPI on prefedined pins
| SPI Bit Bang     | :green_heart:  | Software  | `SPI::BitBang`           | Bit Bang SPI on any pins
| UART             | :heart:        | Hardware  | `UART::Native`           | Most boards have extra hardware UARTs
| UART Bit Bang    | :yellow_heart: | Software  | `UART::BitBang`          | Only on boards with 1 hardware UART. Write only
| Maxim OneWire    | :green_heart:  | Software  | `OneWire::Bus`           | No overdrive support
| Infrared Emitter | :green_heart:  | Software  | `PulseIO::IRTransmitter` | Library on Board
| Infrared Receiver| :heart:        | Software  | `PulseIO::IRReceiver`    | Doable with existing library

### Generic Peripherals

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

**Note:** Most Digital In and Out peripherals can be used seamlessley through Input and Output Registers respectively.

### Motors / Motor Drivers

| Name                 | Status         | Interface      | Component Class    | Notes |
| :---------------     | :------:       | :--------      | :---------------   |------ |
| Servo                | :green_heart:  | PWM + Library  | `Motor::Servo`     | Maximum of 6 on ATmega168, 16 on ESP32 and 12 otherwise
| L298N                | :green_heart:  | Digi + PWM Out | `Motor::L298`      | H-Bridge DC motor driver
| A3967                | :green_heart:  | Digital Out    | `Motor::Stepper`   | 1ch microstepper (EasyDriver)
| PCA9685              | :heart:        | I2C            | `PulseIO::PCA9685` | 16ch 12-bit PWM for servo or LED

### Displays

| Name                     | Status         | Interface                    | Component Class     | Notes |
| :---------------         | :------:       | :--------                    | :---------------    |------ |
| HD44780 LCD              | :green_heart:  | Digital Out, Output Register | `Display::HD44780`  | 
| SSD1306 OLED             | :yellow_heart: | I2C                          | `Display::SSD1306`  | 1 font, some graphics

### Addressable LEDs

| Name               | Status             | Interface         | Component Class    | Notes |
| :---------------   | :------:           | :--------         | :---------------   |------ |
| Neopixel / WS2812B | :yellow_heart:     | Adafruit Library  | `LED::WS2812`      | Not working on RP2040 |
| Dotstar / APA102   | :green_heart:      | SPI               | `LED::APA102`      |

### I/O Expansion

| Name             | Status         | Interface  | Component Class      | Notes |
| :--------------- | :------:       | :--------  | :---------------     |------ |
| PCF8574 Expander | :heart:        | I2C        | `DigitalIO::PCF8574` | 8ch bi-directional digital I/O
| ADS1115 ADC      | :heart:        | I2C        | `AnalogIO::ADS1115`  | 15-bit +/- 4ch ADC
| ADS1118 ADC      | :green_heart:  | SPI        | `AnalogIO::ADS1118`  | 15-bit +/- 4ch ADC, and temperature
| PCF8591 ADC/DAC  | :heart:        | I2C        | `AnalogIO::PCF8591`  | 4ch ADC + 1ch DAC, 8-bit resolution

### Environmental Sensors

| Name             | Status         | Interface   | Component Class    | Notes |
| :--------------- | :------:       | :--------   | :---------------   |------ |
| DHT 11/21/22     | :green_heart:  | Digi In/Out | `Sensor::DHT`      | Temp/RH
| DS18B20          | :green_heart:  | OneWire     | `Sensor::DS18B20`  | Temp
| MAX31850         | :heart:        | OneWire     | `Sensor::MAX31850` | Thermocouple Amplifier
| BME280           | :green_heart:  | I2C         | `Sensor::BME280`   | Temp/RH/Press
| BMP280           | :green_heart:  | I2C         | `Sensor::BMP280`   | Temp/Pres
| HTU21D           | :green_heart:  | I2C         | `Sensor::HTU21D`   | Temp/RH. Locks I2C bus during read. No user register read.
| HTU31D           | :heart:        | I2C         | `Sensor::HTU31D`   | Temp/RH
| AHT10            | :heart:        | I2C         | `Sensor::AHT10`    | Temp/RH
| AHT21            | :heart:        | I2C         | `Sensor::AHT20`    | Temp/RH
| ENS160           | :heart:        | I2C         | `Sensor::ENS160`   | CO2e/TVOC/AQI
| AGS02MA          | :heart:        | I2C         | `Sensor::AGS02MA`  | TVOC

### Light Sensors

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| APDS9960         | :heart:        | I2C       | `Sensor::APDS9960`| Proximity, RGB, Gesture

### Distance Sensors

| Name             | Status         | Interface | Component Class    | Notes |
| :--------------- | :------:       | :-------- | :---------------   |------ |
| HC-SR04          | :heart:        | Direct    | `Sensor::HCSR04`   | Ultrasonic, 20-4000mm
| VL53L0X          | :heart:        | I2C       | `Sensor::VL53L0X`  | Laser, 30 - 1000mm
| GP2Y0E03         | :heart:        | I2C       | `Sensor::GP2Y0E03` | Infrared, 40 - 500mm

### Motion Sensors

| Name             | Status         | Interface | Component Class    | Notes |
| :--------------- | :------:       | :-------- | :---------------   |------ |
| ADXL345          | :heart:        | I2C       | `Sensor::ADXL345`  | 3-axis Accelerometer
| IT3205           | :heart:        | I2C       | `Sensor::IT3205`   | 3-axis Gyroscope
| HMC5883L         | :heart:        | I2C       | `Sensor::HMC5883L` | 3-axis Compass

### Real Time Clock

| Name             | Status         | Interface | Component Class   | Notes |
| :--------------- | :------:       | :-------- | :---------------  |------ |
| DS1302           | :heart:        | I2C       | `RTC::DS1302`     |
| DS3221           | :yellow_heart: | I2C       | `RTC::DS3231`     | Only set and get time implemented

### Miscellaneous

| Name             | Status         | Interface  | Component Class      | Notes |
| :--------------- | :------:       | :--------  | :---------------     |------ |
| MFRC522          | :heart:        | SPI/I2C    | `DigitalIO::MFRC522` | RFID tag reader / writer
