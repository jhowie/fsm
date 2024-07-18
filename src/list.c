/* File: list.c
**
** Author: jfc, 1990...
**
** Copyright: (c) John Howie (jfc@dcs.napier.ac.uk)
**
** Description
**
**  This file contains the linked list functions used in the program. It
** is extremely generic and can be adapted for use elsewhere.
**
** jfc, 08/05/90	changed code so that it doesn't know what it is going
**			to store...
**
** jfc, 27/07/90	changed code for non-ANSI C compiler (minix)...
**
** jfc, 22/11/90	modified so that code will work in kernel applications
**			in SunOS environments, changes are within # ifdef KERNEL
**
** 05/08/93 jfc	ANSI'fied code (again) so that port to NT will work... Code
**		should *really* be completely re-worked and improved.
*/

# include <stdlib.h>
# include <string.h>

# include "stdinclude.h"

# include "list.h"

/* BOOLEAN newlist (LIST *)
**
**  This function will initialise the list structure passed to it. It will
** always return true.
*/

BOOLEAN newlist (LIST *list_id)
{
	list_id -> list_start =NIL;
	list_id -> list_last =NIL;
	list_id -> list_current =NIL;
	list_id -> list_last_save =NIL;
	list_id -> list_current_save =NIL;
	list_id -> num_in_list =0;
	list_id -> modified =FALSE;

	return (TRUE);
}

/* BOOLEAN empty (LIST *)
**
**  This function will return TRUE if the list contains no items.
*/

BOOLEAN empty (LIST *list_id)
{
	return (list_id -> list_start == NIL);
}

/* BOOLEAN active (LIST *)
**
**  This function will return TRUE if the current node (item) holds anything.
** It is primarily used to test end of list.
*/

BOOLEAN active (LIST *list_id)
{
	return (list_id -> list_current != NIL);
}

/* void front (LIST *)
**
**  This function goes to the front of the list.
*/

void front (LIST *list_id)
{
	list_id -> list_last = NIL;
	list_id -> list_current = list_id -> list_start;
}

/* void get_next_member (LIST *)
**
**  This function will make the list look to the next member of the list.
*/

void get_next_member (LIST *list_id)
{
	if (active (list_id)) {
		list_id -> list_last = list_id -> list_current;
		list_id -> list_current = list_id -> list_current -> link;
	}
}

/* BOOLEAN insert (LIST *, void *, int)
**
**  This function will insert the data pointed to by the second argument into
** the list pointed to by the first argument. The length of the item is the
** third argument. The item will be inserted BEFORE the current node (item).
** The function will return TRUE if it was successful, otherwise it will
** return FALSE.
*/

BOOLEAN insert (LIST *list_id, void *value, int length)
{
	PTRNODE new_node;

	/*
	 * allocate memory for linked list node
	 */

	if ((new_node = (PTRNODE) MALLOC ((sizeof (NODE) +(length -1)))) == NIL) {

		/*
		 * MALLOC failed...
		 */

		return (FALSE);
	}
	else {
		/*
		 * allocate memory for data pointed to by node
		 */

# ifdef KERNEL
		/*
		 * make a note of the length of the data
		 */

		new_node -> data_size = length;
# endif

		/*
		 * copy data into area of memory so we don't lose it
		 */

		memcpy (new_node -> data, value, length);

		/*
		 * insert new node in front of the current node
		 */

		new_node -> link = list_id -> list_current;
		if (list_id -> list_last != NIL)
			list_id -> list_last -> link = new_node;
		else
			/*
			 * new node is also the new start of the list
			 */

			list_id -> list_start = new_node;

		/*
		 * make the list current point to inserted node
		 */

		list_id -> list_current = new_node;

		list_id -> modified = TRUE;
		list_id -> num_in_list ++;
		return (TRUE);
	}
}

/* BOOLEAN delete_node (LIST *)
**
**  This functione deletes the current node. It will return TRUE if it was
** successful otherwise it will return FALSE.
*/

BOOLEAN delete_node (LIST *list_id)
{
	PTRNODE old;

	/*
	 * make sure we having something to delete
	 */

	if (active (list_id)) {
		/*
		 * detach node from list
		 */
		old = list_id -> list_current;
		list_id -> list_current = list_id -> list_current -> link;

# ifdef KERNEL
		/*
		 * FREE up all the space we used
		 */

		FREE ((void *) old, old -> length);
# else
		/*
		 * FREE the old list node
		 */

		FREE ((void *) old);
# endif

		/*
		 * reconnect the list
		 */

		if (list_id -> list_last != NIL)
			list_id -> list_last -> link = list_id -> list_current;
		else
			list_id -> list_start = list_id -> list_current;

		list_id -> num_in_list --;
		list_id -> modified =TRUE;
		return (TRUE);
	}
	else
		return (FALSE);
}

/* void *return_value (LIST *)
**
**  This function will return a pointer to the current data pointed to in the
** linked list.
*/

void *return_value (LIST *list_id)
{
	/*
	 * return pointer to data
	 */

	return ((void *) list_id -> list_current -> data);
}

/* BOOLEAN append_to_list (LIST *, void *, int)
**
**  This function will add the data pointed to by the second argument to the
** list pointed to by the first. The length of the data to be added is the
** third argument. The item is added to the end of the list. As we don't know
** where the end of the list is we just search for it. The routine doesn't
** return a success or failure - use with caution.
*/

BOOLEAN append_to_list (LIST *list_id, void *data_in, int length)
{
	/*
	 * go to front of list
	 */

	front (list_id);

	/*
	 * while not at end of list
	 */

	while (active (list_id))

		/*
		 * get next member of list
		 */

		get_next_member (list_id);

	/*
	 * append the data
	 */

	return (insert (list_id, data_in, length));
}

/* void save_ptrs (LIST *)
**
**  This function is used to store where we are in the list if another part
** of our program is going to change it. Allows us to be extra sure that the
** code won't blow up in our face.
*/

void save_ptrs (LIST *list_id)
{
	list_id -> list_last_save = list_id -> list_last;
	list_id -> list_current_save = list_id -> list_current;
}

/* void restore_ptrs (LIST *)
**
**  This function will restore the pointers that we saved earlier.
*/

void restore_ptrs (LIST *list_id)
{
	list_id -> list_last = list_id -> list_last_save;
	list_id -> list_current = list_id -> list_current_save;
}

void deletelist (LIST *list_id)
{
	front (list_id);
	while (active (list_id))
		(void) delete_node (list_id);
}

unsigned long countlist (LIST *list_id)
{
	return (list_id -> num_in_list);
}
