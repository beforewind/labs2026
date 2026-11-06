
# 临时记录草稿箱

```sh


riscv64-unknown-elf-objdump -d test > test.txt
```

cd labs2026
git pull
git submodule update --init --recursive

riscv-none-elf-as -march=rv32g -mabi=ilp32 -o test.o test.s

```sh

cd .\sw\apps\test
riscv-none-elf-gcc -S -march=rv32g -mabi=ilp32 -o test.s test.c
riscv-none-elf-gcc -S -march=rv32im -mabi=ilp32 -o test_rv32m.s test.c

riscv-none-elf-as -march=rv32im -mabi=ilp32 -o test.o test.s

riscv-none-elf-gcc -c -march=rv32im -mabi=ilp32 -o test.o test.c

riscv-none-elf-gcc -c -march=rv32im -mabi=ilp32 -o test.o test.s

riscv-none-elf-ld -m elf32lriscv -Ttext 0x00000000 -o test test.o

riscv-none-elf-objdump -d test > test.txt

riscv-none-elf-gcc -march=rv32im -mabi=ilp32 -o test test.o

riscv-none-elf-objdump -d test > test_with_lib.txt

cd ./sw
make
```

```sh

python ./run_win.py -d COM5 -b 115200 -f .\project.sim\sim_1\behav\modelsim\build\hello_world

python ../scripts/run_win.py -d COM10 -b 115200 -f  build.riscv.hello_world/hello_world


C:\tools\Python310\python.exe C:\training\labs2026\scripts\run\poke.py -t uart -d COM10 -b 115200 -a 0xF0000000 -v 0x0
C:\tools\Python310\python.exe C:\training\labs2026\scripts\run\load.py -t uart -d COM10 -b 115200 -f build.riscv.hello_world/hello_world -p 
ELF: Loading 0x0 - size 1KB
 |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| 100.0% 
ELF: Loading 0x0 - size 9KB
 |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| 100.0% 
C:\tools\Python310\python.exe C:\training\labs2026\scripts\run\console-uart.py -t uart -d COM10 -b 115200 -f build.riscv.hello_world/hello_world
helloworld!
```

### 添加模块

添加submodule

添加方法：

git submodule add https://github.com/alexforencich/verilog-axi.git deps/verilog-axi
