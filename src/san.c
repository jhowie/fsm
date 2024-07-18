/* File: san.c
**
** Author: jfc, 22/01/92
**
** Copyright: (c) John Howie (jfc@dcs.napier.ac.uk)
**
** Description
**
**      This file contains the state animator. Like spp the yyparse ()
** function is called from here.
**
** Modifications
**
** 08/07/93 jfc ANSI-fied function prototypes and broke out some routines
**              in preparation for added functionality of when keyword.
**
** 30/07/93 jfc Created do_when () function and function to create eventout
**              triggers.
**
** 01/08/93 jfc Created function check_event_triggers () and supporting code
**              to handle matching triggers.
**
** 04/08/93 jfc Converted functions to ANSI for port to NT.
*/

# include <stdio.h>
# include <string.h>
# include <unistd.h>
# include <stdlib.h>
# include <ctype.h>

# include <time.h>

# include "stdinclude.h"

# include "list.h"
# include "states.h"

# include "y.tab.h"

_PROTOTYPE( void do_it, (int argc, char *argv []));
_PROTOTYPE( void san, (void));
_PROTOTYPE( void do_event, (void));
_PROTOTYPE( void eventin, (struct evstruct *ep));
_PROTOTYPE( void do_help, (void));
_PROTOTYPE( void do_quit, (void));
_PROTOTYPE( void do_set, (void));
_PROTOTYPE( void do_show, (void));
_PROTOTYPE( void do_list, (void));
_PROTOTYPE( void do_source, (void));
_PROTOTYPE( void do_state, (void));
_PROTOTYPE( void do_table, (void));
_PROTOTYPE( void do_when, (void));
_PROTOTYPE( void changetable, (struct table *tp));
_PROTOTYPE( void changestate, (char *statename));
_PROTOTYPE( void list_tables, (void));
_PROTOTYPE( void list_states, (void));
_PROTOTYPE( void list_events, (void));
_PROTOTYPE( void trigger_eventout, (void));
_PROTOTYPE( void check_event_triggers, (struct evstruct *ep));
_PROTOTYPE( void check_preds, (struct cnode *c));
_PROTOTYPE( void process_actionlist, (struct anode *a));
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
static FILE *cin;

struct command  { char *name;
		  void (*func) ();
		};

static struct command commands [] =
	{               { "event", do_event },
			{ "help", do_help },
			{ "list", do_list },
			{ "quit", do_quit },
			{ "set", do_set },
			{ "show", do_show },
			{ "state", do_state },
			{ "source", do_source },
			{ "table", do_table },
			{ "when", do_when },
	};

static struct command lists [] =
	{               { "tables", list_tables },
			{ "states", list_states },
			{ "events", list_events },
	};

static struct command triggers [] =
	{               { "eventout", trigger_eventout },
	};

# define NUM_COMMANDS   (sizeof (commands) / sizeof (struct command))
# define NUM_LISTS      (sizeof (lists) / sizeof (struct command))
# define NUM_TRIGGERS   (sizeof (triggers) / sizeof (struct command))

static struct table *curr_table;
static struct tablestate *curr_state;
static struct evstruct *curr_eventin;

/* The following are used when dealing with event triggers... */

struct event_trigger    { struct evstruct *eventout;
			  struct table *fromtable;
			  struct stastruct *fromstate;
			  struct evstruct *eventin;
			  struct table *totable;
			};

struct eventq_trigger   { struct table *totable;
			  struct evstruct *eventin;
			};

static LIST event_triggers;
static LIST eventq_triggers;

/* void do_it (int argc, char *argv [])
**
** The following function is called by main () to start the ball rolling.
*/

void do_it (int argc, char *argv [])
{
	int errs = 0, c;
	extern int optind;
	extern char *optarg;

	cin = stdin;
	yydebug = 0;
	while ((c = getopt (argc, argv, "o:v")) != EOF) {
		switch (c) {
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
		fprintf (stderr, "Usage: %s [-o output] [-v] input\n",
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
	printf ("Num Predicates: %03d\tNum Actions: %03d\tNum Tables: %03d\n",
		num_predicates, num_actions, num_tables);

	(void) fclose (yyin);

	san ();
}

void san (void)
{
	struct predstruct *pp;
	char line_in [132 +1], *comm, *cptr;
	int i;

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
	 * Initialise all the predicates and stuff...
	 */

	front (&predicates);
	while (active (&predicates)) {
		pp = (struct predstruct *) return_value (&predicates);

		pp -> value = 0;

		get_next_member (&predicates);
	}

	/*
	 * Clear the list of triggers and the event queue.
	 */

	newlist (&event_triggers);
	newlist (&eventq_triggers);

	/*
	 * Now go to the first table and change to its initial state,
	 * this is the start of the animator.
	 */

	front (&tables);
	curr_table = (struct table *) return_value (&tables);
	changestate (curr_table -> statename -> initialstate -> name);

	/*
	 * This is the command loop. Commands are taken from cin, which can be
	 * stdin OR a file...
	 */

	do {
		/*
		 * If we have reached the end of input from cin and cin was
		 * not the standard input, ie. it was a file, make it the
		 * standard input.
		 */

		if (feof (cin) && (cin != stdin)) {
			(void) fclose (cin);
			cin = stdin;
		}

		if (cin == stdin)
			printf ("(san) ");

		if (fgets (line_in, sizeof (line_in), cin) == NULL)
			continue;

		/*
		 * Get the command that the user wants to execute...
		 */

		comm = strtok (line_in, " \t\n");
		if (comm == (char *) NULL)
			continue;

		/*
		 * Convert the command to lower case if required.
		 */

		cptr = comm;
		while (*cptr != (char) NULL) {
			if (isupper ((char) *cptr))
				*cptr = (char) tolower ((char) *cptr);
			cptr ++;
		}

		/*
		 * Search through the list of commands we know about
		 * looking for a match.
		 */

		for (i = 0; i < NUM_COMMANDS; i ++) {
			if (! strcmp (comm, commands [i].name)) {
				(commands [i].func) ();
				break;
			}
		}

		/*
		 * We didn't find a matching command.
		 */

		if ((i == NUM_COMMANDS) && (comm != (char *) NULL))
			printf ("Unknown command %s\n", comm);

	} while (comm == (char *) NULL || strcmp (comm, "quit"));
}

/* void do_event (void)
**
** This function is called to get the name of the event from the user's
** command line. It checks to see if the event actually exists and, if
** it does, the function eventin () will be called to actually simulate the
** arrival of the event.
*/

void do_event (void)
{
	char *event;
	int event_exists;
	struct evstruct *ep;
	struct stateevent *sep;
	struct table *saved_table;
	struct eventq_trigger *evqtp;

	/*
	 * Get the name of the incoming event...
	 */

	event = strtok (NULL, " \t\n");
	if (event == (char *) NULL) {
		printf ("Missing incoming event!\n");
		return;
	}

	/*
	 * Check that the event selected by the user actually
	 * exists...
	 */

	event_exists = 0;
	front (&events);
	while (active (&events)) {
		ep = (struct evstruct *) return_value (&events);

		if (! strcmp (event, ep -> name)) {
			event_exists = 1;
			break;
		}

		get_next_member (&events);
	}

	if (! event_exists)
		printf ("Event %s doesn't exist...\n", event);
	else   eventin (ep);

	/*
	 * Now process any events that might have been queued for
	 * delivery to other tables. First of all save the current
	 * table as we will want to restore to it later afterwards.
	 */

	saved_table = curr_table;
	front (&eventq_triggers);
	while (active (&eventq_triggers)) {
		/*
		 * Get the event at the head of the queue of events to
		 * be delivered.
		 */

		evqtp = (struct eventq_trigger *) return_value (&eventq_triggers);

		/*
		 * Change to the table that the event is to be sent to.
		 */

		changetable (evqtp -> totable);

		/*
		 * Now send the event to the table...
		 */

		eventin (evqtp -> eventin);

		/*
		 * Make sure that we are at the head of the queue and then
		 * delete the eventq_trigger.
		 */

		front (&eventq_triggers);
		if (! delete_node (&eventq_triggers)) {
			printf ("ERROR: couldn't delete triggered event, exiting.\n");
			exit (1);
		}
	}

	/*
	 * Restore the table...
	 */

	changetable (saved_table);
}

/* void eventin (struct evstruct *ep)
**
** This function is called to actually simulate the arrival of the named
** event for the current state and table.
*/

void eventin (struct evstruct *ep)
{
	int event_exists;
	struct stateevent *sep;

	/*
	 * Copy the event pointer to the global event pointer. This is a
	 * frig required for the function that checks outgoing event
	 * triggers.
	 */

	curr_eventin = ep;

	/*
	 * Now enter the current table with the current state
	 * and user selected event. Although the event exists
	 * it might not be legal for the current state...
	 */

	 printf ("Entering Table %s (State= %s, Event= %s)\n",
		curr_table -> name, curr_state -> state -> name,
		ep -> name);

	event_exists = 0;
	front (&(curr_state -> stateevents));
	while (active (&(curr_state -> stateevents))) {
		sep = (struct stateevent *) return_value (&(curr_state -> stateevents));

		if (! strcmp (ep -> name, sep -> event -> name)) {
			event_exists = 1;
			break;
		}

		get_next_member (&(curr_state -> stateevents));
	}

	if (event_exists) {
		/*
		 * If there are predicates associated with this event see if
		 * any are satisfied, otherwise display the actionlist...
		 */

		if (sep -> type == PRED)
			check_preds (sep -> ptr.c);
		else    process_actionlist (sep -> ptr.a);
	}
	else    printf ("\tBADEVENT (%s)\n", ep -> name);
}

void do_help (void)
{
	/*
	 * Print out some useful help - such as the commands that can be
	 * used and so on.
	 */

	printf ("\n  event  - simulate an incoming event");
	printf ("\n  list   - list tables, states, or events");
	printf ("\n  quit   - quit the animator");
	printf ("\n  set    - set a predicate value");
	printf ("\n  show   - show a predicate, or all, and it's value");
	printf ("\n  state  - show the current state or change to a state");
	printf ("\n  source - source a file containing commands for san");
	printf ("\n  table  - show the current table or change to a table");
	printf ("\n  when   - set a trigger on an outgoing event");
	printf ("\n\n");
}

void do_quit (void)
{
	if (ofp != (FILE *) NULL)
		(void) fclose (ofp);
}

void do_set (void)
{
	struct predstruct *pp;
	char *pred, *value, *cptr;
	int pred_value, do_all =0;

	/*
	 * Get the name of the predicate to set....
	 */

	pred = strtok (NULL, " \t\n");
	if (pred == (char *) NULL) {
		printf ("Missing predicate and value\n");
		return;
	}

	if (! strcmp (pred, "all"))
		do_all = 1;

	/*
	 * Get the value the predicate is to be set to...
	 */

	value = strtok (NULL, " \t\n");
	if (value == (char *) NULL) {
		printf ("Missing value for predicate\n");
		return;
	}

	cptr = value;
	while (*cptr != (char) NULL) {
		if (isupper ((char) *cptr))
			*cptr = (char) tolower ((int) *cptr);
		cptr ++;
	}

	if (! strcmp (value, "true")) pred_value = 1;
	else if (! strcmp (value, "false")) pred_value = 0;
	else {
		printf ("Bad value for predicate\n");
		return;
	}

	/*
	 * Set the predicate (if it exists...) or all predicates
	 */

	front (&predicates);
	while (active (&predicates)) {
		pp = (struct predstruct *) return_value (&predicates);

		if (! strcmp (pp -> name, pred) || do_all) {
			pp -> value = pred_value;
			if (! do_all)
				return;
		}

		get_next_member (&predicates);
	}

	if (! do_all)
		printf ("Unknown predicate %s\n", pred);
}

void do_list (void)
{
	char *listwhat, *cptr;
	int i;

	/*
	 * Find out what the user wants to list...
	 */

	listwhat = strtok (NULL, " \t\n");
	if (listwhat == (char *) NULL) {
		printf ("List what? (tables states events)\n");
		return;
	}

	cptr = listwhat;
	while (*cptr != (char) NULL) {
		if (isupper ((char) *cptr))
			*cptr = (char) tolower ((int) *cptr);
		cptr ++;
	}

	for (i = 0; i < NUM_LISTS; i ++) {
		if (! strcmp (listwhat, lists [i].name)) {
			(lists [i].func) ();
			return;
		}
	}

	printf ("I don't know how to show that!\n");
}

void do_state (void)
{
	char *statename;

	statename = strtok (NULL, " \t\n");
	if (statename == (char *) NULL) {
		/*
		 * Print the name of the current state...
		 */

		printf ("Current state is %s\n", curr_state -> state -> name);
		return;
	}

	/*
	 * User wants to change the state, call the appropriate function...
	 */

	changestate (statename);
}

void do_table (void)
{
	char *tablename;
	struct table *tp;

	tablename = strtok (NULL, " \t\n");
	if (tablename == (char *) NULL) {
		/*
		 * Print the current tablename...
		 */

		printf ("Current table is %s\n", curr_table -> name);
		return;
	}

	/*
	 * User wants to change the current table. If it exists set the current
	 * state to the initial state...
	 */

	front (&tables);
	while (active (&tables)) {
		tp = (struct table *) return_value (&tables);

		if (! strcmp (tp -> name, tablename)) {
			/*
			 * This is the table that the user wanted, call
			 * the changetable () function.
			 */

			changetable (tp);
			return;
		}

		get_next_member (&tables);
	}

	printf ("Table %s not found\n", tablename);
}

/* void changetable (struct table *tp)
**
** This function is called to switch tables and to restore the state
** that the table was in when we left it.
*/

void changetable (struct table *tp)
{
	curr_table -> currentstate = curr_state -> state;
	curr_table = tp;
	changestate (curr_table -> currentstate -> name);
}

void changestate (char *statename)
{
	struct tablestate *sp;
	struct enode *endstate;

	/*
	 * Better check to see whether new state is an end state...
	 */

	for (endstate = curr_table -> statename -> endstates; endstate; endstate = endstate -> next) {
		if (! strcmp (statename, endstate -> s -> name)) {
			printf ("\t*** %s is an end state ***\n", statename);
			break;
		}
	}

	/*
	 * Go through all the states in the table looking for the desired
	 * state. If it exists change to it, otherwise print an error
	 * message.
	 */

	front (&(curr_table -> tablestates));
	while (active (&(curr_table -> tablestates))) {
		sp = (struct tablestate *) return_value (&(curr_table -> tablestates));

		if (! strcmp (sp -> state -> name, statename)) {
			curr_state = sp;

			return;
		}

		get_next_member (&(curr_table -> tablestates));
	}

	printf ("\t*** State %s not found in table ***\n", statename);
}

void list_tables (void)
{
	struct table *tp;

	/*
	 * List all the tables that we know about...
	 */

	front (&tables);
	while (active (&tables)) {
		tp = (struct table *) return_value (&tables);

		if (tp == curr_table)
			printf ("> ");
		else    printf ("  ");
		printf ("%s\n", tp -> name);

		get_next_member (&tables);
	}
}

void list_states (void)
{
	struct tablestate *sp;

	/*
	 * List all the states that we know about...
	 */

	front (&(curr_table -> tablestates));
	while (active (&(curr_table -> tablestates))) {
		sp = (struct tablestate *) return_value (&(curr_table -> tablestates));

		if (sp == curr_state)
			printf ("> ");
		else    printf ("  ");
		printf ("%-24s", sp -> state -> name);

		if (sp -> state -> comment != (char *) NULL)
			printf ("%s", sp -> state -> comment);
		printf ("\n");

		get_next_member (&(curr_table -> tablestates));
	}
}

void list_events (void)
{
	struct stateevent *ep;

	/*
	 * List all the events that we know about...
	 */

	front (&(curr_state -> stateevents));
	while (active (&(curr_state -> stateevents))) {
		ep = (struct stateevent *) return_value (&(curr_state -> stateevents));

		printf ("  %-24s", ep -> event -> name);

		if (ep -> event -> comment != (char *) NULL)
			printf ("%s", ep -> event -> comment);
		printf ("\n");

		get_next_member (&(curr_state -> stateevents));
	}
}

void do_show (void)
{
	char *pred;
	struct predstruct *pp;
	int show_all = 0;

	/*
	 * Get the name of the predicate that the user wants to see...
	 */

	pred = strtok (NULL, " \t\n");
	if (pred == (char *) NULL) {
		printf ("Missing predicate\n");
		return;
	}

	if (! strcmp (pred, "all"))
		show_all = 1;

	/*
	 * Look for the predicate. If found, or if the user wants to see all
	 * the predicates, print the predicate entry...
	 */

	front (&predicates);
	while (active (&predicates)) {
		pp = (struct predstruct *) return_value (&predicates);

		if (show_all || (! strcmp (pred, pp -> name))) {
			if (pp -> value)
				printf ("%s: true   ", pp -> name);
			else    printf ("%s: false  ", pp -> name);
			printf ("(%s)\n", pp -> comment);

			if (! show_all)
				return;
		}

		get_next_member (&predicates);
	}

	if (! show_all)
		printf ("Unknown predicate %s\n", pred);
}

void do_source (void)
{
	char *file;

	/*
	 * Get filename to source...
	 */

	file = strtok (NULL, " \t\n");
	if (file == (char *) NULL) {
		printf ("Missing filename to source!\n");
		return;
	}

	/*
	 * Attempt to open the source file...
	 */

	if ((cin = fopen (file, "r")) == NULL) {
		printf ("Couldn't source %s\n", file);
		cin = stdin;
		return;
	}
}

/* void do_when (void)
**
** This function is called when the user chooses the when verb. It sets
** up certain triggers which will be fired under certain circumstances.
*/

void do_when (void)
{
	char *trigger, *cptr;
	int i;

	/*
	 * Get the trigger type.
	 */

	trigger = strtok (NULL, " (\t\n");
	if (trigger == (char *) 0) {
		printf ("Missing trigger type!\n");
		return;
	}

	/*
	 * Convert the trigger type to lower case.
	 */

	cptr = trigger;
	while (*cptr != (char) 0) {
		if (isupper (*cptr))
			*cptr = tolower (*cptr);
		cptr ++;
	}

	/*
	 * Check for a matching trigger name and if one is found call
	 * the appropriate function.
	 */

	for (i = 0; i < NUM_TRIGGERS; i ++) {
		if (! strcmp (trigger, triggers [i].name)) {
			(triggers [i].func) ();
			return;
		}
	}

	printf ("Unknown trigger type %s, ignored!\n", trigger);
}

/* void trigger_eventout (void)
**
** This function is called to set up a trigger based on an outgoing
** event.
*/

void trigger_eventout (void)
{
	char *word, *words [4];
	char *fromtable = (char *) 0,
	     *fromstate = (char *) 0,
	     *eventin = (char *) 0,
	     *eventout = (char *) 0, 
	     *totable = (char *) 0;
	int i, event_found;
	struct event_trigger et;
	struct evstruct *evp;
	struct tablestate *tstp;
	struct table *tap;
	struct stateevent *sep;

	/*
	 * Get the next component of the user's command.
	 */

	word = strtok (NULL, " (,)\t\n");

	/*
	 * Check it against certain conditions...
	 */

	i = 0;
	while (( i < 5) && (word != (char *) 0) && (strcmp (word, "send"))) {
		/*
		 * Add the word to the array of words...
		 */

		words [i ++] = word;

		/*
		 * Get the next component of the command line...
		 */

		word = strtok (NULL, " ,)\t\n");
	}

	if ((i == 5) || (word == (char *) 0)) {
		/*
		 * Whoops, the statement is not valid...
		 */

		printf ("Error in statement, should be one of:\n");
		printf ("  when eventout (Table, State, IncomingEvent, OutgoingEvent) send to Table, or\n");
		printf ("  when eventout (Table, State, OutgoingEvent) send to Table, or\n");
		printf ("  when eventout (Table, OutgoingEvent) send to Table\n");
		return;
	}

	/*
	 * Depending on what the value of i is we can fill out the various
	 * variables.
	 */

	switch (i) {
		case 4:
			/*
			 * TableName, StateName, Incoming and Outgoing
			 * EventNames provided.
			 */

			fromtable = words [0];
			fromstate = words [1];
			eventin = words [2];
			eventout = words [3];
			break;

		case 3:
			/*
			 * TableName, StateName and Outgoing EventName
			 * provided.
			 */

			fromtable = words [0];
			fromstate = words [1];
			eventout = words [2];
			break;

		case 2:
			/*
			 * Only TableName and Outgoing EventName provided.
			 */

			fromtable = words [0];
			eventout = words [1];
			break;

		default:
			/*
			 * There was an error, display a message...
			 */

			printf ("Error in statement, should be one of:\n");
			printf ("  when eventout (Table, State, IncomingEvent, OutgoingEvent) send to Table, or\n");
			printf ("  when eventout (Table, State, OutgoingEvent) send to Table, or\n");
			printf ("  when eventout (Table, OutgoingEvent) send to Table\n");
			return;
			break;
	}

	/*
	 * Get the next word in the command. It *should* be "to".
	 */

	word = strtok (NULL, " \t\n");
	if ((word == (char *) 0) || (strcmp (word, "to"))) {
		printf ("Error in command, should be ... send to Table, command ignored!\n");
		return;
	}

	/*
	 * Now get the table name that the event is to be sent to.
	 */

	word = strtok (NULL, " \t\n");
	if (word == (char *) 0) {
		printf ("Error in command, should be ... send to Table, command ignored!\n");
		return;
	}
	totable = word;

	/*
	 * Validate the table, state, and event names provided, building
	 * up the event trigger structure so that we can add it to the list
	 * of event triggers.
	 */

	/*     
	 * First of all, validate the table names provided.
	 */

	et.fromtable = (struct table *) 0;
	et.totable = (struct table *) 0;

	front (&tables);
	while (active (&tables)) {
		tap = (struct table *) return_value (&tables);

		if ((et.fromtable == (struct table *) 0) && (! strcmp (fromtable, tap -> name))) {
			/*
			 * We have found a match for the fromtable, fill out
			 * the structure accordingly.
			 */

			et.fromtable = tap;
		}

		if ((et.totable == (struct table *) 0) && (! strcmp (totable, tap -> name))) {
			/*
			 * We have found a match for the totable, fill out
			 * the structure accordingly.
			 */

			et.totable = tap;
		}

		get_next_member (&tables);
	}

	if (et.fromtable == (struct table *) 0) {
		printf ("Unknown table name %s, command ignored!\n", fromtable);
		return;
	}

	if (et.totable == (struct table *) 0) {
		printf ("Unknown table name %s, command ignored!\n", totable);
		return;
	}

	/*
	 * Now validate the event names supplied by the user.
	 */

	et.eventout = (struct evstruct *) 0;
	et.eventin = (struct evstruct *) 0;

	front (&events);
	while (active (&events)) {
		evp = (struct evstruct *) return_value (&events);

		if ((et.eventout == (struct evstruct *) 0) && (! strcmp (eventout, evp -> name))) {
			/*
			 * We have found a match for the outgoing event,
			 * update the trigger structure.
			 */

			et.eventout = evp;
		}

		if ((eventin != (char *) 0) && (et.eventin == (struct evstruct *) 0) && (! strcmp (eventin, evp -> name))) {
			/*
			 * We have found a match for the incoming event,
			 * update the trigger structure.
			 */

			et.eventin = evp;
		}

		get_next_member (&events);
	}

	if (et.eventout == (struct evstruct *) 0) {
		/*
		 * The outgoing event specified by the user wasn't found in the
		 * list of events.
		 */

		printf ("Unknown outgoing event %s, command ignored!\n", eventout);
		return;
	}

	if ((eventin != (char *) 0) && (et.eventin == (struct evstruct *) 0)) {
		/*
		 * The incoming event specified by the user wasn't found in the
		 * list of events.
		 */

		printf ("Unknown incoming event %s, command ignored!\n", eventin);
		return;
	}

	/*
	 * Now validate the state name supplied by the user (if any). There is
	 * a lot of checking to be done if it was supplied. Note that we check
	 * the states in the table specified, not the list of all possible
	 * states.
	 */

	et.fromstate = (struct stastruct *) 0;
	if (fromstate != (char *) 0) {
		front (&(et.fromtable -> tablestates));
		while (active (&(et.fromtable -> tablestates))) {
			tstp = (struct tablestate *) return_value (&(et.fromtable -> tablestates));

			if ((et.fromstate == (struct stastruct *) 0) && (! strcmp (fromstate, tstp -> state -> name))) {
				/*
				 * A matching state name was found. This is
				 * where the fun starts... First of all update
				 * the trigger structure.
				 */

				et.fromstate = tstp -> state;

				if (et.eventin != (struct evstruct *) 0) {
					/*
					 * The user specified an incoming
					 * event that the trigger is to be
					 * associated with. Check that it
					 * is actually a legal incoming
					 * event for this state.
					 */

					event_found = 0;
					front (&(tstp -> stateevents));
					while (active (&(tstp -> stateevents))) {
						sep = (struct stateevent *) return_value (&(tstp -> stateevents));

						if (sep -> event == et.eventin)
							event_found = 1;

						get_next_member (&(tstp -> stateevents));
					}

					if (! event_found) {
						printf ("Incoming event (%s) not valid for state %s, command ignored!\n", eventin, fromstate);
						return;
					}
				}
			}

			get_next_member (&(et.fromtable -> tablestates));
		}
	}

	/*
	 * Now add the trigger to the list of outgoing event triggers.
	 */

	if (! append_to_list (&event_triggers, &et, sizeof (struct event_trigger)))
		printf ("Couldn't add trigger to list of event triggers, command ignored\n");
}

void check_preds (struct cnode *c)
{
	struct cnode *ptr;

	/*
	 * For all the predicate/actionlist entries for the current event,
	 * evaluate the predicates and, if they are TRUE, display the
	 * actionlist.
	 */

	for (ptr = c; ptr; ptr = ptr -> next) {
		printf ("Evaluating ");
		display_predicates (ptr -> p);

		if (eval (ptr -> p)) {
			printf (" (TRUE)\n");
			process_actionlist (ptr -> a);
			return;
		}
		else    printf (" (FALSE)\n");
	}

	printf ("\tWARNING: No predicates satisfied\n");
}

/* void check_event_triggers (struct evstruct *ep)
**
** This function is called to check for event triggers that match the
** current table, state, incoming event and outgoing event.
*/

void check_event_triggers (struct evstruct *ep)
{
	struct event_trigger *etp;
	int trigger_found;
	struct eventq_trigger evqt;

	/*
	 * Go through the list of event triggers. As soon as a match is
	 * found process it and then return.
	 */

	front (&event_triggers);
	while (active (&event_triggers)) {
		etp = (struct event_trigger *) return_value (&event_triggers);

		/*
		 * Be positive, assume that we will find a match.
		 */

		trigger_found = 1;

		/*
		 * Start by checking the name of the outgoing event with that
		 * in the trigger.
		 */

		if (ep != etp -> eventout)
			trigger_found = 0;

		/*
		 * If the user specified an incoming event in the trigger
		 * check that against the current incoming event.
		 */

		if ((etp -> eventin != (struct evstruct *) 0) && (etp -> eventin != curr_eventin))
			trigger_found = 0;

		/*
		 * Check the state next, but only if one was specified by
		 * the user.
		 */

		if ((etp -> fromstate != (struct stastruct *) 0) && (curr_state -> state != etp -> fromstate))
			trigger_found = 0;

		/*
		 * Finally check that we are in the correct table!
		 */

		if (curr_table != etp -> fromtable)
			trigger_found = 0;

		/*
		 * Check for trigger match.
		 */

		if (trigger_found) {
			/*
			 * We have a matching trigger, process it.
			 */

			printf ("\tEVENT TRIGGER: queuing outgoing event: %s for table: %s\n", etp -> eventout -> name, etp -> totable -> name);

			/*
			 * Build up the event queue trigger and add to the
			 * event queue.
			 */

			evqt.totable = etp -> totable;
			evqt.eventin = etp -> eventout;

			if (! append_to_list (&eventq_triggers, &evqt, sizeof (struct eventq_trigger)))
				printf ("\tERROR: couldn't add triggered event to queue\n");
			
/*                      return; */
		}

		get_next_member (&event_triggers);
	}

	/*
	 * If we got here there we no event triggers fired.
	 */
}

void process_actionlist (struct anode *a)
{
	struct anode *ptr;

	/*
	 * For all the entries in the actionlist, display the entry and, if
	 * a comment exists, the comment.
	 */

	for (ptr = a; ptr; ptr = ptr -> next) {
		switch (ptr -> type) {
			case EVENT:
				printf ("\tSend outgoing event %s", ptr -> ptr.e -> name);

				if (ptr -> ptr.e -> comment != (char *) NULL)
					printf (" (%s)", ptr -> ptr.e -> comment);
				printf ("\n");
				
				/*
				 * Check for an event trigger here.
				 */

				check_event_triggers (ptr -> ptr.e);
				break;

			case STATE:
				printf ("\tChange state to %s", ptr -> ptr.s -> name);

				if (ptr -> ptr.s -> comment != (char *) NULL)
					printf (" (%s)", ptr -> ptr.s -> comment);
				printf ("\n");
				changestate (ptr -> ptr.s -> name);
				break;

			case ACTION:
				printf ("\tPerform action %s", ptr -> ptr.a -> name);

				if (ptr -> ptr.a -> comment != (char *) NULL)
					printf (" (%s)", ptr -> ptr.a -> comment);
				printf ("\n");
				break;

			case NOTE:
				printf ("\tNote: %s", ptr -> ptr.n -> name);

				if (ptr -> ptr.n -> comment != (char *) NULL)
					printf (" (%s)", ptr -> ptr.n -> comment);
				printf ("\n");
				break;
		}
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
		case PRED:      printf ("%s", p -> p -> name);
				if (p -> p -> comment != (char *) NULL)
					printf (" (%s)", p -> p -> comment);
				break;
		case AND:       printf (" AND "); break;
		case OR:        printf (" OR "); break;
		case NOT:       printf ("NOT "); break;
	}
	if (p -> r)
		display_predicates (p -> r);

	if (p -> type != PRED)
		printf (")");
}
