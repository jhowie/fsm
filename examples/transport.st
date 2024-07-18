# transport layer state change definitions and tables
# by jfc, 26/12/90
#
# The following are all incoming events
#
define events
begin
	TCONreq		TS_user	/* T-CONNECT request primitive */
	TCONresp	TS_user	/* T-CONNECT response primitive */
	TDTreq		TS_user	/* T-DATA request primitive */
	TEXreq		TS_user	/* T-EXPEDITED DATA request primitive */
	TDISreq		TS_user	/* T-DISCONNECT request primitive */
	NDISind		NS_provider	/* N-DISCONNECT indication primitive */
	NCONconf	NS_provider	/* N-CONNECT indication primitive */
	NRSTind		NS_provider	/* N-RESET indication primitive */
#
	CR		TPDU	/* Connection request TPDU */
	CC		TPDU	/* Connection confirm TPDU */
	DR		TPDU	/* Disconnect request TPDU */
	DC		TPDU	/* Disconnect confirm TPDU */
	AK		TPDU	/* Data acknowledgement TPDU */
	EA		TPDU	/* Expedited data acknowledgement TPDU */
	DT		TPDU	/* Data TPDU */
	ED		TPDU	/* Expedited data TPDU */
	ER		TPDU	/* TPDU error TPDU */
	RJ		TPDU	/* Reject TPDU */
end
#
# The following are the possible states
#
define states
begin
	WFNC		/* Wait for network connection */
	WFCC		/* Wait for the CC TPDU */
	WBCL		/* Wait before releasing (wait for CC TPDU before sending the DR TPDU) */
	OPEN		/* Transport connection is open */
	CLOSING		/* Release in progress */
	WFTRESP		/* Wait for T_CONNECT response */
	CLOSED		/* Transport connection is closed */
	WFNC_R		/* Wait for network connection and reassignment in progress */
	WFCC_R		/* Wait for CC TPDU and reassignment in progress */
	WBCL_R		/* Wait before realeasing and reassignment in progress */
	OPEN_R		/* Open and reassignment in progress */
	OPEN_WR		/* Open and wait for reassignment */
	CLOSING_R	/* Release in progress and reassignment in progress */
	CLOSING_WR	/* Release in progress and wait for reassignment */
	WFTRESP_WR	/* Wait for T-CONNECT response and wait for assignment */
	WBCL_WR		/* Wait before releasing and wait for reassignment */
	CLOSING_BOC	/* Wait before open complete and release in progress */
	CLOSING_BOC_WR	/* Idem and wait for reassignment */
	ACKWAIT		/* Wait for acknowledgement of CC TPDU */
	REFWAIT		/* Waiting for frozen reference time */
end
#
# The following are outgoing events
#
define events
begin
	TCONind		TS_provider	/* T-CONNECT indication primitive */
	TCONconf	TS_provider	/* T-CONNECT confirm primitive */
	TDTind		TS_provider	/* T-DATA indication primitive */
	TEXind		TS_provider	/* T-EXPEDITED DATA indication primitive */
	TDISind		TS_provider	/* T-DISCONNECT indication primitive */
	NDISreq		NS_user	/* N-DISCONNECT request primitive */
	NRSTresp	NS_user	/* N-RESET response primitive */
	NCONreq		NS_user	/* N-CONNECT request primitive */
#
	CR		TPDU		/* Connection request TPDU */
	CC		TPDU		/* Connection confirm TPDU */
	DR		TPDU		/* Disconnect request TPDU */
	DC		TPDU		/* Disconnect confirm TPDU */
	AK		TPDU		/* Data acknowledgement TPDU */
	EA		TPDU		/* Expedited data acknowledgement TPDU */
	DT		TPDU		/* Data TPDU */
	ED		TPDU		/* Expedited data TPDU */
	ER		TPDU		/* TPDU error TPDU */
	RJ		TPDU		/* Reject TPDU */
end
#
# Define the predicates for classes 0 and 2
#
define predicates
begin
	P0	/* T-CONNECT request unacceptable */
	P1	/* Unacceptable CR TPDU */
	P2	/* No network connection available */
	P3	/* Network connection available and open */
	P4	/* Network connection available and open in progress */
	P5	/* Class is class 0 (class selected in CC) */
	P6	/* Unacceptable CC */
	P7	/* Class is class 2 */
	P8	/* Acceptable CC */
	P9	/* Class 4 CR */
end
#
# Define the actions allowed for classes 0 and 2.
#
define actions
begin
	[1]	/* If the network connection is not used by another transport connection assigned to it, it may be released. */
	[2]	/* See 6.22 (receipt of an ER TPDU) */
	[3]	/* See data transfer procedures of the class */
	[4]	/* See expedited data transfer procedures of the class */
	[5]	/* An N-RESET response has to be issued once for the network connection if the network connection has not been released. In class 0, an N-DISCONNECT request has to be issued. */
end

#
# define the name of the state variable and the initial state
#
define statevarname TLclass_0 initialstate CLOSED	# no end states
#
# this is the state table definition...
#
table TL_class0
begin
#
# We begin by defining the notes that accompany this table...
#
	notes
		(1)	/* An ER TPDU shall be sent in certain cases (see 6.6). */
		(2)	/* If received, it shall be processed as a protocol error (see 6.22). */
		(3)	/* A CR with Class 2 has been sent and a CC Class 0 is received. */
		(4)	/* If DC is not available (i.e. Class 0 only implemented), or SRC-REF is zero. */
#
# For each state we define the events that occur. If another event occurs that
# is not handled explicitly, a default condition will be invoked to cater with
# the event.
#
	state WFNC
		event TDISreq		[1] CLOSED
		event NCONconf		CR WFCC
		event NDISind		TDISind CLOSED
		event DC		(2)
		event AK		(2)
		event EA		(2)
		event ED		(2)
#
	state WFCC
		event TDISreq		not P7	: NDISreq CLOSED ;
					P7	: WBCL
		event NRSTind		TDISind [1] [5] CLOSED
		event NDISind		TDISind CLOSED
		event DR		TDISind [1] CLOSED
		event DC		(2)
		event CC		P8	: TCONconf OPEN ;
					P6 & P5 : TDISind NDISreq CLOSED ;
					P6 & P7 : TDISind DR CLOSING
		event AK		(2)
		event EA		(2)
		event ED		(2)
		event ER		TDISind [1] CLOSED
#
	state WBCL
		event NRSTind		[1] [5] CLOSED
		event NDISind		CLOSED
		event DR		[1] CLOSED
		event DC		(2)
		event CC		P5 : (3) NDISreq CLOSED ;
					P7 : DR CLOSING
		event AK		(2)
		event EA		(2)
		event ED		(2)
		event ER		[1] CLOSED
#
	state OPEN
		event TDTreq		[3] OPEN
		event TDISreq		P5 : NDISreq CLOSED ;
					P7 : DR CLOSING
		event NRSTind		TDISind [1] [5] CLOSED
		event NDISind		TDISind CLOSED
		event CR		P9 : OPEN
		event DR		P5 : (2) ;
					P7 : DC TDISind CLOSED
		event DC		(2)
		event AK		(2)
		event EA		(2)
		event ED		(2)
		event DT		[3] OPEN
		event ER		[2]
#
#	state T_CLOSING - This is a Class 2 state, does not exist in class 0
#
	state WFTRESP
		event TCONresp		CC OPEN
		event TDISreq		DR CLOSED
		event NRSTind		TDISind [1] [5] CLOSED
		event NDISind		TDISind CLOSED
		event CR		P9 : WFTRESP
		event DC		(2)
		event AK		(2)
		event EA		(2)
		event ED		(2)
#
	state CLOSED
		event TCONreq		P0 : TDISind CLOSED ;
					P2 : NCONreq WFNC ;
					P3 : CR WFCC ;
					P4 : WFNC
		event CR		P1 : DR (1) CLOSED ;
					not P1 : TCONind WFTRESP
		event DR		(4) CLOSED
		event DC		(2)
		event CC		DR CLOSED
		event AK		(2)
		event EA		(2)
		event ED		(2)
		event DT		CLOSED
		event ER		CLOSED
#
end
