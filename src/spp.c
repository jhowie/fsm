/* File: spp.c
**
** Author: jfc, 29/12/91
**
** Copyright: (c) John Howie (jfc@cs.napier.ac.uk)
**
** Description
**
**      This file contains the routines that perform the spp functions. Note
** that we call yyparse here...
**
** Modification History
**
** 05/08/93 jfc	ANSI'fied code in readiness for port to NT.
*/

# include <stdio.h>
# include <time.h>
# include <unistd.h>
# include <stdlib.h>
# include <string.h>

# include "stdinclude.h"

# include "list.h"
# include "states.h"
# include "y.tab.h"

_PROTOTYPE( void do_it, (int argc, char *argv []));
_PROTOTYPE( void spp, (void));
_PROTOTYPE( static void write_pa, (FILE *fp, char *svar, struct stateevent *se));
_PROTOTYPE( static void write_actions, (FILE *fp, char *svar, struct anode *ap, int indent));
_PROTOTYPE( static void write_conditions, (FILE *fp, char *svar, struct cnode *cp));
_PROTOTYPE( static void write_predicates, (FILE *fp, struct pnode *preds));

_PROTOTYPE( int yyparse, (void));

extern int yydebug;
extern FILE *yyin;
extern int lineno;
extern LIST categories, events, states, predicates, actions, svars, tables;
extern int num_categories, num_events, num_states, num_predicates,
	   num_actions, num_tables, num_warnings, num_errors;

static int no_functions = 0;

# if FATFS
static char *output = "stateout";
# else
static char *output = "states_out";
# endif

static char *ifile = "<stdin>";

static int num_h = 0, num_c = 0;

void do_it (int argc, char *argv [])
{
	int errs = 0, c;
	extern int optind;
	extern char *optarg;

	yydebug = 0;
	while ((c = getopt (argc, argv, "fo:v")) != EOF) {
		switch (c) {
			case 'f': no_functions = 1;     break;
			case 'o': output = optarg;      break;
			case 'v': yydebug = 1;          break;

			default:        errs ++;        break;
		}
	}

	if (errs) {
		fprintf (stderr, "Usage: %s [-f] [-o output] [-v] [input]\n",
			argv [0]);
		exit (1);
	}

	if (optind < argc) {
		ifile = argv [optind];
		if ((yyin = fopen (ifile, "r")) == NULL) {
			fprintf (stderr, "Can't open file %s\n", ifile);
			exit (1);
		}
	}

	newlist (&categories);
	newlist (&events);
	newlist (&states);
	newlist (&predicates);
	newlist (&actions);
	newlist (&svars);
	newlist (&tables);

	yyparse ();
	spp ();

	/*
	 * Print out some statistics about what we have done...
	 */

	printf ("     \n");
	printf ("Number of lines read: %05d\n", (lineno -1));
	printf ("Number of warnings: %05d\tNumber of errors: %05d\n",
		num_warnings, num_errors);
	printf ("Number of header lines: %05d\tNumber of source lines: %05d\n",
		num_h, num_c);
	printf ("Num Categories: %03d\tNum Events: %03d\t\tNum States: %03d\n",
		num_categories, num_events, num_states);
	printf ("Num Predicates: %03d\tNum Actions: %03d\tNum Tables: %03d\n",
		num_predicates, num_actions, num_tables);

	(void) fclose (yyin);
}

void spp (void)
{
	FILE *fp;
	char buffer [128 +1], *cptr;

	time_t timeval;

	struct catstruct *cp;
	struct evstruct *ep;
	struct stastruct *sp;
	struct predstruct *pp;
	struct actstruct *ap;
	struct svar *vp;
	struct table *tp;
	struct tablestate *tsp;
	struct stateevent *sep;

	LIST *ts, *se;

	/*
	 * This function has to create the .c and .h files that are derived
	 * from the state description file...
	 */

	/*
	 * Create the output header file first, it is easier...
	 */

	sprintf (buffer, "%s.h", output);
	if ((fp = fopen (buffer, "w")) == NULL) {
		fprintf (stderr, "Can't create header file %s\n", buffer);
		exit (1);
	}

	/*
	 * Write out the file header....
	 */

	(void) time (&timeval);

	fprintf (fp, "/*\n * %s from %s on %s */\n\n",
			buffer, ifile, ctime (&timeval));
	num_h += 4;

	/*
	 * Go through all the categories, writing out info to the file...
	 */

	fprintf (fp, "/* Categories */\n"); num_h ++;
	front (&categories);
	while (active (&categories)) {
		cp = (struct catstruct *) return_value (&categories);

		fprintf (fp, "# define %s\t\t%d\n", cp -> name, cp -> id);
		num_h ++;
		get_next_member (&categories);
	}
	fprintf (fp, "\n\n"); num_h += 2;

	/*
	 * Go through all the events, writing out info to the file...
	 */

	fprintf (fp, "/* Events */\n"); num_h ++;
	front (&events);
	while (active (&events)) {
		ep = (struct evstruct *) return_value (&events);

		fprintf (fp, "# define %s\t\t%d", ep -> name, ep -> id);

		if (ep -> comment) {
			if (ep -> comment [0] == '"')
				fprintf (fp, "\t/* %s */", ep -> comment);
			else    fprintf (fp, "\t%s", ep -> comment);
		}

		fprintf (fp, "\n");
		num_h ++;

		get_next_member (&events);
	}
	fprintf (fp, "\n\n"); num_h += 2;

	/*
	 * Go through all the states, writing out info to the file...
	 */

	fprintf (fp, "/* States */\n"); num_h ++;
	front (&states);
	while (active (&states)) {
		sp = (struct stastruct *) return_value (&states);

		fprintf (fp, "# define %s\t\t%d", sp -> name, sp -> id);

		if (sp -> comment) {
			if (sp -> comment [0] == '"')
				fprintf (fp, "\t/* %s */", sp -> comment);
			else    fprintf (fp, "\t%s", sp -> comment);
		}

		fprintf (fp, "\n");
		num_h ++;

		get_next_member (&states);
	}
	fprintf (fp, "\n\n"); num_h += 2;

	/*
	 * Go through all the predicates, writing out function decls...
	 */

	fprintf (fp, "/* Predicate function declarations */\n"); num_h ++;
	front (&predicates);
	while (active (&predicates)) {
		pp = (struct predstruct *) return_value (&predicates);

		fprintf (fp, "extern int %s ();", pp -> name);

		if (pp -> comment) {
			if (pp -> comment [0] == '"')
				fprintf (fp, "\t\t/* %s */", pp -> comment);
			else    fprintf (fp, "\t\t%s", pp -> comment);
		}

		fprintf (fp, "\n");
		num_h ++;

		get_next_member (&predicates);
	}
	fprintf (fp, "\n\n"); num_h += 2;

	/*
	 * Go through all the actions, writing out action decls...
	 */

	fprintf (fp, "/* Action function declarations */\n"); num_h ++;
	front (&actions);
	while (active (&actions)) {
		ap = (struct actstruct *) return_value (&actions);

		strcpy (buffer, &(ap -> name [1]));
		cptr = (char *) INDEX (buffer, ']');
		*cptr = (char) 0;
		fprintf (fp, "extern void action%s ();", buffer);

		if (ap -> comment) {
			if (ap -> comment [0] == '"')
				fprintf (fp, "\t\t/* %s */", ap -> comment);
			else    fprintf (fp, "\t\t%s", ap -> comment);
		}

		fprintf (fp, "\n");
		num_h ++;

		get_next_member (&actions);
	}
	fprintf (fp, "\n\n"); num_h += 2;

	/*
	 * Go through all the tables writing out their function prototypes
	 */

	fprintf (fp, "/* Table function declarations */\n"); num_h ++;
	front (&tables);
	while (active (&tables)) {
		tp = (struct table *) return_value (&tables);

		fprintf (fp, "extern void %s ();\n", tp -> name); num_h ++;
		get_next_member (&tables);
	}
	fprintf (fp, "\n\n"); num_h += 2;

	/*
	 * Write out the standard function declarations...
	 */

	fprintf (fp, "/* Standard function declarations */\n");
	fprintf (fp, "extern void badstate ();\nextern void badevent ();\n\n");
	num_h += 4;

	/*
	 * End of header file... 
	 */

	fclose (fp);

	/*
	 * Now create the output source file...
	 */

	sprintf (buffer, "%s.c", output);
	if ((fp = fopen (buffer, "w")) == NULL) {
		fprintf (stderr, "Can't create source file %s\n", buffer);
		exit (1);
	}

	/*
	 * Write out the file header....
	 */

	fprintf (fp, "/*\n * %s from %s on %s */\n\n# include \"%s.h\"\n\n",
			buffer, ifile, ctime (&timeval), output);
	num_c += 6;

	/*
	 * If the user wants functions write out the prototypes here...
	 */

	if (! no_functions) {
		fprintf (fp, "/* Function prototypes */\n\n"); num_c += 2;
		front (&predicates);
		while (active (&predicates)) {
			pp = (struct predstruct *) return_value (&predicates);

			fprintf (fp, "int %s ();\n", pp -> name); num_c ++;

			get_next_member (&predicates);
		}

		front (&actions);
		while (active (&actions)) {
			ap = (struct actstruct *) return_value (&actions);

			strcpy (buffer, &(ap -> name [1]));
			cptr = (char *) INDEX (buffer, ']');
			*cptr = (char) 0;
			fprintf (fp, "void action%s ();\n", buffer); num_c ++;

			get_next_member (&actions);
		}

		fprintf (fp, "void badevent ();\n"); num_c ++;
		fprintf (fp, "void badstate ();\n"); num_c ++;
		fprintf (fp, "\n\n"); num_c += 2;
	}

	/*
	 * Write out all the state variable names....
	 */

	fprintf (fp, "/* State variables */\n"); num_c ++;
	front (&svars);
	while (active (&svars)) {
		vp = (struct svar *) return_value (&svars);

		fprintf (fp, "int %s = %s;\n", vp -> name, vp -> initialstate -> name);
		num_c ++;

		get_next_member (&svars);
	}
	fprintf (fp, "\n\n"); num_c +=2;

	/*
	 * Go through all the tables in the table list...
	 */

	front (&tables);
	while (active (&tables)) {
		tp = (struct table *) return_value (&tables);

		fprintf (fp,
			"void %s (event)\nint event;\n{\n\tswitch (%s) {\n",
			tp -> name, tp -> statename -> name);
		num_c += 4;

		/*
		 * Go through all the states in the table....
		 */

		ts = &(tp -> tablestates);
		front (ts);
		while (active (ts)) {
			tsp = (struct tablestate *) return_value (ts);

			fprintf (fp, "\t\tcase %s:\n\t\t\tswitch (event) {\n",
				tsp -> state -> name);
			num_c += 2;

			/*
			 * Go through all the events for this state...
			 */

			se = &(tsp -> stateevents);
			front (se);
			while (active (se)) {
				sep = (struct stateevent *) return_value (se);

				fprintf (fp, "\t\t\t\tcase %s:\n", sep -> event -> name);
				num_c ++;

				/*
				 * Write out the predicate and/or action list
				 * for this state event combination...
				 */

				write_pa (fp, tp -> statename -> name, sep);

				fprintf (fp, "\t\t\t\t\tbreak;\n\n");
				num_c += 2;

				get_next_member (se);
			}

			fprintf (fp, "\n\t\t\t\tdefault: badevent (event); break;\n\t\t\t}\n\t\t\tbreak;\n\n");
			num_c += 5;

			get_next_member (ts);
		}

		fprintf (fp,
			"\n\t\tdefault: badstate (%s); break;\n\t}\n}\n\n",
			tp -> statename -> name);
		num_c += 5;

		get_next_member (&tables);
	}

	/*
	 * Write out all the predicate and action functions (if the user wants
	 * them) ...
	 */

	if (! no_functions) {
		/*
		 * Write out the predicate functions first...
		 */

		fprintf (fp, "/* Predicate functions.. */\n\n"); num_c += 2;
		front (&predicates);
		while (active (&predicates)) {
			pp = (struct predstruct *) return_value (&predicates);

			fprintf (fp, "int %s ()\n{\n\t", pp -> name);

			if (pp -> comment) {
				if (pp -> comment [0] == '"')
					fprintf (fp, "/* %s */", pp -> comment);
				else    fprintf (fp, "%s", pp -> comment);
			}

			fprintf (fp, "\n}\n\n");

			num_c += 5;

			get_next_member (&predicates);
		}

		/*
		 * Now write out the action functions...
		 */

		fprintf (fp, "/* Action functions... */\n\n"); num_c += 2;
		front (&actions);
		while (active (&actions)) {
			ap = (struct actstruct *) return_value (&actions);

			strcpy (buffer, &(ap -> name [1]));
			cptr = (char *) INDEX (buffer, ']');
			*cptr = (char) 0;
			fprintf (fp, "void action%s ()\n{\n\t", buffer);

			if (ap -> comment) {
				if (ap -> comment [0] == '"')
					fprintf (fp, "/* %s */", ap -> comment);
				else    fprintf (fp, "%s", ap -> comment);
			}

			fprintf (fp, "\n}\n\n");

			num_c += 5;

			get_next_member (&actions);
		}

		fprintf (fp, "/* Standard functions... */\n\n"); num_c += 2;
		fprintf (fp, "void badevent ()\n{\n\t/* Bad event received... */\n}\n\n");
		num_c += 5;
		fprintf (fp, "void badstate ()\n{\n\t/* Bad state received... */\n}\n\n");
		num_c += 5;
	}

	/*
	 * Close the source file...
	 */

	fclose (fp);
}

static void write_pa (FILE *fp, char *svar, struct stateevent *se)
{
	struct cnode *predact;
	struct pnode *preds;
	struct anode *acts;

	/*
	 * This function takes a pointer to a struct of type stateevent and
	 * writes out the predicate and/or actionlist associated with it.
	 */

	switch (se -> type) {
		case ACTION:
			write_actions (fp, svar, se -> ptr.a, 0);
			break;

		case PRED:
			write_conditions (fp, svar, se -> ptr.c);
			break;
	}
}

static void write_actions (FILE *fp, char *svar, struct anode *ap, int indent)
{
	struct anode *acts;
	char *cptr, buf [20 +1];
	int count;

	/*
	 * This function writes out actionlists....
	 */

	for (acts = ap; acts; acts = acts -> next) {
		for (count = 0; count < indent; count ++)
			fprintf (fp, "\t");

		switch (acts -> type) {
			case EVENT:
				fprintf (fp, "\t\t\t\t\teventout (%s);\n",
					acts -> ptr.e -> name);
				num_c ++;
				break;

			case STATE:
				fprintf (fp, "\t\t\t\t\t%s = %s;\n",
					svar, acts -> ptr.s -> name);
				num_c ++;
				break;

			case ACTION:
				strcpy (buf, &(acts -> ptr.a -> name [1]));
				cptr = (char *) INDEX (buf, ']');
				*cptr = (char) 0;
				fprintf (fp, "\t\t\t\t\taction%s ();\n", buf);
				num_c ++;
				break;

			case NOTE:
				fprintf (fp, "\t\t\t\t\t");
				if (acts -> ptr.n -> comment [0] == '"') {
					fprintf (fp, "/* %s */\n",
					acts -> ptr.n -> comment);
				}
				else {
					fprintf (fp, "%s\n",
					acts -> ptr.n -> comment);
				}
				num_c ++;
				break;
		}
	}
}

static void write_conditions (FILE *fp, char *svar, struct cnode *cp)
{
	struct cnode *conds;
	int elseclause = 0;

	/*
	 * For every condition write out the predicate list and then write
	 * out the action list.
	 */

	for (conds = cp; conds; conds = conds -> next) {
		if (elseclause)
			fprintf (fp, "\t\t\t\t\telse if ( ");
		else {
			fprintf (fp, "\t\t\t\t\tif ( ");
			elseclause = 1;
		}

		write_predicates (fp, conds -> p);
		fprintf (fp, " ) {\n"); num_c ++;
		write_actions (fp, svar, conds -> a, 1);
		fprintf (fp, "\t\t\t\t\t}\n"); num_c ++;
	}
}

static void write_predicates (FILE *fp, struct pnode *preds)
{
	/*
	 * Note: This is a recursive function. On very large predicate lists
	 * there could be stack size problems...
	 */

	if (preds -> type != PRED)
		fprintf (fp, "(");

	if (preds -> l)
		write_predicates (fp, preds -> l);
	switch (preds -> type) {
		case PRED:      fprintf (fp, "%s ()", preds -> p -> name); break;
		case AND:       fprintf (fp, " && "); break;
		case OR:        fprintf (fp, " || "); break;
		case NOT:       fprintf (fp, "! "); break;
	}
	if (preds -> r)
		write_predicates (fp, preds -> r);

	if (preds -> type != PRED)
		fprintf (fp, ")");
}
