rem OK THIS IS THE POOR MAN MAKEFILE
@echo off

rem CHANGE THIS ROOT VAR TO THE DIRECTORY THAT FIT
rem (i know it's stupid but avoiding spaces may help)
set ROOT=d:\az\d\az-02_-_Extatique_src

rem az-02 will NOT compile with further release of DMD because of 
set PATH=%ROOT%\dmd.1.046\windows\bin

set MAINFILE=az02

rem DEBUG version
set BUD_PARAMS= -g -debug=2 -w

rem RELEASE version 
rem seems to introduce bugs but i'm not sure
rem set BUD_PARAMS= -release -inline -O -w -gui

rem Capped version for video capturing
rem - no audio sync
rem - no texture compression
rem set BUD_PARAMS= -release -inline -O -w -gui -version=Capped


bud %MAINFILE%.d %BUD_PARAMS% -cleanup -names -version=Phobos -I..\common 
rem cdc %MAINFILE%.d %BUD_PARAMS% -version=Phobos -I..\common  -verbose



if errorlevel 1 goto fin
rem lanceur.exe

%MAINFILE%.exe -gamma 1.0 -w 1024 -h 768 -ratio 16/9 -nf 
:fin

pause