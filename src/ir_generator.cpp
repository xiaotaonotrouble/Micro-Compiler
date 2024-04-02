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
 * This file defines the LLVM IR Generator class, which generate LLVM IR (.ll) file given the AST from parser.
 */

#include "ir_generator.hpp"
#include <vector>
#include <algorithm>

std::vector<std::string> ID_table;

int tmp_counter = 1;

void IR_Generator::export_ast_to_llvm_ir(Node* node) {
    /* TODO: your program here */
    out << "; Declare printf" << std::endl;
    out << "declare i32 @printf(i8*, ...)" << std::endl;
    out << std::endl;
    out << "; Declare scanf" << std::endl;
    out << "declare i32 @scanf(i8*, ...)" << std::endl;
    out << std::endl;
    out << "define i32 @main() {" << std::endl;
    
    gen_llvm_ir(node);

    out << "\tret i32 0" << std::endl;
    out << "}" << std::endl;

    out.close();
}

void IR_Generator::gen_llvm_ir(Node* node) {
    /* TODO: Your program here */
    // std::cout << symbol_class_to_str(node->symbol_class) << std::endl;
    // std::cout << "fuck!" << std::endl;
    switch (node->symbol_class)
    {
    case SymbolClass::ASSIGNOP:
        gen_ASSIGNOP_llvm_ir(node);
        break;
    case SymbolClass::READ:
        gen_READ_llvm_ir(node);
        break;
    case SymbolClass::WRITE:
        gen_WRITE_llvm_ir(node);
        break;
    case SymbolClass::ID:
        // do nothing
        ;
        break;
    case SymbolClass::INTLITERAL:
        // do nothing
        ;
        break;
    default:
        // walk down past the <statement_list> and generate IR for every statement(child)
        for (Node* child : node->children) {
            
            gen_llvm_ir(child);
        }
        break;
    }
}

void IR_Generator::gen_ASSIGNOP_llvm_ir(Node* node) {
    std::string id = node->children[0]->lexeme;
    std::string rvalue = get_expression_value(node->children[1]);
    auto it = std::find(ID_table.begin(), ID_table.end(), id);
    if (it == ID_table.end()) {
        ID_table.push_back(id);
        out << "\t%" << id << " = alloca i32" << std::endl;
    }

    out << "\tstore i32 " << rvalue << ", i32* %" << id << std::endl;

}
void IR_Generator::gen_READ_llvm_ir(Node* node) {
    std::string ids_string = "";
    std::string d_string = "";
    for (auto &child : node->children) {
        std::string id = child->lexeme;
        auto it = std::find(ID_table.begin(), ID_table.end(), id);
        if (it == ID_table.end()) {
            ID_table.push_back(id);
            out << "\t%" << id << " = alloca i32" << std::endl;
        }
        ids_string += (", i32* %" + id);
        d_string += "%d ";
    }
    int i8 = d_string.length();
    d_string = std::string(d_string.begin(), d_string.end() - 1);
    std::string i8_s = std::to_string(i8) + " x i8";

    out << "\t%_scanf_format_1 = alloca [" << i8_s << "]" << std::endl;
    out << "\tstore [" << i8_s << "] c\"" << d_string << "\\00\", [" << i8_s << "]* %_scanf_format_1" << std::endl;
    out << "\t%_scanf_str_1 = getelementptr [" << i8_s << "], [" << i8_s << "]* %_scanf_format_1, i32 0, i32 0" << std::endl;
    out << "\tcall i32 (i8*, ...) @scanf(i8* %_scanf_str_1" << ids_string << ")" << std::endl;


}
void IR_Generator::gen_WRITE_llvm_ir(Node* node) {
    int child_num = node->children.size();
    int aloc_num = 3 * child_num + 1;
    std::string d_string;
    for (int i=0; i<child_num; i++) {
        d_string += "%d ";
    }
    d_string = std::string(d_string.begin(), d_string.end()-1);
    out << "\t%_printf_format_1 = alloca [" << aloc_num << " x i8]" << std::endl;
    out << "\tstore [" << aloc_num << "x i8] c\"" << d_string << "\\0A\\00\", [" << aloc_num << " x i8]* %_printf_format_1" << std::endl;
    out << "\t%_printf_str_1 = getelementptr [" << aloc_num << " x i8], [" << aloc_num << " x i8]* %_printf_format_1, i32 0, i32 0" << std::endl;
    std::string argument_list = "";
    for (auto& child : node->children) {
        argument_list += "i32 ";
        argument_list += get_expression_value(child);
        argument_list += ", ";
    }
    argument_list = std::string(argument_list.begin(), argument_list.end()-2);
    out << "\tcall i32 (i8*, ...) @printf(i8* %_printf_str_1, " << argument_list << ")" << std::endl;
}
std::string IR_Generator::get_expression_value(Node* node) {
    std::string value;      // for return
    std::string lvalue;     // for PLUSOP and MINUSOP
    std::string rvalue;
    Node* lexpression;
    Node* rexpression;
    std::string id;         // for ID
    switch (node->symbol_class)
    {
    case SymbolClass::ID:
        id = node->lexeme;
        value = "%_tmp_" + std::to_string(tmp_counter);
        out << "\t%_tmp_" << tmp_counter << " = load i32, i32* %" << id << std::endl;
        tmp_counter++;
        return value;
        break;
    case SymbolClass::INTLITERAL:
        value = node->lexeme;
        return value;
        break;
    case SymbolClass::PLUSOP:
        lexpression = node->children[0];
        rexpression = node->children[1];
        lvalue = get_expression_value(lexpression);
        rvalue = get_expression_value(rexpression);
        out << "\t%_tmp_" << tmp_counter << " = add i32 " << lvalue << ", " << rvalue << std::endl;
        value = "%_tmp_" + std::to_string(tmp_counter);
        tmp_counter++;
        return value;
        break;
    case SymbolClass::MINUSOP:
        lexpression = node->children[0];
        rexpression = node->children[1];
        lvalue = get_expression_value(lexpression);
        rvalue = get_expression_value(rexpression);
        out << "\t%_tmp_" << tmp_counter << " = sub i32 " << lvalue << ", " << rvalue << std::endl;
        value = "%_tmp_" + std::to_string(tmp_counter);
        tmp_counter++;
        return value;
        break;
    
    default:
        return "expression value";
        break;
    }
}
