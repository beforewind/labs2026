import sys
import atexit
import os

# 尝试导入 termios (Unix)，失败则导入 msvcrt (Windows)
try:
    import termios
    PLATFORM = 'unix'
except ImportError:
    import msvcrt
    PLATFORM = 'windows'

orig_term = None

def stdio_init():
    """初始化输入模式：Unix关闭回显和规范模式，Windows无需特殊设置"""
    global orig_term
    if PLATFORM == 'unix':
        atexit.register(stdio_close)
        orig_term = termios.tcgetattr(sys.stdin)
        new_settings = termios.tcgetattr(sys.stdin)
        # 关闭回显(ECHO)和规范模式(ICANON)
        new_settings[3] = new_settings[3] & ~(termios.ECHO | termios.ICANON)
        new_settings[6][termios.VMIN] = 0   # 非阻塞
        new_settings[6][termios.VTIME] = 0
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, new_settings)
    else:
        # Windows 控制台默认就支持无回显读取，无需初始化
        # 注册退出处理（虽然这里不需要恢复什么，但保持结构一致）
        atexit.register(stdio_close)

def stdio_close():
    """恢复终端设置（仅Unix需要）"""
    global orig_term
    if PLATFORM == 'unix' and orig_term is not None:
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, orig_term)
        orig_term = None

def stdio_read():
    """非阻塞读取一个字节，无数据时返回None"""
    if PLATFORM == 'unix':
        # Unix 原实现：os.read 在 VMIN=0 时非阻塞
        ch = os.read(sys.stdin.fileno(), 1)
        return ch if len(ch) > 0 else None
    else:
        # Windows 实现：kbhit() 检查缓冲区，getch() 读取单字节
        if msvcrt.kbhit():
            return msvcrt.getch()
        return None
