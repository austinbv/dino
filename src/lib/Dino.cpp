/*
  Library for dino ruby gem.
*/

#include "Arduino.h"
#include "Dino.h"
#if defined(__SAM3X8E__)
  #include <avr/dtostrf.h>
#endif

DinoLCD dinoLCD;
DHT dht;
IRsend irsend;

// SoftwareSerial doesn't work on the Due yet.
#if !defined(__SAM3X8E__)
  DinoSerial dinoSerial;
#endif

Dino::Dino(){
  newline[0] = '\n'; newline[1] = '\0';
  messageFragments[0] = cmdStr;
  messageFragments[1] = pinStr;
  messageFragments[2] = valStr;
  messageFragments[3] = auxMsg;
  reset();
}

void Dino::parse(byte c) {
  if ((c == '\n') || (c == '\\')) {
    // If last char was a \, this \ or \n is escaped.
    if(backslash){
      append(c);
      backslash = false;
    }

    // If EOL, process and reset.
    else if (c == '\n'){
      append('\0');
      process();
      fragmentIndex = 0;
      charIndex = 0;
    }

    // Backslash is the escape character.
    else if (c == '\\') backslash = true;
  }

  // If fragment delimiter, terminate current fragment and move to next.
  // Unless we're in the auxillary message fragment, then just append.
  else if (c == '.') {
    if (fragmentIndex < 3) {
      append('\0');
      fragmentIndex++;
      charIndex = 0;
    } else {
      append(c);
    }
  }

  // Else just append the character.
  else append(c);
}

void Dino::append(byte c) {
  messageFragments[fragmentIndex][charIndex++] = c;
}

void Dino::process() {
  cmd = atoi(cmdStr);
  pin = atoi(pinStr);
  val = atoi(valStr);
  response[0] = '\0';

  #ifdef debug
   Serial.print("Received - Command: "); Serial.print(cmdStr);
   Serial.print(" Pin: ");               Serial.print(pinStr);
   Serial.print(" Value: ");             Serial.print(valStr); Serial.print("\n")
  #endif

  // Call the command.
  switch(cmd) {
    case 0:  setMode             ();    break;
    case 1:  dWrite              ();    break;
    case 2:  dRead               (pin); break;
    case 3:  aWrite              ();    break;
    case 4:  aRead               (pin); break;
    case 5:  addDigitalListener  ();    break;
    case 6:  addAnalogListener   ();    break;
    case 7:  removeListener      ();    break;
    case 8:  servoToggle         ();    break;
    case 9:  servoWrite          ();    break;
    case 10: handleLCD           ();    break;
    case 12: handleSerial        ();    break;
    case 13: handleDHT           ();    break;
    case 15: ds18Read            ();    break;
    case 16: irSend              ();    break;
    case 20: tone                ();    break;
    case 21: noTone              ();    break;

    // Request format for shift register functions.
    // pin        = latch pin (int)
    // val        = length (int)
    // auxMsg[0]  = data pin (byte)
    // auxMsg[1]  = clock pin (byte)
    // auxMsg[2]  = send clock high before reading (byte) (0/1) (read func only)
    // auxMsg[3]+ = data (bytes) (write func only)
    case 22: shiftWrite (pin, val, auxMsg[0], auxMsg[1], &auxMsg[3]);  break;
    case 23: shiftRead  (pin, val, auxMsg[0], auxMsg[1], auxMsg[2]);   break;
    // Request format for single direction SPI functions.
    // pin         = slave select pin (int)
    // val         = length (int)
    // auxMsg[0]   = SPI mode (byte)
    // auxMsg[1-4] = clock frequency (uint32_t as 4 bytes)
    // auxMsg[5]+  = data (bytes) (write func only)
    case 24: writeSPI   (pin, val, auxMsg[0], (uint32_t)auxMsg[1], &auxMsg[5]); break;
    case 25: readSPI    (pin, val, auxMsg[0], (uint32_t)auxMsg[1]            ); break;
    // These add listeners for both shift in and SPI registers.
    // They mirror the read function interfaces of the respective devices.
    case 26: addShiftListener(pin, val, auxMsg[0], auxMsg[1], auxMsg[2]); break;
    case 27: addSPIListener  (pin, val, auxMsg[0], (uint32_t)auxMsg[1]);  break;
    // This removes either type of listener and frees its space in the cache.
    // The only input it needs is the select/latch pin.
    case 28: removeRegisterListener();

    // I2C functions.
    case 30: i2cBegin            ();  break;
    case 31: i2cEnd              ();  break;
    case 32: i2cScan             ();  break;
    case 33: i2cWrite            ();  break;
    case 34: i2cRead             ();  break;

    case 90: reset               ();  break;
    case 95: setAnalogDivider    ();  break;
    case 96: setAnalogResolution ();  break;
    case 97: setAnalogDivider    ();  break;
    case 98: setHeartRate        ();  break;
    default:                          break;
  }

  // Write the response.
  if (response[0] != '\0') writeResponse();

  #ifdef debug
   Serial.print("Responded with - "); Serial.print(response); Serial.print("\n\n");
  #endif
}


// WRITE CALLBACK
void Dino::setupWrite(void (*writeCallback)(char *str)) {
  _writeCallback = writeCallback;
}
void Dino::writeResponse() {
  _writeCallback(response);
  _writeCallback(newline);
}

// LISTNENERS
void Dino::updateListeners() {
  if (timeSince(lastUpdate) > heartRate || timeSince(lastUpdate) < 0) {
    lastUpdate = micros();
    loopCount++;
    updateDigitalListeners();
    if (loopCount % registerDivider == 0) updateRegisterListeners();
    if (loopCount % analogDivider   == 0) updateAnalogListeners();
  }
}
void Dino::updateDigitalListeners() {
  for (int i = 0; i < PIN_COUNT; i++) {
    if (digitalListeners[i]) {
      dRead(i);
      if (rval != digitalListenerValues[i]) {
        digitalListenerValues[i] = rval;
        writeResponse();
      }
    }
  }
}
void Dino::updateRegisterListeners() {
  for (int i = 0; i < SPI_LISTENER_COUNT; i++) {
    if (spiListeners[i].enabled) {
      readSPI(spiListeners[i].selectPin,
              spiListeners[i].len,
              spiListeners[i].spiMode,
              spiListeners[i].clockRate);
    }
  }
  for (int i = 0; i < SHIFT_LISTENER_COUNT; i++) {
    if (shiftListeners[i].enabled) {
      shiftRead(shiftListeners[i].latchPin,
                shiftListeners[i].len,
                shiftListeners[i].dataPin,
                shiftListeners[i].clockPin,
                shiftListeners[i].clockHighFirst);
    }
  }
}
void Dino::updateAnalogListeners() {
  for (int i = 0; i < PIN_COUNT; i++) {
    if (analogListeners[i]) {
      aRead(i);
      writeResponse();
    }
  }
}
long Dino::timeSince(long event) {
 long time = micros() - event;
 return time;
}


// API FUNCTIONS

// CMD = 00
// Set a pin to output (0), or input (1).
void Dino::setMode() {
  if (val == 0) {
    removeListener();
    pinMode(pin, OUTPUT);
  }
  else {
    pinMode(pin, INPUT);
  }

  #ifdef debug
    Serial.print("Called Dino::setMode()\n");
  #endif
}

// CMD = 01
// Write a digital output pin. 0 for LOW, 1 or >0 for HIGH.
void Dino::dWrite() {
  if (val == 0) {
    digitalWrite(pin, LOW);
  }
  else {
    digitalWrite(pin, HIGH);
  }

  #ifdef debug
    Serial.print("Called Dino::dWrite()\n");
  #endif
}

// CMD = 02
// Read a digital input pin. 0 for LOW, 1 for HIGH.
void Dino::dRead(int pin) {
  rval = digitalRead(pin);
  sprintf(response, "%d:%d", pin, rval);

  #ifdef debug
    Serial.print("Called Dino::dRead()\n");
  #endif
}

// CMD = 03
// Write an analog output pin. 0 for LOW, up to 255 for HIGH @ 8-bit resolution.
void Dino::aWrite() {
  analogWrite(pin,val);

  #ifdef debug
    Serial.print("Called Dino::aWrite()\n");
  #endif
}

// CMD = 04
// Read an analog input pin. 0 for LOW, up to 1023 for HIGH @ 10-bit resolution.
void Dino::aRead(int pin) {
  rval = analogRead(pin);
  sprintf(response, "%d:%d", pin, rval);

  #ifdef debug
    Serial.print("Called Dino::aRead()\n");
  #endif
}

// CMD = 05
// Set a flag to periodically read a digital pin without further requests.
// Runs around other requests in the main loop. Only sends value when changed.
void Dino::addDigitalListener() {
  removeListener();
  digitalListeners[pin] = true;
  digitalListenerValues[pin] = 2;

  #ifdef debug
    Serial.print("Called Dino::addDigitalListener()\n");
  #endif
}

// CMD = 06
// Set a flag to periodically read an analog pin without further requests.
// Runs around other requests in the main loop. Sends value on every read.
void Dino::addAnalogListener() {
  removeListener();
  analogListeners[pin] = true;

  #ifdef debug
    Serial.print("Called Dino::addAnalogListener()\n");
  #endif
}

// CMD = 07
// Remove analog and digital listen flags on the pin.
void Dino::removeListener() {
  analogListeners[pin] = false;
  digitalListeners[pin] = false;

  #ifdef debug
    Serial.print("Called Dino::removeListener()\n");
  #endif
}

// CMD = 08
// Attach the servo object to pin or detach it.
void Dino::servoToggle() {
  if (val == 0) {
    #ifdef debug
      Serial.print("Detaching servo"); Serial.print(" on pin "); Serial.println(pin);
    #endif
    servos[pin - SERVO_OFFSET].detach();
  }
  else {
    #ifdef debug
      Serial.print("Attaching servo"); Serial.print(" on pin "); Serial.println(pin);
    #endif
    servos[pin - SERVO_OFFSET].attach(pin);
  }
}

// CMD = 09
// Write a value to the servo object.
void Dino::servoWrite() {
  #ifdef debug
    Serial.print("Servo write "); Serial.print(val); Serial.print(" to pin "); Serial.println(pin);
  #endif
  servos[pin - SERVO_OFFSET].write(val);
}

// CMD = 10
// Write a value to the servo object.
void Dino::handleLCD() {
  #ifdef debug
    Serial.print("DinoLCD command: "); Serial.print(val); Serial.print(" with data: "); Serial.println(auxMsg);
  #endif
  dinoLCD.process(val, auxMsg);
}


// CMD = 12
// Control the SoftwareSerial.
void Dino::handleSerial() {
  #ifdef debug
    Serial.print("DinoSerial command: "); Serial.print(val); Serial.print(" with data: "); Serial.println(auxMsg);
  #endif
  // SoftwareSerial doesn't work on the Due yet.
  #if !defined(__SAM3X8E__)
  dinoSerial.process(val, auxMsg);
  #endif
}


// CMD = 13
// Read a DHT sensor
void Dino::handleDHT() {
  #ifdef debug
    Serial.print("DinoDHT command: "); Serial.print(val); Serial.print(" with data: "); Serial.println(auxMsg);
  #endif
  // dtostrf doesn't work on the Due yet.
  #if !defined(__SAM3X8E__)
  if (pin != dht.pin) dht.setup(pin);
  float reading;
  char readingBuff[10];
  char prefix;
  if (val == 0) {
    reading = dht.getTemperature();
    prefix = 'T';
  } else {
    reading = dht.getHumidity();
    prefix = 'H';
  }
  if (! isnan(reading)) {
    dtostrf(reading, 6, 4, readingBuff);
    sprintf(response, "%d:%c%s", pin, prefix, readingBuff);
  }
  #endif
}


// CMD = 15
void Dino::ds18Read() {
  OneWire ds(pin);

  byte data[12];
  byte addr[8];

  if ( !ds.search(addr)) {
    ds.reset_search();
    return;
   }

  if ( OneWire::crc8( addr, 7) != addr[7]) {
    // Serial.println("CRC is not valid!");
    return;
  }

  if ( addr[0] != 0x10 && addr[0] != 0x28) {
    // Serial.print("Device is not recognized");
    return;
  }

  ds.reset();
  ds.select(addr);
  ds.write(0x44,1); // start conversion, with parasite power on at the end

  byte present = ds.reset();
  ds.select(addr);
  ds.write(0xBE); // Read Scratchpad

  for (int i = 0; i < 9; i++) { // we need 9 bytes
    data[i] = ds.read();
  }

  ds.reset_search();

  byte MSB = data[1];
  byte LSB = data[0];

  float tempRead = ((MSB << 8) | LSB); //using two's compliment
  float reading = tempRead / 16;
  char readingBuff[10];

  if (! isnan(reading)) {
    dtostrf(reading, 6, 4, readingBuff);
    sprintf(response, "%d:%s", pin, readingBuff);
  }
}


// CMD = 16
void Dino::irSend(){
  irsend.sendRaw((uint16_t)&auxMsg[1], (uint8_t)auxMsg[0], val);
}

// CMD = 20
void Dino::tone() {
  //unsigned int duration = atoi(auxMsg);
  //::tone(pin, val, duration);
}

// CMD = 21
void Dino::noTone() {
  //::noTone(pin);
}


// CMD = 22
// Write to a shift register.
void Dino::shiftWrite(int latchPin, int len, byte dataPin, byte clockPin, byte *data) {
  // Set latch pin low to begin serial write.
  digitalWrite(latchPin, LOW);

  // Write one byte at a time.
  for (uint8_t i = 0;  i < len;  i++) {
    shiftOut(dataPin, clockPin, LSBFIRST, data[i]);
  }

  // Set latch pin high so register writes to parallel output.
  digitalWrite(latchPin, HIGH);
}


// CMD = 23
// Read from a shift register.
void Dino::shiftRead(int latchPin, int len, byte dataPin, byte clockPin, byte clockHighFirst) {
  // Send clock pin high if using a register that clocks on rising edges.
  // If not, the MSB will not be read on those registers (always 1),
  // and all other bits will be shifted by 1 towards the LSB.
  if (clockHighFirst > 0) digitalWrite(clockPin, HIGH);

  // Latch high to read parallel state, then low again to stop.
  digitalWrite(latchPin, HIGH);
  digitalWrite(latchPin, LOW);

  // Send data as if coming from the latch pin so it's easy to identify.
  // Start with just pin number and : for now.
  sprintf(response, "%d:", latchPin);
  _writeCallback(response);

  for (int i = 1;  i <= len;  i++) {
    // Read a single byte from the register.
    byte reading = shiftIn(dataPin, clockPin, LSBFIRST);

    // If we're on the last byte, append \n. If not, append a comma, then write.
    if (i == len) {
      sprintf(response, "%d\n", reading);
    } else {
      sprintf(response, "%d,", reading);
    }
    _writeCallback(response);
  }

  // Leave latch pin high and clear response so main loop doesn't send anything.
  digitalWrite(latchPin, HIGH);
  response[0] = '\0';
}


// CMD = 24
// Write to an SPI device.
void Dino::writeSPI(int selectPin, int len, byte spiMode, uint32_t clockRate, byte *data) {
  // Start the SPI library if it isn't already being used by the main sketch.
  SPI.begin();

  // Set the mode we want.
  switch(spiMode) {
    case 0:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE0)); break;
    case 1:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE1)); break;
    case 2:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE2)); break;
    case 3:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE3)); break;
  }

  // Select the device.
  digitalWrite(selectPin, LOW);

  // Write one byte at a time.
  for (uint8_t i = 0;  i < len;  i++) {
    SPI.transfer(data[i]);
  }

  // End the SPI transaction, and then library if not in use by main sketch.
  SPI.endTransaction();

  // TXRX_SPI is set to false in Dino.h.
  // CLI generator will auto set to true for any sketch other than serial.
  #if !(TXRX_SPI)
    SPI.end();
  #endif

  // Leave select high.
  digitalWrite(selectPin, HIGH);
}


// CMD = 25
// Read from an SPI device.
void Dino::readSPI(int selectPin, int len, byte spiMode, uint32_t clockRate) {
  // Start the SPI library if it isn't already being used by the main sketch.
  SPI.begin();

  // Set the mode we want.
  switch(spiMode) {
    case 0:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE0)); break;
    case 1:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE1)); break;
    case 2:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE2)); break;
    case 3:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE3)); break;
  }

  // Select the device.
  digitalWrite(selectPin, LOW);

  // Send data as if coming from the slave select pin so it's easy to identify.
  // Start with just pin number and : for now.
  sprintf(response, "%d:", selectPin);
  _writeCallback(response);

  for (int i = 1;  i <= len;  i++) {
    // Read a single byte from the register.
    byte reading = SPI.transfer(0x00);

    // If we're on the last byte, append \n. If not, append a comma, then write.
    if (i == len) {
      sprintf(response, "%d\n", reading);
    } else {
      sprintf(response, "%d,", reading);
    }
    _writeCallback(response);
  }

  // End the SPI transaction, and then library if not in use by main sketch.
  SPI.endTransaction();

  // TXRX_SPI is set to false in Dino.h.
  // CLI generator will auto set to true for any sketch other than serial.
  #if !(TXRX_SPI)
    SPI.end();
  #endif

  // Leave select high and clear response so main loop doesn't send anything.
  digitalWrite(selectPin, HIGH);
  response[0] = '\0';
}

// CMD = 26
// Start listening to a register using the Arduino shiftIn function.
// Overwrite the first disabled listener in the struct array.
void Dino::addShiftListener(int latchPin, int len, byte dataPin, byte clockPin, byte clockHighFirst) {
  for (int i = 0;  i < SHIFT_LISTENER_COUNT;  i++) {
    if (shiftListeners[i].enabled == false) {
      shiftListeners[i] = {
        latchPin,
        len,
        dataPin,
        clockPin,
        clockHighFirst,
        true
      };
      return;
    } else {
    // Should send some kind of error if all are in use.
    }
  }
}

// CMD = 26
// Start listening to an SPI register.
// Overwrite the first disabled listener in the struct array.
void Dino::addSPIListener(int selectPin, int len, byte spiMode, uint32_t clockRate) {
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    if (spiListeners[i].enabled == false) {
      spiListeners[i] = {
        selectPin,
        len,
        spiMode,
        clockRate,
        true
      };
      return;
    } else {
    // Should send some kind of error if all are in use.
    }
  }
}


// CMD = 27
// Send a number for a select/latch pin to remove either type of register listener.
void Dino::removeRegisterListener() {
  for (int i = 0;  i < SHIFT_LISTENER_COUNT;  i++) {
    if (shiftListeners[i].latchPin == pin) {
      shiftListeners[i].enabled = false;
    }
  }
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    if (spiListeners[i].selectPin == pin) {
      spiListeners[i].enabled = false;
    }
  }
}


// CMD = 30
// Start I2C communication.
void Dino::i2cBegin() {
  I2c.begin();
  // I2c.setSpeed(??);
  // I2c.pullup(??);
  // I2c.timeOut(??);
  sprintf(response, "%d:I2C:1", SDA);
}


// CMD = 31
// Stop I2C communication.
void Dino::i2cEnd() {
  I2c.end();
  sprintf(response, "%d:I2C:0", SDA);
}


// CMD = 32
// Scan for I2C devices.
//
// WARNING: This takes a long time! Try to record the device addresses
// results and put them into your code.
//
// Returns each found address as if a separate reading from SDA pin, eg. "18:104".
// Returns 128 as if read from SDA pin for search complete, eg. "18:128".
// Returns 255 as if read from SDA pin for I2C errors, eg. "18:255".
//
void Dino::i2cScan() {
  uint8_t address = 0;
  while (address < 128) {
    // Scan for the next device.
    address = I2c.scanOne(address);

    // Write whatever we get including address space end or errors.
    sprintf(response, "%d:%d", SDA, address);
    writeResponse();
    address++;
  }
  // Clear the response to make sure it doesn't get sent twice.
  response[0] = '\0';
}


// CMD = 33
// Write to an I2C device.
// All parameters need to be sent in binary in the auxMsg.
//
// auxMsg[0]  = device address
// auxMsg[1]  = register start address
// auxMsg[2]  = number of bytes
// auxMsg[3]+ = data
//
// Limited to 255 bytes. Validate on remote end.
//
void Dino::i2cWrite() {
  I2c.write(auxMsg[0], auxMsg[1], &auxMsg[3], auxMsg[2]);
}


// CMD = 34
// Read from an I2C device.
// All params need to be sent in binary in the auxMsg.
//
// auxMsg[0]  = device address
// auxMsg[1]  = register start address
// auxMsg[2]  = number of bytes
//
// Streams data back in comma delimited ASCII decimal for now,
// matching shiftRead and readSPI. Limited to 32 bytes by I2C library buffer.
// Validate on remote end.
//
void Dino::i2cRead() {
  // Force length to be min 1, max 32.
  if (auxMsg[2] > 32) auxMsg[2] = 32;
  if (auxMsg[2] == 0) auxMsg[2] =  1;

  // Read all the bytes into the library buffer.
  I2c.read(auxMsg[0], auxMsg[1], auxMsg[2]);

  // Send back the SDA pin, the device address, and start register address first.
  sprintf(response, "%d:%d:%d:", SDA, auxMsg[0], auxMsg[1]);
  _writeCallback(response);

  // Send back the data bytes.
  uint8_t currentByte = 0;
  while(I2c.available()){
    currentByte++;
    // Append comma, but \n for last byte, then write.
    if (currentByte == auxMsg[2]){
      sprintf(response, "%d\n", I2c.receive());
    } else {
      sprintf(response, "%d,", I2c.receive());
    }
    _writeCallback(response);
  }

  // Clear the response to make sure it doesn't get sent twice.
  response[0] = '\0';
}


// CMD = 90
void Dino::reset() {
  // Clear the analog and digital pin listeners.
  for (int i = 0; i < PIN_COUNT; i++) digitalListeners[i] = false;
  for (int i = 0; i < PIN_COUNT; i++) digitalListenerValues[i] = 2;
  for (int i = 0; i < PIN_COUNT; i++) analogListeners[i] = false;

  // Disable the register listeners.
  for (int i = 0; i < SHIFT_LISTENER_COUNT; i++) shiftListeners[i].enabled = false;
  for (int i = 0; i < SPI_LISTENER_COUNT;   i++) spiListeners[i].enabled = false;

  heartRate = 4000; // Update digital listeners every ~4ms.
  analogDivider   = 4; // Update analog listeners every ~16ms.
  registerDivider = 2; // Update register listeners every ~8ms.
  fragmentIndex = 0;
  charIndex = 0;
  loopCount = 0;
  lastUpdate = micros();

  #if defined(__SAM3X8E__)
    sprintf(response, "ACK:%d,%d", A0, DAC0);
  #else
    sprintf(response, "ACK:%d", A0);
  #endif
}

// CMD = 95
// Set the register read divider. Powers of 2 up to 128 are valid.
void Dino::setRegisterDivider() {
  registerDivider = val;
}

// CMD = 96
// Set the analog read and write resolution.
void Dino::setAnalogResolution() {
  #if defined(__SAM3X8E__)
    analogReadResolution(val);
    analogWriteResolution(val);
  #endif
}

// CMD = 97
// Set the analog divider. Powers of 2 up to 128 are valid.
void Dino::setAnalogDivider() {
  analogDivider = val;
}

// CMD = 98
// Set the heart rate in milliseconds. Store it in microseconds.
void Dino::setHeartRate() {
  heartRate = atoi(auxMsg);
}
