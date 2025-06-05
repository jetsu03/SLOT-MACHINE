# SLOT-MACHINE
A simple terminal-based Slot Machine game implemented using x86-64 NASM Assembly, developed as part of my Microcontroller Programming coursework to explore low-level instruction sets.

### Prerequisites
System Requirements:
* Operating System: Linux (Ubuntu, Debian, Fedora, Arch, etc.) or WSL on Windows
* Architecture: x86-64 (64-bit)
* Memory: Minimal (< 1MB)
* Permissions: Standard user access

### Pre-Installation
Installs everything you need to write, assemble, and run NASM assembly programs on Linux. 
```
$ sudo apt update
$ sudo apt install nasm build-essential
```

## Steps
Step 1: Create a folder and create ``` &.asm ``` file in it. Write down the code and save. 

Step 2 : Open WSL and go into the project directory folder.
```
$cd /mnt/c/path/to/your/folder
```

Step 3: Use this command to assemble your assembly code (slot_machine.asm) into an object file (slot_machine.o) using NASM.
```
$nasm -f elf64 slot_machine.asm -o slot_machine.o
```

Step 4: Use this command which uses the linker (ld) to turn the object file into a final executable binary called slot_machine.
```
$ld slot_machine.o -o slot_machine
```

Step 5: Run the project file.
```
$./slot_machine
```

## Output
![image alt](https://github.com/jetsu03/SLOT-MACHINE/blob/e53e5401dfdb6ccd0aa9cc7b62f4194f9f558f0b/Image.jpg)
