ROM_DIR=/home/bee/.wine/drive_c/users/bee/2k6
STELLA=/home/bee/.wine/drive_c/Program\ Files/Stella/Stella.exe
WINE=wine

%.run: %/kernel.bin %/kernel.lst %/kernel.sym
	cp $+ $(ROM_DIR)
	$(WINE) $(STELLA) 

%.build: %/kernel.s DEPS
	dasm $< -l$*/kernel.lst -s$*/kernel.sym -f3 -v5 -o$*/kernel.bin

%/kernel.bin: %.build;
%/kernel.lst: %.build;
%/kernel.sym: %.build;

DEPS: macro.h vcs.h;