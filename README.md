# labs2026

Github: http://github.com/beforewind/labs2026

2026年电子学综合实验课-数字前端流程模块的实验源码和脚本。

实验用开发板和实验教程另行发放。

## Cloning

```
# Clone repository and submodules
git clone https://github.com/beforewind/labs2026.git --recursive
```

## Directories

| Name    | Contents                                                     |
| ------- | ------------------------------------------------------------ |
| build   | FPGA工程和软件编译目录，会生成大量的中间文件，不必做版本管理 |
| deps    | 开源的软硬件库，在.gitmodules中维护                          |
| hw      | 不同顶层的RTL设计，如uart2mem在pynq-z2开发板上实现的设计代码 |
| scripts | python和shell脚本                                            |
| sw      | 软件代码和脚本                                               |
| tb      | testbench                                                    |
| tools   | 压缩的工具程序                                               |

## lab1-数字模块设计与验证

### uart2mem模块

用一个运行在pynq-z2开发板上的FPGA工程uart2mem，让学生熟悉完整的Vivado开发流程，掌握从PC访问FPGA/RTL设计内部数据的基本方案。

## lab2-riscv soc



## lab3-riscv core



## 致谢

实验源码、脚本和文档综合了多个网络来源，未一一列出，在此表示感谢！
