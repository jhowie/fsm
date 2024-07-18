/* File: graph.c
**
** Author: jfc, 08/01/93
**
** Copyright: (c) John Howie (jfc@dcs.napier.ac.uk)
**
** Description
**
**	This source file contains a set of routines for handling a directed
** graph. It uses functions found in the linked list suite.
**
** Modification History
**
** 05/08/93 jfc	ANSI'fied code in readiness for port to NT.
*/

# include <stdio.h>
# include <string.h>
# include <stdlib.h>

# include "stdinclude.h"

# include "graph.h"

_PROTOTYPE( static int gstrlen, (char *str)				);
_PROTOTYPE( static BOOLEAN connected, (GRAPH graph, void *f, void *t, \
					LIST *visited));

/* static int gstrlen (char *str)
**
** This function is the default length-calculating function used by the
** graph functions.
*/

static int gstrlen (char *str)
{
	return (strlen (str) +1);
}

/* BOOLEAN newgraph (GRAPH *graph, int (*cmpfunc) (), int (*lenfunc) ())
**
** This function is used to initialise a graph and assign to it a compare
** function. If the second argument is a null pointer the default compare
** function, strcmp, is used.
*/

BOOLEAN newgraph (GRAPH *graph, int (*cmpfunc) (), int (*lenfunc) ())
{
	/*
	 * Initialise the list component of the graph first...
	 */

	if (! newlist (&(graph -> graphlist)))
		return FALSE;

	/*
	 * Assign the compare function to the graph. If the value passed is
	 * a NULL pointer, use the strcmp function.
	 */

	if (cmpfunc == NULL)
		graph -> cmpfunc = strcmp;	/* Causes compiler warnings */
	else	graph -> cmpfunc = cmpfunc;

	/*
	 * Assign the length function for the graph. If the value passed is
	 * a NULL pointer use the default which is strlen(_X) +1.
	 */

	if (lenfunc == NULL)
		graph -> lenfunc = gstrlen;
	else	graph -> lenfunc = lenfunc;

	return TRUE;
}

/* BOOLEAN add_to_graph (GRAPH *graph, void *f, void *t)
**
** This function is used to add an edge or connection to the graph.
*/

BOOLEAN add_to_graph (GRAPH *graph, void *f, void *t)
{
	EDGE edge, *eptr;

	/*
	 * Check all the edges in the graph. If there is is already one
	 * (f, t) don't bother adding this one, it doesn't make sense.
	 */

	front (&(graph -> graphlist));
	while (active (&(graph -> graphlist))) {
		eptr = (EDGE *) return_value (&(graph -> graphlist));

		if (! (graph -> cmpfunc) (eptr -> from, f) && ! (graph -> cmpfunc) (eptr -> to, t)) {
			/*
			 * The edge already exists, just return true...
			 */

			return TRUE;
		}

		get_next_member (&(graph -> graphlist));
	}

	/*
	 * Fill in the edge structure and add it to the list of edges that make
	 * up the graph. We know we are at the end of the list because of the
	 * above search so just use insert () ...
	 */

	edge.from = f;
	edge.to = t;

	return (insert (&(graph -> graphlist), &edge, sizeof (EDGE)));
}

/* BOOLEAN is_connected (GRAPH *graph, void *from, void *to)
**
** This function determines whether or not there is a path between from and
** to. It does not attempt to calculate the best or shortest path. That is
** left to other, faster, functions.
*/

BOOLEAN is_connected (GRAPH *graph, void *from, void *to)
{
	GRAPH graphcopy;
	LIST visited;
	EDGE *eptr;
	int ret_val;

	/*
	 * First of all, check that there isn't an edge (from, to) in the
	 * graph. If there is it would make sense to look for it here and now.
	 */

	front (&(graph -> graphlist));
	while (active (&(graph -> graphlist))) {
		eptr = (EDGE *) return_value (&(graph -> graphlist));
		if ((! (graph -> cmpfunc) (eptr -> from, from)) && (! (graph -> cmpfunc) (eptr -> to, to)))
			return TRUE;
		get_next_member (&(graph -> graphlist));
	}

	/*
	 * There is not a direct connection. We now have to search for a path
	 * through the graph. Start by initialising the two lists we use.
	 */

	(void) newlist (&visited);
	if (! insert (&visited, from, graph -> lenfunc (from))) {
		fprintf (stderr, "couldn't add to list of visited noeds\n");
		exit (1);
	}

	bcopy (graph, &graphcopy, sizeof (GRAPH));

	ret_val = connected (graphcopy, from, to, &visited);
	deletelist (&visited);
	return ret_val;
}

/* static BOOLEAN connected (GRAPH graph, void *f, void *t, LIST *visited)
**
** This is a recursive function that works out intermediate paths between the
** real from and to. Note that to, or t, usually remains constant throughout.
*/

static BOOLEAN connected (GRAPH graph, void *f, void *t, LIST *visited)
{
	EDGE *eptr;
	int been_visited;

	front (&graph.graphlist);
	while (active (&graph.graphlist)) {
		eptr = (EDGE *) return_value (&graph.graphlist);
		if (! (graph.cmpfunc) (eptr -> from, f)) {
			/*
			 * We have found an edge that emanates from the node
			 * specified by f. Check that where it goes, to, is
			 * not where we want to go or in the list of nodes
			 * visited already.
			 */

			if (! (graph.cmpfunc) (eptr -> to, t)) {
				/*
				 * This is where we wanted to get to! Return
				 * TRUE so that it gets reported back...
				 */

				return TRUE;
			}

			been_visited = 0;
			front (visited);
			while (active (visited)) {
				/*
				 * Compare the node that the edge goes to with
				 * nodes in the list of visited nodes.
				 */

				if (! (graph.cmpfunc) (eptr -> to, return_value (visited))) {
					been_visited = 1;
					break;
				}

				get_next_member (visited);
			}

			if (! been_visited) {
				/*
				 * The node has not been visited. Call this
				 * function recursively to try and establish
				 * a link with where we wish to go.
				 */

				if (! insert (visited, eptr -> to, graph.lenfunc (eptr -> to))) {
					fprintf (stderr, "couldn't insert node to list of visited nodes\n");
					exit (1);
				}

				if (connected (graph, eptr -> to, t, visited))
					return TRUE;
			}
		}

		get_next_member (&graph.graphlist);
	}

	/*
	 * We couldn't find a path at this level...
	 */

	return FALSE;
}
	
/* void deletegraph (GRAPH *graph)
**
** This function just clears the compare function and calls deletelist. It DOES
** NOT free any of the pointers. If memory was malloc'ed and passed as nodes
** to the add function it must be de-allocated in another manner.
*/

void deletegraph (GRAPH *graph)
{
	graph -> cmpfunc = NULL;
	graph -> lenfunc = NULL;
	deletelist (&(graph -> graphlist));
}
