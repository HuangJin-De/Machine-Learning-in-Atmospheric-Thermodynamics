# compiler
FC = mpifort
DEBUG = -CB -g -traceback -debug all #-check all
FCFLAGS = -O3 -free -mcmodel=large -heap-arrays 10 -shared-intel -assume byterecl $(DEBUG)
FINCLUDE = -I/home/der0318/.local/include
LDLIBS = -L/home/der0318/.local/lib -lnetcdff -lnetcdf

# code paths
VPATH = src

# objects
LIST = cal_lts.F
LIST_o = $(LIST:.F=.o)
target = cal_lts.exe

cal_lts.exe: cal_lts.o
cal_lts.o: cal_lts.F

all: $(target)

$(LIST_o): %.o: %.F
	$(FC) $(FCFLAGS) $(FINCLUDE) -c $<

$(target) : $(LIST_o)
	$(FC) $(FCFLAGS) $(FINCLUDE) $^ -o $@ $(LDLIBS)

clean:
	rm -rf *.o *.mod

cleanexe:
	rm -rf cal_lts.exe

