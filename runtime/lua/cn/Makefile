CC ?= cc
AR ?= ar
CFLAGS ?= -O2

# Paths
OPAM_SWITCH_PREFIX ?= $(shell opam var prefix)
CN_RUNTIME := $(OPAM_SWITCH_PREFIX)/lib/cn/runtime

INCLUDES := \
	-I$(CN_RUNTIME)/lua/cn \
	-I$(CN_RUNTIME)/lua/src \
	-I$(CN_RUNTIME)/include

OBJS := lua_wrappers.o
LIB  := lua_wrappers.a

LUA_CN_PATH_VAL := $(CN_RUNTIME)/lua/cn/?.lua
CFLAGS += -DCN_LUA_PATH='"$(LUA_CN_PATH_VAL)"'

all: $(LIB)

$(LIB): $(OBJS)
	$(AR) rcs $@ $^

lua_wrappers.o: lua_wrappers.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJS) $(LIB)
