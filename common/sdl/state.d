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
module sdl.state;


import derelict.sdl.sdl;
import util.singleton, util.logger, util.common;
import std.stdio, sdl.joystick, sdl.keyboard;

public class SDLError : object.Exception
{	
	this(char[] message)
	{
		super(message);	
	}
}

class SDL
{	
	
	mixin Singleton;
	
	private
	{
		SDLKeyboard m_kb;
		SDLJoystick[] m_joy;
		
		bool subSystemInitialized(int subSystem)
		{
			int inited = SDL_WasInit(SDL_INIT_EVERYTHING);
			return 0 != ( inited & subSystem );
		}
		
		this()
		{
			trace(">sdl.State.this()");
			DerelictSDL.load();
			
			if (0 != SDL_Init(0)) throw new SDLError("Unable to initialize SDL");
			
			subSystemInit(SDL_INIT_TIMER);
			subSystemInit(SDL_INIT_VIDEO);
			subSystemInit(SDL_INIT_JOYSTICK);
			
			// initialize joysticks, if any
			m_joy.length = SDL_NumJoysticks();
			for (int i = 0; i < m_joy.length; i++)
			{
				m_joy[i] = new SDLJoystick(i);	
			}			
			
			m_kb = new SDLKeyboard();
			
			SDL_EventState ( cast(ubyte) SDL_ALLEVENTS, SDL_ENABLE);			
			trace("<sdl.State.this()");
		}
		
		~this()
		{
			trace(">sdl.State.~this()");
			for (int i = 0; i < m_joy.length; i++)
			{
				delete m_joy[i];
			}
			delete m_joy;
			delete m_kb;
			trace("    SDL_Quit();");
			SDL_Quit();	
			trace("<sdl.State.~this()");		
		}
	}	
	
	public
	{	
		SDLKeyboard keyboard()
		{
			return m_kb;
		}
		
		SDLJoystick joystick(int i)
		{
			return m_joy[i];
		}
		
		int numJoysticks()
		{
			return m_joy.length;	
		}
		
		void subSystemInit(int flag)
		{
			if (! subSystemInitialized(flag))
			{
				int res = SDL_InitSubSystem(flag);
				if (0 != res) throw new SDLError("Unable to initialize SDL subsystem.");			
			}			
		}
		
		void subSystemQuit(int flag)
		{
			SDL_QuitSubSystem(flag);
		}
		
		char[] keyName(int key)
		{
			return toDString(SDL_GetKeyName(key));
		}
		
		
		
	}
	
}