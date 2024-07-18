.nr LL +1.5i
.in +0.5i
.ad b
.PP
.ce 2
san - A Tool For Animating State Machine Descriptions
(c) John Howie, 1992
.bp
.SH
1. Introduction
.PP
This document describes how to use the State Animator to test and debug the
description of operation for a Finite State Machine.
.sp 2
.SH
2. Overview Of The State Animator
.PP
The state animator is a tool that can be used by the programmer to check the
description of operation of a finite state machine before implementing it by
hand or through use of a tool such as the state pre-processor. By allowing the
programmer to check a description of operation for errors or inconsistences
before implementation the number of errors introduced at the design stage
should be minimised.
.LP
The state animator takes a file whose contents follow a defined syntax and
checks it for errors. If there are no errors the animator will prompt the
user for further instructions. For more details on the format of the input
file please consult the handout:
.sp
.nf
		spp - A State Pre-Processor
.fi
.sp
.bp
.SH
3. Using The State Animator
.PP
The state animator may be used to test the description of operation of a finite
state machine by simulating incoming events and setting predicate values.
The animator will respond by displaying details of the change of state (if
any) in response to incoming events and predicate values (where appropriate).
.LP
The animator will accept a number of commands at the (san) prompt. These
are event, list, quit, set, show, state, source, and table. Each will be
discussed in turn.
.sp
.SH
3.1 event - Simulate Incoming Events
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
simulation of sending outgoing events, performing actions and cahnging state.
.sp
.SH
3.2 list - List Tables, States Or Events
.PP
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
.sp
.SH
3.3 quit - Leave The Animator Gracefully
.PP
This command will close any open files and leave the program gracefully. It
should be used in preference to a CTRL-C or CTRL-D.
.sp
.SH
3.4 set - Set A Predicate To A Value
.PP
Predicates may be either true or false. They are used when evaluating
expressions that affect the state change mechanism. The set command takes
two arguments. The first is the name of the predicate to change, or all, and
the second is the value. The value may be one of true, TRUE, false, or FALSE.
.sp
.SH
3.5 show - Show A Predicate Or All Predicate Values
.PP
This command takes one argument, the name of the predicate to show. If the
name is
.UL all
then all predicate values will be shown. This is useful for attempting to
predict the operation of the state change mechanism where predicates are
involved.
.sp
.SH
3.6 state - Get The Current State Or Change To A State Unconditionally
.PP
This command, without any arguments, will display the name of the current
state for the current table. By specifying a current state name for the
current table, the animator will unconditionally change to the named state,
to which the next incoming event will be applied.
.sp
.SH
3.7 source - Read san Commands From A File
.PP
If a series of commands normally typed at the (san) prompt are used
frequently, it may be worthwhile typing them into a text file, one to a
line. The commands in this text file may then be executed by using the
source command. The only argument to this command is the name of the file
to read commands from.
.LP
Once the end of file has been reached the user is prompted for more
commands in the usual manner, ie. at the (san) prompt.
.sp
.SH
3.8 table - Get The Name Of The Current Table Or Change Table
.PP
This command, without any arguments, displays the name of the table
to which the current state and an incoming event are applied. By supplying
an argument, which is a valid table name, the animator will use the named
table in all future operations.
