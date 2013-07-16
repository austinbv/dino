#ifndef DinoSerial_h
#define DinoSerial_h

#include "Arduino.h"
#include <SoftwareSerial.h>

class DinoSerial {
  public:
    DinoSerial();
    void process(int cmd, char *message);
  private:
    int *parse(char *aux);
    void setPins(char *aux);
    void begin(char *aux);
    int parseSize;
};

#endif
