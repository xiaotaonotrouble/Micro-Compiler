/**
 * --------------------------------------
 * CUHK-SZ CSC4180: Compiler Construction
 * Assignment 1: Micro Language Compiler
 * --------------------------------------
 * Author: Mr.Liu Yuxuan
 * Position: Teaching Assisant
 * Date: January 25th, 2024
 * Email: yuxuanliu1@link.cuhk.edu.cn
 * 
 * This file implements some lexical analysis rules to scan the input file 
 * and return the tokens which will be used for parser 
 */

%{
/* C/C++ Stuff (headers, declarations, variables, etc.) */
#include <cstdio>
#include <string>
#include <vector>
#include <iostream>
#include "parser.hpp"
#include "node.hpp"
#ifdef PRINT
#define TOKEN(t) { printf("Token: %s\n", #t); return t; }
#else
#define TOKEN(t) return t
#endif
void print_token(const std::string& token_name, const std::string& value);
void copy_string();

int yyerror (char *s);

int yylex();



/**
 * scan_only indicates whehter the flex scanner should print out the token information for debug.
 * The token information is in the following form:
 *   <token-class, lexeme>
 */
extern int scan_only;
int end = 0;
%}

SPACE       [\t]+
EOL         [\t]*[\n\r]+
COMMENT     "--".*[\n\r]
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
/* TODO: define some regular expressions here */
/* TODO: define your scanning rule here */
%%
{SPACE}       {;} // ignore
{EOL}         {;} // ignore
{COMMENT}     {;} // ignore
{BEGIN_}      {if(scan_only) { print_token("BEGIN_", yytext);}      copy_string(); return BEGIN_; }
{END}         {if(scan_only) { print_token("END", yytext);}         copy_string(); return END; }
{READ}        {if(scan_only) { print_token("READ", yytext);}        copy_string(); return READ; }
{WRITE}       {if(scan_only) { print_token("WRITE", yytext);}       copy_string(); return WRITE; }
{LPAREN}      {if(scan_only) { print_token("LPAREN", yytext);}      copy_string(); return LPAREN; }
{RPAREN}      {if(scan_only) { print_token("RPAREN", yytext);}      copy_string(); return RPAREN; }
{SEMICOLON}   {if(scan_only) { print_token("SEMICOLON", yytext);}   copy_string(); return SEMICOLON; }
{COMMA}       {if(scan_only) { print_token("COMMA", yytext);}       copy_string(); return COMMA; }
{ASSIGNOP}    {if(scan_only) { print_token("ASSIGNOP", yytext);}    copy_string(); return ASSIGNOP; }
{PLUSOP}      {if(scan_only) { print_token("PLUSOP", yytext);}      copy_string(); return PLUSOP; }
{MINUSOP}     {if(scan_only) { print_token("MINUSOP", yytext);}     copy_string(); return MINUSOP; }
{ID}          {if(scan_only) { print_token("ID", yytext);}          copy_string(); return ID; }
{INTLITERAL}  {if(scan_only) { print_token("INTLITERAL", yytext);}  yylval.num = std::stoi(yytext); return INTLITERAL; }
<<EOF>>       {if(scan_only) { std::cout << "<SCANEOF>" << std::endl; yyterminate();} return SCANEOF; }
.             {;} // ignore any unmatched element



%%
void print_token(const std::string& token_name, const std::string& value) {
    std::cout << '<' << token_name << ", " << value << '>' << std::endl;
}

void copy_string() {
    yylval.str = (char*)malloc(strlen(yytext) + 1);
    strcpy(yylval.str, yytext);
}
int yywrap (void) {return 1;}
