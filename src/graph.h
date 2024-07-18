/* File: graph.h
**
** Author: jfc, 09/01/93
**
** Copyright: (c) John Howie (jfc@cs.napier.ac.uk)
**
** Description
**
**	This header file contains some definitions and prototype functions
** for the graph functions.
*/

# ifndef __GRAPH_H__
# define __GRAPH_H__

# include "list.h"

typedef struct	{ LIST graphlist;
		  int (*cmpfunc) ();
		  int (*lenfunc) ();
		} GRAPH;

typedef struct	{ void *from;
		  void *to;
		} EDGE;

_PROTOTYPE( BOOLEAN newgraph, (GRAPH *graph, int (*cmpfunc) (), \
				int (*lenfunc) ())			);
_PROTOTYPE( BOOLEAN add_to_graph, (GRAPH *graph, void *f, void *t)	);
_PROTOTYPE( BOOLEAN remove_from_graph, (GRAPH *graph, void *f, void *t)	);
_PROTOTYPE( BOOLEAN is_connected, (GRAPH *graph, void *f, void *t)	);
_PROTOTYPE( void deletegraph, (GRAPH *graph)				);

# endif
