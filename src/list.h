/* File: list.h
**
** Author: jfc, 1990...
**
** Copyright: (c) John Howie (jfc@dcs.napier.ac.uk)
**
** Modification History
**
** 22/11/90 jfc	Modified for SunOS kernel applications.
**
** 05/08/93 jfc	Modified for port to NT...
*/

# ifndef __LIST_H__
# define __LIST_H__

# ifndef MALLOC
# ifdef KERNEL
# define MALLOC		kmem_alloc
# define FREE		kmem_free
# else
# define MALLOC		malloc
# define FREE		free
# endif
# endif

typedef int	BOOLEAN;

typedef struct node	{ struct node *link;
			  long data_size;
			  char data [1];
			} NODE;

typedef NODE	*PTRNODE;

# define NIL		(PTRNODE)NULL

typedef struct		{ PTRNODE list_start;
			  PTRNODE list_last;
			  PTRNODE list_current;
			  PTRNODE list_last_save;
			  PTRNODE list_current_save;
			  BOOLEAN modified;
			  unsigned long num_in_list;
			} LIST;

_PROTOTYPE( BOOLEAN newlist, (LIST *list_id));
_PROTOTYPE( BOOLEAN empty, (LIST *list_id));
_PROTOTYPE( BOOLEAN active, (LIST *list_id));
_PROTOTYPE( void front, (LIST *list_id));
_PROTOTYPE( void get_next_member, (LIST *list_id));
_PROTOTYPE( BOOLEAN insert, (LIST *list_id, void *data, int length));
_PROTOTYPE( BOOLEAN delete_node, (LIST *list_id));
_PROTOTYPE( void *return_value, (LIST *list_id));
_PROTOTYPE( BOOLEAN append_to_list, (LIST *list_id, void *data, int length));
_PROTOTYPE( void save_ptrs, (LIST *list_id));
_PROTOTYPE( void restore_ptrs, (LIST *list_id));
_PROTOTYPE( void deletelist, (LIST *list_id));
_PROTOTYPE( unsigned long countlist, (LIST *list));

# endif
