/* File: tidyfuncs.c
**
** Author: jfc, 12/01/93
**
** Copyright: (c) John Howie (jfc@cs.napier.ac.uk)
**
** Description
**
**	Functions in this file are called to tidy up memory used for cnode's,
** anode's, pnode's and enode's amongst others.
*/

# include "list.h"
# include "states.h"

void delete_cnodes ();
void delete_anodes ();
void delete_pnodes ();

void delete_cnodes (cp)
struct cnode *cp;
{
	struct anode *ap;
	struct pnode *pp;

	if (cp -> next)
		delete_cnodes (cp -> next);

	delete_pnodes (cp -> p);
	delete_anodes (cp -> a);

	free ((void *) cp);
}

void delete_pnodes (pp)
struct pnode *pp;
{
	if (pp -> l)
		delete_pnodes (pp -> l);

	if (pp -> r)
		delete_pnodes (pp -> r);

	free ((void *) pp);
}

void delete_anodes (ap)
struct anode *ap;
{
	if (ap -> next)
		delete_anodes (ap -> next);

	free ((void *) ap);
}
