/*
** Copyright: (c) John Howie (jfc@cs.napier.ac.uk)
*/

%{
# define YYDEBUG        1

# include "stdinclude.h"

# include "list.h"
# include "states.h"

extern int lineno;
int yylex (void);
int yyerror (char *s);
%}

%union {
	char *str;
	char oper;
	struct enode *enode;
	struct pnode *pnode;
	struct anode *anode;
	struct cnode *cnode;
}

%token  DEFINE
%token  PREDS ACTIONS EVENTS STATES CATS TABLE
%token  SNAME ISTATE ESTATE
%token  NOTES STATE EVENT
%token  BEGN END
%token  <oper>  NOT AND OR
%token  <str>   ACTION PRED NOTE CES COMMENT

%left   OR
%left   AND
%left   NOT

%type   <pnode> predlist
%type   <anode> actionlist
%type   <cnode> cond
%type   <enode> endstate

%%

fsm     : /* No declarations or tables */
	| decls fsm
	| table fsm
	;

decls   : /* No declarations... */
/*
	| decls cats
*/
	| decls events
	| decls preds
	| decls actions
	| decls states
	| decls svar
	;

/*
cats    : DEFINE CATS
	  BEGN
	  catdecls
	  END
	;
*/

/*
catdecls        : /* No categories */
/*              | catdecls cat
		| cat
		;

cat     : CES           { add_category ($1); }
	;
*/

events  : DEFINE EVENTS
	  BEGN
	  evdecls
	  END
	;

evdecls : /* No events */
	| evdecls ev
	| ev
	;

/*
ev      : CES CES COMMENT       { add_event ($1, $2, $3); }
	| CES CES               { add_event ($1, $2, (char *) 0); }
	;
*/

ev      : CES CES COMMENT       { add_category ($2); add_event ($1, $2, $3); }
	| CES CES               { add_category ($2); add_event ($1, $2, (char *) 0); }
	;

actions : DEFINE ACTIONS
	  BEGN
	  actdecls
	  END
	;

actdecls        : /* No actions */
		| actdecls act
		| act
		;

act     : ACTION COMMENT        { add_action ($1, $2); }
	| ACTION                { add_action ($1, (char *) 0); }
	;

preds   : DEFINE PREDS
	  BEGN
	  preddecls
	  END
	;

preddecls       : /* No predicates */
		| preddecls pred
		| pred
		;

pred    : PRED COMMENT          { add_predicate ($1, $2); }
	| PRED                  { add_predicate ($1, (char *) 0); }
	;

states  : DEFINE STATES
	  BEGN
	  stadecls
	  END
	;

stadecls        : /* No states */
		| stadecls sta
		| sta
		;

sta     : CES COMMENT           { add_state ($1, $2); }
	| CES                   { add_state ($1, (char *) 0); }
	;

svar    : DEFINE SNAME CES ISTATE CES                   { add_svar ($3, $5, 0); }
	| DEFINE SNAME CES ISTATE CES ESTATE endstate   { add_svar ($3, $5, $7); }
	;

table   : TABLE CES BEGN                { begin_table ($2); }
	  tablebody
	  END                           { end_table (); }
	;

endstate        : /* No end state defined */    { $$ = add_enode (0, 0); }
		| CES endstate                  { $$ = add_enode ($1, $2); }
		;

tablebody       : /* Nothing in table... */
		| tablebody tablenotes
		| tablebody tablestates
		;

tablenotes      : NOTES
		  notesbody
		;

notesbody       : /* No notes */
		| notesbody tablenote
		| tablenote
		;

tablenote       : NOTE COMMENT                  { add_note ($1, $2); }
		;

tablestates     : STATE CES                     { begin_state ($2); }
		  statesbody
		;

statesbody      : /* No events in state... */
		| statesbody stateevent
		| stateevent
		;

stateevent      : EVENT CES             { begin_event ($2); }
		  eventbody
		;

eventbody       : cond                  { add_to_event (PRED, $1); }
		| actionlist            { add_to_event (ACTION, $1); }
		;

cond            : predlist ':' actionlist ';' cond      { $$ = evpredact ($1, $3, $5); }
		| predlist ':' actionlist               { $$ = evpredact ($1, $3, (char *) 0); }
		;

actionlist      : /* No more actions */ { $$ = add_anode (0, 0, 0); }
		| ACTION actionlist     { $$ = add_anode (ACTION, $1, $2); }
		| CES actionlist        { $$ = add_anode (CES, $1, $2); }
		| NOTE actionlist       { $$ = add_anode (NOTE, $1, $2); }
		;

predlist        : '(' predlist ')'      { $$ = $2; }
		| predlist AND predlist { $$ = add_pnode (AND, 0, $1, $3); }
		| predlist OR predlist  { $$ = add_pnode (OR, 0, $1, $3); }
		| NOT predlist          { $$ = add_pnode (NOT, 0, 0, $2); }
		| PRED                  { $$ = add_pnode (PRED, $1, 0, 0); }
		;

%%
int yyerror (char *s)
{
	fatal (s);
	return 0;
}
