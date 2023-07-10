# Installation directory for clam
CLAM_INSTALL=/clam/build/run
# Installation directory for llvm
LLVM_CONFIG=/usr/bin/llvm-config-14
# Installation directory for Boost
#BOOST_ROOT=/opt/homebrew
# Installation directory for GMP 
#GMP_DIR=/opt/homebrew
# Installation directory for MPFR (needed only by Apron and Elina)
#MPFR_DIR=/opt/homebrew

# whether clam was compiled with flag -DCRAB_USE_ELINA=ON or
# -DCRAB_USE_APRON=ON
ELINA_OR_APRON ?= APRON
# whether clam was compiled with flag -DCRAB_USE_LDD=ON
LDD_BOXES = true

TOOL=AllocSizeAnalyzer


## Include this file if Clam was built without external libraries
## (ldd, apron, elina)
# include Makefile.config

## Include this file if Clam was built with external libraries (ldd,
## apron, elina).
include Makefile.external.config




