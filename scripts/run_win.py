import sys
import argparse
import os
import subprocess


def run_script(script_path, script_args):
    """用当前 Python 解释器执行脚本，参数以列表传递，避免 shell 解析。"""
    cmd = [sys.executable, script_path] + script_args
    print(" ".join(cmd))  # 仅用于显示，实际执行不经过 shell
    result = subprocess.run(cmd)
    if result.returncode != 0:
        raise SystemExit(f"Command failed with exit code {result.returncode}: {script_path}")
    return result


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', dest='type',    default='uart',                     help='Device type (uart|ftdi)')
    parser.add_argument('-d', dest='device',  default='/dev/ttyUSB1',             help='Serial Device')
    parser.add_argument('-b', dest='baud',    default=1000000,       type=int,    help='Baud rate')
    parser.add_argument('-f', dest='filename', required=True,                     help='File to load')
    parser.add_argument('-p', dest='progargs', default="",                         help='Program load argument string')
    args = parser.parse_args()

    run_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "run")

    # 1. poke.py
    run_script(
        os.path.join(run_path, "poke.py"),
        [
            "-t", args.type,
            "-d", args.device,
            "-b", str(args.baud),
            "-a", "0xF0000000",
            "-v", "0x0",
        ],
    )

    # 2. load.py
    run_script(
        os.path.join(run_path, "load.py"),
        [
            "-t", args.type,
            "-d", args.device,
            "-b", str(args.baud),
            "-f", args.filename,
            "-p", args.progargs,
        ],
    )

    # 3. console-uart.py
    run_script(
        os.path.join(run_path, "console-uart.py"),
        [
            "-t", args.type,
            "-d", args.device,
            "-b", str(args.baud),
            "-f", args.filename,
        ],
    )


if __name__ == "__main__":
    main(sys.argv[1:])
