#!/bin/bash
# =====================================================================
#  Compiler Design Lab - Experiments 6 to 14
#  Usage:  chmod +x run_compiler_lab.sh && ./run_compiler_lab.sh
#  Creates all programs in ~/compiler_lab, compiles and runs them in order.
# =====================================================================

WORK="${1:-$HOME/compiler_lab}"
mkdir -p "$WORK" && cd "$WORK" || exit 1

# ---------- make sure the tools exist ----------
need=()
command -v gcc   >/dev/null 2>&1 || need+=(gcc)
command -v flex  >/dev/null 2>&1 || need+=(flex)
command -v bison >/dev/null 2>&1 || need+=(bison)
command -v script >/dev/null 2>&1 || need+=(bsdutils)
if [ ${#need[@]} -gt 0 ]; then
    echo "Installing missing packages: ${need[*]}"
    sudo apt-get update -qq && sudo apt-get install -y -qq "${need[@]}"
fi
if command -v yacc >/dev/null 2>&1; then YACC="yacc"; else YACC="bison -y"; fi
if command -v lex  >/dev/null 2>&1; then LEX="lex";   else LEX="flex";     fi

# ---------- helpers ----------
prompt() { printf '%s@%s:%s$ ' "$USER" "$HOSTNAME" "${PWD/#$HOME/~}"; }

# cmd "text to display" real command...   (shows the command, runs it silently)
cmd() {
    local shown="$1"; shift
    prompt; echo "$shown"
    "$@" >/dev/null 2>&1 || { echo "!! command failed: $*"; exit 1; }
}

# run ./a.out  [typed line 1] [typed line 2] ...   (typed lines are echoed like a real terminal)
run() {
    local prog="$1"; shift
    prompt; echo "$prog"
    if [ $# -eq 0 ]; then
        $prog
    else
        { for l in "$@"; do sleep 0.35; printf '%s\n' "$l"; done; sleep 0.35; } \
            | script -qec "$prog" /dev/null
    fi
}

# =====================================================================
#  SOURCE FILES
# =====================================================================

# ---------------- Experiment 6 ----------------
cat > exp6.l <<'EOF'
%{
#include "y.tab.h"
%}
%%
[0-9]+                    { return DIGIT; }
[a-zA-Z_][a-zA-Z0-9_]*    { return ID; }
\n                        { return NL; }
[ \t]                     ;
.                         { return yytext[0]; }
%%
int yywrap() { return 1; }
EOF

cat > exp6.y <<'EOF'
%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
%}
%token DIGIT ID NL
%left '+' '-'
%left '*' '/'
%%
stmt : exp NL   { printf("Valid Expression\n"); exit(0); } ;
exp  : exp '+' exp
     | exp '-' exp
     | exp '*' exp
     | exp '/' exp
     | '(' exp ')'
     | DIGIT
     | ID
     ;
%%
void yyerror(const char *s) { printf("Invalid Expression\n"); }
int main() {
    printf("Enter an arithmetic expression: ");
    yyparse();
    return 0;
}
EOF

# ---------------- Experiment 7 ----------------
cat > exp7.l <<'EOF'
%{
#include "y.tab.h"
%}
%%
[a-zA-Z_][a-zA-Z0-9_]*    { return ID; }
\n                        { return NL; }
.                         { return yytext[0]; }
%%
int yywrap() { return 1; }
EOF

cat > exp7.y <<'EOF'
%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
%}
%token ID NL
%%
stmt : ID NL   { printf("Valid Identifier\n"); exit(0); } ;
%%
void yyerror(const char *s) { printf("Invalid Identifier\n"); }
int main() {
    printf("Enter an identifier: ");
    yyparse();
    return 0;
}
EOF

# ---------------- Experiment 8 ----------------
cat > exp8.l <<'EOF'
%{
#include <stdlib.h>
#include "y.tab.h"
%}
%%
[0-9]+     { yylval = atoi(yytext); return DIGIT; }
\n         { return NL; }
[ \t]      ;
.          { return yytext[0]; }
%%
int yywrap() { return 1; }
EOF

cat > exp8.y <<'EOF'
%{
#include <stdio.h>
#include <stdlib.h>
int yylex(void);
void yyerror(const char *s);
%}
%token DIGIT NL
%left '+' '-'
%left '*' '/'
%%
stmt : exp NL   { printf("Result = %d\n", $1); exit(0); } ;
exp  : exp '+' exp   { $$ = $1 + $3; }
     | exp '-' exp   { $$ = $1 - $3; }
     | exp '*' exp   { $$ = $1 * $3; }
     | exp '/' exp   { if ($3 == 0) { yyerror("div0"); YYABORT; } $$ = $1 / $3; }
     | '(' exp ')'   { $$ = $2; }
     | DIGIT         { $$ = $1; }
     ;
%%
void yyerror(const char *s) { printf("Invalid\n"); }
int main() {
    printf("Enter an arithmetic expression: ");
    yyparse();
    return 0;
}
EOF

# ---------------- Experiment 9 ----------------
cat > exp9.c <<'EOF'
#include<stdio.h>
#include<string.h>
char result[20][20],copy[3],states[20][20];
void add_state(char a[3],int i){
    strcpy(result[i],a);
}

void display(int n){
    int k=0;
    printf("\nEpsilon closure of %s = { ",copy);
    while(k < n){
        printf(" %s",result[k]);
        k++;
    }
    printf(" } ");
}

int main()
{
    FILE *INPUT;
    INPUT=fopen("input.dat","r");
    if(INPUT==NULL){ printf("input.dat not found\n"); return 1; }
    char state[3];
    int end,i=0,n,k=0;
    char state1[3],input[3],state2[3];
    printf("Enter the no of states: ");
    scanf("%d",&n);
    printf("Enter the states: ");
    for(k=0;k<n;k++){
        scanf("%s",states[k]);
    }

    for( k=0;k<n;k++){
        i=0;
        strcpy(state,states[k]);
        strcpy(copy,state);
        add_state(state,i++);
        while(1){
            end = fscanf(INPUT,"%s%s%s",state1,input,state2);
            if (end == EOF ){
                break;
            }
            if( strcmp(state,state1) == 0 ){
                if( strcmp(input,"e") == 0 ) {
                    add_state(state2,i++);
                    strcpy(state, state2);
                }
            }
        }
        display(i);
        rewind(INPUT);
    }
    printf("\n");
    return 0;
}
EOF

cat > input.dat <<'EOF'
q1 0 q1
q1 e q2
q2 1 q3
q2 e q3
EOF

# ---------------- Experiment 10 ----------------
cat > exp10.c <<'EOF'
#include <stdio.h>
#include <string.h>
#include <ctype.h>

int n;
char prod[20][20];
int visF[128], visW[128];

void addc(char *s, char c) {
    if (!strchr(s, c)) { int l = strlen(s); s[l] = c; s[l + 1] = '\0'; }
}

void findfirst(char c, char *res) {
    int i, j, k;
    if (!isupper((unsigned char)c)) { addc(res, c); return; }
    if (visF[(int)c]) return;
    visF[(int)c] = 1;
    for (i = 0; i < n; i++) {
        if (prod[i][0] != c) continue;
        char *r = prod[i] + 2;
        if (r[0] == '#') { addc(res, '#'); continue; }
        for (j = 0; r[j]; j++) {
            char t[20] = ""; int eps = 0;
            findfirst(r[j], t);
            for (k = 0; t[k]; k++) { if (t[k] == '#') eps = 1; else addc(res, t[k]); }
            if (!eps) break;
            if (!r[j + 1]) addc(res, '#');
        }
    }
    visF[(int)c] = 0;
}

void findfollow(char c, char *res) {
    int i, j, k, m;
    if (visW[(int)c]) return;
    visW[(int)c] = 1;
    if (c == prod[0][0]) addc(res, '$');
    for (i = 0; i < n; i++) {
        char *r = prod[i] + 2;
        for (j = 0; r[j]; j++) {
            if (r[j] != c) continue;
            int allEps = 1;
            for (k = j + 1; r[k]; k++) {
                char t[20] = ""; int eps = 0;
                findfirst(r[k], t);
                for (m = 0; t[m]; m++) { if (t[m] == '#') eps = 1; else addc(res, t[m]); }
                if (!eps) { allEps = 0; break; }
            }
            if (allEps) findfollow(prod[i][0], res);
        }
    }
    visW[(int)c] = 0;
}

int main() {
    int i, k, cnt = 0;
    char nt[20];
    printf("Enter no. of production rules: ");
    scanf("%d", &n);
    printf("Enter the production rules\n");
    for (i = 0; i < n; i++) scanf("%s", prod[i]);

    for (i = 0; i < n; i++)                       /* list non-terminals in order */
        if (!memchr(nt, prod[i][0], cnt)) nt[cnt++] = prod[i][0];

    for (i = 0; i < cnt; i++) {
        char res[20] = "";
        memset(visF, 0, sizeof visF);
        findfirst(nt[i], res);
        printf("First(%c) = { ", nt[i]);
        for (k = 0; res[k]; k++) printf("%c, ", res[k]);
        printf("}\n");
    }
    printf("-----------------------------------------------\n");
    for (i = 0; i < cnt; i++) {
        char res[20] = "";
        memset(visW, 0, sizeof visW);
        findfollow(nt[i], res);
        printf("Follow(%c) = { ", nt[i]);
        for (k = 0; res[k]; k++) printf("%c, ", res[k]);
        printf("}\n");
    }
    return 0;
}
EOF

# ---------------- Experiment 11 ----------------
cat > exp11.c <<'EOF'
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char lhs[20][10], rhs[20][20][10], ptext[20][100];
int  rlen[20], np;
char stack[100][10]; int sp = 0;
char input[100][10]; int nin = 0, ip = 0;

void show(const char *action) {
    char st[500] = "", in[500] = "";
    int i;
    for (i = 0; i < sp; i++) strcat(st, stack[i]);
    for (i = ip; i < nin; i++) strcat(in, input[i]);
    strcat(in, "$");
    printf("%-16s%-16s%s\n", st, in, action);
}

int main() {
    char buf[200], act[200];
    int i, j;

    printf("Enter number of productions: ");
    fgets(buf, sizeof buf, stdin);
    np = atoi(buf);

    printf("Enter productions (example: E -> E + E):\n");
    for (i = 0; i < np; i++) {
        fgets(buf, sizeof buf, stdin);
        char *t = strtok(buf, " \t\n");
        strcpy(lhs[i], t);
        strtok(NULL, " \t\n");                       /* skip "->" */
        rlen[i] = 0;
        while ((t = strtok(NULL, " \t\n")))
            strcpy(rhs[i][rlen[i]++], t);
        sprintf(ptext[i], "%s ->", lhs[i]);
        for (j = 0; j < rlen[i]; j++) { strcat(ptext[i], " "); strcat(ptext[i], rhs[i][j]); }
    }

    printf("Enter input tokens separated by spaces: ");
    fgets(buf, sizeof buf, stdin);
    char *t = strtok(buf, " \t\n");
    while (t) { strcpy(input[nin++], t); t = strtok(NULL, " \t\n"); }

    strcpy(stack[sp++], "$");
    printf("\n%-16s%-16s%s\n", "Stack", "Input", "Action");
    show("--");

    while (1) {
        int reduced = 0;
        for (i = 0; i < np && !reduced; i++) {
            int len = rlen[i];
            if (sp - 1 < len) continue;
            for (j = 0; j < len; j++)
                if (strcmp(stack[sp - len + j], rhs[i][j]) != 0) break;
            if (j == len) {
                sp -= len;
                strcpy(stack[sp++], lhs[i]);
                sprintf(act, "REDUCE TO %s (%s)", lhs[i], ptext[i]);
                show(act);
                reduced = 1;
            }
        }
        if (reduced) continue;
        if (ip < nin) { strcpy(stack[sp++], input[ip++]); show("SHIFT"); continue; }
        if (sp == 2 && strcmp(stack[1], lhs[0]) == 0) show("ACCEPT");
        else show("REJECT");
        break;
    }
    return 0;
}
EOF

# ---------------- Experiment 12 ----------------
cat > exp12.c <<'EOF'
#include<stdio.h>
#include <time.h>

void fun1()
{
    for (int i = 0; i < 5; i++)
        printf("Hello\n");
}

void fun2()
{
    printf("Hello\n");
    printf("Hello\n");
    printf("Hello\n");
    printf("Hello\n");
    printf("Hello\n");
}

int main()
{
    clock_t t1, t2;

    t1 = clock();
    fun1();
    t1 = clock() - t1;
    double time_taken1 = ((double)t1) / CLOCKS_PER_SEC;
    printf("/normal loop/\n");
    printf("Time taken: %f seconds\n\n", time_taken1);

    t2 = clock();
    fun2();
    t2 = clock() - t2;
    double time_taken2 = ((double)t2) / CLOCKS_PER_SEC;
    printf("/unrolled loop/\n");
    printf("Time taken: %f seconds\n", time_taken2);
    return 0;
}
EOF

# ---------------- Experiment 13 ----------------
cat > exp13.c <<'EOF'
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char temp = 'Z';

void replace(char *e, int pos, int len, char c) {
    e[pos] = c;
    memmove(e + pos + 1, e + pos + len, strlen(e + pos + len) + 1);
}

/* reduces a bracket-free expression to one symbol, printing one line per operator */
char reduce(char *e) {
    const char *levels[2] = { "/*", "+-" };      /* division/multiplication first, then +/- */
    int l, p;
    for (l = 0; l < 2; l++) {
        while (1) {
            for (p = 0; e[p]; p++)
                if (strchr(levels[l], e[p])) break;
            if (!e[p]) break;
            printf("%c := %c%c%c\n", temp, e[p - 1], e[p], e[p + 1]);
            replace(e, p - 1, 3, temp--);
        }
    }
    return e[0];
}

int main() {
    char in[100], s[100], *e, *o, *c;
    printf("INTERMEDIATE CODE GENERATION\n\n");
    printf("Enter the Expression : ");
    scanf("%s", in);
    e = strchr(in, ':');
    strcpy(s, e ? e + 1 : in);
    printf("The intermediate code:\n");

    while ((o = strrchr(s, '('))) {               /* brackets first */
        c = strchr(o, ')');
        if (!c) { printf("Unbalanced brackets\n"); exit(1); }
        char inner[100];
        strncpy(inner, o + 1, c - o - 1);
        inner[c - o - 1] = '\0';
        char r = reduce(inner);
        replace(s, o - s, c - o + 1, r);
    }
    reduce(s);
    return 0;
}
EOF

# ---------------- Experiment 14 ----------------
cat > exp14.c <<'EOF'
#include <stdio.h>

int main() {
    char fname[50], op, a[20], b[20], r[20];
    FILE *in, *out;

    printf("Enter input file name: ");
    scanf("%s", fname);
    in = fopen(fname, "r");
    if (!in) { printf("Cannot open %s\n", fname); return 1; }
    out = fopen("output.txt", "w");

    while (fscanf(in, " %c %s %s %s", &op, a, b, r) == 4) {
        if (op == '=') {
            fprintf(out, "MOV R0,%s\nMOV %s,R0\n", a, r);
        } else {
            const char *ins = (op == '+') ? "ADD" : (op == '-') ? "SUB" :
                              (op == '*') ? "MUL" : "DIV";
            fprintf(out, "MOV R0,%s\n%s R0,%s\nMOV %s,R0\n", a, ins, b, r);
        }
    }
    fclose(in);
    fclose(out);
    printf("Target code generated in output.txt\n");
    return 0;
}
EOF

cat > input14.txt <<'EOF'
+ a b t1
* c d t2
- t1 t2 t
= t ? x
EOF

# =====================================================================
#  COMPILE + RUN, IN ORDER
# =====================================================================
clear

# ---- Exp 6 ----
cmd "yacc -d exp6.y"          $YACC -d exp6.y
cmd "lex exp6.l"              $LEX exp6.l
cmd "gcc y.tab.c lex.yy.c"    gcc -w y.tab.c lex.yy.c
run ./a.out "(2+3)/(4-1)"
run ./a.out "x+y=z"
echo

# ---- Exp 7 ----
cmd "yacc -d exp7.y"          $YACC -d exp7.y
cmd "lex exp7.l"              $LEX exp7.l
cmd "gcc y.tab.c lex.yy.c"    gcc -w y.tab.c lex.yy.c
run ./a.out "total123"
run ./a.out "12total"
echo

# ---- Exp 8 ----
cmd "yacc -d exp8.y"             $YACC -d exp8.y
cmd "lex exp8.l"                 $LEX exp8.l
cmd "gcc y.tab.c lex.yy.c -lm"   gcc -w y.tab.c lex.yy.c -lm
run ./a.out "2+3*90"
run ./a.out "a+b"
echo

# ---- Exp 9 ----
cmd "gcc exp9.c"   gcc -w exp9.c
run ./a.out "3" "q1 q2 q3"
echo

# ---- Exp 10 ----
cmd "gcc exp10.c"  gcc -w exp10.c
run ./a.out "8" "E=TR" "R=+TR" "R=#" "T=FY" "Y=*FY" "Y=3" "F=(E)" "F=i"
echo

# ---- Exp 11 ----
cmd "gcc exp11.c"  gcc -w exp11.c
run ./a.out "4" "E -> E + E" "E -> E * E" "E -> ( E )" "E -> id" "id + id"
echo

# ---- Exp 12 ----
cmd "gcc exp12.c"  gcc -w exp12.c
run ./a.out
echo

# ---- Exp 13 ----
cmd "gcc exp13.c"  gcc -w exp13.c
run ./a.out "w:a+b*c+d"
echo

# ---- Exp 14 ----
cmd "gcc exp14.c"  gcc -w exp14.c
run ./a.out "input14.txt"
prompt; echo "cat output.txt"
cat output.txt
echo
echo "All programs are saved in: $WORK"
