/*     DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2009 Adinpsz contributors
  7 chemin Villebois 38100 Grenoble
 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO. */
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */ 
module az02;

import util.all;
import std.stdio;
import std.file;
import std.path;
import sdl.all;
import std.conv;
import demo.all;
import std.gc;

import std.c.stdlib;


class InvalidCommandLine : object.Exception
{
	this(string msg)
	{
		super(msg);	
	}	
}

T safeConvert(T)(string src, string errorMsg)
{
	static if(is(T : int))
	{
		alias std.conv.toInt conv;
	} else static if(is(T : float))
	{
		alias std.conv.toFloat conv;
	} else
	{
		static assert(false);	
	}	
	
	try
	{
		T res = conv(src);
		return res;
	} catch(ConvError)
	{
		throw new InvalidCommandLine(format(errorMsg, src));			
	}
}


int mainProcedure(char[][] args)
{
	chdir(getDirName(args[0]));
	
	trace("Command-line :");
	
	foreach(string s; args)
	{
		trace(s);	
	}
	
//	int fsaa = 4;	
		
	auto width = SDLApp.AUTO_DETECT;
	auto height = SDLApp.AUTO_DETECT;
	string sratio = "auto"; // auto-detect ratio from width and height
	bool fullscreen = true; // by default, fullscreen
	float gamma = 1.f;
	bool music = true;
	bool vsync = true;
	string help = "
Usage: az02 [options]
Options:
  -help		Show help
  -f		Enable fullscreen (default)
  -nf		Disable fullscreen
  -r		Set screen ratio value; must be 'auto', '4/3', '5/4', '16/9' or '16/10'
  -h		Height; must be 'auto' or an integer (eg. 1024)
  -w		Width; must be 'auto' or an integer (eg. 768)
  -gamma	Set gamma value; must be a float (eg. 1.0)
  -no-music	Disable music";

	// parse command-line arguments
	{
		int i = 1; 
		
		while (i < args.length)
		{
			switch(args[i])
			{
				case "-width": 
				case "-w": 
					if (i + 1 == args.length) throw new InvalidCommandLine("Missing width");
					if (args[i+1] == "auto") 
					{
						width = SDLApp.AUTO_DETECT;
					} 
					else
					{					
						width = safeConvert!(int)(args[i+1], "integer  or \"auto\" expected for width, not %s");
					}
					i += 2;
					break;
					
				case "-height":
				case "-h": 
					if (i + 1 == args.length) throw new InvalidCommandLine("Missing height");
					if (args[i+1] == "auto") 
					{
						height = SDLApp.AUTO_DETECT;
					} 
					else
					{					
						height = safeConvert!(int)(args[i+1], "integer or \"auto\" expected for height, not %s");
					}					
					i += 2;
					break;
					
				case "-ratio":  // autorized : 16/9  4/3  16/10
				case "-r": 
					if (i + 1 == args.length) throw new InvalidCommandLine("Missing ratio");
					sratio = args[i+1];
					i += 2;
					break;
	/*				
				case "-a":
				case "-fsaa": 
					if (i + 1 == args.length) throw new InvalidCommandLine("Missing FSAA option");
					fsaa = safeConvert!(int)(args[i+1], "integer expected for FSAA, not %s"); 
					i += 2;
					break;
	*/				
				case "-g":
				case "-gamma": 
					if (i + 1 == args.length) throw new InvalidCommandLine("Missing gamma");
					gamma = safeConvert!(float)(args[i+1], "float expected for Gamma, not %s");
					i += 2;
					break;
					
				case "-f":
				case "-fullscreen": 
					fullscreen = true;
					i += 1;
					break;
					
				case "-nf":
				case "-no-fullscreen": 
				case "-nofullscreen": 
				case "-windowed": 
					fullscreen = false;
					i += 1;
					break;
					
				case "-nomusic": 
				case "-no-music": 
					music = false;
					i += 1;
					break;
					
				case "-nosync":
				case "-no-sync":
					vsync = false;
					i += 1;
					break;
					
				case "-sync":
					vsync = true;
					i += 1;
					break;
				
				case "-help":
				case "--help":	
					writefln(help);
					return 0;
					
				
					
				default: 
					throw new InvalidCommandLine(format("Unknown argument : %s", args[i]) ~ help);
			}
		}
	}
	
/*	
	if ((fsaa != 1) 
	 && (fsaa != 2) 
	 && (fsaa != 4) 
	 && (fsaa != 8) 
	 && (fsaa != 16))
		throw new InvalidCommandLine("No such FSAA option (should be 1, 2, 4, 8 or 16)");
*/
	double ratio = void;	
	
	if (sratio == "4/3") ratio = 4.0/3.0;
	else if (sratio == "5/4") ratio = 5.0/4.0;
	else if (sratio == "16/9") ratio = 16.0/9.0;
	else if (sratio == "16/10") ratio = 16.0/10.0;
	else if (sratio == "auto") ratio = 0.0;
	else throw new InvalidCommandLine("Use 4/3, 5/4, 16/9, 16/10 or \"auto\" as ratio");
	
	trace("### create app");
	
	auto app = new AZ02Program(width, height, ratio, fullscreen, 1, music, gamma, vsync);
	trace("### GC collect");
	fullCollect();
	trace("### >run demo");
	
	
	app.run();	
	trace("### <run demo");
	delete app;
	return 0;
}

version(Windows)
{	
	debug
	{
		int main(char[][] args)
		{
			return mainProcedure(args);
		}
	}
	else
	{
		import std.string;
		import std.stream;
		import std.math;
		import std.c.stdlib;
		import std.c.windows.windows;
	  	import std.string;
	
		extern (C) 
		{
			void gc_init();
			void gc_term();
			void _minit();
			void _moduleCtor();
		}
		
		
		extern (Windows) public int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) 
		{
			int result;
			gc_init();
			_minit();
			try 
			{
				_moduleCtor();
				char exe[4096];
				GetModuleFileNameA(null, exe.ptr, 4096);
				char[][1] prog;
				prog[0] = std.string.toString(exe.ptr);
				result = mainProcedure(prog ~ std.string.split(std.string.toString(lpCmdLine)));
			}
			catch (Object o) 
			{
				result = EXIT_FAILURE;
			}
			gc_term();
			return result;
		}
	}
	
}
else 
{

	int main(char[][] args)
	{
		return mainProcedure(args);
	}
}
