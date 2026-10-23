Compiler Design Lab: Experiments 6 to 14
A single shell script that generates, compiles and runs all the compiler design lab programs (Experiments 6 to 14) on Ubuntu, printing each program's output in order.
Experiments covered
Exp	Program
6	Recognise a valid arithmetic expression (LEX + YACC)
7	Check a valid identifier (LEX + YACC)
8	Calculator (LEX + YACC)
9	ε-closure of all states of an NFA
10	First and Follow of a grammar
11	Shift-reduce parser
12	Code optimization simulation (loop unrolling)
13	Intermediate code generation
14	Back end: three-address code to 8086-style assembly
Requirements
Ubuntu (tested on 24.04) or another Debian-based Linux distribution
`bash`, `gcc`, `flex`, `bison`
`script` (from `bsdutils`, already installed on Ubuntu)
The script installs `gcc`, `flex` and `bison` automatically with `sudo apt` if they are missing. To install them yourself first:
```bash
sudo apt update && sudo apt install -y gcc flex bison
```
How to run
Open a terminal in the folder containing `run_compiler_lab.sh`, then run:
```bash
chmod +x run_compiler_lab.sh
./run_compiler_lab.sh
```
Or, without changing permissions:
```bash
bash run_compiler_lab.sh
```
To save the full output to a file (for example, for your lab record):
```bash
./run_compiler_lab.sh | tee output_log.txt
```
What the script does
Creates the folder `~/compiler_lab`.
Writes every source file there (`exp6.l`/`exp6.y` through `exp14.c`), plus the input files `input.dat` and `input14.txt`.
Compiles and runs Experiments 6 to 14 in order, showing each command and echoing the typed inputs as a real terminal would.
All generated programs stay in `~/compiler_lab` after the run.
Notes
Experiment 10: the correct result for the sample grammar is `Follow(Y) = { +, $, ), }`, since Y ends the production `T=FY`, so Follow(T) is included.
Experiment 12: the timings are real measurements and differ on every run. The unrolled version is normally faster.
Platform: Linux only. It will not run in Windows CMD or PowerShell, and the typed-input echo does not work on macOS because `script` behaves differently there.
Troubleshooting
If a command fails, the script stops and prints `!! command failed: ...`. Check that `gcc`, `flex` and `bison` are installed, then run it again.
