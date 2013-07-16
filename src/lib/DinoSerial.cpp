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
    case 0:  setPins(message);            break;
    case 1:  begin(message);              break;
    case 2:  softSerial.print(message);   break;
    case 3:  softSerial.println(message); break;
    default:                              break;
  }
}

void DinoSerial::setPins(char *aux) {
  int *pins = parse(aux);
  SoftwareSerial newSerial(pins[0],pins[1]);
  softSerial = newSerial;
}

void DinoSerial::begin(char *aux) {
  int baud = atoi(aux);
  softSerial.begin(baud);
}