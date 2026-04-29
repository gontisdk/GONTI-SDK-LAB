#include <stdio.h>
#include "events/events.h"
#include "game/game.h"
#include "core/entry.h"
#include "defines/defines.h"

#include <GONTI-ENGINE/GONTI.RUNTIME/Source/Application/Vulkan/GtVkApp.h>
#include <GONTI-ENGINE/GONTI.RUNTIME/Source/Application/GtApp.h>
#include <GONTI-ENGINE/GONTI.CORE/Source/Platform/GtPlatform.h>
#include <GONTI-ENGINE/GONTI.CORE/Source/Math/Algebra/Vectors/Vector3/GtVector3.h>


int main(void) {
       GameState state;

       GTINFO("Memory system initialized.");
       gontiMemoryInitialize(&state.memorySystemMemoryRequirement, 0);
       state.memorySystemState = gontiPlatformAllocate(state.memorySystemMemoryRequirement, GtFalse);
       gontiMemoryInitialize(&state.memorySystemMemoryRequirement, state.memorySystemState);

       GtEntry entry;
       entry.windowConfig.windowName = "GONTI GAME ENGINE TESTBED";
       entry.windowConfig.className = "0xGONTIENGINE";
       entry.windowConfig.startPosX = 100;
       entry.windowConfig.startPosY = 100;
       entry.windowConfig.startWidth = 800;
       entry.windowConfig.startHeight = 600;
       entry.GtUpdateFN = gameUpdate;
       entry.GtRenderFN = gameRender;
       entry.GtFixedUpdateFN = gameFixedUpdate;
       entry.GtInitializeFN = gameInitialize;
       entry.GtOnResizeFN = gameOnResize;
       entry.GtShutdownFN = gameShutdown;
       entry.GtState = gt_allocate(sizeof(GameState), GT_MEM_TAG_ENTRY);
       entry.disableSystemEvents = GtFalse;
       entry.GtAppState = 0;
       
       gontiApplicationCreate(&entry);
       gontiApplicationRun(30, true);

       GTINFO("Shutting down memory system...");
       gontiMemoryShutdown(state.memorySystemState);
       gontiPlatformFree(state.memorySystemState, GtFalse);

       return 0;
}