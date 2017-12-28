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

void Dino::parse(char c) {
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

void Dino::append(char c) {
  messageFragments[fragmentIndex][charIndex++] = c;
}

void Dino::process() {
  cmd = atoi(cmdStr);
  pin = atoi(pinStr);
  val = atoi(valStr);
  response[0] = '\0';

  #ifdef debug
   Serial.print("Command - ");          Serial.println(cmdStr);
   Serial.print("Pin - ");              Serial.println(pinStr);
   Serial.print("Value - ");            Serial.println(valStr);
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

    case 90: reset               ();  break;
    case 96: setAnalogResolution ();  break;
    case 97: setAnalogDivider    ();  break;
    case 98: setHeartRate        ();  break;
    default:                          break;
  }

  // Write the response.
  if (response[0] != '\0') writeResponse();

  #ifdef debug
   Serial.print("Responded with - "); Serial.println(response);
   Serial.println();
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
    if (loopCount % analogDivider == 0) updateAnalogListeners();
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
// CMD = 00 // Pin Mode
void Dino::setMode() {
  if (val == 0) {
    removeListener();
    pinMode(pin, OUTPUT);
    #ifdef debug
      Serial.print("Set pin "); Serial.print(pin); Serial.print(" to "); Serial.println("OUTPUT mode");
    #endif
  }
  else {
    pinMode(pin, INPUT);
    #ifdef debug
      Serial.print("Set pin "); Serial.print(pin); Serial.print(" to "); Serial.println("INPTUT mode");
    #endif
  }
}

// CMD = 01 // Digital Write
void Dino::dWrite() {
  if (val == 0) {
    digitalWrite(pin, LOW);
    #ifdef debug
      Serial.print("Digital write "); Serial.print(LOW); Serial.print(" to pin "); Serial.println(pin);
    #endif
  }
  else {
    digitalWrite(pin, HIGH);
    #ifdef debug
      Serial.print("Digital write "); Serial.print(HIGH); Serial.print(" to pin "); Serial.println(pin);
    #endif
  }
}

// CMD = 02 // Digital Read
void Dino::dRead(int pin) {
  rval = digitalRead(pin);
  sprintf(response, "%02d:%02d", pin, rval);
}

// CMD = 03 // Analog (PWM) Write
void Dino::aWrite() {
  analogWrite(pin,val);
  #ifdef debug
    Serial.print("Analog write "); Serial.print(val); Serial.print(" to pin "); Serial.println(pin);
  #endif
}

// CMD = 04 // Analog Read
void Dino::aRead(int pin) {
  rval = analogRead(pin);
  sprintf(response, "%02d:%02d", pin, rval);
}

// CMD = 05
// Listen for a digital signal on any pin.
void Dino::addDigitalListener() {
  removeListener();
  digitalListeners[pin] = true;
  digitalListenerValues[pin] = 2;
  #ifdef debug
    Serial.print("Added digital listener on pin "); Serial.println(pin);
  #endif
}

// CMD = 06
// Listen for an analog signal on analog pins only.
void Dino::addAnalogListener() {
  removeListener();
  analogListeners[pin] = true;
  #ifdef debug
    Serial.print("Added analog listener on pin "); Serial.println(pin);
  #endif
}

// CMD = 07
// Remove analog and digital listeners from any pin.
void Dino::removeListener() {
  analogListeners[pin] = false;
  digitalListeners[pin] = false;
  #ifdef debug
    Serial.print("Removed listeners on pin "); Serial.println(pin);
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
  sprintf(response, "%02d:", latchPin);
  _writeCallback(response);

  for (int i = 1;  i <= len;  i++) {
    // Read a single byte from the register.
    byte reading = shiftIn(dataPin, clockPin, LSBFIRST);

    // If we're on the last byte, append \n. If not, append a comma, then write.
    if (i == len) {
      sprintf(response, "%03d\n", reading);
    } else {
      sprintf(response, "%03d,", reading);
    }
    _writeCallback(response);
  }

  // Leave latch pin high and clear response so main loop doesn't send anything.
  digitalWrite(latchPin, HIGH);
  response[0] = "\0";
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
  sprintf(response, "%02d:", selectPin);
  _writeCallback(response);

  for (int i = 1;  i <= len;  i++) {
    // Read a single byte from the register.
    byte reading = SPI.transfer(0x00);

    // If we're on the last byte, append \n. If not, append a comma, then write.
    if (i == len) {
      sprintf(response, "%03d\n", reading);
    } else {
      sprintf(response, "%03d,", reading);
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
  response[0] = "\0";
}


// CMD = 90
void Dino::reset() {
  heartRate = 4000; // Default heartRate is ~4ms.
  loopCount = 0;
  analogDivider = 4; // Update analog listeners every ~16ms.
  for (int i = 0; i < PIN_COUNT; i++) digitalListeners[i] = false;
  for (int i = 0; i < PIN_COUNT; i++) digitalListenerValues[i] = 2;
  for (int i = 0; i < PIN_COUNT; i++)  analogListeners[i] = false;
  lastUpdate = micros();
  fragmentIndex = 0;
  charIndex = 0;

  #if defined(__SAM3X8E__)
    sprintf(response, "ACK:%d,%d", A0, DAC0);
  #else
    sprintf(response, "ACK:%d", A0);
  #endif
}

// CMD = 97
// Set the analog read and write resolution.
void Dino::setAnalogResolution() {
  #if defined(__SAM3X8E__)
    analogReadResolution(val);
    analogWriteResolution(val);
    #ifdef debug
      Serial.print("Analog R/W resolution set to "); Serial.println(val);
    #endif
  #endif
}

// CMD = 97
// Set the analog divider. Powers of 2 up to 128 are valid.
void Dino::setAnalogDivider() {
  analogDivider = val;
  #ifdef debug
    Serial.print("Analog divider set to "); Serial.println(analogDivider);
  #endif
}

// CMD = 98
// Set the heart rate in milliseconds. Store it in microseconds.
void Dino::setHeartRate() {
  heartRate = atoi(auxMsg);
  #ifdef debug
    Serial.print("Heart rate set to "); Serial.print(heartRate); Serial.println(" microseconds");
  #endif
}
