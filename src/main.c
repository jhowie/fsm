/* File: main.c
**
** Author: jfc, 29/12/91
**
** Copyright: (c) John Howie (jfc@cs.napier.ac.uk)
**
** Description
**
**      This module contains the common functions used when dealing with the
** state description files.
**
** Modification History
**
** 04/08/93 jfc ANSI'fied function prototypes and code in preparation for NT
**              version.
*/

# include <stdio.h>

# include <stdlib.h>
# include <stdarg.h>
# include <string.h>

# include "stdinclude.h"

# include "list.h"
# include "states.h"

# include "y.tab.h"

extern int yydebug;
extern int lineno;

_PROTOTYPE( int main, (int argc, char *argv []));
_PROTOTYPE( void do_it, (int argc, char *argv []));

/* The following are global variables, eughh.... */

LIST categories, events, states, predicates, actions, svars, tables;
int     num_categories = 0,
	num_events = 0,
	num_states = 0,
	num_predicates = 0,
	num_actions = 0,
	num_tables = 0,
	num_warnings = 0,
	num_errors = 0;

struct svar *curr_svar;
struct stateevent *curr_event;
LIST *tablenotes, *tablestates, *stateevents;
int duplicate_table, duplicate_state, duplicate_event;

int main (int argc, char *argv [])
{
	/*
	 * Call the user-supplied function that will eventually call yyparse
	 */

	do_it (argc, argv);
	return 0;
}

void fatal (char *fmt, ...)
{
	va_list args;

	va_start (args, fmt);

	fprintf (stderr, "%05d: (fatal) ", lineno);
	vfprintf (stderr, fmt, args);
	va_end (args);

	exit (1);
}

void error (char *fmt, ...)
{
	va_list args;

	va_start (args, fmt);

	fprintf (stderr, "%05d: (error) ", lineno);
	vfprintf (stderr, fmt, args);
	va_end (args);

	num_errors ++;
}

void warning (char *fmt, ...)
{
	va_list args;

	va_start (args, fmt);

	fprintf (stderr, "%05d: (warning) ", lineno);
	vfprintf (stderr, fmt, args);
	va_end (args);

	num_warnings ++;
}

void add_category (char *cat)
{
	struct catstruct c, *cp;

	front (&categories);
	while (active (&categories)) {
		cp = (struct catstruct *) return_value (&categories);

		if (! strcmp (cp -> name, cat)) {
/*
			warning ("duplicate category %s\n", cp -> name);
*/

			return;
		}

		get_next_member (&categories);
	}

	c.name = cat;
	c.id = (++ num_categories);

	if (insert (&categories, &c, sizeof (struct catstruct)) == FALSE)
		fatal ("couldn't add category %s to list\n", c.name);
}

void add_event (char *ev, char *cat, char *comment)
{
	struct evstruct e, *ep;

	front (&events);
	while (active (&events)) {
		ep = (struct evstruct *) return_value (&events);

		if (! strcmp (ep -> name, ev)) {
			warning ("duplicate event %s\n", ep -> name);

			return;
		}

		get_next_member (&events);
	}

	e.name = ev;
	e.refcount = 0;
	e.id = (++ num_events);
	e.cat = cat;
	e.comment = comment;

	if (insert (&events, &e, sizeof (struct evstruct)) == FALSE)
		fatal ("couldn't add event %s to list\n", e.name);
}

void add_state (char *sta, char *comment)
{
	struct stastruct s, *sp;

	front (&states);
	while (active (&states)) {
		sp = (struct stastruct *) return_value (&states);

		if (! strcmp (sp -> name, sta)) {
			warning ("duplicate state %s\n", sp -> name);

			return;
		}

		get_next_member (&states);
	}

	s.name = sta;
	s.refcount = 0;
	s.id = (++ num_states);
	s.comment = comment;

	if (insert (&states, &s, sizeof (struct stastruct)) == FALSE)
		fatal ("couldn't add state %s to list\n", s.name);
}

void add_predicate (char *pred, char *comment)
{
	struct predstruct p, *pp;

	front (&predicates);
	while (active (&predicates)) {
		pp = (struct predstruct *) return_value (&predicates);

		if (! strcmp (pp -> name, pred)) {
			warning ("duplicate predicate %s\n", pp -> name);

			return;
		}

		get_next_member (&predicates);
	}

	p.name = pred;
	p.refcount = 0;
	p.id = (++ num_predicates);
	p.comment = comment;

	if (insert (&predicates, &p, sizeof (struct predstruct)) == FALSE)
		fatal ("couldn't add predicate %s to list\n", p.name);
}

void add_action (char *act, char *comment)
{
	struct actstruct a, *ap;

	front (&actions);
	while (active (&actions)) {
		ap = (struct actstruct *) return_value (&actions);

		if (! strcmp (ap -> name, act)) {
			warning ("duplicate action %s\n", ap -> name);

			return;
		}

		get_next_member (&actions);
	}

	a.name = act;
	a.refcount = 0;
	a.id = (++ num_actions);
	a.comment = comment;

	if (insert (&actions, &a, sizeof (struct actstruct)) == FALSE)
		fatal ("couldn't add action %s to list\n", a.name);
}

void add_svar (char *svar, char *state, struct enode *endstates)
{
	struct svar v, *vp;
	struct stastruct *sp;

	front (&svars);
	while (active (&svars)) {
		vp = (struct svar *) return_value (&svars);

		if (! strcmp (vp -> name, svar)) {
			error ("duplicate state variable name %s\n", vp -> name);

			return;
		}

		get_next_member (&svars);
	}

	v.name = svar;
	v.initialstate = 0;
	v.endstates = endstates;

	front (&states);
	while (active (&states)) {
		sp = (struct stastruct *) return_value (&states);

		if (! strcmp (sp -> name, state)) {
			v.initialstate = sp;

			break;
		}

		get_next_member (&states);
	}

	if (! v.initialstate)
		fatal ("initialstate %s not known\n", state);

	if (insert (&svars, &v, sizeof (struct svar)) == FALSE)
		fatal ("couldn't add new svar %s to list of svars\n", state);

	curr_svar = (struct svar *) return_value (&svars);
}

void begin_table (char *tablename)
{
	struct table t, *tp;

	if (curr_svar == (struct svar *) 0)
		fatal ("no current state variable\n");

	duplicate_table = 0;
	front (&tables);
	while (active (&tables)) {
		tp = (struct table *) return_value (&tables);

		if (! strcmp (tp -> name, tablename)) {
			duplicate_table = 1;
			error ("duplicate table name %s\n", tp -> name);

			return;
		}

		get_next_member (&tables);
	}
	
	t.name = tablename;
	t.statename = curr_svar;
	t.currentstate = curr_svar -> initialstate;

	if (insert (&tables, &t, sizeof (struct table)) == FALSE)
		fatal ("couldn't add table %s to list\n", t.name);

	tp = (struct table *) return_value (&tables);
	tablenotes = &tp -> tablenotes;
	tablestates = &tp -> tablestates;
	newlist (tablenotes); newlist (tablestates);
}

void end_table (void)
{
	if (! duplicate_table)
		num_tables ++;
}

void add_note (char *note, char *comment)
{
	struct tablenote t, *tp;

	if (duplicate_table)
		return;

	front (tablenotes);
	while (active (tablenotes)) {
		tp = (struct tablenote *) return_value (tablenotes);

		if (! strcmp (tp -> name, note)) {
			warning ("duplicate table note %s\n", tp -> name);

			return;
		}

		get_next_member (tablenotes);
	}

	t.name = note;
	t.comment = comment;

	if (insert (tablenotes, &t, sizeof (struct tablenote)) == FALSE)
		fatal ("couldn't add table note %s for current table\n", t.name);
}

void begin_state (char *state)
{
	struct stastruct *sp;
	struct tablestate t, *tp;
	int found_state = 0;

	if (duplicate_table) {
		/*
		 * Pretend that this state is a duplicate, it will stop
		 * it from being processed.
		 */

		duplicate_state = 1;
		return;
	}

	front (&states);
	while (active (&states)) {
		sp = (struct stastruct *) return_value (&states);

		if (! strcmp (sp -> name, state)) {
			found_state = 1;
			break;
		}

		get_next_member (&states);
	}

	if (! found_state) {
		error ("undefined state %s\n", state);

		/*
		 * Although it's not a duplicate state this will prevent further
		 * processing of this state and its events.
		 */

		duplicate_state = 1;
		return;
	}

	duplicate_state = 0;
	front (tablestates);
	while (active (tablestates)) {
		tp = (struct tablestate *) return_value (tablestates);

		if (tp -> state == sp) {
			/*
			 * This is a duplicate state. Don't process any
			 * further for this state.
			 */

			error ("duplicate state in table %s\n", sp -> name);
			duplicate_state = 1;

			return;
		}

		get_next_member (tablestates);
	}

	t.state = sp;

	if (insert (tablestates, &t, sizeof (struct tablestate)) == FALSE)
		fatal ("couldn't add state %s to list of states in table\n", t.state -> name);

	tp = (struct tablestate *) return_value (tablestates);
	stateevents = &tp -> stateevents;
	newlist (stateevents);
}

void begin_event (char *event)
{
	struct evstruct *ep;
	struct stateevent s, *sp;
	int found_event = 0;

	if (duplicate_state) {
		/*
		 * This event is in a duplicate state. We will not process
		 * any further. To make sure that the event functions are
		 * not processed we will also mark this as a duplicate event.
		 */

		duplicate_event = 1;
		return;
	}

	front (&events);
	while (active (&events)) {
		ep = (struct evstruct *) return_value (&events);

		if (! strcmp (ep -> name, event)) {
			found_event = 1;

			break;
		}

		get_next_member (&events);
	}

	if (! found_event) {
		error ("undefined event %s\n", event);

		/*
		 * Although this is not a duplicate event, the following will
		 * prevent the rest of this event from being processed.
		 */

		duplicate_event = 1;
		return;
	}

	duplicate_event = 0;
	front (stateevents);
	while (active (stateevents)) {
		sp = (struct stateevent *) return_value (stateevents);

		if (sp -> event == ep) {
			/*
			 * This is a duplicate event. We won't bother
			 * processing it any further.
			 */

			error ("duplicate event in state %s\n", ep -> name);
			duplicate_event = 1;

			return;
		}

		get_next_member (stateevents);
	}

	s.event = ep;

	if (insert (stateevents, &s, sizeof (struct stateevent)) == FALSE)
		fatal ("couldn't add event %s to state in table\n", s.event -> name);

	curr_event = (struct stateevent *) return_value (stateevents);
}

void add_to_event (int type, void *ptr)
{
	if (duplicate_event) {
		/*
		 * This is a duplicate event in a state. We aren't interested
		 * in any of the associated actionlist.
		 */

		return;
	}

	curr_event -> type = type;
	switch (type) {
		case ACTION:
			curr_event -> ptr.a = (struct anode *) ptr;
			break;

		case PRED:
			curr_event -> ptr.c = (struct cnode *) ptr;
			break;

		default:
			fatal ("illegal type passed to add_to_event ()\n");
			break;
	}
}

struct enode *add_enode (char *s, struct enode *next)
{
	struct enode *newnode;
	struct stastruct *sp;

	if (s == (char *) 0)
		return (struct enode *) 0;

	newnode = (struct enode *) malloc (sizeof (struct enode));
	if (newnode == (struct enode *) 0)
		fatal ("couldn't allocate mem for enode\n");

	front (&states);
	while (active (&states)) {
		sp = (struct stastruct *) return_value (&states);
		if (! strcmp (s, sp -> name)) {
			/*
			 * We found a match for the name passed as an end
			 * state in the list of states. Update the newly
			 * created enode so that it points to the state
			 * definition structure and then return the enode.
			 */

			newnode -> s = sp;
			newnode -> next = next;
			return newnode;
		}
		get_next_member (&states);
	}

	/*
	 * If we get here it means that there is no matching state in the
	 * definitions of states. Print out an error message, free up the
	 * newly allocated memory and then return the pointer for next.
	 */

	free (newnode);
	error ("endstate %s not found", s);
	return next;
}

struct cnode *evpredact (struct pnode *p, struct anode *a, struct cnode *next)
{
	struct cnode *newnode;

	if (duplicate_event) {
		/*
		 * This is part of a duplicate event, don't go any further.
		 */

		return (struct cnode *) NULL;
	}

	newnode = (struct cnode *) malloc (sizeof (struct cnode));
	if (newnode == (struct cnode *) 0)
		fatal ("couldn't allocate mem for cnode\n");

	newnode -> p = p;
	newnode -> a = a;
	newnode -> next = next;

	return newnode;
}

struct anode *add_anode (int type, char *item, struct anode *next)
{
	struct anode *newnode;

	struct evstruct *ep;
	struct stastruct *sp;
	struct actstruct *ap;
	struct tablenote *np;

	if (duplicate_event) {
		/*
		 * This is part of a duplicate event, don't bother processing
		 * it any further.
		 */

		return (struct anode *) 0;
	}

	if (item == (char *) 0)
		return (struct anode *) 0;

	newnode = (struct anode *) malloc (sizeof (struct anode));
	if (newnode == (struct anode *) 0)
		fatal ("couldn't allocate memory for anode\n");

	memset (newnode, 0, sizeof (struct anode));
	newnode -> type = type;
	newnode -> next = next;

	switch (type) {
		case ACTION:
			front (&actions);
			while (active (&actions)) {
				ap = (struct actstruct *) return_value (&actions);

				if (! strcmp (ap -> name, item)) {
					newnode -> ptr.a = ap;

					break;
				}

				get_next_member (&actions);
			}

			if (! newnode -> ptr.a) {
				error ("action %s not found\n", item);

				free (newnode);
				return next;
			}

			break;

		case NOTE:
			front (tablenotes);
			while (active (tablenotes)) {
				np = (struct tablenote *) return_value (tablenotes);

				if (! strcmp (np -> name, item)) {
					newnode -> ptr.n = np;

					break;
				}

				get_next_member (tablenotes);
			}

			if (! newnode -> ptr.n) {
				error ("note %s not found\n", item);

				free (newnode);
				return next;
			}

			break;

		case CES:
			/*
			 * We don't know if this is an event or a state,
			 * check events first...
			 */

			front (&events);
			while (active (&events)) {
				ep = (struct evstruct *) return_value (&events);

				if (! strcmp (ep -> name, item)) {
					newnode -> type = EVENT;
					newnode -> ptr.e = ep;

					break;
				}

				get_next_member (&events);
			}

			if (newnode -> ptr.e)
				break;

			front (&states);
			while (active (&states)) {
				sp = (struct stastruct *) return_value (&states);

				if (! strcmp (sp -> name, item)) {
					newnode -> type = STATE;
					newnode -> ptr.s = sp;

					break;
				}

				get_next_member (&states);
			}

			if (! newnode -> ptr.s) {
				error ("event/state %s not found\n", item);

				free (newnode);
				return next;
			}

			break;

		default:
			fatal ("bad type passed to add_anode\n");
			break;
	}

	return newnode;
}

struct pnode *add_pnode (int type, char *item, struct pnode *l, struct pnode *r)
{
	struct pnode *newnode;

	struct predstruct *pp;

	if (duplicate_event) {
		/*
		 * This is part of a duplicate event. Just return.
		 */

		return (struct pnode *) 0;
	}

	newnode = (struct pnode *) malloc (sizeof (struct pnode));
	if (newnode == (struct pnode *) 0)
		fatal ("couldn't allocate memory for new pnode\n");

	memset (newnode, 0, sizeof (struct pnode));

	switch (type) {
		case PRED:
			front (&predicates);
			while (active (&predicates)) {
				pp = (struct predstruct *) return_value (&predicates);

				if (! strcmp (pp -> name, item)) {
					newnode -> p = pp;

					break;
				}

				get_next_member (&predicates);
			}

			if (! newnode -> p)
				fatal ("unknown predicate %s in actionlist\n", item);

			break;

		case AND:
		case OR:
		case NOT:
			break;

		default:
			fatal ("illegal type passed to add_pnode\n");
			break;
	}

	newnode -> type = type;
	newnode -> l = l;
	newnode -> r = r;

	return newnode;
}
