#include "events.h"

#include <GONTI/GONTI-ENGINE/GONTI.RUNTIME/Source/Inputs/GtInputs.h>
#include <GONTI/GONTI-ENGINE/GONTI.CORE/Source/Logging/GtLogger.h>
#include <GONTI/GONTI-ENGINE/GONTI.RUNTIME/Source/Application/GtApp.h>

GtB8 applicationOnEvent(GtU16 code, void* sender, void* listenerInst, GtEventContext context) {
    switch (code) {
        case GT_EVENT_CODE_APPLICATION_QUIT: {
            GTINFO("EVENT_CODE_APPLICATION_QUIT recived, shutting down.\n");
            gontiApplicationShutdown();

            return GtTrue;
        }
    }

    return GtFalse;
}