.nr LL +1.5i
.in +0.5i
.ad b
.PP
.ce 2
spp - A State Pre-Processor
(c) John Howie, 1992
.bp
.SH
1. Introduction
.PP
This document describes how to use the State Pre-Processor (SPP) and the uses
to which it may be put.
.sp 2
.SH
2. Overview Of The State Pre-Processor
.PP
The state pre-processor is a tool that can be used by the programmer to cut down
both software development and maintenance time. It can also cut down the
number of compile and runtime errors that may occur.
.LP
The state pre-processor takes a file whose contents follow a defined syntax and
checks it for errors. This file describes a finite state machine. If there are
no errors the pre-processor will, unless otherwise directed, produce two output
files. The first is a header file containing definitions and function
prototypes. The second is a 'C' source code file that uses information in the
header file. All information is derived from the file used for input.
.LP
The output files can form the heart of a state driven module or program. The
programmer is expected to add code to the empty functions in the 'C' source
file or to provide support functions of the same name.
.bp
.SH
3. Overview Of A State Machine
.PP
Many programs and modules that are written with real time or data communication
systems in mind are state driven. They are often called
.UL Finite
.UL State
.UL Machines
or
.UL Automatons .
.LP
The unique property of these systems is that they always know what state they
are currently in. These systems can only change into another state as a result
of an event occurring. The system will follow a rigid set of rules to determine
what it's new state will be taking into account it's current state and the
nature of the event. The system will only change into a valid state. This means
that if the event is illegal for the current state or conditions do not permit
a change into the new state the system must take action to recover from the
error condition.
.LP
When an automaton starts it is in an initial state. An automaton may terminate
only when it is in a pre-determined state. There may be more than one state in
which an automaton may terminate. The state or states that an automaton may be
in or terminate at will not change between invocations of the automaton or
during execution unless the state change tables are modified. An automaton will
not normally modify it's own state change tables.
.sp 2
.SH
4. Applications To Which The State Pre-Processor May Be Applied
.PP
The state pre-processor was written to convert the information held in the
standard for the ISO's Transport Layer into 'C' source code. All the information
was taken from an Annex dedicated to describing the state change mechanism. This
information is represented by a series of tables. All the events, states,
actions to be taken, and predicates for state changes are described in a tabular
form.
.LP
The ISO's Session and Presentation Layers in the OSI Protocol Stack also have
state change tables described in tabular form. The information is described
slightly differently but can be easily changed to conform to the syntax
required by the pre-processor.
.LP
Although the pre-processor was written with the ISO's standards in mind it can
be used in many other applications. In fact, any module that can, or requires,
to be implemented as an automaton can benefit from use of the pre-processor.
.LP
A piece of software is a candidate for implementation as an automaton if it
has a notion of events and states and can only change state in response to
events.
.bp
.SH
5. The Input File
.PP
The input file contains all the information required by the state pre-processor
to produce the two output files. The pre-processor is coded so that it can
understand a defined syntax. The input file is free format.
This syntax is used to describe events, states,
actions, predicates and state change tables. By looking at the file, once
coded, it is possible to see how the state pre-processor works.
.LP
Before the state pre-processor writes out any data to one of the output files
it will check the input data for errors. Errors can arise due to missing or
duplicated data, incorrect syntax and missing keywords. Whenever an error is
encountered the pre-processor will report the line number in the input file
where it thinks the error is.
.LP
The following information is defined in the input file:
.sp 1
.nf
	Event Categories (as part of Event definitions)
	Events
	States
	Predicates
	Actions
	State Change Tables (including Table Notes)
.fi
.LP
Each is discussed in detail.
.bp
.SH
5.1 Event Categories
.PP
Each event must belong to a category. It may be that all events belong to one
category or that one category holds some events while another category has
others. An event can belong to only one category. A category is often used to
describe the source of an event, eg. all events relating to timers may belong
to a category called Time_Events.
.LP
Event categories are determined whilst processing event declarations.
Unlike previous versions of the State Pre-Processor there is no need, or
facility, to define categories explicitly before use in event
declarations.
.bp
.SH
5.2 Events
.PP
Events are defined by declaring the name of the event, the category it belongs
to and a description of the event. The description is optional and may be
ommitted. If it is included it must be enclosed in double quotes ("), or be
escaped by using the ANSI 'C' or C++ comment delimiters, /* ... */ or //.
.LP
Events need not be declared all at the same time. If an event is declared
twice the pre-processor will display a warning message. The actual entry in the
input file could be different, ie. the event could have a different category
or event description than the previous declaration, but the pre-processor will
not check past the event name if it has been declared previously. It is wise,
therefor, to check all warnings about duplicate events.
.LP
The syntax for defining events is:
.sp
.nf
define events
begin
	event_name	category_name	"event description here"
	event_name	category_name	"event description here"
	event_name	category_name	"event description here"
	.
	.
	.
	event_name	category_name	"event description here"
end
.bp
.SH
5.3 States
.PP
The input file requires that all the states that the automaton can be in
be defined before use in a state change table. The reason for this is to
add to the amount of error checking that can be done. By checking the states
used in the state change table against the list defined earlier the programmer
can be more confident about the output files. It would be easy, say, for a
typing error in the state change table to cause a new state to be created. The
ISO and CCITT documents used when developing the state pre-processor defined
states before the state change table.
.LP
Another benefit of defining the states before the state change table is that
the states can have explanatory text and doing this once per state is more
desirable than somehow declaring the text every time the state is encountered
in the state change table.
.LP
The pre-processor will check that a state has not been previously declared in
the input file. If it has a warning message is printed along with some other
information. If a duplicate is found any explanatory text given is ignored.
.LP
As with events, the description field is optional but, if included, must be
between double quotes (") or be represented as a comment.
.LP
The syntax for declaring states is:
.sp
.nf
define states
begin
	state_name	"explanatory text"
	state_name	"explanatory text"
	state_name	"explanatory text"
	.
	.
	.
	state_name	"explanatory text"
end
.fi
.bp
.SH
5.4 Predicates
.PP
The definition of a predicate is unlike that of event categories, events or
states. The reason is that a predicate is a function that will either return
TRUE or FALSE depending on whether or not the predicate is true. The state
change table can have a predicate or combination of predicates followed by
an action list that is to be executed if the predicate list is logically TRUE.
.LP
The fact that a predicate is a function whose return value is to be used is a
problem as the name of the function to be executed when the predicate is
encountered is not defined anywhere.
.LP
The state pre-processor will prototype a predicate function and, unless
otherwise directed, create an empty function to handle the predicate
evaluation. The function name used is the predicate name. Predicate names
must start with an upper or lower case P followed by a numeric identifier.
The pre-processor is case sensitive so, for example, P15 is not the same
predicate as p15.
.LP
Like event categories, events and states before, duplicate predicates are
ignored. Again, if a duplicate is found, the rest of the information provided
with the predicate name is not checked. This means that all warning messages
should be investigated. Predicates need not be declared together. Also, the
sames rules for explanatory text exist for predicates.
.LP
The predicates are defined in the following manner:
.sp
.nf
define predicates
begin
	predicate_name	"explanatory text"
	predicate_name	"explanatory text"
	predicate_name	"explanatory text"
	.
	.
	.
	predicate_name	"explanatory text"
end
.fi
.bp
.SH
5.5 Actions
.PP
Actions, like predicates, have functions to be called associated with them.
When an action is encountered in an action list in the state change table the
name of the action is replaced with a call to the corresponding function in
the 'C' source output file. The pre-processor will prototype and create an
empty function whose name is based on the action identifier. The action
identifier consists of a numeric identifier between square brackets, eg.
[05].
.LP
Like all the others before, duplicate actions are ignored. When a duplicate
action is encountered the pre-processor doesn't check any other information
provided.
.LP
The syntax for declaring actions is:
.sp
.nf
define actions
begin
	action_name	"explanatory text"
	action_name	"explanatory text"
	action_name	"explanatory text"
	.
	.
	.
	action_name	"explanatory text"
end
.fi
.bp
.SH
5.6 State Change Table (including Table Notes)
.PP
The real work done by the pre-processor is when it converts the state change
table(s) from the input file into 'C' source code. The table(s) contain
information about states, the events that can occur, the predicates and actions
associated with each event and, optionally, table notes.
.LP
Before the state change table can be converted to 'C' source code the
pre-processor has to know what the name of the state variable is. The state
variable is used to keep track of the current state of a system. A state
variable may be used in many tables or each table can use it's own state
variable. When producing the 'C' source file the state pre-processor uses
the most recently declared state variable for each table.
The state variable is set to an initial state, ie. the state the system
will be in before any events occur. The syntax for defining the state variable
and it's initial state is:
.sp
.nf
define statevarname variablename initialstate some_predefined_state
.fi
.LP
If the initial state has not been previously defined the pre-processor will
print an error message.
.LP
Table notes and the state/event/action combination are represented in a
slightly different manner to the event, action, etc. definitions. Both are
described within a table. The keyword
.UL table
signifies the start of the table. A table must have a name. This name becomes
the name of the function that handles the state switch mechanism when the 'C'
source code is written out. Like the defines before the keyword
.UL begin
marks the beginning proper. It must follow the table declaration.
.LP
Once in the table notes and states can be declared. Notes are declared using
the keyword
.UL notes .
Notes have the format note identifier, a number between circular brackets,
eg. (24), followed by note text. The notes are terminated by the keyword
.UL state ,
which signifies the beginning of a state declaration or by the keyword
.UL end .
If a note name is a duplicate of a previous note name a warning message is
printed and the rest of the note declaration, ie. the note text, is ignored.
The keyword
.UL end
also terminates the table. It is important to remember that notes are table
specific and if more than one table is declared and the notes are used in
the second table they will have to be declared in the second table.
.LP
Like notes, states are declared using the
.UL state
keyword. This keyword is followed by a state name. If the state name was not
declared earlier in a 'define states' an error message is printed. If the
state name is a duplicate, ie. a 'state statename' is the same as an earlier
one in the same table, the state and all it's related events are ignored. All
warnings of this nature should be investigated. If the state name has been
declared previously but not used already in the current table the
pre-processor will look at the following lines. The lines will be read and
considered to be part of the current state description until the keyword
.UL state
or
.UL notes
or
.UL end
is encountered. Each of the following lines relates to a particular event
that can occur when the system is in the current state. The format of the
event lines are
.sp
.nf
	event event_name	actions
	event event_name	predicates : actions;
	event event_name	predicates: actions; predicates: actions; ...
.fi
.LP
The actions are made up of actions, events, table notes, or a combination of
these. Predicates can be combined with the logical operators
.UL and ,
.UL or ,
and
.UL not .
Instead of words the following symbols can be used.
.sp
.nf
	and	&
	not	^
.fi
.LP
It is important that the predicates and actions following an event are
syntactically correct. If they are not then the pre-processor will print
error messages and no output files will be created. The format of a each
combination will be described in turn.
.LP
Predicates followed by actions take the following form:
.sp
.nf
	predicate_list : action_list
.fi
.LP
The colon (:) and semi-colon (;) must be present, separated by a space and in
the correct place. The predicate list can, as mentioned earlier, use
logical operators to combine predicates. Brackets can also be used to group
predicates and logical operators together, eg.
.sp
.nf
	( P0 & P2 ) or not P1 : action_list
.fi
.LP
Brackets can be nested. Another predicate list may follow the semi-colon. In
this case the pre-processor will understand this to mean that if the first
set of predicates equals a logical FALSE, the second set is to be tested.
In other words an if...then...elif...then... contruct is created.
.LP
The action list is made up of notes, events, states, and actions. Each must be
separated by a space. A note will become a comment, an event - a function call,
an action - a function call, and a state - reassign the state variable to the
value of the given state.
.LP
If an event is declared twice for a given state the pre-processor will print
a warning message and skip onto the next event. It does not check the rest
of the event description. For this reason all warnings should be investigated.
.LP
For an example of what the state table declaration can look like, read the
example input file for the Transport Layer.
.bp
.SH
6. The Output Files
.PP
As stated above, the state pre-processor will produce two output files from
an input file. The first file is a header file. This contains definitions of
categories, events, and states. Each is given a unique number such that, eg., no
two events can have the same number but an event and a state could. In addition
to defining the categories, events and states, the functions associated with
each of the predicates and actions are prototyped. It is up to the programmer
to decide whether or not the values given to the definitions are changed or
not and whether or not to add more information to the header file.
.LP
The 'C' source file is both syntactically and semantically correct and can be
run through a 'C' compiler as is. The programmer should, however, modify the
source code. If the state pre-processor was run with no special options a set
of empty functions will be created. There is one function for each predicate
and action. Their names correspond to predicates and actions defined in the
input file. The
programmer should fill out the functions to check the required conditions and
to perform the necessary actions. Two other functions are created. The first,
called badstate (), is called whenever a bad state is entered into in the
state switch mechanism. The second is called badevent (). It is called whenever
an event is not catered for in a state. The programmer should also code these
two functions to do whatever error recovery is required. The only other
functions found in the source code file are those relating to the table
declarations in the input file, one per table. The functions are given the
name as supplied by the programmer in the input file. These functions may
need alteration to suit particular circumstances, eg. where a table note says
that something is to be done but no actions or events are present to do it.
.LP
One other function that needs coding is not created by the state pre-processor.
It is called eventout () and is passed the event that is to be sent out.
.bp
.SH
7. Using The State Pre-Processor
.PP
The state pre-processor will take command line arguments that will influence
that way that it operates. In the simplest form of invocation the state
pre-processor will take an input file and produce two files called states_out.c
and states_out.h, eg.
.sp
.nf
	% ls
	stateinfile
	% spp stateinfile
	.
	.
	.
	% ls
	stateinfile	states_out.c	states_out.h
	%
.fi
.LP
The command line options are:
.sp
.nf
	-c   Check only, do not produce any output files.

	-f   No functions, don't create empty functions. This allows
	     programmers to change just the state switch tables. Remember
	     to keep a copy of the old ones.

	-o   Use the following filename as a basis for the output files,
	     eg. '-o tl' will produce the output file tl.c and tl.h

	-v   Display verbose information about what the program is doing,
	     really only useful when debugging the pre-processor or
	     trying to find really tricky errors.
.fi 
.LP
When using the state pre-processor check all warnings that are printed and
check the summary at the end. If there are any errors no output files will
be created and any previous output files with the same names are removed.
.LP
If you are unsure what input file was used to create an output file and on
what date, the first few lines of both the 'C' source and header files
contain this information.
