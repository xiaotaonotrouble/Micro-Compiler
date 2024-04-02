# CSC4180 Micro Compiler Report
Name: Zhang_Hongtao&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ID: 121090811&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date: 2024.2.26

---

## 1.How to execute my compiler?


Use commands below to run the compiler:

```bash
cd /path/to/project
make all
121090811@c2d52c9b1339:~/CSC4180-Compiler/Assignment1/src$ ./compiler --help
CUHK-SZ CSC4180 Assignment-1: Micro Language Compiler Frontend
Usage: Usage: compiler [options] source-program.m
Allowed options:
  -h [ --help ]                     Usage: compiler [options] 
                                    source-program.m
  -s [ --scan-only ]                [Default: false] print out token class and 
                                    lexeme pairs for each token, no parsing 
                                    operations onwards
  -c [ --cst-only ]                 [Default: false] generate concrete syntax 
                                    tree only, do not generate AST and LLVM IR
  -d [ --dot ] arg (=ast.dot)       [Default: ast.dot] the .dot filename where 
                                    compiler will output the tree
  -o [ --output ] arg (=program.ll) [Default: program.ll] LLVM IR file compiled
                                    from source code
  --source-program arg              source Micro program to compile
```
### Sample: test0.m
```
121090811@c2d52c9b1339:~/A1$ ./compiler ../testcases/test0.m
dot file name: ast.dot
IR output: program.ll
Source program: ../testcases/test0.m
export parse tree filename: ast.dot
121090811@c2d52c9b1339:~/A1$ dot -Tpng ./ast.dot -o ./ast.png
121090811@c2d52c9b1339:~/A1$ opt ./program.ll -S --O3 -o ./program_optimized.ll
121090811@c2d52c9b1339:~/A1$ llc -march=riscv64 ./program_optimized.ll -o ./program.s
121090811@c2d52c9b1339:~/A1$ riscv64-unknown-linux-gnu-gcc ./program.s -o ./program
121090811@c2d52c9b1339:~/A1$ qemu-riscv64 -L /opt/riscv/sysroot ./program
30
```
## 2.How do I design the Scanner?
```
There are 14 kinds of tokens in Micro Language, and their corersponding matching regular expressions are:
BEGIN_      "begin"
END         "end"
READ        "read"
WRITE       "write"
LPAREN      "("
RPAREN      ")"
SEMICOLON   ";"
COMMA       ","
ASSIGNOP    ":="
PLUSOP      "+"
MINUSOP     "-"
ID          [a-zA-Z][a-zA-Z0-9_]{0,31}
INTLITERAL  -?[0-9]+ 
SCANEOF     <<EOF>>
as well as another 3 regular expressions to match other elements:
SPACE       [\t]+
EOL         [\t]*[\n\r]+
COMMENT     "--".*[\n\r]
.           . // anything that's unmatched
```
for each matched token: 
1. Store its value in variables that are accessible to the parser (except SCANEOF token) using following code
```cpp
copy_string();                      // for tokens that are str type
yylval.num = std::stoi(yytext);     // for tokens that are num type
```
2. Return its token type to the parser
```cpp
return BEGIN_; // replace BEGIN_ with any token names
```
Enabling [scanner-only] option, the scanner is able to print tokens that it recognize in `<token-class, lexeme>` format by setting the scanner_only flag to 1.
Example output after running `121090811@c2d52c9b1339:~/A1$ ./compiler -s ../testcases/test0.m`
```
<BEGIN_, begin>
<ID, A>
<ASSIGNOP, :=>
<INTLITERAL, 10>
<SEMICOLON, ;>
<ID, B>
<ASSIGNOP, :=>
<ID, A>
<PLUSOP, +>
<INTLITERAL, 20>
<SEMICOLON, ;>
<WRITE, write>
<LPAREN, (>
<ID, B>
<RPAREN, )>
<SEMICOLON, ;>
<END, end>
<SCANEOF>
```
## 3.How do I design the Parser?
Parser takes token stream as input and outputs a CFG tree or ABS tree, the latter one is used for llvm ir generation.
### yylval data structure
Define three data types for receiving values for each tokens from scanner and for tree building:
```cpp
%union {
        int num;
        char* str;
        struct Node* node;
}
```
### symbols definition
Define terminals and non-terminals and their data types for both lexical analysis and tree building:
```cpp
// terminal symbols with %token.
%token <str> BEGIN_ END READ WRITE LPAREN RPAREN SEMICOLON COMMA ASSIGNOP PLUSOP MINUSOP ID SCANEOF
%token <num> INTLITERAL
// Start Symbol
%start start
// Non-Terminal Symbols with %type.
%type <node> program statement_list statement id_list expr_list expression primary
```
### tree building
In each production rule, use $$ to reference left value and $i to reference right value, and manipulate the global variable root_node at appropriate time.
## 4.How do I design the Intermediate Code Generator?
Intermediate code generator take an AST tree as input and output corresponding llvm ir language program. 

### The overall structure is:
one main routine:
```cpp
gen_llvm_ir()
```
three sub_routines:
```cpp
gen_BINARYOP_llvm_ir()
gen_WRITE_llvm_ir()
gen_READ_llvm_ir()

```
one helper function:
```cpp
get_expression_value()
```
### Main calling routine:
Call `gen_llvm_ir()` on the root node, the recursive function will walk down the tree until it finds nodes that are of Symbol_Class `BINARYOP, WRITE, READ`.  
And then calls `gen_BINARYOP_llvm_ir(), 
gen_WRITE_llvm_ir(), 
gen_READ_llvm_ir()
`accordingly.  
The sub_routine will call the helper function `get_expression_value()` when it encounters expression in its children and write relevent llvm ir codes to the output file.
The helper function will recursively call itself walking down the tree, until it encounters base case nodes of Symbol_Class `ID, INTLITERAL`, and returns string to its caller.
## A calling flow example for test0.m
```
<gen_llvm_ir, <program>>
<gen_llvm_ir, <statement list>>
<gen_llvm_ir, :=>
<gen_ASSIGNOP_llvm_ir, :=>
<get_expression_value, 10>
<gen_llvm_ir, :=>
<gen_ASSIGNOP_llvm_ir, :=>
<get_expression_value, +>
<get_expression_value, A>
<get_expression_value, 20>
<gen_llvm_ir, write>
<gen_WRITE_llvm_ir, write>
<get_expression_value, B>
```
