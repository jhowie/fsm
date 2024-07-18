#
#  Define the categories
#
#define categories
#begin
#        SS_provider
#        TS_user
#        SS_user
#        TS_provider
#        SPDU
#        Timer
#end
#
# The following are incoming events
#
define events
begin
	SACTDreq	SS_user	"S_ACTIVTY_DISCARD request primitive"
	SACTDrsp	SS_user	"S_ACTIVITY_DISCARD response primitive"
	SACTEreq	SS_user	"S_ACTIVITY_END request primitive"
	SACTErsp	SS_user	"S_ACTIVITY_END response primitive"
	SACTIreq	SS_user	"S_ACTIVITY_INTERRUPT request primitive"
	SACTIrsp	SS_user	"S_ACTIVITY_INTERRUPT response primitive"
	SACTRreq	SS_user	"S_ACTIVITY_RESUME request primitive"
	SACTSreq	SS_user	"S_ACTIVITY_START request primitive"
	SCDreq	SS_user	"S_CAPABILITY_DATA request primitive"
	SCDrsp	SS_user	"S_CAPABILITY_DATA response primitive"
	SCGreq	SS_user	"S_CONTROL_GIVE request primitive"
	SCONreq	SS_user	"S_CONNECT request primitive"
	SCONrspP	SS_user	"S_CONNECT (accept) response primitive"
	SCONrspM	SS_user	"S_CONNECT (reject) response primitive"
	SDTreq	SS_user	"S_DATA request primitive"
	SEXreq	SS_user	"S_EXPEDITED_DATA request primitive"
	SGTreq	SS_user	"S_TOKEN_GIVE request primitive"
	SPTreq	SS_user	"S_TOKEN_PLEASE request primitive"
	SRELreq	SS_user	"S_RELEASE request primitive"
	SRELrspP	SS_user	"S_RELEASE (accept) response primitive"
	SRELrspM	SS_user	"S_RELEASE (reject) response primitive"
	SRSYNreq_a	SS_user	"S_RESYNCHRONIZE (abandon) request primitive"
	SRSYNreq_r	SS_user	"S_RESYNCHRONIZE (restart) request primitive"
	SRSYNreq_s	SS_user	"S_RESYNCHRONIZE (set) request primitive"
	SRSYNrsp	SS_user	"S_RESYNCHRONIZE response primitive"
	SSYNMreq	SS_user	"S_SYNC_MAJOR request primitive"
	SSYNMrsp	SS_user	"S_SYNC_MAJOR response primitive"
	SSYNmreq	SS_user	"S_SYNC_MINOR request primitive"
	SSYNmrsp	SS_user	"S_SYNC_MINOR response primitive"
	STDreq	SS_user	"S_TYPED_DATA request primitive"
	SUABreq	SS_user	"S_U_ABORT request primitive"
	SUERreq	SS_user	"S_U_EXCEPTION_REPORT request primitive"
# 
	TCONind	TS_provider	"T_CONNECT indication primitive"
	TCONcnf	TS_provider	"T_CONNECT confirm primitive"
	TDISind	TS_provider	"T_DISCONNECT indication primitive"
#
	TIM		Timer		"Time out"
#
	AA		SPDU		"ABORT ACCEPT SPDU"
	ABnr		SPDU		"ABORT (not reuse) SPDU"
	ABr		SPDU		"ABORT (reuse) SPDU"
	AC		SPDU		"ACCEPT SPDU"
	AD		SPDU		"ACTIVITY DISCARD SPDU"
	ADA		SPDU		"ACTIVITY DISCARD ACK SPDU"
	AE		SPDU		"ACTIVITY END SPDU"
	AEA		SPDU		"ACTIVITY END ACK SPDU"
	AI		SPDU		"ACTIVITY INTERRUPT SPDU"
	AIA		SPDU		"ACTIVITY INTERRUPT ACK SPDU"
	AR		SPDU		"ACTIVITY RESUME SPDU"
	AS		SPDU		"ACTIVITY START SPDU"
	CD		SPDU		"CAPABILITY DATA SPDU"
	CDA		SPDU		"CAPABILITY DATA ACK SPDU"
	CN		SPDU		"CONNECT SPDU"
	DN		SPDU		"DISCONNECT SPDU"
	DT		SPDU		"DATA TRANSFER SPDU"
	ED		SPDU		"EXCEPTION DATA SPDU"
	ER		SPDU		"EXCEPTION REPORT SPDU"
	EX		SPDU		"EXPEDITED DATA SPDU"
	FNnr		SPDU		"FINISH (not reuse) SPDU"
	FNr		SPDU		"FINISH (reuse) SPDU"
	GT		SPDU		"GIVE TOKENS SPDU"
	GTA		SPDU		"GIVE TOKENS ACK SPDU"
	GTC		SPDU		"GIVE TOKENS CONFIRM SPDU"
	MAA		SPDU		"MAJOR SYNC ACK SPDU"
	MAP		SPDU		"MAJOR SYNC POINT SPDU"
	MIA		SPDU		"MINOR SYNC ACK SPDU"
	MIP		SPDU		"MINOR SYNC POINT SPDU"
	NF		SPDU		"NOT FINISHED SPDU"
	PR_MAA	SPDU		"PREPARE (MAJOR SYNC ACK) SPDU"
	PR_RA		SPDU		"PREPARE (RESYNCHRONIZE  ACK) SPDU"
	PR_RS		SPDU		"PREPARE (RESYNCHRONIZE) SPDU"
	PT		SPDU		"PLEASE TOKENS SPDU"
	RA		SPDU		"RESYNCHRONIZE ACK SPDU"
	RFnr		SPDU		"REFUSE (not reuse) SPDU"
	RFr		SPDU		"REFUSE (reuse) SPDU"
	RSa		SPDU		"RESYNCHRONIZE (abandon) SPDU"
	RSr		SPDU		"RESYNCHRONIZE (restart) SPDU"
	RSs		SPDU		"RESYNCHRONIZE (set) SPDU)"
	TD		SPDU		"TYPED DATA SPDU"
end
#
#  The following are outgoing events
#
define events
begin
        SACTDind      SS_provider   "SMACTIVITYMDISCARD indication primitive"
        SACTDcnf      SS_provider   "SMACTIVITYMDISCARD confirm primitive"
        SACTEind      SS_provider   "SMACTIVITYMEND indication primitive"
        SACTEcnf      SS_provider   "SMACTIVITYMEND confirm primitive"
        SACTIind      SS_provider   "SMACTIVITYMINTERRUPT indication primitive"
        SACTIcnf      SS_provider   "SMACTIVITYMINTERRUPT confirm primitive"
        SACTRind      SS_provider   "SMACTIVITYMRESUME indication primitive"
        SACTSind      SS_provider   "SMACTIVITYMSTART indication primitive"
        SCDind        SS_provider   "SMCAPABILITYMDATA indication primitive"
        SCDcnf        SS_provider   "SMCAPABILITYMDATA confirm primitive"
        SCGind        SS_provider   "SMCONTROLMGIVE indication primitive"
        SCONind       SS_provider   "SMCONNECT indication primitive"
        SCONcnfP      SS_provider   "SMCONNECT (accept) confirm primitive"
        SCONcnfM      SS_provider   "SMCONNECT (reject) confirm primitive"
        SDTind        SS_provider   "SMDATA indication primitive"
        SEXind        SS_provider   "SMEXPEDITEDMDATA indication primitive"
        SGTind        SS_provider   "SMTOKENMGIVE indication primitive"
        SPABind       SS_provider   "SMPMABORT indication primitive"
        SPERind       SS_provider   "SMPMEXCEPTIONMREPORT indication primitive"
        SPTind        SS_provider   "SMTOKENMPLEASE indication primitive"
        SPABind       SS_provider   "SMPMABORT indication primitive"
        SRELind       SS_provider   "SMRELEASE indication primitive"
        SRELcnfP      SS_provider   "SMRELEASE (accept) confirm primitive"
        SRELcnfM      SS_provider   "SMRELEASE (reject) confirm primitive"
        SRSYNind      SS_provider   "SMRESYNCHRONIZE indication primitive"   
        SRSYNcnf      SS_provider   "SMRESYNCHRONIZE confirm primitive"   
        SSYNMind      SS_provider   "SMSYNCMMAJOR indication primitive"   
        SSYNMcnf      SS_provider   "SMSYNCMMAJOR confirm primitive"   
        SSYNmind      SS_provider   "SMSYNCMMINOR indication primitive"   
        SSYNmcnf      SS_provider   "SMSYNCMMINOR confirm primitive"   
        STDind        SS_provider   "SMTYPEDMDATA indication primitive"
        SUABind       SS_provider   "SMUMABORT indication primitive"
        SUERind       SS_provider   "SMUMEXCEPTIONMREPORT indication primitive"
        TCONreq       TS_user       "TMCONNECT request primitive"
        TCONrsp       TS_user       "TMCONNECT response primitive"
        TDISreq       TS_user       "TMDISCONNECT request primitive"
#
        AA            SPDU          "Abort accept SPDU"
        ABnr          SPDU          "Abort (not reuse) SPDU"
        ABr           SPDU          "Abort (reuse) SPDU"
        AC            SPDU          "Accept SPDU"
        AD            SPDU          "Activity discard SPDU"
        ADA           SPDU          "Activity discard Ack SPDU"
        AE            SPDU          "Activity end SPDU"
        AEA           SPDU          "Activity end Ack SPDU"
        AI            SPDU          "Activity interrupt SPDU"
        AIA           SPDU          "Activity interrupt Ack SPDU"
        AR            SPDU          "Activity resume SPDU"
        AS            SPDU          "Activity start SPDU"
        CD            SPDU          "Capability data SPDU"
        CDA           SPDU          "Capability data Ack SPDU"
        CN            SPDU          "Connect SPDU"
        DN            SPDU          "Disconnect SPDU"
        DT            SPDU          "Data transfer SPDU"
        ED            SPDU          "Exception data SPDU"
        EX            SPDU          "Expedited data SPDU"
        FNnr          SPDU          "Finish (not reuse) SPDU"
        FNr           SPDU          "Finish (reuse) SPDU"
        GT            SPDU          "Give tokens SPDU"
        GTA           SPDU          "Give tokens Ack SPDU"
        GTC           SPDU          "Give tokens confirm SPDU"
        MAA           SPDU          "Major sync Ack SPDU"
        MAP           SPDU          "Major sync point SPDU"
        MIA           SPDU          "Minor sync Ack SPDU"
        MIP           SPDU          "Minor sync point SPDU"
        NF            SPDU          "Not finished SPDU"
        PR_MAA        SPDU          "Prepare (Major sync Ack) SPDU"
        PR_RA         SPDU          "Prepare (Resynchronize Ack) SPDU"
        PR_RS         SPDU          "Prepare (Resynchronize) SPDU"
        PT            SPDU          "Please tokens SPDU"
        RA            SPDU          "Resynchronize Ack SPDU"
        RFnr          SPDU          "Refuse (not reuse) SPDU"
        RFr           SPDU          "Refuse (reuse) SPDU"
        RSa           SPDU          "Resynchronize (abandon) SPDU"
        RSr           SPDU          "Resynchronize (restart) SPDU"
        RSs           SPDU          "Resynchronize (set) SPDU"
        TD            SPDU          "Typed data SPDU"
end
#
#  The following are the possible states
#
define states
begin
        STA01           "Idle, no transport connection"
        STA01A          "Wait for AA SPDU"
        STA01B          "Wait for CONNECT confirm"
        STA01C          "Idle, transport connected"
        STA02A          "Wait for AC SPDU"
        STA03           "Wait for DN SPDU"
        STA04A          "Wait for MAA SPDU or PRMMAA SPDU"
        STA04B          "Wait for AEA SPDU or PRMMAA SPDU"
        STA05A          "Wait for RA SPDU"
        STA05B          "Wait for AIA SPDU or PRMRA SPDU"
        STA05C          "Wait for ADA SPDU or PRMRA SPDU"
        STA06           "Wait for RESYNCHRONIZE SPDU"
        STA08           "Wait for CONNECT response"
        STA09           "Wait for RELEASE response"
        STA10A          "Wait for SYNC_MAJOR response"
        STA10B          "Wait for ACTIVITY_END response"
        STA11A          "Wait for RESYNCHRONIZE response"
        STA11B          "Wait for ACTIVITY_INTERRUPT response"
        STA11C          "Wait for ACTIVITY_DISCARD response"
        STA15A          "After PREPARE, wait for MAA SPDU or AEA SPDU"
        STA15B          "After PREPARE, wait for RESYNC or AI or AD SPDU"
        STA15C          "After PREPARE, wait for RA or AIA or AD SPDU"
        STA16           "Wait for DISCONNECT indication"
        STA18           "Wait for GTA SPDU"
        STA19           "Wait for recovery request or SPDU (initiator of ED SPDU)"
        STA20           "Wait for recovery SPDU or request"
        STA21           "Wait for CDA SPDU"
        STA22           "Wait for CAPABILITY_DATA response"
        STA713          "Data transfer state"
end
#
#  The following are the predicates 
#
define predicates
begin
        P01      "^Vtca"
        P02      "local choice & ^TEXP"
        P03      "I(dk)"
        P04      "FU(FD) & ^Vcoll"
        P05      "A(dk)"
        P06      "FU(TD)"
        P07      "FU(TD) & ^Vcoll"
        P08      "FU(EX)"
        P09      "FU(EX) & ^Vcoll"
        P10     "^Vcoll"
        P11     "II(ma)"
        P12     "(^FU(ACT) OR Vact) & A(dk) & A(mi) & AA(ma)"
        P13     "(^FU(ACT) OR Vact) & I(dk) & I(mi) & II(ma)"
        P14     "(^FU(ACT) OR Vact) & A(dk) & AA(mi)"
        P15     "(^FU(ACT) OR Vact) & II(dk) & II(ma)"
        P16     "^TEXP"
        P17     "(^FU(ACT) OR Vact) & FU(SY) & ^Vsc"
        P18     "(^FU(ACT) OR Vact) & FU(SY) & Vsc"
        P19     "serial number = V(M)"
        P20     "serial number = V(M) M 1"
        P21     "V(M) > serial number > V(A)"
        P22     "Unused"
        P23     "FU(ACT) & ^Vnextact"
        P24     "^SPMwinner"
        P25     "(FU(SY) OR FU(MA)) & FU(RESYN)"
        P26     "(^FU(ACT) OR Vact)"
        P27     "Vrsp = no"
        P28     "FU(RESYN)"
        P29     "(^FU(ACT) OR Vact) & FU(RESYN)"
        P30     "^FU(ACT) OR Vnextact"
        P31     "FU(ACT) & Vnextact"
        P32     "serial number > V(R)"
        P33     "V(M) > serial number > V(R)"
        P34     "FU(ACT)"
        P35     "FU(RESYN) & ^TEXP"
        P36     "FU(RESYN) & TEXP"
        P37     "FU(ACT) & TEXP"
        P38     "FU(ACT) & ^TEXP"
        P39     "Vact & II(ma)"
        P40     "AA(ma)"
        P41     "Vrsp = dsc"
        P42     "Vrsp = int"
        P43     "((Vrsp = r) & (serial number = Vrspnb)) OR ((Vrsp = a) & (serial number = V(M))) OR (Vrsp = s)"
        P44     "(FU(ACT) & ^Vact) & A(dk) & A(mi) & A(ma)"
        P45     "(FU(ACT) & ^Vact) & I(dk) & I(mi) & I(ma)"
        P46     "FU(CD) & (FU(ACT) & ^Vact) & A(dk) & A(mi) & ^OWNED(ma)"
        P47     "FU(CD) & (FU(ACT) & ^Vact) & I(dk) & I(mi) & OWNED(ma)"
        P48     "FU(EXCEP) & FU(HD)"
        P49     "((Vrsp = r) & (serial number = Vrspnb)) OR ((Vrsp = s) & (serial number > V(M))) OR (Vrsp = s)"
        P50     "FU(EXCEP) & (^FU(ACT) OR Vact) & AA(dk)"
        P51     "FU(EXCEP) & (^FU(ACT) OR Vact) & II(dk)"
        P52     "FU(EXCEP) & (^FU(ACT) & II(dk)"
        P53     "ANY(AV,RT)"
        P54     "ALL(I,GT) & ANY(AV,GT)"
        P55     "(FU(ACT) & ^Vact) & ALL(I,tkMdom)"
        P56     "Unused"
        P57     "ALL(I,GT) & (dk no in GT) & ANY(AV,GT)"
        P58     "ALL(I,GT) & (dk in GT)"
        P59     "ALL(A,GT) & ANY(AV,GT)"
        P60     "ALL(A,GT) & (dk not in GT) & ANY(AV,GT)"
        P61     "ALL(A,GT) & (dk in GT)"
        P62     "(FU(ACT) & ^Vact) & ALL(A,tkMdom)"
        P63     "ALL(I,tkMdom) & (^FU(ACT) OR ^Vact)"
        P64     "local choice & ^Vtca & ^TEXP"
        P65     "ANY(AV,tkMdom)"
        P66     "Vtrr"
        P67     "FU(NR)"
        P68     "ALL(A,tkMdom) & (^FU(ACT) OR ^Vact)"
        P69     "Vcoll"
        P70     "FU(FD)"
        P71     "FU(ACT) & Vact & I(dk) & I(mi) & II(ma)"
        P72     "FU(ACT) & Vact & A(dk) & A(mi) & AA(ma)"
        P75     "(Vcoll & Vdnr) OR ^Vcoll"
end
#
#  Define the allowable actions
#
define actions
begin
        [1]     "Set Vtca = true"
        [2]     "Set Vtca = false"
        [3]     "Stop timer TIM"
        [4]     "Start timer TIM"
        [5]     "Set V(A) = V(M) = serial number in AC SPDU. Set V(R) = 0. Set Vcoll = false. Set Vrsp = no. Set Vsc = false. Set TEXP. Set FU(f) for f in fuMdom to Session User. Requirements in CN SPDU and AC SPDU. If FU(ACT) = true, set Vact = false. Set Vdnr = false"
        [6]     "Recall queued events until queue is empty"
        [7]     "Set Vtrr = true"
        [8]     "Set Vtrr = false"
        [9]     "Set Vtrr according to transport disconnect. PV field in SPDU"
        [10]    "Store event in the queue"
        [11]    "Update the position of the tokens"
        [12]    "Set Vact = true"
        [13]    "Set Vnextact"
        [14]    "Set Vact = Vnextact"
        [15]    "Clear the queue"
        [16]    "Update Vrsp and, if RSr, Vrspnb"
        [17]    "Not used"
        [18]    "Set Vcoll = true"
        [19]    "V(M) = max (V(M), received serial number)"
        [20]    "Set Vsc = false"
        [21]    "Set V(M) = V(M) P 1"
        [22]    "Set V(R) = V(A) = V(M)"
        [23]    "If Vsc = false, set V(A) = V(M). Set Vsc = true.  Set V(M) = V(M) P 1"
        [24]    "If Vsc = true, set V(A) = V(M). Set Vsc = false.  Set V(M) = V(M) P 1"
        [25]    "Set V(A) = serial number P 1"
        [26]    "Set V(A) = V(M) = V(R) = 1"
        [27]    "Set V(A) = V(M) = serial number P 1. Set V(R) = 1"
        [28]    "Set V(A) = V(M) = serial number. If Vrsp = a then set V(R) = 0. If Vrsp = s then set V(R) = 0. Set Vrsp = no"
        [29]    "Set position of tokens so all available tokens are owned. Set Vact = false.  Set Vrsp = no"
        [30]    "Set position of tokens so all available tokens are not owned. Set Vact = false.  Set Vrsp = no"
        [31]    "If Vsc = false, set V(A) = V(M). Set V(M) = V(M) P 1"
        [32]    "Set Vdnr = true"
end
#
define statevarname SLtables initialstate STA01
#	
#
table SL_connect_establish
begin
notes
(1) "PR is not sent if TEXP is false."
(2) "The serial number given in the indication is V(M)."
(3) "SxABind : SUABind if bit 2 of DISCON PV field AB = user abort. Else SPABind."  
#
        state STA01
                event SCONreq       TCONreq [2] STA01B
                event TCONind       TCONrsp [1] STA01C
#
        state STA01A
                event AC            STA01A
                event CN            TDISreq [3] STA01
                event RFnr          STA01A
                event RFr           STA01A
#
        state STA01B
                event TCONcnf       CN STA02A
#
        state STA01C
                event AC            TDISreq STA01
                event CN            ^ P01 : SCONind STA08 ; P01 : TDISreq STA01 
                event RFnr          TDISreq STA01
                event RFr           TDISreq STA01
                event SCONreq       P01 : CN STA02A 
#
        state STA02A
                event AC            SCONcnfP [5] [11] STA713 [6]
                event RFnr          SCONcnfM TDISreq STA01
                event RFr           ^ P02 : SCONcnfM TDISreq STA01 ; P02 : SCONcnfM STA01C 
#
        state STA08
                event SCONrspP      AC [5] [11] STA713
                event SCONrspM      ^ P02 : RFnr [4] STA16  ; P02 : RFr STA01C 
#
        state STA16
                event AC            STA16
                event CN            TDISreq [3] STA01
                event RFnr          STA16
                event RFr           STA16
end
#
table SL_data_transfer
begin
notes
#
(1) "PR is not sent if TEXP is false."
(2) "The serial number given in the indication is V(M)."
(3) "SxABind : SUABind if bit 2 of DISCON PV field AB = user abort. Else SPABind."  
#
        state STA01A
                event DT            STA01A
                event EX            STA01A
                event TD            STA01A
#
        state STA01C
                event DT            TDISreq STA01
                event EX            TDISreq STA01
                event TD            TDISreq STA01
#
        state STA02A
                event EX            [10] STA02A
#
        state STA03
                event DT            P05 & P10 : SDTind STA03 
                event EX            P09 : SEXind STA03 
                event TD            P06 & P10 : STDind STA03 
#
        state STA04A
                event DT            P05 : SDTind STA04A 
                event EX            P08 : SEXind STA04A 
                event TD            P06 : STDind STA04A 
#
        state STA04B
                event DT            P05 : SDTind STA04B 
                event EX            P08 : SEXind STA04B 
                event TD            P06 : STDind STA04B 
#
        state STA05A
                event DT            P05 : STA05A 
                event EX            P08 : STA05A 
                event TD            P06 : STA05A 
#
        state STA05B
                event DT            P05 : STA05B 
                event EX            P08 : STA05B 
                event TD            P06 : STA05B 
#
        state STA05C
                event DT            P05 : STA05C 
                event EX            P08 : STA05C 
                event TD            P06 : STA05C 
#
        state STA06
                event DT            P05 : STA06 
                event EX            P08 : [10] STA06 
                event TD            P06 : STA06 
#
        state STA09
                event SDTreq        P04 : DT STA09 
                event SEXreq        P09 : EX STA09 
                event STDreq        P07 : TD STA09 
#
        state STA10A
                event SDTreq        P03 : DT STA10A 
                event SEXreq        P08 : EX STA10A 
                event STDreq        P06 : TD STA10A 
#
        state STA10B
                event SDTreq        P03 : DT STA10B 
                event SEXreq        P08 : EX STA10B 
                event STDreq        P06 : TD STA10B 
#
        state STA15A
                event DT            P05 : SDTind STA15A 
                event EX            P08 : [10] STA15A 
                event TD            P06 : STDind STA15A 
#
        state STA15B
                event EX            P05 : STA15B 
                event TD            P06 : STA15B 
                event SDTreq        P03 : STA15B 
                event SEXreq        P08 : STA15B 
                event STDreq        P06 : STA15B 
#
        state STA15C
                event DT            P05 : STA15C 
                event EX            P08 : [10] STA15C 
                event TD            P06 : STA15C 
#
        state STA16
                event DT            STA16
                event EX            STA16
                event TD            STA16
#
        state STA18
                event DT            P70 : SDTind STA18 
                event EX            P08 : SEXind STA18 
                event TD            P06 : STDind STA18 
                event SDTreq        P70 : DT STA18 
                event SEXreq        P08 : EX STA18 
                event STDreq        P06 : TD STA18 
#
        state STA19
                event DT            STA19
                event EX            P08 : STA19 
                event TD            P06 : STA19 
#
        state STA20
                event DT            P05 : STA20 
                event EX            P08 : STA20 
                event TD            P06 : STA20 
#
        state STA21
                event DT            P70 : SDTind STA21 
                event EX            P08 : SEXind STA21 
                event TD            P06 : STDind STA21 
#
        state STA713
                event DT            P05 : SDTind STA713 
                event EX            P08 : SEXind STA713 
                event TD            P06 : STDind STA713 
                event SDTreq        P03 : DT STA713 
                event SEXreq        P08 : EX STA713 
                event STDreq        P06 : TD STA713 
end
#
table SL_synchronization
begin
notes
#
(1) "PR is not sent if TEXP is false."
(2) "The serial number given in the indication is V(M)."
(3) "SxABind : SUABind if bit 2 of DISCON PV field AB = user abort. Else SPABind."  
#
        state STA01A
                event MAA           STA01A
                event AEA           STA01A
                event MAP           STA01A
                event PR_MAA        STA01A
                event AE            STA01A
                event MIA           STA01A
                event MIP           STA01A
#
        state STA01C
                event MAA           TDISreq STA01
                event AEA           TDISreq STA01     
                event MAP           TDISreq STA01
                event PR_MAA        TDISreq STA01
                event AE            TDISreq STA01
                event MIA           TDISreq STA01
                event MIP           TDISreq STA01
#
        state STA04A
                event MAA           P16 & P20 : SSYNMcnf [14] [22] STA713 
                event AEA           P16 & P20 : SSYNMcnf [14] [22] STA713
                event PR_MAA        STA15A
                event MIA           P17 & ^ P20 & P21 : SSYNmcnf [25] STA04A 
#
        state STA04B
                event MAA           P16 & P20 : SACTEcnf [14] [22] STA713 
                event AEA           P16 & P20 : SACTEcnf [14] [22] STA713 
                event PR_MAA        STA15A
                event MIA           P17 & ^ P20 & P21 : SSYNmcnf [25] STA04B 
#
        state STA05A
                event MAA           STA05A
                event AEA           STA05A          
                event MAP           P12 : STA05A  
                event PR_MAA        STA05A
                event AE            P72 : STA05A 
                event MIA           P17 : STA05A  
                event MIP           P14 : STA05A  
#
        state STA05B
                event MAA           STA05B
                event AEA           STA05B      
                event PR_MAA        STA05B
                event MIA           P17 : STA05B  
                event MIP           P14 : STA05B  
#
        state STA05C
                event MAA           STA05C
                event AEA           STA05C 
                event PR_MAA        STA05C
                event MIA           P17 : STA05C  
                event MIP           P14 : STA05C  
#
        state STA06
                event MAA           STA06
                event AEA           STA06   
                event MAP           P12 : STA06 
                event AE            P72 : STA06 
                event MIA           P17 : STA06  
                event MIP           P14 : STA06  
#
        state STA10A
                event SSYNMrsp      PR_MAA (1) MAA [14] [22] STA713
                event SSYNmrsp      P18 & ^ P20 & P21 : MIA [25] STA10A 
#
        state STA15A
                event MAA           P20 & ^ P23 : SSYNMcnf [14] [22] STA713 [6] ; P20 & P23 : SACTEcnf [14] [22] STA713 [6]
                event AEA           P20 & ^ P23 : SSYNMcnf [14] [22] STA713 [6] ; P20 & P23 : SACTEcnf [14] [22] STA713 [6] 
                event MIA           P17 & ^ P20 & P21 : SSYNmcnf [25] STA15A 
#
        state STA15B
                event MAA           STA15B
                event AEA           STA15B
                event MAP           P12 : STA15B  
                event SSYNMreq      P13 : STA15B 
                event SSYNMrsp      STA15B
                event AE            P72 : STA15B 
                event MIA           P17 : STA15B 
                event MIP           P14 : STA15B 
                event SACTEreq      P71 : STA15B 
                event SSYNmreq      P15 : STA15B 
                event SSYNmrsp      P18 & P21 : STA15B 
#
        state STA15C
                event MAA           STA15C
                event AEA           STA15C
                event MAP           P12 : STA15C 
                event AE            P72 : STA15C 
                event MIA           P17 : STA15C 
                event MIP           P14 : STA15C 
#
        state STA16
                event MAA           STA16
                event AEA           STA16
                event MAP           STA16
                event PR_MAA        STA16
                event AE            STA16
                event MIA           STA16
                event MIP           STA16
#
        state STA19
                event MAP           P12 & P19 : [31] STA19
                event AE            P72 & P19 : [31] STA19 
                event MIA           P17 & P21 : [25] STA19 
                event MIP           P14 & P19 : [23] STA19 
#
        state STA20
                event MAA           P20 : STA20 
                event AEA           P20 : STA20
                event MAP           P12 & P19 : [31] STA20
                event AE            P72 & P19 : [31] STA20 
                event MIA           P17 & P21 : STA20 
                event MIP           P14 & P19 : [23] STA20 
#
        state STA713
                event MAP           P12 & P19 : SSYNMind [13] [31] STA10A
                event SSYNMreq      P13 : MAP [13] [24] STA04A
                event AE            P72 & P19 : SACTEind [13] [31] STA10B 
                event MIA           P17 & P21 : SSYNmcnf [25] STA713 
                event MIP           P14 & P19 : SSYNmind [23] STA713 
                event SACTEreq      P71 : AE [13] [24] STA04B 
                event SSYNmreq      P15 : MIP [24] STA713 
                event SSYNmrsp      P18 & P21 : MIA [25] STA713 
#
        state STA03
                event MIA           P17 & P21 : SSYNmcnf [25] STA03 
#
        state STA09
                event SSYNmrsp      P18 & P21 : MIA [25] STA09 
#
        state STA10B
                event SACTErsp      PR_MAA (1) AEA [14] [22] STA713
                event SSYNmrsp      P18 & ^ P20 & P21 : MIA [25] STA10B 
end
#
table SL_resynchronization
begin
notes
#
(1) "PR is not sent if TEXP is false."
(2) "The serial number given in the indication is V(M)."
(3) "SxABind : SUABind if bit 2 of DISCON PV field AB = user abort. Else SPABind."  
#
        state STA01A
                event PR_RA         STA01A
                event PR_RS         STA01A
                event RA            STA01A
                event RSa           STA01A
                event RSr           STA01A
                event RSs           STA01A
#
        state STA01C
                event PR_RA         TDISreq STA01
                event PR_RS         TDISreq STA01
                event RA            TDISreq STA01
                event RSa           TDISreq STA01
                event RSr           TDISreq STA01
                event RSs           TDISreq STA01
#
        state STA02A
                event PR_RS         [10] STA02A
#
        state STA03
                event PR_RS         P10 : STA15B 
                event RSa           P10 & ^ P34 & P35 : [19] SRSYNind (2) [16] STA11A 
                event RSr           P10 & ^ P34 & P35 & P32 : SRSYNind [16] STA11A 
                event RSs           P10 & ^ P34 & P35 : SRSYNind [16] STA11A 
#
        state STA04A
                event PR_RS         STA15B
                event RSa           P35 : [19] SRSYNind (2) [16] STA11A 
                event RSr           P32 & P35 : SRSYNind [16] STA11A 
                event RSs           P35 : SRSYNind [16] STA11A 
                event SRSYNreq_a    P28 : PR_RS (1) RSa [16] STA05A 
                event SRSYNreq_s    P28 : PR_RS (1) RSa [16] STA05A 
#
        state STA04B
                event PR_RS         STA15B
                event RSa           P35 : [19] SRSYNind (2) [16] STA11A 
                event RSr           P32 & P35 : SRSYNind [16] STA11A 
                event RSs           P35 : SRSYNind [16] STA11A 
#
        state STA05A
                event PR_RA         STA15C
                event PR_RS         STA06
                event RA            P35 & P49 : SRSYNcnf [28] [11] STA713 
                event RSa           ^ P24 & P35 : STA05A ; P24 & P35 : [19] SRSYNind (2) [16] STA11A 
                event RSr           ^ P24 & P32 & P35 : STA05A ; P24 & P32 & P35 : SRSYNind [16] STA11A 
                event RSs           ^ P24 & P35 : STA05A ; P24 & P35 : SRSYNind [16] STA11A 
#
        state STA05B
                event PR_RA         STA15C
                event PR_RS         STA05B
                event RSa           P28 : STA05B 
                event RSr           P28 : STA05B 
                event RSs           P28 : STA05B 
#
        state STA05C
                event PR_RA         STA15C
                event PR_RS         STA05C
                event RSa           P28 : STA05C 
                event RSr           P28 : STA05C 
                event RSs           P28 : STA05C 
#
        state STA06
                event PR_RA         [10] STA06
                event PR_RS         [10] STA06
                event RSa           ^ P24 : STA05A [6] ; P24 : [19] SRSYNind (2) [16] STA11A [6] 
                event RSr           ^ P24 & P32 : STA05A [6] ; P24 & P32 : SRSYNind [16] STA11A [6] 
                event RSs           ^ P24 : STA05A [6] ; P24 : SRSYNind [16] STA11A [6] 
#
        state STA09
                event SRSYNreq_a    P10 & P28 & ^ P34 : PR_RS (1) RSa [16] STA05A 
                event SRSYNreq_r    P10 & P25 & ^ P34 & P33 : PR_RS (1) RSr [16] STA05A 
                event SRSYNreq_s    P10 & P25 & ^ P34 : PR_RS (1) RSs [16] STA05A 
#
        state STA10A
                event PR_RS         STA15B
                event RSa           P35 : [19] SRSYNind (2) [16] STA11A 
                event RSs           P35 : SRSYNind [16] STA11A 
                event SRSYNreq_a    P28 : PR_RS (1) RSa [16] STA05A 
                event SRSYNreq_r    P25 & P33 : PR_RS (1) RSr [16] STA05A 
                event SRSYNreq_s    P25 : PR_RS (1) RSs [16] STA05A 
#
        state STA10B
                event PR_RS         STA15B
                event SRSYNreq_a    P28 : PR_RS (1) RSa [16] STA05A 
                event SRSYNreq_r    P25 & P33 : PR_RS (1) RSr [16] STA05A 
                event SRSYNreq_s    P25 : PR_RS (1) RSs [16] STA05A 
#
        state STA11A
                event SRSYNreq_a    P24 : PR_RS (1) RSa [16] STA05A 
                event SRSYNreq_r    P24 & P33 : PR_RS (1) RSr [16] STA05A 
                event SRSYNreq_s    P24 : PR_RS (1) RSs [16] STA05A 
                event SRSYNrsp      P43 : PR_RA (1) RA [28] [11] STA713 
#
        state STA15A
                event PR_RS         [10] STA15A
                event SRSYNreq_a    P28 & P30 : PR_RS (1) RSa [16] STA05A 
                event SRSYNreq_s    P28 & P30 : PR_RS (1) RSs [16] STA05A 
#
        state STA15B
                event RSa           P29 : [19] SRSYNind (2) [16] STA11A 
                event RSr           P32 & P29 : SRSYNind [16] STA11A 
                event RSs           P29 : SRSYNind [16] STA11A 
                event SRSYNreq_a    P27 & P28 : PR_RS (1) RSa [16] STA06 
                event SRSYNreq_r    P25 & P27 & P33 : PR_RS (1) RSr [16] STA06 
                event SRSYNreq_s    P25 & P27 : PR_RS (1) RSs [16] STA06 
#
        state STA15C
                event PR_RS         [10] STA15C
                event RA            P36 & P49 : SRSYNcnf [28] [11] STA713 [6] 
#
        state STA16
                event PR_RA         STA16
                event PR_RS         STA16
                event RA            STA16
                event RSa           STA16
                event RSr           STA16
                event RSs           STA16
#
        state STA18
                event PR_RS         [10] STA18
#
        state STA19
                event PR_RS         STA15B
                event RSa           P35 : [19] SRSYNind (2) [16] STA11A 
                event RSr           P32 & P35 : SRSYNind [16] STA11A 
                event RSs           P35 : SRSYNind [16] STA11A 
#
        state STA20
                event PR_RS         STA15B
                event RSa           P35 : [19] SRSYNind (2) [16] STA11A 
                event RSr           P32 & P35 : SRSYNind [16] STA11A 
                event RSs           P35 : SRSYNind [16] STA11A 
                event SRSYNreq_a    P28 : PR_RS (1) RSa [16] STA05A 
                event SRSYNreq_r    P25 & P33 : PR_RS (1) RSr [16] STA05A 
                event SRSYNreq_s    P25 : PR_RS (1) RSs [16] STA05A 
#
        state STA713
                event PR_RS         P26 : STA15B ; ^ P26 : [10] STA713 
                event RSa           P26 & P35 : [19] SRSYNind (2) [16] STA11A 
                event RSr           P32 & P26 & P35 : SRSYNind [16] STA11A 
                event RSs           P26 & P35 : SRSYNind [16] STA11A 
                event SRSYNreq_a    P29 : PR_RS (1) RSa [16] STA05A 
                event SRSYNreq_r    P25 & P26 & P33 : PR_RS (1) RSr [16] STA05A 
                event SRSYNreq_s    P25 & P26 : PR_RS (1) RSs [16] STA05A 
#
end
#
table SL_activity_interrupt
begin
notes
#
(1) "PR is not sent if TEXP is false."
(2) "The serial number given in the indication is V(M)."
(3) "SxABind : SUABind if bit 2 of DISCON PV field AB = user abort. Else SPABind."  
#
        state STA01A
                event AD            STA01A
                event ADA           STA01A
                event AI            STA01A
                event AIA           STA01A
#
        state STA01C
                event AD            TDISreq STA01
                event ADA           TDISreq STA01
                event AI            TDISreq STA01
                event AIA           TDISreq STA01
#
        state STA04A
                event SACTDreq      P34 & P39 : PR_RS (1) AD [16] STA05C 
                event SACTIreq      P34 & P39 : PR_RS (1) AI [16] STA05B 
#
        state STA04B
                event SACTDreq      P39 : PR_RS (1) AD [16] STA05C 
                event SACTIreq      P39 : PR_RS (1) AI [16] STA05B 
#
        state STA05A
                event AD            P38 & P40 : SACTDind [16] STA11C 
                event AI            P38 & P40 : SACTIind [16] STA11B 
#
        state STA05B
                event AIA           P38 : SACTIcnf [29] STA713 
#
        state STA05C
                event ADA           P38 : SACTDcnf [29] STA713 
#
        state STA06
                event AD            P37 & P40 : SACTDind [16] STA11C 
                event AI            P37 & P40 : SACTIind [16] STA11B 
#
        state STA10A
                event AD            P38 & P40 : SACTDind [16] STA11C 
                event AI            P38 & P40 : SACTIind [16] STA11B 
#
        state STA10B
                event AD            P38 & P40 : SACTDind [16] STA11C 
                event AI            P38 & P40 : SACTIind [16] STA11B 
#
        state STA11A
                event SACTDreq      P34 & P39 : PR_RS (1) AD [16] STA05C 
                event SACTIreq      P34 & P39 : PR_RS (1) AI [16] STA05B 
#
        state STA11B
                event SACTIrsp      PR_RA (1) AIA [30] STA713
#
        state STA11C
                event SACTDrsp      PR_RA (1) ADA [30] STA713
#
        state STA15A
                event SACTDreq      P34 & P39 : PR_RS (1) AD [16] STA05C [6] 
                event SACTIreq      P34 & P39 : PR_RS (1) AI [16] STA05B [6] 
#
        state STA15B
                event AD            P37 & P40 : SACTDind [16] STA11C 
                event AI            P37 & P40 : SACTIind [16] STA11B 
                event SACTDreq      P27 & P34 & P39 : PR_RS (1) AD [16] STA05C 
                event SACTIreq      P27 & P34 & P39 : PR_RS (1) AI [16] STA05B 
#
        state STA15C
                event ADA           P37 & P11 : SACTDcnf [29] STA713 [6] 
                event AIA           P37 & P42 : SACTIcnf [29] STA713 [6] 
#
        state STA16     
                event ADA           STA16
                event AD            STA16
                event AI            STA16
                event AIA           STA16
#
        state STA19
                event AD            P38 & P40 : SACTDind [16] STA11C 
                event AI            P38 & P40 : SACTIind [16] STA11B 
#
        state STA20
                event AD            P38 & P40 : SACTDind [16] STA11C 
                event AI            P38 & P40 : SACTIind [16] STA11B 
                event SACTDreq      P34 & P11 : PR_RS (1) AD [16] STA05C 
                event SACTIreq      P34 & P11 : PR_RS (1) AI [16] STA05B 
#
        state STA713
                event AD            P38 & P40 : SACTDind [16] STA11C 
                event AI            P38 & P40 : SACTIind [16] STA11B 
                event SACTDreq      P34 & P39 : PR_RS (1) AD [16] STA05C 
                event SACTIreq      P34 & P39 : PR_RS (1) AI [16] STA05B 
#
end
#
table SL_activity_start_resume_CDT
begin
notes
#
(1) "PR is not sent if TEXP is false."
(2) "The serial number given in the indication is V(M)."
(3) "SxABind : SUABind if bit 2 of DISCON PV field AB = user abort. Else SPABind."  
#
        state STA01A
                event AR            STA01A
                event AS            STA01A
                event CD            STA01A
                event CDA           STA01A
#
        state STA01C
                event AR            TDISreq STA01
                event AS            TDISreq STA01
                event CD            TDISreq STA01
                event CDA           TDISreq STA01
#
        state STA15B
                event AR            P44 : SACTRind [12] [27] STA15B 
                event AS            P44 : SACTSind [12] [26] STA15B 
#
        state STA16
                event AR            STA16
                event AS            STA16
                event CD            STA16
                event CDA           STA16
#
        state STA21
                event CDA           SCDcnf STA713
#
        state STA22
                event SCDrsp        CDA STA713
#
        state STA713
                event AR            P44 : SACTRind [12] [27] STA713 [6] 
                event AS            P44 : SACTSind [12] [26] STA713 [6] 
                event CD            P46 : SCDind STA22 
                event SACTRreq      P45 : AR [12] [27] STA713 
                event SACTSreq      P45 : AS [12] [26] STA713 
                event SCDreq        P47 : CD STA21 
#
end
#
table SL_token_management
begin
notes
#
(1) "PR is not sent if TEXP is false."
(2) "The serial number given in the indication is V(M)."
(3) "SxABind : SUABind if bit 2 of DISCON PV field AB = user abort. Else SPABind."  
#
	state STA01A
		event ED		STA01A  
		event ER		STA01A  
		event GT		STA01A  
		event GTA		STA01A  
		event GTC		STA01A  
		event PT		STA01A  
#
	state STA01C
		event ED		TDISreq STA01  
		event ER		TDISreq STA01  
		event GT		TDISreq STA01  
		event GTA		TDISreq STA01  
		event GTC		TDISreq STA01  
		event PT		TDISreq STA01  

#
	state STA03
		event ED		P52 : SUERind STA20 
		event ER		P52 : SPERind STA20 
		event PT		P53 : SPTind  STA03 
#
	state STA04A
		event ED		P48 & P03 : SUERind STA20 ; P48 & ^ P03 : SUERind STA713 
		event ER		P48 & P03 : SPERind STA20 ; P48 & ^ P03 : SPERind STA713 
		event GT		P59 : SGTind [11] STA04A 
		event PT		P53 : SPTind STA04A 
		event SGTreq	P54 : GT [11] STA04A 
#
	state STA04B
		event ED		P48 & P03 : SUERind STA20 ; P48 & ^ P03 : SUERind STA713 
		event ER		P48 & P03 : SPERind STA20 ; P48 & ^ P03 : SPERind STA713 
		event GT		P59 : SGTind [11] STA04B 
		event PT		P53 : SPTind STA04B 
		event SGTreq	P54 : GT [11] STA04B 
#
	state STA05A
		event ED		P48 : STA05A 
		event ER		P48 : STA05A 
		event GT		P59 : STA05A 
		event PT		P53 : STA05A 
#
	state STA05B
		event ED		P48 : STA05B 
		event ER 		P48 : STA05B 
		event GT		P59 : STA05B 
		event PT		P53 : STA05B 
#
	state STA05C
		event ED		P48 : STA05C 
		event ER		P48 : STA05C 
		event GT		P59 : STA05C 
		event PT 		P53 : STA05C 
#
	state STA06
		event ED		P48 : STA06 
		event ER		P48 : STA06 
		event GT		P59 : STA06 
		event PT		P53 : STA06 
#
	state STA09	
		event SPTreq	P53 : PT STA09 
		event SUERreq	P50 : ED STA19 
#
	state STA10A
		event GT		P59 : SGTind [11] STA10A 
		event SGTreq	P54 : GT [11] STA10A 
		event SPTreq	P53 : PT STA10A 
		event SUERreq	P50 : ED STA19 
#
	state STA10B
		event GT		P59 : SGTind [11] STA10B 
		event SGTreq	P54 : GT [11] STA10B 
		event SPTreq	P53 : PT STA10B 
		event SUERreq	P50 : ED STA19 
#
	state STA15A
		event GT		P59 : SGTind [11] STA15A 
		event PT		P53 : SPTind STA15A 
		event SGTreq	P54 : GT [11] STA15A 
#
	state STA15B
		event GT		P59 : STA15B 
		event PT		P53 : STA15B 
		event SGTreq	P54 : STA15B 
		event SPTreq 	P53 : STA15B 
		event SUERind	P50 : STA15B 
#
	state STA15C
		event ED		P48 : STA15C 
		event ER		P48 : STA15C 
		event GT		P59 : STA15C 
		event PT 		P53 : STA15C 
#
	state STA16
		event ED	        STA16  
		event ER		STA16  
		event GT		STA16  
		event GTA		STA16  
		event GTC		STA16  
		event PT		STA16  
#
	state STA18
		event GTA		STA713 [6]  
		event PT		P53 : SPTind STA18 
#
	state STA19
		event ED		P50 : SUERind STA19 
		event ER		P50 : SPERind STA19 
		event GT		P60 : SGTind [11] STA19 ; P61 : SGTind [11] STA713 
		event PT		P53 : STA19
#
	state STA20		
		event GT		P60 : SGTind [11] STA20 ; P61 : SGTind [11] STA713 
		event PT		P53 : STA20 
		event SGTreq	P57 : GT [11] STA20 ; P58 : GT [11] STA713 
#
	state STA21
		event ER 		P48 : SPERind STA20 
		event GT		P59 : SGTind  [11] STA21 
		event PT 		P53 : SPTind STA21 
#
	state STA22
		event SPTreq	P53 : PT STA22 
#
	state STA713
		event ED		P50 : SUERind STA713 ; P51 : SUERind STA20 
		event ER		P50 : SPERind STA713 ; P51 : SPERind STA20 
		event GT		P59 : SGTind [11] STA713 
		event GTC		P62 : SCGind GTA [11] STA713 
		event PT		P53 : SPTind STA713 
		event SCGreq	P55 : GTC [11] STA18 
		event SGTreq	P54 : GT [11] STA713 
		event SPTreq	P53 : PT STA713 
		event SUERreq	P50 : ED STA19 
#
end
#
table SL_connect_rel
begin
notes
#
(1) "PR is not sent if TEXP is false."
(2) "The serial number given in the indication is V(M)."
(3) "SxABind : SUABind if bit 2 of DISCON PV field AB = user abort. Else SPABind."  
#
	state STA01A
		event DN		STA01A  
		event FNnr		STA01A  
		event FNr		STA01A  
		event NF		STA01A  
#
	state STA01C
		event DN		TDISreq STA01  
		event FNnr		TDISreq STA01  
		event FNr		TDISreq STA01  
		event NF		TDISreq STA01  
#
	state STA03
		event DN		^ P66 : SRELcnfP TDISreq STA01 ; P66 : SRELcnfP STA01C 
		event FNnr		^ P65 : SRELind [8] [18] STA09 
		event FNr		^ P65 & ^ P01 & P16 : SRELind [8] [18] STA09 
		event NF		P67 : SRELcnfM STA713 
#
	state STA05A
		event FNnr		P68 : STA05A 
		event FNr		P68 & ^ P01 & P16 : STA05A 
#
	state STA06
		event FNnr		P68 : STA06 
#
	state STA09
		event DN		P69 & ^ P01 : SRELcnfP [32] STA09 
		event SRELreq	^ P65 : FNnr [8] [18] STA09 
		event SRELrspP	^ P66 & P75 : DN [4] STA16 ; P66 : DN STA01C ; P69 & P01 : DN STA03 
		event SRELrspM	P67 : NF STA713 
#
	state STA15B
		event NF		P67 : SRELcnfM STA15B 
		event SRELreq	P63 : STA15B 
#
	state STA15C
		event FNnr		P68 : STA15C 
		event FNr		P68 & ^ P01 & P16 : STA15C 
#
	state STA16
		event DN		STA16  
		event FNnr		STA16  
		event FNr		STA16  
		event NF		STA16  
#
	state STA19
		event FNnr		P68 : STA19 
		event FNr		P68 & ^ P01 & P16 : STA19 
#
	state STA20
		event FNnr		P68 : STA20 
		event FNr		P68 & ^ P01 & P16 : STA20 
#
	state STA713
		event FNnr		P63 : SRELind [8] STA09 
		event FNr		P68 & ^ P01 & P16 : SRELind [9] STA09 
		event SRELreq	P63 & ^ P64 : FNnr [8] STA03 ; P63 & P64 : FNr [7] STA03 
#
end
#
table SL_abort
begin
notes
#
(1) "PR is not sent if TEXP is false."
(2) "The serial number given in the indication is V(M)."
(3) "SxABind : SUABind if bit 2 of DISCON PV field AB = user abort. Else SPABind."  
#
	state STA01A
		event AA		[3] STA01C  
		event ABnr		[3] TDISreq STA01  
		event ABr		[3] STA01C  
		event TDISind	[3] STA01  
		event TIM		TDISreq STA01  
#
	state STA01B
		event SUABreq	TDISreq STA01  
		event TDISind	SPABind STA01  
#
	state STA01C
		event AA		TDISreq STA01  
		event ABnr		TDISreq STA01  
		event ABr		^ P02 : TDISreq STA01 ; P02 : AA STA01C 
		event TDISind	STA01  
#
	state STA02A
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA03
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA04A
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA04B
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA05A
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 :  AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA05B
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA05C
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA06
		event ABnr		(3) TDISreq STA01  
		event SUABreq	^ P02 : ABnr [4] STA16 
		event TDISind	SPABind STA01  
#
	state STA08
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA09
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA10A
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA10B
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
# 
	state STA11A
		event ABnr		(3) TDISreq STA01   
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA11B
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA11C
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA15A
		event ABnr		(3) TDISreq STA01 
		event SUABreq	^ P02 : ABnr [4] STA16 
		event TDISind	SPABind STA01  
#
	state STA15B
		event ABnr		(3) TDISreq STA01  
		event SUABreq	^ P02 : ABnr [4] STA16  
		event TDISind	SPABind STA01  
#
	state STA15C
		event ABnr		(3) TDISreq STA01  
		event SUABreq	^ P02 : ABnr [4] STA16 
		event TDISind	SPABind STA01  
#
	state STA16
		event AA		[3] TDISreq STA01  
		event ABnr		[3] TDISreq STA01  
		event ABr		[3] TDISreq STA01  
		event TDISind	[3] STA01  
		event TIM		TDISreq STA01  
#
	state STA18
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA19
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA20
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq 	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA21
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA22
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#
	state STA713
		event ABnr		(3) TDISreq STA01  
		event ABr		^ P02 : (3) TDISreq STA01 ; P02 : (3) AA STA01C 
		event SUABreq	^ P02 : ABnr [4] STA16 ; P02 : ABr [4] STA01A 
		event TDISind	SPABind STA01  
#	
end
