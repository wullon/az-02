---------------------- az-02 - Extatique (source release) ---------------------

  Hi, I'm still in my crusade to promote D usage in the demoscene :) 
So here is the source of Extatique, if anyone cares. 
Do you really think you were meant to write C++ _as a hobby_, seriously ?

  Our engine is less buggy than az-01's one but still very crude. It's not 
"state of the art" D. 

                                                           #ponce/adinpsz



What's in the archive :
	- az02 : Extatique with sources. Lots and lots of CRAP code.
	- common/derelict/ : dynamic bindings to libogg, OpenGL, Portaudio and SDL	
	- common/gl : OpenGl 2.0 wrapper	
	- common/sdl : SDL 1.2 wrapper	
	- common/util : data structures, soft rendering, stuff, math
	- common/util/geometry : vectors, matrices, quaternions... 
    - dmd.1.046 : a D compiler which can run our code (1.047 and 1.048 won't)               


az-02 requirements : 
    Windows, OpenGL 2.0
    may work with Linux
    to compile the demo : edit and run az02/compile.bat

az-02 known bugs : 
   - audio sync slowly decaying with certain sound cards
   - bugs in Launcher.exe, hangs with Seven and Vista
   - the first planet effect staying throughout the demo

-------------------------------------------------------------------------------