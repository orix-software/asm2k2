cl65.exe -tnone src/loaderorix.asm   -o src/loader.o
cl65.exe -vm -C src/config.txt src/asm2k2.asm -o  asm2k2
cp src/loadere.bin ../../../oricutron-iss2-debug/sdcard/
cp asm2k2 ../../../oricutron-iss2-debug/sdcard/bin