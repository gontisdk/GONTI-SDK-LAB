#pragma once

#include <GONTI-ENGINE/GONTI.CORE/Source/Logging/GtLogger.h>
#include <GONTI-ENGINE/GONTI.CORE/Source/Math/GtMath.h>
#include "defines.h"

#define expect_should_be(expected, actual) \
    if (actual != expected) { \
        GTERROR("--> Excepted %lld, but got: %lld. File: %s:%d", expected, actual, __FILE__, __LINE__); \
        return false; \
    }

#define expect_should_not_be(expected, actual) \
    if (actual == expected) { \
        GTERROR("--> Expected %d != %d, but they are equal. File: %s:%d", expected, actual, __FILE__, __LINE__); \
        return false; \
    }

#define expect_float_to_be(expected, actual) \
    if (gontiMathAbs(expected - actual) > 0.001f) { \
        GTERROR("--> Expected %f, but got: %f. File: %s:%d", expected, actual, __FILE__, __LINE__); \
        return false; \
    }

#define expect_to_be_true(actual) \
    if (actual != true) { \
        GTERROR("--> Expected true, but got: false. File: %s:%d", __FILE__, __LINE__); \
        return false; \
    }

#define expect_to_be_false(actual) \
    if (actual != false) { \
        GTERROR("--> Expected false, but got: true. File: %s:%d", __FILE__, __LINE__); \
        return false; \
    }