.nr LL +1.0i
.in .25i
.ce 2
Protocol CASE Tools - A guide for users.
(c) John Howie, 1993.
.bp  
.NH
Introduction
.LP
The case tools described in this guide are the state pre-processor (spp), the
state animator (san), and the state validator (schk). The use of each tool is
described in detail later.
.LP
Each tool has one thing in common, an input file. The format of this input file
is identical for all three tools and its syntax is described later.
.LP
The uses and applications to which the tools may be applied is outwith the
scope of this document. The first tool, the pre-processor, was designed
originally to aid implementors of OSI protocols working from the ISO and CCITT
standards. The animator and validator came later but are useful in checking
for errors in the standards and input files derived from them. All three
tools have been used to aid implementors of proprietary protocols and in
teaching the principles of protocol design.
.NH
The Input File
.LP
The input file is a text file that is used to describe the operation of a
protocol. The protocol is modelled as a Finite State Machine. The protocol
may be in one of a number of pre-determined states. A change to a new state is
made in response to an incoming event. In addition a protocol may perform
actions or send outgoing events. The actions to perform, events to send,
and changes of state may be processed conditionally depending on the
outcome of evaluating an expression made up of predicates.
.LP
The format of the input file is similar to that used in the CCITT OSI
protocol standards and a simple syntax is used to describe events, states,
actions, predicates and state change tables which describe protocol
operation.
.LP
All three tools check the input data for errors. Errors can arise due to missing
or duplicated data, incorrect syntax and missing keywords. Whenever an error is
encountered the line number of the error in the input file is reported with
a message describing the error.
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
.sp
.LP
Each is discussed in detail.
.bp
.NH 2
Event Categories
.LP
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
.NH 2
Defining Events
.LP
Events are defined by declaring the name of the event, the category it belongs
to and a description of the event. The description is optional and may be
omitted. If it is included it must be enclosed in double quotes ("), or be
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
.NH 2
Defining States
.LP
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
.sp
.NH 2
Defining Predicates
.LP
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
.sp
.NH 2
Defining Actions
.LP
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
.sp
.NH 2
State Change Tables (including Table Notes)
.LP
State change tables are used to describe operation of a protocol. One table
may be used to describe the operation of a protocol or several tables may
be used, one for each stage of protocol operation, eg. one for connection
establishment, one for data transfer, and one for connection release.
.LP
Like the tables presented in the standards the state change tables in the
input file are made up of state-event combinations. At each combination
expressions, consisting of predicates, may be used to control which, if any,
actions, state changes, and outgoing events are to be performed.
.LP
Each table uses a state variable, which must be defined before the table. There
may be one state variable for each table or tables may share a state variable.
The state variable is set to an initial state, ie. the state the system
will be in before any events occur. The syntax for defining the state variable
and it's initial state is:
.sp
.nf
define statevarname variablename initialstate some_predefined_state
.fi
.sp
.LP
If a protocol has defined end-states these may be declared with the state
variable name and initial state. The declaration must follow the initial
state declaration. The syntax is:
.sp
.nf
	endstate[s] end_state [end_state] [end_state] [...]
.fi
.sp
.LP
If the initial or end states have not been defined before use and error message
will be printed.
.LP
Table notes and the state/event/action combination are represented in a
slightly different manner to the event, action, etc. definitions. Both are
described within a table. The keyword
.UL table
signifies the start of the table. A table must have a name. Like the defines
before, the keyword
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
parser will look at the following lines. The lines will be read and
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
	event event_name	predicates : actions
	event event_name	predicates : actions; predicates: actions; ...
.fi
.sp
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
	or	|
	not	^
.fi
.sp
.LP
It is important that the predicates and actions following an event are
syntactically correct. If they are not then the parser will print
error messages and no output files will be created. The format of a each
combination will be described in turn.
.LP
Predicates followed by actions take the following form:
.sp
.nf
	predicate_list : action_list
.fi
.sp
.LP
The colon (:) and semi-colon (;) must be present, separated by a space and in
the correct place. The predicate list can, as mentioned earlier, use
logical operators to combine predicates. Brackets can also be used to group
predicates and logical operators together, eg.
.sp
.nf
	( P0 and P2 ) or not P1 : action_list
.fi
.sp
.LP
Brackets can be nested. Another predicate list may follow the semi-colon. In
this case the parser will understand this to mean that if the first
set of predicates equals a logical FALSE, the second set is to be tested.
In other words an if...then...elif...then... contruct is created.
.LP
The action list is made up of notes, events, states, and actions. Each must be
separated by a space. A note will become a comment, an event - a function call,
an action - a function call, and a state - reassign the state variable to the
value of the given state.
.LP
If an event is declared more than once for a given state an error message
will be displayed for each declaration other than the first. The associated
action list is not processed but each error should be checked. If a state is
declared more than once in a table an error message will also be displayed and
it, and all its events, will not be processed either.
.LP
For an example of what the state table declaration can look like, read the
example input file for the Transport Layer.
.bp
.NH
The State Pre-Processor
.NH 2
Overview
.LP
The state pre-processor is a code generator. It takes an input file and
produce two output files. It will only do so if the input file is parsed
without any fatal errors. Files will be created even though an input file
contains warnings or errors. If warnings or errors are generated they should
be investigated.
.NH 2
The Output Files
.LP
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
.NH 2
Using The State Pre-Processor
.LP
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
.sp
.LP
The command line options are:
.IP -c
Check only, do not produce any output files.
.IP -f
No functions, don't create empty functions. This allows
programmers to change just the state switch tables. Remember
to keep a copy of the old ones.
.IP -o
Use the following filename as a basis for the output files,
eg. '-o tl' will produce the output file tl.c and tl.h
.IP -v
Display verbose information about what the program is doing,
really only useful when debugging the pre-processor or
trying to find really tricky errors.
.LP
If you are unsure what input file was used to create an output file and on
what date, the first few lines of both the 'C' source and header files
contain this information.
.bp
.NH
The State Animator
.NH 2
Overview
.LP
The state animator is a tool that can be used by the programmer to check the
description of operation of a finite state machine before implementing it by
hand or through use of a tool such as the state pre-processor. By allowing the
programmer to check a description of operation for errors or inconsistences
before implementation the number of errors introduced at the design stage
should be minimised.
.LP
The state animator takes a file with the same format as the state
pre-processor (and described above) and, if it contains no fatal errors,
allows the user to animate it.
.NH 2
Using The State Animator
.LP
The state animator may be used to test the description of operation of a finite
state machine by simulating incoming events and setting predicate values.
The animator will respond by displaying details of the change of state (if
any) in response to incoming events and predicate values (where appropriate).
.LP
The animator will accept a number of commands at the (san) prompt. These
are event, list, quit, set, show, state, source, and table. Each will be
discussed in turn.
.LP
The animator takes, as an argument, the name of an input file to animate.
Other command line options include:
.IP -o
This option, which is not supported on all systems, instructs the debugger
to make a copy of all screen output and keyboard or file input and send it
to the file named after the switch.
.IP -v
This option turns on debugging in the parser. It generates a lot of
information that, in most cases, is not needed. It is useful in checking
syntax errors in input files.
.NH 3
event - Simulate Incoming Events
.PP
The syntax of this command is:
.sp
.nf
	(san) event eventname
.fi
.sp
.LP
where eventname is a valid event for the current state in the current
table. If the event specified does not exist then an error message is
printed. Specifying an event that is defined in the input file will cause
the animator to enter the current table for the current state and incoming
event combination. The result of this is displayed.
.LP
This result may include details of any expressions being evaluated and the
simulation of sending outgoing events, performing actions and changing state.
.LP
If the state is changed the new state is checked. If it is not in the table
an error message is displayed and the state will not change. If the state
changed to is an end state a message to this effect will be printed.
.NH 3
list - List Tables, States Or Events
.LP
The list command will take, as it's argument, one of tables, states or
events. Listing tables will cause a list of the tables defined in the input
file to be displayed. A '>' will be displayed next to the current table.
.LP
Listing states will cause a list of the states defined in the current table
to be displayed. Against the current state a '>' will be displayed.
.LP
Listing events will cause a list of the valid events for the current state
to be displayed on the screen.
.LP
Using the list command, the programmer can see what options are available
for switching between tables, states within tables, and selecting events
for the current state and table.
.NH 3
quit - Leave The Animator Gracefully
.LP
This command will close any open files and leave the program gracefully. It
should be used in preference to a CTRL-C or CTRL-D.
.NH 3
set - Set A Predicate To A Value
.LP
Predicates may be either true or false. They are used when evaluating
expressions that affect the state change mechanism. The set command takes
two arguments. The first is the name of the predicate to change, or all, and
the second is the value. The value may be one of true, TRUE, false, or FALSE.
.NH 3
show - Show A Predicate Or All Predicate Values
.LP
This command takes one argument, the name of the predicate to show. If the
name is
.UL all
then all predicate values will be shown. This is useful for attempting to
predict the operation of the state change mechanism where predicates are
involved.
.NH 3
state - Get The Current State Or Change To A State Unconditionally
.LP
This command, without any arguments, will display the name of the current
state for the current table. By specifying a current state name for the
current table, the animator will unconditionally change to the named state,
to which the next incoming event will be applied.
.NH 3
source - Read san Commands From A File
.LP
If a series of commands normally typed at the (san) prompt are used
frequently, it may be worthwhile typing them into a text file, one to a
line. The commands in this text file may then be executed by using the
source command. The only argument to this command is the name of the file
to read commands from.
.LP
Once the end of file has been reached the user is prompted for more
commands in the usual manner, ie. at the (san) prompt.
.NH 3
table - Get The Name Of The Current Table Or Change Table
.LP
This command, without any arguments, displays the name of the table
to which the current state and an incoming event are applied. By supplying
an argument, which is a valid table name, the animator will use the named
table in all future operations.
.LP
When changing table, the state of the previous table is stored. This allows
the user to switch between two tables, such as a client table and a server
table, without losing state in either table. Currently predicates are global
and if set by the user in one table, the change will be seen in another. This
may change in the future.
.LP
The author is of the opinion that if multiple tables are used and contained
in an input file then each table should relate to a particular aspect of
protocol operation, eg. connection establishment, data transfer, and connection
release. The use of two tables, one for each end of a communication path, eg.
Client and Server, is frowned upon and problems may be encountered (such as
with the predicates).
.bp
.NH
The State Validator
.NH 2
Overview
.LP
Both the pre-processor and animator parse an input file before proceeding
to either generate code or animate a description. Both will report
warnings, errors or fatal errors. These may be caused by either syntax
errors or missing and bad declarations. An input file may be parsed without
any of these occurring but it may still be incorrect. A file may be
syntactically correct but the semantics could be wrong. Most semantic
errors occur in tables and include the introduction of non-determinism or
the use of mutually exclusive predicates in an expression. The validator
attempts to point out a variety of problems, if encountered, in a
description.
.NH 2
Using The Validator
.LP
The validator, like the pre-processor and animator, is invoked with the
name of the description file as an argument. There are other command line
options. These are:
.IP -i
Ignore errors in the input file. By default the validator will abort with a
message telling users to correct all errors in an input file before
attempting to run the validator. The validator will work with a file
containing warnings.
.IP -o
Use of this option is not supported (yet) on all systems. It should be
followed by the name of an output file into which all problems found should
be reported.
.IP -v
This switches on the verbose mode of the parser and can generate pages of
debugging information. In most cases this option can be ignored.
.NH 2
Conditions Checked For By The Animator
.LP
The animator checks input files for several conditions, or rather
violations of conditions. The first is the use of predicates in
expressions. The first condition checked is that expressions can,
theoretically, evaluate true. If, for example, the predicate p1 was used in
the following expression, that expression would never evaluate true:
.sp
.nf
	p1 and (not p1)
.fi
.LP
When such an expression is encountered, an message is displayed on the
screen.
.LP
The next condition checked is that all expressions used at a state-event
combination may evaluate true and be processed. An expression might
evaluate true but never be processed due to an earlier expression, using a
subset of the predicates in the later expression, evaluates true. The
following is an example:
.sp
.nf
	state STATE1
		event EVENT1	p8 : ... ;
				p6 & p7 : ... ;
				(p6 & p7) | p8 : ...
.fi
.LP
In the above example the first two expressions can evaluate true
independantly of the other and will be processed. The third expression,
however, can evaluate true but will never be processed as either the first
or second expression will evaluate true and be processed first. This type
of error, one that can be the cause of non-determinism, will be reported.
Note that both the first two expressions can evaluate true at the same time
but this is allowed and is not considered to be a cause of non-determinism.
.LP
The validator, on checking an expression and finding that it can evaluate
true, goes on to check the associated action list. The parser will have
ensured that all outgoing events, actions and state changes have been
declared. The only possible problem is that the state change may be to a
state that is not in the current table. If there is a change of state to a
state that isn't found in the table an error message will be printed.
.LP
The final two checks made on tables are that all states in a table are
reachable from the initial state and that end states, if defined, can be
reached from every other state. Where there are more than one end state
only one end state needs to be reachable. If either a table state can't be
reached from the initial state or an end state can't be reached an error
message will be printed.
