#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Assembling program
/usr/bin/as --64 -o /home/and3md/fpc/testy/cge/teren1/castle-engine-output/standalone/lazarus-lib/x86_64-linux/teren1_standalone.o   /home/and3md/fpc/testy/cge/teren1/castle-engine-output/standalone/lazarus-lib/x86_64-linux/teren1_standalone.s
if [ $? != 0 ]; then DoExitAsm program; fi
rm /home/and3md/fpc/testy/cge/teren1/castle-engine-output/standalone/lazarus-lib/x86_64-linux/teren1_standalone.s
echo Linking /home/and3md/fpc/testy/cge/teren1/teren1
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2     -L. -o /home/and3md/fpc/testy/cge/teren1/teren1 -T /home/and3md/fpc/testy/cge/teren1/link25013.res -e _start -E
if [ $? != 0 ]; then DoExitLink /home/and3md/fpc/testy/cge/teren1/teren1; fi
IFS=$OFS
