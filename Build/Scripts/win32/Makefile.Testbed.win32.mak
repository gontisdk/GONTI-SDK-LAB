BUILD := Build/bin
BUILD_LIB := Lib/GONTI-SDK
OBJ := Build/obj
SRC := Source
INC_DIR := Include/GONTI-SDK

ASSEMBLY := Testbed
EXTENSION := .exe
COMPILER_FLAGS := -g -Wvarargs -Wall -Werror
INCLUDE_FLAGS := -I"$(VULKAN_SDK)/include" -IInclude -IInclude/GONTI-SDK -I$(INC_DIR)/GONTI-CORE/GONTI.CORE/Source -I$(INC_DIR)/GONTI-CORE/GONTI.CONTAINERS/Source -I$(INC_DIR)/GONTI-CORE/GONTI.MATH/Source -I$(INC_DIR)/GONTI-CORE/GONTI.STRING/Source -I$(INC_DIR)/GONTI-CORE/GONTI.FILESYSTEM/Source -I$(INC_DIR)/GONTI-RENDER/GONTI.RENDER/Source -I$(INC_DIR)/GONTI-RENDER/GONTI.RENDER.COMMON/Source -I$(INC_DIR)/GONTI-RENDER/GONTI-RENDER-VK/GONTI.RENDER.COMMON.VK/Source -I$(INC_DIR)/GONTI-RENDER/GONTI-RENDER-VK/GONTI.RENDER.CORE.VK/Source -I$(INC_DIR)/GONTI-RENDER/GONTI-RENDER-VK/GONTI.RENDER.DEBUGGER.VK/Source -I$(INC_DIR)/GONTI-RENDER/GONTI-RENDER-VK/GONTI.RENDER.SHADERS.VK/Source -I$(INC_DIR)/GONTI-RENDER/GONTI-RENDER-VK/GONTI.RENDER.UTILITIES.VK/Source -I$(INC_DIR)/GONTI-RENDER/GONTI-RENDER-VK/GONTI.RENDER.VK/Source -I$(INC_DIR)/GONTI-RUNTIME/GONTI.RUNTIME/Source
LINKER_FLAGS := -luser32 -lvulkan-1 -L"$(VULKAN_SDK)/lib" -L$(BUILD_LIB) -lGONTI.CORE -lGONTI.MATH -lGONTI.CONTAINERS -lGONTI.STRING -lGONTI.FILESYSTEM -lGONTI.RENDER.UTILITIES.VK -lGONTI.RENDER.DEBUGGER.VK -lGONTI.RENDER.CORE.VK -lGONTI.RENDER.SHADERS.VK -lGONTI.RENDER.VK -lGONTI.RENDER -lGONTI.RUNTIME
DEFINES := -D_DEBUG -DKIMPORT

FIX_PATH = $(subst /,\,$1)
BUILD_DIR := $(BUILD)/$(ASSEMBLY)
OBJ_DIR := $(OBJ)/$(ASSEMBLY)

rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

SRC_PREFIX := $(SRC)/$(ASSEMBLY)
SRC_FILES := $(call rwildcard,$(SRC_PREFIX)/,*.c) 
OBJ_FILES := $(SRC_FILES:%.c=$(OBJ_DIR)/%.c.o)

all: scaffold compile link

.PHONY: scaffold
scaffold:
	@echo --- Scaffolding folder structure ---
	@if not exist $(call FIX_PATH,$(BUILD_DIR)) mkdir $(call FIX_PATH,$(BUILD_DIR))
	@if not exist $(call FIX_PATH,$(OBJ_DIR)) mkdir $(call FIX_PATH,$(OBJ_DIR))

.PHONY: compile
compile:
	@echo --- Compiling $(ASSEMBLY) ---

.PHONY: link
link: $(OBJ_FILES)
	@echo --- Linking $(ASSEMBLY) ---
	@clang $(OBJ_FILES) -o $(BUILD_DIR)/$(ASSEMBLY)$(EXTENSION) $(LINKER_FLAGS)

.PHONY: clean
clean:
	@echo --- Cleaning $(ASSEMBLY) ---
	@if exist $(call FIX_PATH,$(BUILD_DIR)/$(ASSEMBLY)$(EXTENSION)) del /Q $(call FIX_PATH,$(BUILD_DIR)/$(ASSEMBLY)$(EXTENSION))
	@if exist $(call FIX_PATH,$(OBJ_DIR)) rmdir /S /Q $(call FIX_PATH,$(OBJ_DIR))

$(OBJ_DIR)/%.c.o: %.c
	@echo   Kompilacja: $<...
	@if not exist $(call FIX_PATH,$(dir $@)) mkdir $(call FIX_PATH,$(dir $@))
	@clang $< $(COMPILER_FLAGS) -c -o $@ $(DEFINES) $(INCLUDE_FLAGS)