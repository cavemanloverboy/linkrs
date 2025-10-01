CC      := gcc
AR      := ar
CFLAGS  := -Wall -O2
OBJCOPY := objcopy
TARGET  := main

# base build dirs
BUILDDIR := build
OBJDIR   := $(BUILDDIR)/obj
LIBDIR   := $(BUILDDIR)/lib
BINDIR   := $(BUILDDIR)/bin
SRCDIR   := c

# rust staticlibs
RUST_ADD := target/release/libkv_add.a
RUST_SUB := target/release/libkv_sub.a

# sources
SRC       := $(SRCDIR)/main.c

# executables
DIRECT_BIN := $(BINDIR)/$(TARGET)_direct
SLIM_BIN   := $(BINDIR)/$(TARGET)_slim

# default
all:
	echo "use make direct (fails) or make slim (succeeds)"

# -------------------------------------------------------
# direct: this fails because rustc is kind of ass
# -------------------------------------------------------
direct: $(DIRECT_BIN)

$(DIRECT_BIN): $(SRC) $(RUST_ADD) $(RUST_SUB) | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $(SRC) $(RUST_ADD) $(RUST_SUB)

# -------------------------------------------------------
# slim (auto-detect kv_* exports, strip everything else)
# -------------------------------------------------------
slim: $(SLIM_BIN)

$(SLIM_BIN): $(SRC) $(LIBDIR)/libkv_add_slim.a $(LIBDIR)/libkv_sub_slim.a | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $(SRC) $(LIBDIR)/libkv_add_slim.a $(LIBDIR)/libkv_sub_slim.a

$(LIBDIR)/libkv_add_slim.a: $(RUST_ADD) | $(LIBDIR) $(OBJDIR)
	rm -rf $(OBJDIR)/kv_add_objs && mkdir -p $(OBJDIR)/kv_add_objs
	cd $(OBJDIR)/kv_add_objs && $(AR) x $(CURDIR)/$(RUST_ADD)
	# detect kv_* exports
	nm -g --defined-only $(RUST_ADD) | awk '/ kv_/ {print $$3}' > $(OBJDIR)/kv_add.keep
	for o in $(OBJDIR)/kv_add_objs/*.o; do \
	  if nm $$o | grep -q " kv_"; then \
	    $(OBJCOPY) --keep-global-symbols=$(OBJDIR)/kv_add.keep $$o $$o.keep; \
	  fi; \
	done
	$(AR) rcs $@ $(OBJDIR)/kv_add_objs/*.keep

$(LIBDIR)/libkv_sub_slim.a: $(RUST_SUB) | $(LIBDIR) $(OBJDIR)
	rm -rf $(OBJDIR)/kv_sub_objs && mkdir -p $(OBJDIR)/kv_sub_objs
	cd $(OBJDIR)/kv_sub_objs && $(AR) x $(CURDIR)/$(RUST_SUB)
	# detect kv_* exports
	nm -g --defined-only $(RUST_SUB) | awk '/ kv_/ {print $$3}' > $(OBJDIR)/kv_sub.keep
	for o in $(OBJDIR)/kv_sub_objs/*.o; do \
	  if nm $$o | grep -q " kv_"; then \
	    $(OBJCOPY) --keep-global-symbols=$(OBJDIR)/kv_sub.keep $$o $$o.keep; \
	  fi; \
	done
	$(AR) rcs $@ $(OBJDIR)/kv_sub_objs/*.keep

# -------------------------------------------------------
# rust build
# -------------------------------------------------------
$(RUST_ADD) $(RUST_SUB):
	cargo build --release

# -------------------------------------------------------
# ensure dirs exist
# -------------------------------------------------------
$(OBJDIR) $(LIBDIR) $(BINDIR):
	mkdir -p $@

# -------------------------------------------------------
# clean
# -------------------------------------------------------
clean:
	rm -rf $(BUILDDIR)
	cargo clean
