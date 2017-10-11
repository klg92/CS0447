# These are constant definitions of common syscalls.
# This way, you can write a syscall like so:
# li $v0, sys_exit
# syscall

.eqv sys_printInt 1
.eqv sys_printFloat 2
.eqv sys_printDouble 3
.eqv sys_printString 4
.eqv sys_readInt 5
.eqv sys_readFloat 6
.eqv sys_readDouble 7
.eqv sys_readString 8
.eqv sys_sbrk 9
.eqv sys_exit 10
.eqv sys_printChar 11
.eqv sys_readChar 12
.eqv sys_openFile 13
.eqv sys_readFile 14
.eqv sys_writeFile 15
.eqv sys_closeFile 16
.eqv sys_exit2 17
.eqv sys_time 30
.eqv sys_sleep 32
.eqv sys_printHex 34
.eqv sys_printBin 35
.eqv sys_printUInt 36