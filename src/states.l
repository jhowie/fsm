/*
** Copyright: (c) John Howie (jfc@cs.napier.ac.uk)
*/

%{
# if FATFS
# include "ytab.h"
# else
# include "y.tab.h"
# endif

int lineno =1;
extern int yydebug;

# define Token(_X)      if (yydebug) printf ("lex: returning %s\n", yytext); return _X

char *mkstr ();
extern void error ();
%}

ws      [ \t]

%%

"#"[ \t\"\'\\\[\]\^\-\?\.\*\+\|\(\)\$\/\{\}\%\<\>_,!A-Za-z0-9&=;:]* { }
"define"                { Token (DEFINE); }
"predicates"            { Token (PREDS); }
"events"                { Token (EVENTS); }
"actions"               { Token (ACTIONS); }
"states"                { Token (STATES); }
"statevarname"          { Token (SNAME); }
"initialstate"          { Token (ISTATE); }
"endstate"[s]*          { Token (ESTATE); }
"table"                 { Token (TABLE); }
"notes"                 { Token (NOTES); }
"state"                 { Token (STATE); }
"event"                 { Token (EVENT); }
"begin"                 { Token (BEGN); }       /* BEGIN conflicts with lex */
"end"                   { Token (END); }

"not"           { Token (NOT); }
"NOT"           { Token (NOT); }
"^"             { Token (NOT); }
"and"           { Token (AND); }
"AND"           { Token (AND); }
"&"             { Token (AND); }
"or"            { Token (OR); }
"OR"            { Token (OR); }
"|"             { Token (OR); }

"["[0-9]+"]"                    { yylval.str = mkstr (yytext); Token (ACTION); }
[Pp][0-9]+                      { yylval.str = mkstr (yytext); Token (PRED); }
[A-Za-z][A-Za-z\.\-_0-9]*       { yylval.str = mkstr (yytext); Token (CES); }
"("[0-9]+")"                    { yylval.str = mkstr (yytext); Token (NOTE); }
"/*"[ \t\"\'\\\[\]\^\-\?\.\*\+\|\(\)\$\/\{\}\%\<\>_,=A-Za-z0-9&;:]*"*/"	{ yylval.str = mkstr (yytext); Token (COMMENT); }
\"[ \t\'\\\[\]\^\-\?\.\*\+\|\(\)\$\/\{\}\%\<\>_,=A-Za-z0-9&;:]*\"               { yylval.str = mkstr (yytext); Token (COMMENT); }
"//"[ \t\"\'\\\[\]\^\-\?\.\*\+\|\(\)\$\/\{\}\%\<\>_,=A-Za-z0-9&;:]*		{ yylval.str = mkstr (yytext); Token (COMMENT); }

{ws}                    { }
\f                      { }
\n                      { fprintf (stderr, "%05d\b\b\b\b\b", lineno ++); }
.                       { Token (yytext [0]); }

%%
char *mkstr (s)
char *s;
{
	char *str;

	str = (char *) malloc (strlen (s) +1);
	if (str == (char *) NULL)
		error ("malloc failed\n");

	strcpy (str, s);

	return str;
}
