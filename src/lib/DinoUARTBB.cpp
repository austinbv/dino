#include "Dino.h"
#ifdef DINO_UART_BB

void Dino::uartBBBegin(uint32_t baud) {
  pinMode(uartBBTx, OUTPUT);
  pinMode(uartBBRx, INPUT);
  
  uartBB = SoftwareSerial(uartBBRx, uartBBTx);
  uartBB.begin(baud);
}

void Dino::uartBBEnd() {
  uartBB.end();
  pinMode(uartBBTx, INPUT);
  pinMode(uartBBRx, INPUT);
}

void Dino::uartBBSetup() {
  // Config format is sames hardware UART, but held in auxMsg[4] instead of pin.
  uint8_t enable = auxMsg[4] & 0b01000000;
  uint8_t listen = auxMsg[4] & 0b10000000;

  if (enable > 0) {
    // Do nothing if TX (pin) and RX (val) are out of range.
    if ((pin < 0) || (pin > 250) || (val < 0) || (val > 250)) return;

    uartBBEnd();
    uartBBTx = pin;
    uartBBRx = val;
    uint32_t baud = *reinterpret_cast<uint32_t*>(auxMsg);

    uartBBBegin(baud);
    if (listen > 0) {
      uartBBListen = true;
      uartBB.listen();
    }
  } else {  
    uartBBEnd();
  }
}

void Dino::uartBBWrite() {
  uartBB.write(auxMsg, val);
}

void Dino::uartBBUpdateListener() {
  if (uartBBListen && uartBB.available()) {
    stream->print(uartBBRx);
    stream->print(':');

    char tempChar;
    while (uartBB.available()) {
      tempChar = uartBB.read();
      // Escape backslashes and newlines.
      if ((tempChar == '\\') || (tempChar == '\n')) stream->print('\\');
      stream->print(tempChar);
    }
    stream->print('\n');
  }
}
#endif
