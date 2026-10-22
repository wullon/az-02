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
module sdl.mutex;

import derelict.sdl.sdl;
import std.stdio;
import sdl.state;

final class Mutex
{
	private
	{
		SDL_mutex *m_handle;			
	}	
	
	public
	{
		this()
		{
			m_handle = SDL_CreateMutex();			
			
			if (m_handle is null)
			{
				throw new SDLError("Unable to create a SDL mutex");
			}
		}
		
		~this()
		{
			SDL_DestroyMutex(m_handle);
		}
		
		void lock()
		{
			int r = SDL_mutexP(m_handle);
			if (r != 0)
			{
				throw new SDLError("Unable to lock the SDL mutex");	
			}			
		}
		
		void unlock()
		{
			int r = SDL_mutexV(m_handle);
			if (r != 0)
			{
				throw new SDLError("Unable to unlock the SDL mutex");	
			}
		}		
	
	
	}
	
}