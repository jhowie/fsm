/* File: states.h
**
** Author: jfc, 29/12/91
**
** Copyright: (c) John Howie (jfc@cs.napier.ac.uk)
**
** Description
**
**      This file contains definitions and declarations used in the state
** processing suite of software.
**
** Modifications
**
** 22/01/92 jfc Added field to the predicate structure for the state animator
**              (san).
**
** 08/01/93 jfc Added refcount field to structures for definitions. Mainly for
**              use by the state validator. Validator also uses field added for
**              the animator in predicate definition structures.
*/

/* Declare some commonly used structures... */

struct catstruct        { char *name;
			  int id;
			};

struct evstruct         { char *name;
			  unsigned long refcount;
			  int id;
			  char *cat;
			  char *comment;
			};

struct stastruct        { char *name;
			  unsigned long refcount;
			  int id;
			  char *comment;
			};

struct predstruct       { char *name;
			  unsigned long refcount;
			  int id;
			  char *comment;
			  char value;           /* TRUE or FALSE */
			};

struct actstruct        { char *name;
			  unsigned long refcount;
			  int id;
			  char *comment;
			};

struct svar             { char *name;
			  struct stastruct *initialstate;
			  struct enode *endstates;
			};

struct table            { char *name;
			  struct svar *statename;
			  struct stastruct *currentstate;
			  LIST tablenotes;
			  LIST tablestates;
			};

struct tablenote        { char *name;
			  char *comment;
			};

struct tablestate       { struct stastruct *state;
			  LIST stateevents;
			};

struct stateevent       { struct evstruct *event;
			  int type;
			  union { struct cnode *c;
				  struct anode *a;
				} ptr;
			};

struct anode            { int type;
			  union { struct evstruct *e;
				  struct stastruct *s;
				  struct actstruct *a;
				  struct tablenote *n;
				} ptr;
			  struct anode *next;
			};

struct pnode            { int type;
			  struct predstruct *p;
			  struct pnode *l, *r;
			};

struct cnode            { struct pnode *p;
			  struct anode *a;
			  struct cnode *next;
			};

struct enode            { struct stastruct *s;
			  struct enode *next;
			};

/* The following are used in reporting problems to the user */

_PROTOTYPE( void fatal, (char *fmt, ...));
_PROTOTYPE( void error, (char *fmt, ...));
_PROTOTYPE( void warning, (char *fmt, ...));

/* The next set of functions are used to add things to lists */
_PROTOTYPE( void add_category, (char *cat));
_PROTOTYPE( void add_event, (char *ev, char *cat, char *comment));
_PROTOTYPE( void add_state, (char *state, char *comment));
_PROTOTYPE( void add_predicate, (char *pred, char *comment));

_PROTOTYPE( void add_action, (char *act, char *comment));
_PROTOTYPE( void add_svar, (char *svar, char *state, struct enode *endstates));
_PROTOTYPE( struct enode *add_enode, (char *s, struct enode *next));

/* The functions following are used when building the parse tree */
_PROTOTYPE( void begin_table, (char *tablename));
_PROTOTYPE( void end_table, (void));
_PROTOTYPE( void add_note, (char *note, char *comment));
_PROTOTYPE( void begin_state, (char *state));
_PROTOTYPE( void begin_event, (char *event));
_PROTOTYPE( void add_to_event, (int type, void *ptr));
_PROTOTYPE( struct cnode *evpredact, (struct pnode *p, struct anode *a, struct cnode *next));
_PROTOTYPE( struct anode *add_anode, (int type, char *item, struct anode *next));
_PROTOTYPE( struct pnode *add_pnode, (int type, char *item, struct pnode *l, struct pnode *r));
