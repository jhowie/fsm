# fsm
Tools to create C code from descriptions of finite state machines, test the fsm's, and debug them

The source code in this project creates three tools:

spp  - a tool to generate C code from a description of a finite state machine

schk - a tool to check a finite state machine to make sure that an end state
       can be reached from every state, and that predicates do not lead to
       mutually exclusive conditions preventing state change

san  - a tool that "animates" finite state machines, allowing you to debug them

The description of finite state machines is in a format used by the International
Standards Organization, especially in OSI Standards.

Rudimentary documentation and examples are contained in the doc and examples
folders. The documents are built using nroff (for convenience, the text files
resulting from "nroff -ms" are included. The examples include the OSI Layer 4
Transport Layer (transport.st), OSI Layer 6 Session Layer (session.st), and a
file transfer protocol.

NOTES:

1) This is old code, that I found while looking for something else. It compiles
   on MacOS using the command line xcode tools, and will be easily portable to
   UNIX/Linux systems. Previous versions have compiled and run successfully on
   Windows NT and later, and DOS. The code is not at the same quality as code I
   would write today!!!

2) To build the code you need flex and bison (or lex and yacc).

3) The 'san' tool was written pre-threads, on SunOS. It could easily benefit from
   parallelism, to make it far more easy to use.

Please feel free to submit bugs, but I might move slowly in addressing bug
reports.
