//
// After refactoring there's a strange gcc bug referencing the first
// instance of sprintf in Dino.cpp, only when compiling for the 328p/Uno/Nano/Mini.
//
// It only occurs when trying to exlude all the new .cpp files by commenting
// out the #define lines at the top of Dino.h. At least one needed to be left in
// to avoid the error.
//
// Narrowed it down to the following:
// Must declare a function in a separate .cpp file.
// That function must mutate some instance variable in Dino.
// That function must be one of the switch options in the Dino::process case statement.
//
// This file is a stub to meet those requirements.
// Leaving this in until sprintf usage is replaced or bug is fixed.
//
// Similar issues:
// https://github.com/arduino/Arduino/issues/3972
// https://github.com/CongducPham/LowCostLoRaGw/issues/28
//
#include "Dino.h"
void Dino::bugWorkaround() {
  rval = 0;
}
