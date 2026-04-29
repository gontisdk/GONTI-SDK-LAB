#include "test_manager.h"

#include <GONTI-ENGINE/GONTI.CORE/Source/Containers/DynamicArray/GtDArray.h>
#include <GONTI-ENGINE/GONTI.CORE/Source/Logging/GtLogger.h>
#include <GONTI-ENGINE/GONTI.CORE/Source/CStringTools/GtCStrTools.h>
#include <GONTI-ENGINE/GONTI.RUNTIME/Source/Clock/GtClock.h>
#include <GONTI-ENGINE/GONTI.CORE/Source/Memory/GtMemory.h>

typedef struct TestsEntry {
    PFN_Test func;
    char* desc;
} TestsEntry;
static TestsEntry* tests;

void testManagerInit() {
    tests = gontiDarrayCreate(TestsEntry);
}
void testManagerRegisterTest(bool (*PFN_Test)(), char* desc) {
    TestsEntry entry;
    entry.func = PFN_Test;
    entry.desc = desc;
    gontiDarrayPush(tests, entry);
}
void testManagerRunTests() {
    unsigned int passed = 0;
    unsigned int failed = 0;
    unsigned int skipped = 0;
    unsigned int count = gontiDarrayLength(tests);
    GtClock totalTime;

    gontiClockStart(&totalTime);
    for (unsigned int i = 0; i < count; i++) {
        GtClock testTime;
        gontiClockStart(&testTime);
        bool result = tests[i].func();
        gontiClockUpdate(&testTime);

        if (result == true) passed++;
        else if (result == BYPASS) {
            GTWARN("[SKIPPED]: %s", tests[i].desc);
            skipped++;
        } else {
            GTERROR("[FAILED]: %s", tests[i].desc);
            failed++;
        }

        char status[20];
        gontiStringFormat(status, failed ? "*** %d FAILED ***" : "SUCCESS", failed);
        gontiClockUpdate(&totalTime);
        GTINFO("Executed %d of %d (skipped %d) %s (%.6f sec / %.6f sec total)", i + 1, count, skipped, status, testTime.elapsed, totalTime.elapsed);
    }

    gontiClockStop(&totalTime);
    gontiDarrayDestroy(tests);
    GTINFO("Results: %d passed, %d failed, %d skipped", passed, failed, skipped);
}