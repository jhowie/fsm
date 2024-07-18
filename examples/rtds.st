define events
begin
	FTR     sysuser         /* File transfer request */
	TA      sysuser         /* Transfer abort */
	ST      system          /* Start transfer */
	DATA    system          /* Data PDU */
	ACK     system          /* Data OK */
	ET      system          /* End of data */
	TACK    system          /* Transfer finished... */
end

define events
begin
	FTR     sysuser         /* File transfer request */
	TA      sysuser         /* Transfer abort */
end

define states
begin
	WFTR            /* Wait for transfer request */
	DT              /* Data transfer */

	IDLE            /* Wait for transfer request */
	WFTACK          /* Wait for transfer ack */
end

define predicates
begin
	p1      /* File exists */
	p2      /* SeqNo = Expected SeqNo */
	p3      /* End of file */
end

define actions
begin
	[1]     /* Open file for reading */
	[2]     /* Open file for writing */
	[3]     /* Read from file */
	[4]     /* Write to file */
	[5]     /* Close read file */
	[6]     /* Close write file */
	[7]     /* Delete write file */
	[8]     /* Increment Expected SeqNo */
	[9]     /* Exit */
	[10]    /* Increment SeqNo */
	[11]    /* Reset SeqNos */
end

define statevarname ServerState initialstate WFTR endstate

table Server
begin
	state WFTR
		event FTR       p1:TA; ^p1: [2] ST DT

	state DT
		event TA        [6] [7] WFTR
		event DATA      p2 : ACK [4] [8] ; ^p2 : ACK
		event ET        TACK [6] WFTR
end

define statevarname ClientState initialstate IDLE

table Client
begin
	state IDLE
		event FTR       p1: [1] FTR ; 
				^p1 : [9]

		event TA        [5] [9]

		event ST        ^p3 : DATA [5] DT ;
				p3 : ET WFTACK

	state DT
		event TA        [5] [9]

		event ACK       ^p2 : DATA ;
				^p3 : [10] DATA [3] ;
				p3 : ET WFTACK

	state WFTACK
		event TACK      [5] [9]
end
