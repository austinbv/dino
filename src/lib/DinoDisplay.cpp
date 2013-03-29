/*
  DinoDisplay.h - LCD Display handling for Dino.
  Created by Herman Moreno, March 24, 2013.
  Released into the public domain.
*/

#include "Arduino.h"
#include "DinoDisplay.h"

DinoDisplay::DinoDisplay(){

}

int *DinoDisplay::parse(char *aux){
  int *values = new int[11];
  char *str;
  int index = 0;
  while ((str = strsep(&aux, ",")) != NULL) {
    values[index] = atoi(str);
    index++;
  }
  return values;
}

void DinoDisplay::performOperation(LiquidCrystal &display, int cmd, char *aux) {
  switch(cmd) {
    case 1:  beginLCD(display, aux);         break;
    case 2:  display.clear();                break;
    case 3:  display.home();                 break;
    case 4:  setLCDCursor(display, aux);     break;
    case 5:  display.print(aux);             break;
    case 6:  display.cursor();               break;
    case 7:  display.noCursor();             break;
    case 8:  display.blink();                break;
    case 9:  display.noBlink();              break;
    case 10: display.display();              break;
    case 11: display.noDisplay();            break;
    case 12: display.scrollDisplayLeft();    break;
    case 13: display.scrollDisplayRight();   break;
    case 14: display.autoscroll();           break;
    case 15: display.noAutoscroll();         break;
    case 16: display.leftToRight();          break;
    case 17: display.rightToLeft();          break;
    default:                                 break;
  }
}

void DinoDisplay::beginLCD(LiquidCrystal &display, char *aux) {
  int *values = parse(aux);
  display.begin(values[0], values[1]);
}

void DinoDisplay::setLCDCursor(LiquidCrystal &display, char *aux) {
  int *values = parse(aux);
  display.setCursor(values[0], values[1]);
}


