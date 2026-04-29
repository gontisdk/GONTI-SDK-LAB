#include "linear.allocator.tests.h"

#include <GONTI-ENGINE/GONTI.CORE/Source/LinearAllocator/GtLinearAlloc.h>
#include "../test_manager.h"
#include "../defines.h"
#include "../expect.h"

bool linearAllocatorShouldCreateAndDestroy() {
    GtLinearAlloc alloc;
    gontiLinearAllocatorCreate(sizeof(GtU64), 0, &alloc);

    expect_should_not_be(0, alloc.memory);
    expect_should_be(sizeof(GtU64), alloc.totalSize);
    expect_should_be(0, alloc.allocated);

    gontiLinearAllocatorDestroy(&alloc);
    expect_should_be(0, alloc.memory);
    expect_should_be(0, alloc.totalSize);
    expect_should_be(0, alloc.allocated);

    return true;
}

bool linearAllocatorSingleAllocationAllSpace() {
    GtLinearAlloc alloc;
    gontiLinearAllocatorCreate(sizeof(GtU64), 0, &alloc);

    void* block = gontiLinearAllocatorAllocate(&alloc, sizeof(GtU64));
    expect_should_not_be(0, block);
    expect_should_be(sizeof(GtU64), alloc.allocated);

    gontiLinearAllocatorDestroy(&alloc);
    return true;
}

bool linearAllocatorMultiAllocationAllSpace() {
    GtU64 maxAllocs = 1024;
    GtLinearAlloc alloc;
    gontiLinearAllocatorCreate(sizeof(GtU64) * maxAllocs, 0, &alloc);

    void* block;
    for (GtU64 i = 0; i < maxAllocs; i++) {
        block = gontiLinearAllocatorAllocate(&alloc, sizeof(GtU64));
        expect_should_not_be(0, block);
        expect_should_be(sizeof(GtU64) * (i + 1), alloc.allocated);
    }

    gontiLinearAllocatorDestroy(&alloc);
    return true;
}

bool linearAllocatorMultiAllocationOverAllocate() {
    GtU64 maxAllocs = 3;
    GtLinearAlloc alloc;
    gontiLinearAllocatorCreate(sizeof(GtU64) * maxAllocs, 0, &alloc);

    void* block;
    for (GtU64 i = 0; i < maxAllocs; i++) {
        block = gontiLinearAllocatorAllocate(&alloc, sizeof(GtU64));
        expect_should_not_be(0, block);
        expect_should_be(sizeof(GtU64) * (i + 1), alloc.allocated);
    }

    block = gontiLinearAllocatorAllocate(&alloc, sizeof(GtU64));
    expect_should_be(0, block);
    expect_should_be(sizeof(GtU64) * (maxAllocs), alloc.allocated);

    gontiLinearAllocatorDestroy(&alloc);
    return true;
}

bool lineraAllocatorMultiAllocationAllSpaceThenFree() {
    GtU64 maxAllocs = 1024;
    GtLinearAlloc alloc;
    gontiLinearAllocatorCreate(sizeof(GtU64) * maxAllocs, 0, &alloc);

    void* block;
    for (GtU64 i = 0; i < maxAllocs; i++) {
        block = gontiLinearAllocatorAllocate(&alloc, sizeof(GtU64));
        expect_should_not_be(0, block);
        expect_should_be(sizeof(GtU64) * (i + 1), alloc.allocated);
    }

    gontiLinearAllocatorFreeAll(&alloc);
    expect_should_be(0, alloc.allocated);

    gontiLinearAllocatorDestroy(&alloc);
    return true;
}

void linearAllocatorRegisterTests() {
    testManagerRegisterTest(linearAllocatorShouldCreateAndDestroy, "Linear allocator should create and destroy");
    testManagerRegisterTest(linearAllocatorSingleAllocationAllSpace, "Linear allocator single allocation all space");
    testManagerRegisterTest(linearAllocatorMultiAllocationAllSpace, "Linear allocator multi allocation all space");
    testManagerRegisterTest(linearAllocatorMultiAllocationOverAllocate, "Linear allocator multi allocation over allocate");
    testManagerRegisterTest(lineraAllocatorMultiAllocationAllSpaceThenFree, "Linera allocator multi allocation all space then free");
}