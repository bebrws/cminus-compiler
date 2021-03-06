%option noyywrap
%{
/*****************声明和选项设置  begin*****************/
#include <stdio.h>
#include <stdlib.h>

#include "lab1_lexical_analyzer/lexical_analyzer.h"
#include "common/common.h"

#include "syntax_tree/SyntaxTree.h"
#ifndef LAB1_ONLY
#include "syntax_analyzer.h"
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
   yylloc.first_column = yycolumn; \
   yylloc.last_column = yycolumn + yyleng; \
   yycolumn += yyleng;
#endif

int yycolumn = 1;
int files_count;
int lines = 1;
int pos_start;
int pos_end;

/*****************声明和选项设置  end*****************/

%}

commentPattern "/*"([^\*]|(\*)*[^\*/])*(\*)*"*/"
digitPattern [0-9]
numberPattern (0|[1-9]{digitPattern}*)
identifierPattern [a-zA-Z][a-zA-Z]*

%%

 /******************TODO*********************/
 /****请在此补全所有flex的模式与动作  start******/


	
{numberPattern}		{ 
	#ifndef LAB1_ONLY
	yylval.val = yytext;
	#endif
	return NUMBER;
}
{commentPattern} {
				#ifdef LAB1_ONLY
				return COMMENT;
				#endif
}
int				{ return INT;}
if			 	{ return IF;}
void			{ return VOID;}
while			{ return WHILE;}
return			{ return RETURN;}
else			{ return ELSE;}
[\t]			{ 
				#ifdef LAB1_ONLY
				return BLANK;
				#endif
}
"{"				{ return LBRACE;}
"}"				{ return RBRACE;}
"("				{ return LPARENTHESE;}
")"				{ return RPARENTHESE;}
"["				{ return LBRACKET;}
"]"				{ return RBRACKET;}
"+"				{ return ADD;}
"-"				{ return SUB;}
"*"				{ return MUL;}
"/"				{ return DIV;}
">="			{ return GTE;}
"<="			{ return LTE;}
"=="			{ return EQ;}
">"				{ return GT;}
"<"				{ return LT;}
","				{ return COMMA;}
" "				{
				#ifdef LAB1_ONLY
				return BLANK;
				#endif
}
\n				{yycolumn = 1;
				lines++;
				#ifdef LAB1_ONLY
				pos_end = 1;
				pos_start = 1;
				#endif
}
";"				{ return SEMICOLON;}
"!="			{ return NEQ;}
"="				{ return ASSIN;}
\[\]			{ return ARRAY;}
{identifierPattern} 	{ 
	#ifndef LAB1_ONLY
	strcpy(yylval.name, yytext);
	#endif
	return IDENTIFIER;
	} 

. 				{return ERROR;}



 /****请在此补全所有flex的模式与动作  end******/
%%
/****************C代码 start*************/

/// \brief analysize a *.cminus file
///
///	\param input_file_name
/// \param output_file_name
void analyzer(char* input_file_name, char* output_file_name){
	lines = 1;
	pos_start = 1;
	pos_end = 1;
	char input_path[256] = "./testcase/";
	strcat(input_path, input_file_name);
	char output_path[256] = "./tokens/";
	strcat(output_path, output_file_name);
	if(!(yyin = fopen(input_path,"r"))){
		printf("[ERR] No input file\n");
		exit(1);
	}
	printf("[START]: Read from: %s\n", input_file_name);
	FILE *fp = fopen(output_path,"w+");

	int token;
	while(token = yylex()){
		pos_start = pos_end;
		pos_end += strlen(yytext);
		switch(token){
			case ERROR:
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				break;
			case COMMENT:
			case BLANK:
				break;
			case EOL:
				pos_start = 1,pos_end = 1;
				break;
			case NUMBER:
				fprintf(fp, "%d\t%d\t%d\t%d\t%d\n",atoi(yytext), token, lines, pos_start, pos_end);
				break;
			default :
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n",yytext, token, lines, pos_start, pos_end);
		}
	}
	fclose(fp);
	printf("[END]: Analysis completed.\n");
}

/// \brief process all *.cminus file
///
/// note that: use relative path for all i/o operations
int lex_main(int argc, char **argv){
	char filename[50][256];
	char output_file_name[256];
	char suffix[] = ".tokens";
	files_count = getAllTestcase(filename);
	for(int i = 0; i < files_count; i++){
			int name_len = strstr(filename[i], ".cminus")-filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);
			analyzer(filename[i],output_file_name);
	}
	return 0;
}
/****************C代码 end*************/
