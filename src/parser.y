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
 * This file implements some syntax analysis rules and works as a parser
 * The grammar tree is generated based on the rules and MIPS Code is generated
 * based on the grammar tree and the added structures and functions implemented
 * in File: added_structure_function.c
 */

%{
/* C declarations used in actions */
#include <cstdio>     
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <ctype.h>

#include "node.hpp"


int yyerror (char *s);

int yylex();

extern int cst_only;

Node* root_node = nullptr;
%}

// TODO: define yylval data types with %union
%union {
        int num;
        char* str;
        struct Node* node;
}

// TODO: define terminal symbols with %token. Remember to set the type.
%token <str> BEGIN_
%token <str> END
%token <str> READ
%token <str> WRITE
%token <str> LPAREN
%token <str> RPAREN
%token <str> SEMICOLON
%token <str> COMMA
%token <str> ASSIGNOP
%token <str> PLUSOP
%token <str> MINUSOP
%token <str> ID
%token <num> INTLITERAL
%token <str> SCANEOF


// Start Symbol
%start start

// TODO: define Non-Terminal Symbols with %type. Remember to set the type.
%type <node> program
%type <node> statement_list
%type <node> statement
%type <node> id_list
%type <node> expr_list
%type <node> expression
%type <node> primary

%%
/**
 * Format:
 * Non-Terminal  :  [Non-Terminal, Terminal]+ (production rule 1)   { parser actions in C++ }
 *                  | [Non-Terminal, Terminal]+ (production rule 2) { parser actions in C++ }
 *                  ;
 */


// TODO: your production rule here
// The tree generation logic should be in the operation block of each production rule
start   : program SCANEOF
        {   
            if (cst_only) {
                Node* start = new Node(SymbolClass::START);
                Node* SCANEOF = new Node(SymbolClass::SCANEOF);
                start->append_child($1);
                start->append_child(SCANEOF);
                root_node = start;
            }else {
                ;
            }
            return 0;
        }

program : BEGIN_ statement_list END
        {
            if (cst_only) {
                Node* program = new Node(SymbolClass::PROGRAM);
                Node* BEGIN_ = new Node(SymbolClass::BEGIN_);
                Node* END = new Node(SymbolClass::END);
                program->append_child(BEGIN_);
                program->append_child($2);
                program->append_child(END);
                $$ = program;
            }else {
                Node* program = new Node(SymbolClass::PROGRAM);
                program->append_child($2);
                root_node = program;
                $$ = program;
            }
            
        }

statement_list  : statement
        {
            if (cst_only) {
                Node* statement_list = new Node(SymbolClass::STATEMENT_LIST);
                statement_list->append_child($1);
                $$ = statement_list;
            }else {
                Node* statement_list = new Node(SymbolClass::STATEMENT_LIST);
                statement_list->append_child($1);
                $$ = statement_list;
            }
            
        }
        | statement_list statement
        {
            if (cst_only) {
                Node* statement_list = new Node(SymbolClass::STATEMENT_LIST);
                statement_list->append_child($1);
                statement_list->append_child($2);
                $$ = statement_list;
            }else {
                $1->append_child($2);
                $$ = $1;
            }
            
        }

statement  : ID ASSIGNOP expression SEMICOLON
        {
            if (cst_only) {
                Node* statement = new Node(SymbolClass::STATEMENT);
                Node* ID = new Node(SymbolClass::ID);
                Node* ASSIGNOP = new Node(SymbolClass::ASSIGNOP);
                Node* SEMICOLON = new Node(SymbolClass::SEMICOLON);
                statement->append_child(ID);
                statement->append_child(ASSIGNOP);
                statement->append_child($3);
                statement->append_child(SEMICOLON);
                $$ = statement;
            }else {
                Node* ASSIGNOP = new Node(SymbolClass::ASSIGNOP, $2);
                Node* ID = new Node(SymbolClass::ID, $1);
                ASSIGNOP->append_child(ID);
                ASSIGNOP->append_child($3);
                $$ = ASSIGNOP;
            }
            
        }
        | READ LPAREN id_list RPAREN SEMICOLON
        {
            if (cst_only) {
                Node* statement = new Node(SymbolClass::STATEMENT);
                Node* READ = new Node(SymbolClass::READ);
                Node* LPAREN = new Node(SymbolClass::LPAREN);
                Node* RPAREN = new Node(SymbolClass::RPAREN);
                Node* SEMICOLON = new Node(SymbolClass::SEMICOLON);
                statement->append_child(READ);
                statement->append_child(LPAREN);
                statement->append_child($3);
                statement->append_child(RPAREN);
                statement->append_child(SEMICOLON);
                $$ = statement;
                
            }else {
                Node* READ = new Node(SymbolClass::READ, $1);
                READ->children = $3->children;
                $$ = READ;
            }
            
        }
        | WRITE LPAREN expr_list RPAREN SEMICOLON
        {
            if (cst_only) {
                Node* statement = new Node(SymbolClass::STATEMENT);
                Node* WRITE = new Node(SymbolClass::WRITE);
                Node* LPAREN = new Node(SymbolClass::LPAREN);
                Node* RPAREN = new Node(SymbolClass::RPAREN);
                Node* SEMICOLON = new Node(SymbolClass::SEMICOLON);
                statement->append_child(WRITE);
                statement->append_child(LPAREN);
                statement->append_child($3);
                statement->append_child(RPAREN);
                statement->append_child(SEMICOLON);
                $$ = statement;
            }else {
                Node* WRITE = new Node(SymbolClass::WRITE, $1);
                WRITE->children = $3->children;
                $$ = WRITE;
            }
            
        }

id_list : ID
        {
            if (cst_only) {
                Node* id_list = new Node(SymbolClass::ID_LIST);
                Node* ID = new Node(SymbolClass::ID);
                id_list->append_child(ID);
                $$ = id_list;
            }else {
                Node* id_list = new Node(SymbolClass::ID_LIST);
                Node* ID = new Node(SymbolClass::ID, $1);
                id_list->append_child(ID);
                $$ = id_list;
            }
            
        }
        | id_list COMMA ID
        {
            if (cst_only) {
                Node* id_list = new Node(SymbolClass::ID_LIST);
                Node* COMMA = new Node(SymbolClass::COMMA);
                Node* ID = new Node(SymbolClass::ID);
                id_list->append_child($1);
                id_list->append_child(COMMA);
                id_list->append_child(ID);
                $$ = id_list;
            }else {
                Node* ID = new Node(SymbolClass::ID, $3);
                $1->append_child(ID);
                $$ = $1;
            }
            
        }

expr_list : expression
        {
            if (cst_only) {
                Node* expr_list = new Node(SymbolClass::EXPRESSION_LIST);
                expr_list->append_child($1);
                $$ = expr_list;
            }else {
                Node* expr_list = new Node(SymbolClass::EXPRESSION_LIST);
                expr_list->append_child($1);
                $$ = expr_list;
            }
            
        }
        | expr_list COMMA expression
        {
            if (cst_only) {
                Node* expr_list = new Node(SymbolClass::EXPRESSION_LIST);
                Node* COMMA = new Node(SymbolClass::COMMA);
                expr_list->append_child($1);
                expr_list->append_child(COMMA);
                expr_list->append_child($3);
                $$ = expr_list;
            }else {
                $1->append_child($3);
                $$ = $1;
            }
            
        }

expression : primary
        {
            if (cst_only) {
                Node* expression = new Node(SymbolClass::EXPRESSION);
                expression->append_child($1);
                $$ = expression;
            }else {
                $$ = $1;
            }
            
        }
        | expression PLUSOP primary
        {
            if (cst_only) {
                Node* expression = new Node(SymbolClass::EXPRESSION);
                Node* PLUSOP = new Node(SymbolClass::PLUSOP);
                expression->append_child($1);
                expression->append_child(PLUSOP);
                expression->append_child($3);
                $$ = expression;
            }else {
                Node* PLUSOP = new Node(SymbolClass::PLUSOP, $2);
                PLUSOP->append_child($1);
                PLUSOP->append_child($3);
                $$ = PLUSOP;
            }
            
        }
        | expression MINUSOP primary
        {
            if (cst_only) {
                Node* expression = new Node(SymbolClass::EXPRESSION);
                Node* MINUSOP = new Node(SymbolClass::MINUSOP);
                expression->append_child($1);
                expression->append_child(MINUSOP);
                expression->append_child($3);
                $$ = expression;
            }else {
                Node* MINUSOP = new Node(SymbolClass::MINUSOP, $2);
                MINUSOP->append_child($1);
                MINUSOP->append_child($3);
                $$ = MINUSOP;
            }
            
        }

primary : LPAREN expression RPAREN
        {
            if (cst_only) {
                Node* primary = new Node(SymbolClass::PRIMARY);
                Node* LPAREN = new Node(SymbolClass::LPAREN);
                Node* RPAREN = new Node(SymbolClass::RPAREN);
                primary->append_child(LPAREN);
                primary->append_child($2);
                primary->append_child(RPAREN);
                $$ = primary;
            }else {
                $$ = $2;
            }
            
        }
        | ID
        {
            if (cst_only) {
                Node* primary = new Node(SymbolClass::PRIMARY);
                Node* ID = new Node(SymbolClass::ID);
                primary->append_child(ID);
                $$ = primary;
            }else {
                Node* ID = new Node(SymbolClass::ID, $1);
                $$ = ID;
            }
            
        }
        | INTLITERAL
        {
            if (cst_only) {
                Node* primary = new Node(SymbolClass::PRIMARY);
                Node* INTLITERAL = new Node(SymbolClass::INTLITERAL);
                primary->append_child(INTLITERAL);
                $$ = primary;
            }else {
                Node* INTLITERAL = new Node(SymbolClass::INTLITERAL, std::to_string($1));
                // std::cout << $1 << std::endl;
                $$ = INTLITERAL;
            }
            
        }

%%

int yyerror(char *s) {
	printf("Syntax Error on line %s\n", s);
	return 0;
}
