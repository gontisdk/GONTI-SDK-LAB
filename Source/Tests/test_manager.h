#pragma once 

#include "defines.h"
#define BYPASS 2

typedef bool (*PFN_Test)();

void testManagerInit();
void testManagerRegisterTest(PFN_Test, char* desc);
void testManagerRunTests();