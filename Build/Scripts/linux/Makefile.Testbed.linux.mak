BUILD := Build/bin
LIB := Lib/GONTI/GONTI-ENGINE
RELATIVE_LIB_PATH := ../../../$(LIB)
OBJ := Build/obj
SRC := Source
INC_DIR := Include/GONTI/GONTI-ENGINE

ASSEMBLY := Testbed
EXTENSION := 
COMPILER_FLAGS := -g -Wvarargs -Wall -Werror -fPIC
INCLUDE_FLAGS := -I$(VULKAN_SDK)/include -IInclude -IInclude/GONTI -I$(INC_DIR)/GONTI.CORE/Source -I$(INC_DIR)/GONTI.RENDER.VK/Source -I$(INC_DIR)/GONTI.RENDER/Source -I$(INC_DIR)/GONTI.RUNTIME/Source
LINKER_FLAGS := -L$(VULKAN_SDK)/lib -lvulkan -lm -lpthread -lX11 -lxcb -lX11-xcb -L$(LIB) -l:GONTI.CORE.so -l:GONTI.RENDER.VK.so -l:GONTI.RENDER.so -l:GONTI.RUNTIME.so -Wl,-rpath,'\$$ORIGIN:$$ORIGIN/$(RELATIVE_LIB_PATH)'
DEFINES := -D_DEBUG -DKIMPORT

BUILD_DIR := $(BUILD)/$(ASSEMBLY)
OBJ_DIR := $(OBJ)/$(ASSEMBLY)

SRC_PREFIX := $(SRC)/$(ASSEMBLY)
SRC_FILES := $(shell find $(SRC_PREFIX) -name "*.c")
DIRECTORIES := $(shell find $(SRC_PREFIX) -type d)
OBJ_FILES := $(SRC_FILES:%=$(OBJ_DIR)/%.o)

all: scaffold compile link

.PHONY: scaffold
scaffold:
	@echo "--- Scaffolding folder structure (Linux) ---"
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(addprefix $(OBJ_DIR)/,$(DIRECTORIES))
	@echo "Done."

.PHONY: compile
compile:
	@echo "--- Compiling $(ASSEMBLY) ---"

.PHONY: link
link: $(OBJ_FILES)
	@echo "--- Linking $(ASSEMBLY) ---"
	@clang $(OBJ_FILES) -o $(BUILD_DIR)/$(ASSEMBLY)$(EXTENSION) $(LINKER_FLAGS)

.PHONY: clean
clean:
	@echo "--- Cleaning $(ASSEMBLY) ---"
	@rm -rf $(BUILD_DIR)
	@rm -rf $(OBJ_DIR)

$(OBJ_DIR)/%.o: %
	@echo "  $<..."
	@mkdir -p $(dir $@)
	@clang $< $(COMPILER_FLAGS) -c -o $@ $(DEFINES) $(INCLUDE_FLAGS)