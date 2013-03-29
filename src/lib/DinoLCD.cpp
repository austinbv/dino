#include "Arduino.h"
#include "DinoLCD.h"

LiquidCrystal lcd(12,11,5,4,3,2);

DinoLCD::DinoLCD(){
}

void DinoLCD::process(int cmd, char *message) {
   // Remove this test code and build your implementation here.
   
   // Dynamically set up the lcd.
   LiquidCrystal newLCD(8, 9, 4, 5, 6, 7);
   
   // Start it up and write the mssage.
   lcd = newLCD;
   lcd.begin(16,2);
   lcd.clear();
   lcd.print(message);
}

