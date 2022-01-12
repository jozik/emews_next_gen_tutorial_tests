
# SETTINGS.MK

# The settings originate in settings.sh (see the README)
# Populated with compiler settings at configure-time
# Included by Makefile

R_INCLUDE = /usr/share/R/include
R_LIB = /usr/lib
R_INSIDE = /home/nick/R/x86_64-pc-linux-gnu-library/3.6/RInside
RCPP = /home/nick/R/x86_64-pc-linux-gnu-library/3.6/Rcpp

CPPFLAGS := -g -O0 -fPIC -std=c++0x
CPPFLAGS := $(CPPFLAGS) -I/home/nick/anaconda3/include
CPPFLAGS := $(CPPFLAGS) -I$(R_INCLUDE)
CPPFLAGS := $(CPPFLAGS) -I$(RCPP)/include
CPPFLAGS := $(CPPFLAGS) -I$(R_INSIDE)/include
CXXFLAGS = $(CPPFLAGS)

LDFLAGS = -L$(R_INSIDE)/lib -lRInside
LDFLAGS := $(LDFLAGS) -L$(R_LIB) -lR
LDFLAGS := $(LDFLAGS) -L/home/nick/anaconda3/lib -ltcl8.6
LDFLAGS := $(LDFLAGS) -Wl,-rpath -Wl,/home/nick/anaconda3/lib
LDFLAGS := $(LDFLAGS) -Wl,-rpath -Wl,$(R_LIB)
LDFLAGS := $(LDFLAGS) -Wl,-rpath -Wl,$(R_INSIDE)/lib

TCLSH = /home/nick/anaconda3/bin/tclsh8.6
