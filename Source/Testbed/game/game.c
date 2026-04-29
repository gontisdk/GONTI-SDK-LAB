#include "game.h"
#include "../events/events.h"

#include <GONTI-ENGINE/GONTI.CORE/Source/Memory/GtMemory.h>
#include <GONTI-ENGINE/GONTI.CORE/Source/Logging/GtLogger.h>
#include <GONTI-ENGINE/GONTI.RUNTIME/Source/Inputs/GtInputs.h>
#include <GONTI-ENGINE/GONTI.RUNTIME/Source/Application/GtApp.h>

static GtB8 isPaused = GtFalse;

// SAMPLE USER GAME INIT FUNC
GtB8 gameInitialize(GtEntry* gameInst) {
    gontiEventRegister(GT_EVENT_CODE_APPLICATION_QUIT, 0, applicationOnEvent);

    return GtTrue;
}
// SAMPLE USER UPDATE FUNC
GtB8 gameUpdate(GtEntry* gameInst, GtF32 deltaTime) {
    if (gontiInputIsKeyDown(GT_KEY_ESCAPE) && gontiInputWasKeyUp(GT_KEY_ESCAPE)) {
        if (isPaused) gontiApplicationResume();
        else gontiApplicationPause();

        isPaused = !isPaused;
    } 

    static GtU64 allocCount = 0;
    GtU64 prevAllocCount = allocCount;
    allocCount = gontiMemoryGetAllocCount();
    if (gontiInputIsKeyDown(GT_KEY_M) && gontiInputWasKeyUp(GT_KEY_M)) {
        GTTRACE("Allocations: %llu (%llu this frame)", allocCount, allocCount - prevAllocCount);
    }

    return GtTrue;
}
GtB8 gameFixedUpdate(GtEntry* gameInst, GtF32 fixedDelta) {
    return GtTrue;
}
// SAMPLE USER RENDER FUNC
GtB8 gameRender(GtEntry* gameInst, GtF32 deltaTime, GtF32 alpha) {
    return GtTrue;
}

// SAMPLE USER ONRESIZE FUNC
void gameOnResize(GtEntry* gameInst, GtU32 width, GtU32 height) {

}

// SAMPLE USER SHUTDOWN FUNC
void gameShutdown(GtEntry* gameInst) {
    gontiEventUnregister(GT_EVENT_CODE_APPLICATION_QUIT, 0, applicationOnEvent);
}