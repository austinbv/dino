#include "Arduino.h"
#include "DinoSerial.h"

SoftwareSerial softSerial(10,11);

DinoSerial::DinoSerial(){
}

int *DinoSerial::parse(char *aux){
  int *values = new int[11];
  char *str;
  int index = 0;
  while ((str = strsep(&aux, ",")) != NULL) {
    values[index] = atoi(str);
    index++;
  }
  parseSize = index;
  return values;
}

void DinoSerial::process(int cmd, char *message) {
  switch(cmd) {
    case 0:  setPins(message);           break;
    case 1:  beginSerial(message);       break;
    default:                             break;
  }
}

void DinoSerial::setPins(char *aux) {
  int *pins = parse(aux);
  SoftwareSerial newSerial(pins[0],pins[1]);
  softSerial = newSerial;

}

void DinoSerial::beginSerial(char *aux) {
  int *values = parse(aux);
  // set baud rate
  softSerial.begin(values[0]);
}
