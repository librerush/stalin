
stalin ?= ./stalin

OPTIONS = -d1 -d5 -d6 -On -t -c -db\
          -clone-size-limit 4 -split-even-if-no-widening\
          -do-not-align-strings\
          -treat-all-symbols-as-external\
          -do-not-index-constant-structure-types-by-expression\
          -do-not-index-allocated-structure-types-by-expression

architectures := AMD64

arch_c_files := $(addprefix stalin-arch-,$(addsuffix .c,$(architectures)))

# Stalin can be compiled with -freg-struct-return on most platforms. But gcc
# and egcs have a bug on Linux/Alpha that causes them to crash when given
# -freg-struct-return. ARCH_OPTS is set up apprpriately by ./build to handle
# this.

CC_OPTIMIZATION ?= -O3

stalin: stalin.c
	$(CC) -o stalin -I./include $(CC_OPTIMIZATION) -fomit-frame-pointer\
              -fno-strict-aliasing ${ARCH_OPTS}\
	      stalin.c -L./include -lm -lgc
	./post-make

stalin-architecture: stalin-architecture.c
	$(CC) -o stalin-architecture stalin-architecture.c

stalin.c: stalin.sc
	$(stalin) $(OPTIONS) stalin

stalin-arch-%.c: stalin.sc
	$(stalin) $(OPTIONS) -architecture $(patsubst stalin-arch-%.c,%,$@) \
	  $(patsubst %.sc,%,$<)
	mv -f stalin.c $@

all-precompiled-srcs: $(arch_c_files)

# Should ./include/stalin, ./stalin.c, and ./stalin only be deleted in a
# "distclean" target?
clean:
	rm -f ./include/gc.h
	rm -f ./include/gc_config_macros.h
	rm -f ./include/libgc.a
	rm -f ./include/libstalin.a
	rm -f ./include/libTmk.a
	rm -f ./include/stalin
	rm -f ./stalin.c
	rm -f ./stalin
	rm -f ./stalin-architecture
	cd benchmarks && ./make-clean
