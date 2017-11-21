# Makefile for the PowerPC architecture using GLISS V2

# configuration
ARCH=riscv
GLISS_PREFIX	=../gliss2
WITH_DISASM		= 1	# comment it to prevent disassembler building
WITH_SIM		= 1	# comment it to prevent simulator building
#WITH_DYNLIB	= 1	# uncomment it to build dynamicaly linkable library
#WITH_OSEMUL	= 1 # uncomment it to use OS emulation of system calls (only with Unix)
CPU_ENDIAN		= little	# change to big if required
MEM_ENDIAN		= little	# change to big if required

MEMORY=vfast_mem			# select here the memory module
LOADER=old_elf				# select here the loaded module
DECODER=decode32_dtrace		# modify this with CAUTION

# goals definition
GOALS		=
SUBDIRS		=	src
CLEAN		=	$(ARCH).nml $(ARCH).irg include
DISTCLEAN	=	include src

ifdef WITH_DISASM
GOALS		+=	$(ARCH)-disasm
SUBDIRS		+= 	disasm
DISTCLEAN	+= 	disasm
endif

ifdef WITH_SIM
GOALS		+=	$(ARCH)-sim
SUBDIRS		+=	sim
DISTCLEAN	+=	sim
endif

ifdef WITH_DYNLIB
REC_FLAGS = WITH_DYNLIB=1
endif

ifdef WITH_OSEMUL
SYSCALL=syscall-linux
ENV=linux-env
else
SYSCALL=syscall-embedded
ENV=void_env
endif

GFLAGS = \
	-switch \
	-m mem:$(MEMORY) \
	-m loader:$(LOADER) \
	-m syscall:$(SYSCALL) \
	-m sysparm:sysparm-reg32 \
	-m code:code \
	-m exception:extern/exception \
	-m emu:extern/emu \
	-m env:$(ENV) \
	-a disasm.c

#	-m fpi:extern/fpi \

NMP_MAIN = $(ARCH).nmp

NMP =\
	$(NMP_MAIN) \
	nmp/alu.nmp \
	nmp/config.nmp \
	nmp/control.nmp \
	nmp/macros.nmp \
	nmp/mem.nmp \
	nmp/special.nmp \
	nmp/state.nmp


# targets
all: lib $(GOALS)

nmp/config.nmp:
ifeq ($(MEM_ENDIAN),big)
	echo "let BigEndianMem = 1" > $@
else
	echo "let BigEndianMem = 0" > $@
endif
ifeq ($(CPU_ENDIAN),big)
	echo "let BigEndianCPU = 1" >> $@
else
	echo "let BigEndianCPU = 0" >> $@
endif

$(ARCH).nml: $(NMP)
	$(GLISS_PREFIX)/gep/gliss-nmp2nml.pl $< $@

$(ARCH).irg: $(ARCH).nml
	$(GLISS_PREFIX)/irg/mkirg $< $@

src include: $(ARCH).irg
	$(GLISS_PREFIX)/gep/gep $(GFLAGS) $< -S

check: $(ARCH).irg
	$(GLISS_PREFIX)/gep/gep $(GFLAGS) $< -S -c

lib: src include/$(ARCH)/config.h src/disasm.c
	(cd src; make -j $(REC_FLAGS))

$(ARCH)-disasm:
	cd disasm; make -j3

$(ARCH)-sim:
	cd sim; make -j3

src/disasm.c: $(ARCH).irg
	$(GLISS_PREFIX)/gep/gliss-disasm -switch $< -o $@ -c

distclean: clean
	-for d in $(SUBDIRS); do test -d $$d && (cd $$d; make distclean || exit 0); done
	-rm -rf $(DISTCLEAN)

clean: only-clean
	-for d in $(SUBDIRS); do test -d $$d && (cd $$d; make clean || exit 0); done

only-clean:
	-rm -rf $(CLEAN)

HOST_ENDIAN = $(shell python -c "import sys; print(sys.byteorder)")

include/$(ARCH)/config.h: config.tpl
	test -d include/$(ARCH) || mkdir include/$(ARCH)
	cp config.tpl $@
	echo "#define TARGET_ENDIANNESS $(CPU_ENDIAN)" >> $@
	echo "#define HOST_ENDIANNESS $(HOST_ENDIAN)" >> $@


