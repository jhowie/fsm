/* File: schk.c
**
** Author: jfc, 08/01/93
**
** Copyright: (c) John Howie (jfc@cs.napier.ac.uk)
**
** Description
**
**      This file contains the state validator. Like spp and san the yyparse ()
** function is called from here.
**
** Modification History
**
** 05/08/93 jfc	ANSI'fied source code in preparation for port to NT.
*/

# include <stdio.h>
# include <string.h>
# include <unistd.h>
# include <stdlib.h>
# include <ctype.h>

double pow2 (double x);

double pow2 (double x)
{
	double p = 2;

	if (x == 0)
		return 1;

	while (-- x)
		p*= 2;
	return p;
}

# include <time.h>

# include "stdinclude.h"

# include "list.h"
# include "graph.h"
# include "states.h"

# include "y.tab.h"

_PROTOTYPE( void do_it, (int argc, char *argv []));
_PROTOTYPE( void schk, (void));
_PROTOTYPE( void check_table, (struct table *tp));
_PROTOTYPE( void check_state, (struct tablestate *ts));
_PROTOTYPE( void check_event, (struct stateevent *se));
_PROTOTYPE( void check_actions, (struct anode *ap));
_PROTOTYPE( void check_expr, (struct cnode *cp));
_PROTOTYPE( void builduppredlist, (LIST *predlist, struct pnode *pp));
_PROTOTYPE( void check_for_unused_definitions, (void));
_PROTOTYPE( int eval, (struct pnode *p));
_PROTOTYPE( void display_predicates, (struct pnode *p));

_PROTOTYPE( int yyparse, (void));

extern int yydebug;
extern FILE *yyin;
extern int lineno;
extern LIST categories, events, states, predicates, actions, svars, tables;
extern int num_categories, num_events, num_states, num_predicates,
	   num_actions, num_tables, num_warnings, num_errors;

static char *ifile = "<stdin>";
static char *output = (char *) NULL;
static FILE *ofp;
static char *curr_table, *curr_state, *curr_event;
static LIST stateschangedto;
static GRAPH statechanges;

struct statechange      { char *fstate;
			  char *event;
			  char *tstate;
			};

struct predptr  { struct predstruct *pred;
		};

void do_it (int argc, char *argv [])
{
	int errs = 0, c, ignore_errors;
	extern int optind;
	extern char *optarg;

	ignore_errors = 0;
	yydebug = 0;
	while ((c = getopt (argc, argv, "io:v")) != EOF) {
		switch (c) {
			case 'i': ignore_errors = 1;    break;
			case 'o': output = optarg;      break;
			case 'v': yydebug = 1;          break;

			default:        errs ++;        break;
		}
	}

	if (optind < argc) {
		ifile = argv [optind];
		if ((yyin = fopen (ifile, "r")) == NULL) {
			fprintf (stderr, "Can't open file %s\n", ifile);
			exit (1);
		}
	}
	else    errs ++;

	if (errs) {
		fprintf (stderr, "Usage: %s [-i] [-o output] [-v] input\n",
			argv [0]);
		exit (1);
	}

	newlist (&categories);
	newlist (&events);
	newlist (&states);
	newlist (&predicates);
	newlist (&actions);
	newlist (&svars);
	newlist (&tables);

	yyparse ();

	/*
	 * Print out some statistics about what we have done...
	 */

	printf ("     \n");
	printf ("Number of lines read: %05d\n", (lineno -1));
	printf ("Number of warnings: %05d\tNumber of errors: %05d\n",
		num_warnings, num_errors);
	printf ("Num Categories: %03d\tNum Events: %03d\t\tNum States: %03d\n",
		num_categories, num_events, num_states);
	printf ("Num Predicates: %03d\tNum Actions: %03d\tNum Tables: %03d\n\n",
		num_predicates, num_actions, num_tables);

	(void) fclose (yyin);

	if (num_errors && ! ignore_errors)
		printf ("correct all errors before attempting to validate description\n");
	else    schk ();
}

void schk (void)
{
	struct table *tp;


	/*
	 * If user wants to keep a log open the output file...
	 */

	if (output != (char *) NULL) {
		if ((ofp = fopen (output, "w")) == NULL) {
			fprintf (stderr, "Can't open output file %s\n", output);
			ofp = (FILE *) NULL;
		}
	}

	/*
	 * We want to go through each table in turn, calling a function to
	 * check the current table for errors.
	 */

	front (&tables);
	while (active (&tables)) {
		tp = (struct table *) return_value (&tables);
		check_table (tp);
		get_next_member (&tables);
	}

	/*
	 * Check for, and report, unused events, states, actions or predicates.
	 */

	check_for_unused_definitions ();
}

void check_table (struct table *tp)
{
	struct tablestate *ts;
	struct statechange *scp;
	int statefound;
	struct enode *endstate;


	curr_table = tp -> name;
	(void) newlist (&stateschangedto);
	(void) newgraph (&statechanges, NULL, NULL);

	/*
	 * Go through all the states in the table
	 */

	front (&(tp -> tablestates));
	while (active (&(tp -> tablestates))) {
		ts = (struct tablestate *) return_value (&(tp -> tablestates));
		check_state (ts);
		get_next_member (&(tp -> tablestates));
	}

	/*
	 * Make sure that states changed to are actually in the table.
	 */

	front (&stateschangedto);
	while (active (&stateschangedto)) {
		scp = (struct statechange *) return_value (&stateschangedto);
		statefound = 0;

		front (&(tp -> tablestates));
		while (active (&(tp -> tablestates))) {
			ts = (struct tablestate *) return_value (&(tp -> tablestates));
			if (! strcmp (scp -> tstate, ts -> state -> name)) {
				statefound = 1;
				break;
			}
			get_next_member (&(tp -> tablestates));
		}

		if (! statefound)
			printf ("%s (%s, %s): change to state %s invalid, state not in table\n", curr_table, scp -> fstate, scp -> event, scp -> tstate);
		else {
			if (! add_to_graph (&statechanges, scp -> fstate, scp -> tstate)) {
				/*
				 * The state change could not be added to the
				 * graph. Inform the user and then quit.
				 */

				fprintf (stderr, "couldn't add state change to graph\n");
				exit (1);
			}
		}

		delete_node (&stateschangedto);
	}

	/*
	 * We have to check the graph that was built up from the state changes
	 * in the table and make sure that all states are reachable and that the
	 * end states can always be reached.
	 */

	front (&(tp -> tablestates));
	while (active (&(tp -> tablestates))) {
		ts = (struct tablestate *) return_value (&(tp -> tablestates));
		if (strcmp (tp -> statename -> initialstate -> name, ts -> state -> name)) {
			/*
			 * This state is not the initial state, see if it
			 * can be reached from the initial state.
			 */

			if (! is_connected (&statechanges, tp -> statename -> initialstate -> name, ts -> state -> name))
				printf ("%s: state %s can't be reached from initialstate (%s)\n", curr_table, ts -> state -> name, tp -> statename -> initialstate -> name);
		}

		statefound = 1;         /* Assume there are no endstates */
		for (endstate = tp -> statename -> endstates; endstate; endstate = endstate -> next) {
			statefound = 0;
			if (strcmp (endstate -> s -> name, ts -> state -> name)) {
				/*
				 * The state does not appear to be an end state,
				 * it may be though! Check to see if it is
				 * connected to an end state.
				 */

				if (is_connected (&statechanges, ts -> state -> name, endstate -> s -> name)) {
					statefound = 1;
					break;
				}
			}
			else {
				/*
				 * The state is an end state so don't bother
				 * trying to connect it to any.
				 */

				statefound = 1;
				break;
			}
		}

		if (! statefound)
			printf ("%s: no end state can be reached from state %s\n", curr_table, ts -> state -> name);

		get_next_member (&(tp -> tablestates));
	}

	deletegraph (&statechanges);
}

void check_state (struct tablestate *ts)
{
	struct stateevent *se;

	/*
	 * Update the name of the current state and mark the state as used...
	 */

	curr_state = ts -> state -> name;
	ts -> state -> refcount ++;

	/*
	 * Go through all the events that can be received whilst in this
	 * state and call the function that will check them.
	 */

	front (&(ts -> stateevents));
	while (active (&(ts -> stateevents))) {
		se = (struct stateevent *) return_value (&(ts -> stateevents));
		check_event (se);
		get_next_member (&(ts -> stateevents));
	}
}

void check_event (struct stateevent *se)
{
	/*
	 * Update the name of the current event and mark the event as used.
	 */

	curr_event = se -> event -> name;
	se -> event -> refcount ++;

	switch (se -> type) {
		case ACTION:    check_actions (se -> ptr.a);
				break;

		case PRED:      check_expr (se -> ptr.c);
				break;
	}
}

void check_actions (struct anode *ap)
{
	struct anode *acts;
	struct statechange sc;


	/*
	 * Go through all the outgoing events, actions, and state changes
	 * and process them...
	 */

	for (acts = ap; acts; acts = acts -> next) {
		switch (acts -> type) {
			case EVENT:
				acts -> ptr.e -> refcount ++;
				break;

			case STATE:
				/*
				 * In addition to updating the reference count
				 * for this state, we have to update the state
				 * change directed list (this is converted to
				 * a DAG later).
				 */

				acts -> ptr.s -> refcount ++;

				sc.fstate = curr_state;
				sc.event = curr_event;
				sc.tstate = acts -> ptr.s -> name;

				if (! append_to_list (&stateschangedto, &sc, sizeof (struct statechange))) {
					/*
					 * We couldn't add the state to the list
					 * of states changed to, print a message
					 * and exit....
					 */

					fprintf (stderr, "Couldn't add state to list of states changed to\n");
					exit (1);
				}
				break;

			case ACTION:
				acts -> ptr.a -> refcount ++;
				break;

			case NOTE:
				/*
				 * Do nothing for table notes...
				 */

				break;
		}
	}
}

void check_expr (struct cnode *cp)
{
	struct cnode *conds, *moreconds;
	LIST predsused, morepredsused;
	int num_combinations, count, shift, num_true, predfound;
	struct predptr *pptr, *morepptr;

	/*
	 * Check all the predicates that are used in expressions at the
	 * current state/event combination.
	 */

	newlist (&predsused);

	/*
	 * First check that all expressions can evaluate true under 
	 * certain conditions;
	 */

	for (conds = cp; conds; conds = conds -> next) {
		builduppredlist (&predsused, conds -> p);
		num_combinations = (int) pow2 ((double) countlist (&predsused));
		num_true =0;

		for (count = 0; count < num_combinations; count ++) {
			shift = 0;
			front (&predsused);
			while (active (&predsused)) {
				pptr = (struct predptr *) return_value (&predsused);
				pptr -> pred -> value = (count >> shift ++) & 0x1;
				get_next_member (&predsused);
			}

			if (eval (conds -> p))
				num_true ++;
		}

		if (! num_true) {
			/*
			 * The expression never evaluated true so print an
			 * error message....
			 */

			printf ("%s (%s, %s): expression ", curr_table, curr_state, curr_event);
			display_predicates (conds -> p);
			printf (" never evaluates true\n");
		}
		else {
			/*
			 * As the expression can evaluate true, check the
			 * conditional actions, state changes and outgoing
			 * events.
			 */

			check_actions (conds -> a);
		}

		deletelist (&predsused);
	}

	/*
	 * Check to see if more than one expression can evaluate true at a
	 * time due to the way in which the predicates are used.
	 */

	for (conds = cp; conds; conds = conds -> next) {
		builduppredlist (&predsused, conds -> p);

		newlist (&morepredsused);
		for (moreconds = conds -> next; moreconds; moreconds = moreconds -> next) {
			/*
			 * For each subsequent expression, make sure that it
			 * can't evaluate true whilst the current one evaluates
			 * true.
			 */

			builduppredlist (&morepredsused, moreconds -> p);

			/*
			 * Check to see if all the predicates used in the
			 * current expression are used in this subsequent
			 * expression.
			 */

			front (&predsused);
			while (active (&predsused)) {
				pptr = (struct predptr *) return_value (&predsused);

				predfound = 0;
				front (&morepredsused);
				while (active (&morepredsused)) {
					morepptr = (struct predptr *) return_value (&morepredsused);
					if (morepptr -> pred == pptr -> pred) {
						predfound = 1;
						break;
					}
					get_next_member (&morepredsused);
				}

				if (! predfound) {
					/*
					 * This subsequent expression does not
					 * contain a predicate or predicates
					 * used in the current expression. There
					 * is no need to check further.
					 */

					break;
				}

				get_next_member (&predsused);
			}

			if (predfound) {
				/*
				 * All predicates used in the current expression
				 * are used in this subsequent expression. We
				 * have to make sure that both expressions
				 * don't evaluate true for the same predicate
				 * values.
				 */

				num_combinations = (int) pow2 ((double) countlist (&morepredsused));
				for (count = 0; count < num_combinations; count ++) {
					shift = 0;
					front (&morepredsused);
					while (active (&morepredsused)) {
						morepptr = (struct predptr *) return_value (&morepredsused);
						morepptr -> pred -> value = (count >> shift ++) & 0x1;
						get_next_member (&morepredsused);
					}

					if (eval (conds -> p) && eval (moreconds -> p)) {
						/*
						 * Whoops, both expressions
						 * evaluate true for the same
						 * predicate values. This is a
						 * big error!
						 */

						printf ("%s (%s, %s): error, expression ", curr_table, curr_state, curr_event);
						display_predicates (conds -> p);
						printf (" and ");
						display_predicates (moreconds -> p);
						printf (" both evaluate true when ");
						front (&morepredsused);
						while (active (&morepredsused)) {
							morepptr = (struct predptr *) return_value (&morepredsused);
							printf ("%s=%s ", morepptr -> pred -> name, (morepptr -> pred -> value ? "true" : "false"));
							get_next_member (&morepredsused);
						}
						printf ("\n");
					}
				}
			}

			deletelist (&morepredsused);
		}

		deletelist (&predsused);
	}

	/*
	 * What remains is an expression or list of expressions that can
	 * evaluate true independantly of each other. Check to see if they
	 * can also evaluate true together. Note that, at this stage, if they
	 * do they are not likely to result in non-determinism.
	 */

/*
	for (conds = cp; conds; conds = conds -> next)
		builduppredlist (&predsused, conds -> p);

	num_combinations = (int) pow2 ((double) countlist (&predsused));
	num_true =0;

	for (count = 0; count < num_combinations; count ++) {
		shift = 0;
		front (&predsused);
		while (active (&predsused)) {
			pptr = (struct predptr *) return_value (&predsused);
			pptr -> pred -> value = (count >> shift ++) & 0x1;
			get_next_member (&predsused);
		}

		num_true = 0;
		for (conds = cp; conds; conds = conds -> next) {
			if (eval (conds -> p))
				num_true ++;
		}

		if (num_true > 1) {
			printf ("%s (%s, %s): warning, more than one expression evaluates true when ", curr_table, curr_state, curr_event);
			front (&predsused);
			while (active (&predsused)) {
				pptr = (struct predptr *) return_value (&predsused);
				printf ("%s=%s ", pptr -> pred -> name, (pptr -> pred -> value ? "true" : "false"));
				get_next_member (&predsused);
			}
			printf ("\n");
		}
	}

	deletelist (&predsused);
*/
}

void builduppredlist (LIST *predlist, struct pnode *pp)
{
	int predinlist;
	struct predptr ps, *psp;

	/*
	 * This is a recursive function and, as such, problems may be
	 * encountered when traversing large predicate trees.
	 */

	if (pp -> l)
		builduppredlist (predlist, pp -> l);

	if (pp -> type == PRED) {
		predinlist = 0;

		front (predlist);
		while (active (predlist)) {
			psp = (struct predptr *) return_value (predlist);
			if (psp -> pred == pp -> p) {
				predinlist = 1;
				break;
			}
			get_next_member (predlist);
		}

		if (! predinlist) {
			ps.pred = pp -> p;
			if (! insert (predlist, &ps, sizeof (struct predptr))) {
				/*
				 * The predicate information could not be added to the
				 * list, print an error message and then exit.
				 */

				fprintf (stderr, "could not add used predicate to list\n");
				exit (1);
			}
		}

		pp -> p -> refcount ++;
	}

	if (pp -> r)
		builduppredlist (predlist, pp -> r);
}

void check_for_unused_definitions (void)
{
	struct evstruct *ep;
	struct stastruct *sp;
	struct actstruct *ap;
	struct predstruct *pp;

	/*
	 * Start by going through the list of events
	 */

	front (&events);
	while (active (&events)) {
		ep = (struct evstruct *) return_value (&events);
		if (! ep -> refcount)
			printf ("unused event: %s (%s)\n", ep -> name, ep -> comment);
		get_next_member (&events);
	}

	/*
	 * Now check for unused states
	 */

	front (&states);
	while (active (&states)) {
		sp = (struct stastruct *) return_value (&states);
		if (! sp -> refcount)
			printf ("unused state: %s (%s)\n", sp -> name, sp -> comment);
		get_next_member (&states);
	}

	/*
	 * Check for unused actions and print out any...
	 */

	front (&actions);
	while (active (&actions)) {
		ap = (struct actstruct *) return_value (&actions);
		if (! ap -> refcount)
			printf ("unused action: %s (%s)\n", ap -> name, ap -> comment);
		get_next_member (&actions);
	}

	/*
	 * Finally, check for unused predicates.
	 */

	front (&predicates);
	while (active (&predicates)) {
		pp = (struct predstruct *) return_value (&predicates);
		if (! pp -> refcount)
			printf ("unused predicate: %s (%s)\n", pp -> name, pp -> comment);
		get_next_member (&predicates);
	}
}

int eval (struct pnode *p)
{
	/*
	 * Note: This is a recursive function. On very large predicate trees
	 * there could be stack size problems...
	 */

	switch (p -> type) {
		case PRED:      return (p -> p -> value); break;
		case AND:       return ((eval (p -> l)) & (eval (p -> r))); break;
		case OR:        return ((eval (p -> l)) | (eval (p -> r))); break;
		case NOT:       return (! (eval (p -> r))); break;
	}

	/*
	 * We should NEVER get here...
	 */

	return 0;
}

void display_predicates (struct pnode *p)
{
	/*
	 * Note: This is a recursive function. On very large predicate trees
	 * there could be stack size problems...
	 */

	if (p -> type != PRED)
		printf ("(");

	if (p -> l)
		display_predicates (p -> l);
	switch (p -> type) {
		case PRED:      printf ("%s", p -> p -> name); break;
		case AND:       printf (" AND "); break;
		case OR:        printf (" OR "); break;
		case NOT:       printf ("NOT "); break;
	}
	if (p -> r)
		display_predicates (p -> r);

	if (p -> type != PRED)
		printf (")");
}
