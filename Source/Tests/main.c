#include "test_manager.h"
#include <GONTI-CORE/GONTI.CORE/Source/Logging/GtLogger.h>
#include <GONTI-CORE/GONTI.CORE/Source/Memory/GtMemory.h>


#include "unit.tests/linear.allocator.tests.h"

int main() {
    testManagerInit();

    // TODO: add test registration here

    linearAllocatorRegisterTests();

    // end test registration segment

    GTDEBUG("Starting tests...");
    testManagerRunTests();
    return 0;
}