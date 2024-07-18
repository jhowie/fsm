define events
begin
        Start   User    /* Start the ball rolling */
        CommUp  Link    /* Wake up the other side */
        CommOk  Link    /* Acknowledge that the link is up */
        Data1   Link    /* First data packet */
        Data2   Link    /* Second Data packet */
        Data3   Link    /* Third Data packet */
        Data4   Link    /* Fourth and final data packet */
        DataOk  Link    /* Acknowledge receipt of data */
        CommDn  Link    /* Shut down the link */
end

define states
begin
        WaitForStart    /* Wait for dopey user */
        WaitForCommUpOk /* Wait for link to come up */
        WaitForD1Ack    /* Wait for first data ack */
        WaitForD2Ack    /* Wait for second data ack */
        WaitForD3Ack    /* Wait for third data ack */
        WaitForD4Ack    /* Wait for final data ack */
        WaitForCommDnOk /* Wait for link to go down */
        Terminate
#
        WaitForCommUp   /* Wait for link start */
        WaitForD1       /* Wait for first data */
        WaitForD2       /* Wait for second data */
        WaitForD3       /* Wait for third data */
        WaitForD4       /* Wait for final data */
        WaitForCommDn   /* Wait for link termination */
end

define predicates
begin
        P1      /* Loop test */
end

define actions
begin
        [1]     /* Start link */
        [2]     /* Stop link */
        [3]     /* Decode data */
end

define statevarname Client initialstate WaitForStart endstate Terminate

table Client
begin
        state WaitForStart
                event Start     [1] CommUp WaitForCommUpOk

        state WaitForCommUpOk
                event CommOk    Data1 WaitForD1Ack

        state WaitForD1Ack
                event DataOk    P1: Data1 WaitForD1Ack; ^P1: Data2 WaitForD2Ack

        state WaitForD2Ack
                event DataOk    Data3 WaitForD3Ack

        state WaitForD3Ack
                event DataOk    Data4 WaitForD4Ack

        state WaitForD4Ack
                event DataOk    CommDn WaitForCommDnOk

        state WaitForCommDnOk
                event CommOk    [2] Terminate

        state Terminate
end

define statevarname Server initialstate WaitForCommUp endstate Terminate

table Server
begin
        state WaitForCommUp
                event CommUp    CommOk WaitForD1

        state WaitForD1
                event Data1     P1: [3] DataOk WaitForD1; ^P1: [3] DataOk WaitForD2

        state WaitForD2
                event Data2     [3] DataOk WaitForD3

        state WaitForD3
                event Data3     [3] DataOk WaitForD4

        state WaitForD4
                event Data4     [3] DataOk WaitForCommDn

        state WaitForCommDn
                event CommDn    CommOk Terminate

        state Terminate
end
