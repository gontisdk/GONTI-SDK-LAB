BUILD := Build/bin
BUILD_LIB := Lib/GONTI/GONTI-ENGINE
OBJ := Build/obj
SRC := Source
INC_DIR := Include/GONTI/GONTI-ENGINE

ASSEMBLY := Tests
EXTENSION := 
COMPILER_FLAGS := -g -Wvarargs -Wall -Werror -fPIC
INCLUDE_FLAGS := -I$(VULKAN_SDK)/include -IInclude -IInclude/GONTI -I$(INC_DIR)/GONTI.CORE/Source -I$(INC_DIR)/GONTI.RENDER.VK/Source -I$(INC_DIR)/GONTI.RENDER/Source -I$(INC_DIR)/GONTI.RUNTIME/Source
LINKER_FLAGS := -L$(VULKAN_SDK)/lib -lvulkan -lm -lpthread -lX11 -lxcb -lX11-xcb -L$(BUILD_LIB) -l:GONTI.CORE.so -l:GONTI.RENDER.VK.so -l:GONTI.RENDER.so -l:GONTI.RUNTIME.so -Wl,-rpath,'\$$ORIGIN:$(BUILD_LIB)'
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